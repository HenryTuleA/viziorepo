trigger InitialControlNumberTrigger on Control_Number__c (after insert, after update) {
	if(Trigger.isInsert){
		InitialControlNumShareTriggerController.handleInsertTrigger(Trigger.New);
    } else if(Trigger.isUpdate ){
    	InitialControlNumShareTriggerController.handleUpdateTrigger(Trigger.Old, Trigger.New);
    }
}