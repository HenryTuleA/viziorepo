public class RelatedClaimTriggerController {

    public static void handleUpdateTrigger(List<Service_Claim__c> newList, List<Service_Claim__c> oldList) {
        
        system.debug('Update Trigger...');
        Set<Id> IdSet = new Set<Id>();
        for (Integer i = 0; i < newList.size(); i++) {
            if(oldList[i].Status__c != 'Draft' && newList[i].Status__c == 'Draft') {
                if(!IdSet.contains(newList[i].Id)) {
                    IdSet.add(newList[i].Id);
                }
            }
        }
        
        RelatedServiceClaim__c[] rscDelete = [SELECT Id FROM RelatedServiceClaim__c WHERE ParentServiceClaim__c IN :IdSet];
        delete rscDelete;
        
    }
    
    public static void handleDeleteTrigger(List<Service_Claim__c> newList) {
        
        RelatedServiceClaim__c[] rscDelete = [SELECT Id FROM RelatedServiceClaim__c WHERE ParentServiceClaim__c = NULL];
        delete rscDelete;
    }
}