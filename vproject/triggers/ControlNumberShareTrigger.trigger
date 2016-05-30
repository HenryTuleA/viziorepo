trigger ControlNumberShareTrigger on AccountPartner__c (before insert, after update, before update, after delete) {
	
	if(Trigger.isInsert && Trigger.isBefore){
		if(checkRecursive.runOnce()) {
        	ControlNumberShareTriggerController.handleInsertTrigger(Trigger.New);
		}
    } else if(Trigger.isUpdate){
    	if(checkRecursive.runOnce()) {
	        ControlNumberShareTriggerController.handleUpdateTrigger(Trigger.Old, Trigger.New);
    	}
    } else if(Trigger.isDelete && Trigger.isAfter){
    	if(checkRecursive.runOnce()) {
        	ControlNumberShareTriggerController.handleDeleteTrigger(Trigger.Old);
    	}
    }
}