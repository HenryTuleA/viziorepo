trigger VizioSupport_activityTaskTrigger on Task (after insert) 
{
	
	if(Trigger.isInsert && Trigger.isAfter)
	{
		VizioSupport_activityTaskTriggerControl.handleAfterInsertTrigger(Trigger.new);
	}
}