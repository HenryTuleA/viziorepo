@isTest
private class NoteTriggerControllerTest {
	static testmethod void noteTest(){
		Account acc1 = new Account();
        acc1.Name = 'Name';
        acc1.Channel_Id__c = 'test';
        insert acc1;
		
		Claim__c claim = new Claim__c();
        claim.Account__c = acc1.Id;
        claim.Claim_Name__c = 'test Claim';
        claim.Claim_Start_Date__c = system.today();
        claim.Claim_End_Date__c = system.today();
        claim.Co_Op__c = '1';
        claim.status__c = 'Draft';
        insert claim;
		
		Note n1 = new Note();
		n1.Title = 'test';
		n1.ParentId = claim.id;
		insert n1;
		
		claim.status__c = 'Approved';
		update claim;
		
		Note n2 = new Note();
		n2.Title = 'test2';
		n2.ParentId = claim.id;
		
		test.startTest();
		try{
			insert n2;
		}catch(exception e){
			string errorMessage = e.getMessage();
			system.assertEquals(errorMessage.contains('You cannot add a new note to an approved/rejected Claim'), true);
		}
		try{
			update n1;
		}catch(exception e){
			string errorMessage = e.getMessage();
			system.assertEquals(errorMessage.contains('You cannot edit or delete a Note associated to a Claim in an approval process'), true);
		}
		try{
			delete n1;
		}catch(exception e){
			string errorMessage = e.getMessage();
			system.assertEquals(errorMessage.contains('You cannot edit or delete a Note associated to a Claim in an approval process'), true);
		}
		test.stopTest();
		
		List<Note> nList = [SELECT id FROM Note];
		system.assertEquals(nList.size(), 1);	
	}
}