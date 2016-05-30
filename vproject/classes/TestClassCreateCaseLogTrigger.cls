/**
 * Test class to test the CreateCaseLog.trigger
 *
 * @author		Stela Zhang
 * @version		1.0
 * @since		1.0
 */
 
@isTest (SeeAllData=false)
private class TestClassCreateCaseLogTrigger {
	
	/**
     * method to test the task related to case 
     *
     * @param			None	  
     * @return			None
     * @since			1.0
     */
	static testMethod void testTask() {
		Id caseRecordType = [Select Id From RecordType Where Name = 'Support' AND SobjectType = 'Case'].get(0).Id;
        
		Case insertCase = new Case( RecordTypeId = caseRecordType);
		insert insertCase;
	}
}