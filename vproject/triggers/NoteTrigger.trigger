trigger NoteTrigger on Note (before insert, before update, before delete) {
    if(Trigger.isDelete){
        NoteTriggerController.handleDeleteTrigger(Trigger.Old);
    }
    if(Trigger.isInsert){
        NoteTriggerController.handleInsertTrigger(Trigger.New);
    }
    if(Trigger.isUpdate){
        NoteTriggerController.handleUpdateTrigger(Trigger.New);
    }
}