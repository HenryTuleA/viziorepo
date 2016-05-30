public class SubmitServiceClaimController {

    private ApexPages.StandardController stdController;
    private Service_Claim__c scRec;
    
    public SubmitServiceClaimController (ApexPages.StandardController stdController) {
        this.stdController = stdController;
    }
    
    public PageReference submit()
    {    
        // Apex code for handling record from a Detail page goes here
        Id recId = stdController.getId();
        scRec = [SELECT Id, Status__c, Account__c, Serial_No__c, Problem_Description__c, ValidSerialNumber__c, RecordType.DeveloperName, OwnerId FROM Service_Claim__c WHERE Id =: recId];
        String recType = scRec.RecordType.DeveloperName;
        
        // lists of related records: Parts, Labor, Attachments
        List<Warranty_Claim_Labor__c> wcLaborList = [SELECT Id,Warranty_Claim__c FROM Warranty_Claim_Labor__c WHERE Warranty_Claim__c =: recId];
        List<Warranty_Claim_Product__c> wcProdList = [SELECT Id,Warranty_Claim__c FROM Warranty_Claim_Product__c WHERE Warranty_Claim__c =: recId];
        List<Attachment> wcAttList = [SELECT Id,ParentId FROM Attachment WHERE ParentId =: recId];
        List<Approval.ProcessResult> resultList = new List<Approval.ProcessResult>();
        
        Boolean allTrue = true;
        
        if (scRec.ValidSerialNumber__c == false)
        {
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR, 'This serial number has not been validated yet.'));
            return null;
        }

        if (recType == 'Warranty_Claim' && wcLaborList.size() <= 0 && wcProdList.size() <= 0) {
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.WARNING, 'Please add labor charges and/or parts to this claim in order for it to be valid.'));
            return null;
        }
        
        if (recType == 'RMA' && wcAttList.size() <= 0 && scRec.Problem_Description__c.contains('pictures required')) {
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.WARNING, 'Please attached at least two pictures to this submission; one which shows defect of actual issue and one which shows the serial number of the unit.'));
            return null;
        }

        if (scRec.Status__c == 'Draft') {
            scRec.Status__c = 'Submitted';
            update scRec;
            
            Approval.ProcessSubmitRequest req1 = new Approval.ProcessSubmitRequest();
            req1.setComments(recType + ' Submitted for Approval');
            req1.setObjectId(scRec.Id);
            Approval.ProcessResult result = Approval.process(req1); 
            
            if(result.isSuccess()) {
                
                try {
                    relateClaims(scRec.Id, scRec.Serial_No__c);
                }
                catch(Exception e) {
                    ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR, 'There was an error relating claims. The sky is falling!!!'));
                }
                finally {
                    PageReference pageRef = new ApexPages.StandardController(scRec).view();
                    pageRef.setRedirect(true);
                    return pageRef;
                }
                
            }  else {
                ApexPages.addMessage(new ApexPages.message(ApexPages.severity.WARNING, 'This Service Claim cannot be submitted. The approval process was not successful.'));
            }
        } else {
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.WARNING, 'This Service Claim has already been submitted for approval.'));
        }
        return null;
        
    }
    
    public PageReference okButton() {
        PageReference pageRef = new ApexPages.StandardController(scRec).view();
        pageRef.setRedirect(true);
        return pageRef;
    }

    public static void relateClaims(Id recId, String serialNo) {
        
        List<RelatedServiceClaim__c> insertList = new List<RelatedServiceClaim__c>();
        List<Service_Claim__c> rscList = [SELECT Id, Serial_No__c FROM Service_Claim__c WHERE Serial_No__c = :serialNo AND Id != :recId];

        if(rscList.size() > 0) {
            for(Service_Claim__c rsc : rscList) {
                RelatedServiceClaim__c a = new RelatedServiceClaim__c(ParentServiceClaim__c = recId, ChildServiceClaim__c = rsc.Id);
                insertList.add(a);
                RelatedServiceClaim__c b = new RelatedServiceClaim__c(ParentServiceClaim__c = rsc.Id, ChildServiceClaim__c = recId);
                insertList.add(b);
            }
        }
        insert insertList;
    }
}