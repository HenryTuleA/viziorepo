trigger RelatedClaimTrigger on Service_Claim__c (after insert, after update, after delete)
{
    
    if(Trigger.isInsert) {
        //system.debug('Insert Trigger...');
        //RelatedClaimTriggerController.handleInsertTrigger(Trigger.New);
    }
    
     if(Trigger.isUpdate) {
        system.debug('Update Trigger...');
        RelatedClaimTriggerController.handleUpdateTrigger(Trigger.New, Trigger.Old);
    }

    if(Trigger.isDelete) {
        system.debug('Delete Trigger...');
        RelatedClaimTriggerController.handleDeleteTrigger(Trigger.New);
    }
}