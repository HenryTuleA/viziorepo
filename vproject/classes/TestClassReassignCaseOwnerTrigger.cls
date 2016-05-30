/**
 * Test class to test the ReassignCaseOwner.trigger
 *
 * @author		Xin Zhang
 * @version		1.0
 * @since		1.0
 */
 
@isTest (SeeAllData=false)
private class TestClassReassignCaseOwnerTrigger {
	/**
     * method to test the task related to case 
     *
     * @param			None	  
     * @return			None
     * @since			1.0
     */
	static testMethod void testTask() {
				
		Group insertGroup1 = new Group(Type = 'Queue', Name = 'Support Queue');
		insert insertGroup1;
		Group insertGroup2 = new Group(Type = 'Queue', Name = 'Mexico Support Queue');
		insert insertGroup2;
		
		Profile newProfile = [SELECT Id From Profile WHERE Name='Standard User'];
		
		User insertUser = new User(Email = 'testlegalrep@test.com',
                                    Username = 'testlegalrep@test.com',
        							LastName = 'TestLegalRep',
        							FirstName = 'Test',
        						    Alias = 'TestL',
        						    TimeZoneSidKey = 'America/Los_Angeles',
        						    LocaleSidKey='en_US',
        						    emailencodingkey='UTF-8',
        						    ProfileId = newProfile.Id,
        						    LanguageLocaleKey='en_US',
        						    CommunityNickname = 'TestL'); 
        User insertUser2 = new User(Email = 'testlegalrep2@test.com', 
                                    Username = 'testlegalrep2@test.com',
        							LastName = 'TestLegalRep2',
        							FirstName = 'Test2', 
        						    Alias = 'TestL2',
        						    TimeZoneSidKey = 'America/Los_Angeles',
        						    LocaleSidKey='en_US',
        						    emailencodingkey='UTF-8',
        						    ProfileId = newProfile.Id,
        						    LanguageLocaleKey='en_US',
        						    CommunityNickname = 'TestL2');
		
		QueueSobject queues1 = new QueueSobject(QueueId = insertGroup1.Id, SobjectType = 'Case');
		QueueSobject queues2 = new QueueSobject(QueueId = insertGroup2.Id, SobjectType = 'Case');
        
        System.runAs(new User(Id = UserInfo.getUserId())){
            insert queues1;
            insert queues2;
            insert insertUser; 
            insert insertUser2;
        }
		
		Id caseRecordType = [Select Id From RecordType Where Name = 'Support Email' AND SobjectType = 'Case'].get(0).Id;
        
		Case insertCase1 = new Case(OwnerId = insertGroup1.Id, RecordTypeId = caseRecordType);
		insert insertCase1;
		Case insertCase2 = new Case(OwnerId = insertGroup2.Id, RecordTypeId = caseRecordType);
		insert insertCase2;
		Case insertCase3 = new Case(OwnerId = insertUser.Id, RecordTypeId = caseRecordType);
		insert insertCase3;
		
        Task newTask1 = new Task(OwnerId = insertUser.Id,
			                                   Subject = 'Email: Testing',
			                                   whatId = insertCase1.Id);		 
    	insert newTask1; 
    	
    	Task newTask2 = new Task(OwnerId = insertUser.Id,
			                                   Subject = 'Email: Testing',
			                                   whatId = insertCase2.Id);		 
    	insert newTask2;
    	Task newTask3 = new Task(OwnerId = insertUser2.Id,
			                                   Subject = 'Email: Testing',
			                                   whatId = insertCase3.Id);		 
    	insert newTask3;
	} 
}