@isTest
private class ClaimTypeTriggerControllerTest {
	static testmethod void unitTest(){
		Account acc1 = new Account();
        acc1.Name = 'Name';
        acc1.Channel_Id__c = 'test';
        insert acc1;
        
        Control_Number__c cn1 = new Control_Number__c();
        cn1.Control__c = '1';
        cn1.Account__c = acc1.Id;
        cn1.BSTC_Amount__c = 0;
        cn1.PPSTC_Amount__c = 200;
        cn1.Event_Start_Date__c = system.today();
        cn1.Event_End_Date__c = system.today();
        cn1.Price_Type__c = 'ED';
        cn1.SKU__c = 'test';
        insert cn1;
        
        Control_Number__c cn2 = new Control_Number__c();
        cn2.Control__c = '2';
        cn2.Account__c = acc1.Id;
        cn2.BSTC_Amount__c = 100;
        cn2.PPSTC_Amount__c = 200;
        cn2.Event_Start_Date__c = system.today();
        cn2.Event_End_Date__c = system.today();
        cn2.Price_Type__c = 'STC';
        cn2.SKU__c = 'test';
		insert cn2;
		
		Claim__c claim = new Claim__c();
        claim.Account__c = acc1.Id;
        claim.Claim_Name__c = 'test Claim';
        claim.Claim_Start_Date__c = system.today();
        claim.Claim_End_Date__c = system.today();
        claim.Co_Op__c = '1';
        claim.status__c = 'Submitted';
        insert claim;
        
        List<Claim_Item__c> ciList = new List<Claim_Item__c>();
        Claim_Item__c claimItem = new Claim_Item__c();
        claimItem.Control_Number__c = cn1.id;
        claimItem.Claim__c = claim.id;
        claimItem.Quantity_Claimed__c = 1;
        claimItem.Claim_Type_del__c = 'PP';
        ciList.add(claimItem);
        
        Claim_Item__c claimItem2 = new Claim_Item__c();
        claimItem2.Control_Number__c = cn2.id;
        claimItem2.Claim__c = claim.id;
        claimItem2.Quantity_Claimed__c = 1;
        claimItem2.Claim_Type_del__c = 'STC';	
    	ciList.add(claimItem2);
    	insert ciList;
    	
        test.startTest();
		claim__c testclaim = [SELECT claim_type__c FROM claim__c WHERE id=:claim.id];
		system.assertEquals(testclaim.claim_type__c, 'PP;STC');
        delete claimItem2;
        test.stopTest();
		testclaim = [SELECT claim_type__c FROM claim__c WHERE id=:claim.id];
		system.assertEquals(testclaim.claim_type__c, 'PP');
        
	}
}