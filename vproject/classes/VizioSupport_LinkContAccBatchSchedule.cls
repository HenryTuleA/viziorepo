/**
 *
 * This class implements the schedule
 *
 * @author              Cristian Torres
 * @version             1.0
 * @since               1.0
 */  
global class VizioSupport_LinkContAccBatchSchedule implements Schedulable {
    
    global void execute(SchedulableContext sc)
    {
    	VizioSupport_LinkContactToAccountBatch obj;
		obj = new VizioSupport_LinkContactToAccountBatch();
		database.executeBatch(obj, 5000);
    }

/*  
 * This code should be run in order to schedule the job:
 * 
 * //Seconds Minutes Hours Day_of_month Month Day_of_week optional_year
 * VizioSupport_LinkContAccBatchSchedule b = new VizioSupport_LinkContAccBatchSchedule();
 * String sch = '0 0 * * * ? *' ; // This is just like a regular cron job 
 * system.schedule('Account for Orphan Contacts', sch, b);
 */
}