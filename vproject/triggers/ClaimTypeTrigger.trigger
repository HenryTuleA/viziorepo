trigger ClaimTypeTrigger on Claim_Item__c (after update, after delete) {
    
    if(Trigger.isDelete){
        ClaimTypeTriggerController.handleUpdateTrigger(Trigger.Old);
    } 
    if(Trigger.isUpdate){
        ClaimTypeTriggerController.handleUpdateTrigger(Trigger.new);
    }
}