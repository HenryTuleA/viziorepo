public with sharing class SubmitClaimeController {

    private ApexPages.StandardController stdController;
    private Claim__c claimRec;
    
    public SubmitClaimeController (ApexPages.StandardController stdController) {
        this.stdController= stdController;
    }
    
    public PageReference submit()
    {    
        // Apex code for handling record from a Detail page goes here
        Id recordId = stdController.getId();
        claimRec = [SELECT Id, Status__c, Account__c, OwnerId FROM Claim__c WHERE Id =: recordId];
        List<Claim_Item__c> cItemList = [SELECT Id, Claim__c FROM Claim_Item__c WHERE Claim__c =: recordId];
        List<Approval.ProcessResult> resultList = new List<Approval.ProcessResult>();
        AccountPartner__c ap = new AccountPartner__c();
        
        if (cItemList.size() <= 0) {
        	ApexPages.addMessage(new ApexPages.message(ApexPages.severity.WARNING, 'Claim must have claim items to submit.'));
        	return null;
        }
        try {
        	ap = [SELECT Id, Main_AccountId__c, Partner_AccountId__c, Distributor_Contact__c FROM AccountPartner__c WHERE Partner_AccountId__c =: claimRec.Account__c AND Partner_Type__c = 'VAR/Reseller'];
        } catch (exception e) {
        	ap = null;
        }
        //Boolean alltrue = true;
        if (claimRec.Status__c == 'Draft') {
            claimRec.Status__c = 'Submitted';
            if (ap != null) {
            	claimRec.Distributor__c = ap.Id;
            	/*Contact con = [SELECT Id, Email FROM Contact WHERE Id =: ap.Distributor_Contact__c];
            	if (con != null) {
            		claimRec.Distributor_Contact__c = con.Email;
            	}*/
            }
            update claimRec;
            
            Approval.ProcessSubmitRequest req1 = new Approval.ProcessSubmitRequest();  
            req1.setComments('Submitted for Approval');
            req1.setObjectId(claimRec.Id);
            //req1.setSubmitterId(claimRec.OwnerId );
            Approval.ProcessResult result = Approval.process(req1); 
            
            /*if (cItemList.size() > 0) {
	            for (Claim_Item__c ci: cItemList) {
	            	Approval.ProcessSubmitRequest req2 = new Approval.ProcessSubmitRequest();  
		            req2.setComments('Submitted for Approval');
		            req2.setObjectId(ci.Id);
		            //req2.setSubmitterId(ci.OwnerId);
		            //System.debug(LoggingLevel.ERROR,req1 + ' search123 ' + ci.Id);
		            Approval.ProcessResult result1 = Approval.process(req2); 
		            resultList.add(result1);
	            }
	            
	            for (Approval.ProcessResult rt: resultList) {
	            	if (!rt.isSuccess()) {
	            		alltrue = false;
	            	}
	            }
            }*/
            
            //if(result.isSuccess() && alltrue) {
            if(result.isSuccess()) {
                PageReference pageRef = new ApexPages.StandardController(claimRec).view();
                pageRef.setRedirect(true);
                return pageRef;
            }  else {
            	ApexPages.addMessage(new ApexPages.message(ApexPages.severity.WARNING, 'This Claim cannot be submitted. The approval process was not successful.'));
        
            }
        } else {
        	ApexPages.addMessage(new ApexPages.message(ApexPages.severity.WARNING, 'Only Claim in Draft status can be submitted.'));
        }
        
        return null;
        
    }
    
    public PageReference okButton() {
    	PageReference pageRef = new ApexPages.StandardController(claimRec).view();
        pageRef.setRedirect(true);
        return pageRef;
    }
}