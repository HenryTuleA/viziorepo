@isTest
private class AttachmentTriggerControllerTest {
	static testmethod void attachmentTest(){
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
		
		Attachment a1 = new Attachment();
		a1.ParentId = claim.id;
		a1.Name = 'testattachment';
		String myString = 'test';
		Blob myBlob = Blob.valueof(myString);
		a1.Body = myBlob;
		insert a1;
		
		claim.status__c = 'Approved';
		update claim;
		
		Attachment a2 = new Attachment();
		a2.ParentId = claim.id;
		a2.Name = 'testattachment2';
		
		test.startTest();
		try{
			insert a2;
		}catch(exception e){
			string errorMessage = e.getMessage();
			system.assertEquals(errorMessage.contains('You cannot add a new attachment to an approved/rejected Claim'), true);
		}
		try{
			update a1;
			delete a1;
		}catch(exception e){
			string errorMessage = e.getMessage();
			system.assertEquals(errorMessage.contains('You cannot edit or delete an attachment associated to a Claim in an approval process'), true);
		}
		try{
			delete a1;
		}catch(exception e){
			string errorMessage = e.getMessage();
			system.assertEquals(errorMessage.contains('You cannot edit or delete an attachment associated to a Claim in an approval process'), true);
		}
		test.stopTest();
		
		List<Attachment> aList = [SELECT id FROM Attachment];
		system.assertEquals(aList.size(), 1);	
	}
}