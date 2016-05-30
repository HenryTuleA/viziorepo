/**
 *  This class is used by the VizioSupport_activityTaskTrigger and it handles
 *  the events on the trigger
 *
 * @author              Cristian Torres
 * @version             1.0
 * @since               1.0
 */ 

public with sharing class VizioSupport_activityTaskTriggerControl 
{

	/**
     * Constructor
     *
     * @param        
     * @return                
     * @since   1.0                                                                       
     */ 
	public VizioSupport_activityTaskTriggerControl() 
	{
		
	}


	/**
     *  This method handles the event in case the Trigger fires on an INSERT and 
     *  it happens AFTER the insert 
     *
     * @param   newList; The list of new tasks that were just created 
     * @return  
     * @since   1.0                                                                       
     */ 
	public static void handleAfterInsertTrigger (List<Task> newList) 
	{
		
		List<USA800CallData__c> usa800ListToInsert = new List<USA800CallData__c>();		
		Set<ID> taskIDSet = new Set<ID>();
		List<Task> taskList = new List<Task>();


		System.debug('Trigger on Activity/Task has been executed ---- AFTER INSERT ');

		// Get all the IDs from the Tasks
		for (Task t: newList)
		{
			taskIDSet.add(t.ID);
		}	


		// Get the fields email and lastname from the owner of the Task 
		try 
		{
			taskList = 
				[
					SELECT ID, Calltype, geoCallEnded__c, geoCallStarted__c, geoRemoteNumber__c, geoCallID__c,
						Owner.Email, Owner.Lastname
					FROM Task
					WHERE ID IN: taskIDSet
				];  	
		}
		catch(Exception e)
		{
			System.debug('Error in the query');
		}



		// If a new Activity is created check if the Task Subtype is 'Task' and that geoRemoteNumber__c is not null 
		// if so then create a new USA800CallData__c record 
		for (Task t: taskList)
		{	

			if (t.geoRemoteNumber__c != null) /*t.TaskSubType == 'Task' && */
			{
				System.debug('Field geoRemoteNumber__c is different from null, creating a new USA800CallData__c record');

				USA800CallData__c us800 = new USA800CallData__c();

				us800.CallDirection__c = t.Calltype;
				us800.Call_Ended__c = t.geoCallEnded__c;
				us800.Call_Started__c = t.geoCallStarted__c;
				us800.PhoneNumber__c = t.geoRemoteNumber__c;
				us800.CallID__c = t.geoCallID__c;
				us800.CallReceiverEmail__c = t.Owner.Email;
				us800.CallReceiverLastName__c = t.Owner.Lastname;

				//list of records to be inserted
				usa800ListToInsert.add(us800); 

			}
		}

		//inserting new records 
		insert usa800ListToInsert;
	}
    
}