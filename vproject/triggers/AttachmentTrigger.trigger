trigger AttachmentTrigger on Attachment (before insert, before update, before delete) {
    if(Trigger.isDelete){
        AttachmentTriggerController.handleDeleteTrigger(Trigger.Old);
    }
    if(Trigger.isInsert){
        AttachmentTriggerController.handleInsertTrigger(Trigger.new);
    }
    if(Trigger.isUpdate){
        AttachmentTriggerController.handleUpdateTrigger(Trigger.new);
    }
}