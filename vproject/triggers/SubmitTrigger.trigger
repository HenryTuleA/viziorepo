trigger SubmitTrigger on Claim__c (before update, after update) {
    if (Trigger.isBefore) {
        SubmitTriggerController.handleBeforeTrigger(Trigger.new);
    } 
    if (Trigger.isAfter) {
        if(checkRecursive.runtwice()) {
            SubmitTriggerController.handleAfterTrigger(Trigger.new);
        }
    }
}