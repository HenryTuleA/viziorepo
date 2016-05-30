/**
 * Test class to test the VizioSupport_USA800Call.trigger
 *
 * @author		Stela Zhang
 * @version		1.0
 * @since		1.0
 */
 
@isTest (SeeAllData=false)
private class TestClassUSA800CallTrigger {
	
	/**
     * method to test the task related to case 
     *
     * @param			None	  
     * @return			None
     * @since			1.0
     */ 
	static testMethod void testTask() {
		
		Id caseRecordType = [Select Id From RecordType Where Name = 'Support' AND SobjectType = 'Case'].get(0).Id;
        Id contactRecotType = [Select Id From RecordType Where Name = 'Support' AND SobjectType = 'Contact'].get(0).Id;
        
        Contact insertContact = new Contact(LastName = 'Test', Phone = '1112223333', OtherPhone = '3332221111', RecordTypeId = contactRecotType);
        insert insertContact;
        
        Case insertCase = new Case(ContactId = insertContact.Id, RecordTypeId = caseRecordType);
        insert insertCase;
        
        USA800CallData__c insertCall1 = new USA800CallData__c(PhoneNumber__c = '3332221111', Call_Started__c = system.Now());
        insert insertCall1;
        
       
	}
}