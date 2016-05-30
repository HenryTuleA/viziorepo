/**
 * Test class to test the class named EditCase.cls
 *
 * @author		Xin Zhang
 * @version		1.0
 * @since		1.0
 */
 
@isTest (SeeAllData=false)
private class TestClassEditCase {
	static testMethod void myTestEditCaseOwnerisUser() {
		
		// Get Profile
	    Profile getProfile = [SELECT Id FROM Profile WHERE Name='Vizio Support Agent' limit 1]; 
        
        // Create newUser
        User newUser = new User(Alias = 'testu', Email='sampleuser@testorg.com', 
        EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
        LocaleSidKey='en_US', ProfileId = getProfile.Id, 
        TimeZoneSidKey='America/Los_Angeles', UserName='sampleUser2@test.net');
        insert newUser; 
	    
	    Group newGroup = new Group(Type='Queue', Name='Test Queue');
	    insert newGroup;
	    // Create newCase
	    Case currentCase = new Case(Status='New', Action_Code__c = 'ESCALATED',OwnerId = newUser.Id );
        insert currentCase;
        
        ApexPages.Standardcontroller editCase = new ApexPages.Standardcontroller(currentCase); 
        EditCase testEditCase = new EditCase(editCase);
        PageReference editCasePage = Page.Edit_Case; 
        testEditCase.currentCaseComment.CommentBody = 'testing';
        testEditCase.currentCase.Status='Closed';
        testEditCase.Submit(); 
        system.debug(testEditCase.currentCase);
         
        
	}
	
	static testMethod void myTestEditCaseOwnerisQueue() {
		
		// Get Profile
	    Profile getProfile = [SELECT Id FROM Profile WHERE Name='Vizio Support Agent' limit 1]; 
        
        // Create newUser
        User newUser = new User(Alias = 'testu', Email='sampleuser@testorg.com', 
        EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
        LocaleSidKey='en_US', ProfileId = getProfile.Id, 
        TimeZoneSidKey='America/Los_Angeles', UserName='sampleUser2@test.net');
        insert newUser;
	    
	    Group newGroup = new Group(Type='Queue', Name='Test Queue');
	    insert newGroup;
	    
	    QueueSobject queues1 = new QueueSobject(QueueId = newGroup.Id, SobjectType = 'Case');
        
        System.runAs(new User(Id = UserInfo.getUserId())){
            insert queues1;
        }
	    // Create newCase
	    Case currentCase = new Case(Status='New', Action_Code__c = 'ESCALATED',OwnerId = newGroup.Id );
        insert currentCase;
        
        ApexPages.Standardcontroller editCase = new ApexPages.Standardcontroller(currentCase);
        EditCase testEditCase = new EditCase(editCase);
        PageReference editCasePage = Page.Edit_Case;
        testEditCase.currentCaseComment.CommentBody = 'testing';
        testEditCase.currentCase.Status='Closed';
        testEditCase.Submit();
        system.debug(testEditCase.currentCase);
        
        
	}

}