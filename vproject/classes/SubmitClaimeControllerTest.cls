/**
 * This class contains unit tests for validating the behavior of Apex classes
 * and triggers.
 *
 * Unit tests are class methods that verify whether a particular piece
 * of code is working properly. Unit test methods take no arguments,
 * commit no data to the database, and are flagged with the testMethod
 * keyword in the method definition.
 *
 * All test methods in an organization are executed whenever Apex code is deployed
 * to a production organization to confirm correctness, ensure code
 * coverage, and prevent regressions. All Apex classes are
 * required to have at least 75% code coverage in order to be deployed
 * to a production organization. In addition, all triggers must have some code coverage.
 * 
 * The @isTest class annotation indicates this class only contains test
 * methods. Classes defined with the @isTest annotation do not count against
 * the organization size limit for all Apex scripts.
 *
 * See the Apex Language Reference for more information about Testing and Code Coverage.
 */
@isTest
private class SubmitClaimeControllerTest {
	static testmethod void unitTest(){
		List<Account> accList = new List<Account>();
		Account acc1 = new Account();
        acc1.Name = 'Name';
        acc1.Channel_Id__c = 'test';
        accList.add(acc1);
        
        Account acc2 = new Account();
        acc2.Name = 'Name2';
        acc2.Channel_Id__c = 'test2';
        accList.add(acc2);
        insert accList;
        
        List<Contact> conList = new List<Contact>();
        Contact contact1 = new Contact();
        contact1.FirstName = 'Test';
        contact1.Lastname = 'Last';
        contact1.AccountId = acc1.Id;
        contact1.Email = 'test@test.com';
        conList.add(contact1);
        
        Contact contact2 = new Contact();
        contact2.FirstName = 'Test';
        contact2.Lastname = 'Last';
        contact2.AccountId = acc2.Id;
        contact2.Email = 'test@test.com';
        conList.add(contact2);
        insert conList;
        
        List<AccountPartner__c> apList = new List<AccountPartner__c>();
        AccountPartner__c ap1 = new AccountPartner__c();
        ap1.Partner_Type__c = 'Distributor';
        ap1.Partner_AccountId__c = acc1.id;
        ap1.main_accountid__c = acc2.id;
        ap1.distributor_contact__c = contact2.id;
        apList.add(ap1);
        
        AccountPartner__c ap2 = new AccountPartner__c();
        ap2.Partner_Type__c = 'VAR/Reseller';
        ap2.Partner_AccountId__c = acc2.id;
        ap2.main_accountid__c = acc1.id;
        ap2.distributor_contact__c = contact1.id;
        apList.add(ap2);
        insert apList;
        
        Control_Number__c cn1 = new Control_Number__c();
        cn1.Control__c = '1';
        cn1.Account__c = acc1.Id;
        cn1.BSTC_Amount__c = 100;
        cn1.PPSTC_Amount__c = 200;
        cn1.Event_Start_Date__c = system.today();
        cn1.Event_End_Date__c = system.today();
        cn1.Price_Type__c = 'ED';
        cn1.SKU__c = 'test';
        insert cn1;
        
        List<Claim__c> cList = new List<Claim__c>();
        Claim__c claim = new Claim__c();
        claim.Account__c = acc2.Id;
        claim.Claim_Name__c = 'test Claim';
        claim.Claim_Start_Date__c = system.today();
        claim.Claim_End_Date__c = system.today();
        claim.Co_Op__c = '1';
        claim.status__c = 'Draft';
        cList.add(claim);
        
        Claim__c claim2 = new Claim__c();
        claim2.Account__c = acc1.Id;
        claim2.Claim_Name__c = 'test Claim';
        claim2.Claim_Start_Date__c = system.today();
        claim2.Claim_End_Date__c = system.today();
        claim2.Co_Op__c = '1';
        claim2.status__c = 'Submitted';
        cList.add(claim2);
        
        Claim__c claim3 = new Claim__c();
        claim3.Account__c = acc1.Id;
        claim3.Claim_Name__c = 'test Claim';
        claim3.Claim_Start_Date__c = system.today();
        claim3.Claim_End_Date__c = system.today();
        claim3.Co_Op__c = '1';
        claim3.status__c = 'Approved';
        cList.add(claim3);
        insert cList;

        List<Claim_Item__c> ciList = new List<Claim_Item__c>();
        Claim_Item__c claimItem = new Claim_Item__c();
        claimItem.Control_Number__c = cn1.id;
        claimItem.Claim__c = claim.id;
        claimItem.Quantity_Claimed__c = 1;
        claimItem.Claim__c = claim.id;
        ciList.add(claimItem);
        
        Claim_Item__c claimItem2 = new Claim_Item__c();
        claimItem2.Control_Number__c = cn1.id;
        claimItem2.Claim__c = claim2.id;
        claimItem2.Quantity_Claimed__c = 1;
        ciList.add(claimItem2);
        insert ciList;

        Profile p = [SELECT Id FROM Profile WHERE Name='Vizio Sales User' Limit 1];
    	
    	User user1 = new User();
        user1.Email = 'user@123.com';
        user1.Username = 'user@1239.com';
        //user1.ContactId = contact1.Id;
        user1.ProfileId = p.Id;
        user1.Alias = 'test123';
        user1.EmailEncodingKey = 'UTF-8';
        user1.LastName = 'Kumar';
        user1.CommunityNickname = 'test1';
        user1.TimeZoneSidKey = 'America/Los_Angeles';
        user1.LocaleSidKey = 'en_US';
        user1.LanguageLocaleKey = 'en_US';
        insert user1;
        
        test.startTest();
        system.runAs(user1){
        	ApexPages.StandardController controller = new ApexPages.StandardController(claim);
	        SubmitClaimeController main = new SubmitClaimeController(controller);
	        main.submit();
	        claim.status__c = 'Approved';
			update claim;
			main.submit();

	        ApexPages.StandardController controller2 = new ApexPages.StandardController(claim2);
	        SubmitClaimeController main2 = new SubmitClaimeController(controller2);
	        main2.submit();
	        main2.okButton();	
	        
	        ApexPages.StandardController controller3 = new ApexPages.StandardController(claim3);
	        SubmitClaimeController main3 = new SubmitClaimeController(controller3);
	        main3.submit();
	        main3.okButton();	
        }
        test.stopTest();
        Claim__c resultClaim = [SELECT Id, status__c FROM Claim__c WHERE Id =: Claim.Id];
        system.assertEquals(resultClaim.status__c, 'Approved');
        Claim__c resultClaim2 = [SELECT Id, status__c FROM Claim__c WHERE Id =: Claim2.Id];
        system.assertEquals(resultClaim2.status__c, 'Submitted');
	}
}