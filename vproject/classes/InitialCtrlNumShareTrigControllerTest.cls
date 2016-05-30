//Setting SeeAllData=true because of Mixed DML Operation Exception
@isTest 
public with sharing class InitialCtrlNumShareTrigControllerTest {
	
	static testmethod void myUnitTest(){
		List<Account> accList = new List<Account>();
		//Distributor Account
		Account acc1 = new Account();
        acc1.Name = 'Name';
        acc1.Channel_Id__c = 'test';
        accList.add(acc1);
        
        //Reseller Account
        Account acc2 = new Account();
        acc2.Name = 'Name2';
        acc2.Channel_Id__c = 'test2';
        accList.add(acc2);
        
		Account acc3 = new Account();
        acc3.Name = 'Name';
        acc3.Channel_Id__c = 'test';
        accList.add(acc3);
        
        Account acc4 = new Account();
        acc4.Name = 'Name';
        acc4.Channel_Id__c = 'test';
        accList.add(acc4);
        
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
        
        Contact contact3 = new Contact();
        contact3.FirstName = 'Test';
        contact3.Lastname = 'Last';
        contact3.AccountId = acc3.Id;
        contact3.Email = 'test@test.com';
        conList.add(contact3);
        
        Contact contact4 = new Contact();
        contact4.FirstName = 'Test';
        contact4.Lastname = 'Last';
        contact4.AccountId = acc3.Id;
        contact4.Email = 'test@test.com';
        conList.add(contact4);
        
        insert conList;
        
        Profile p = [SELECT Id FROM Profile WHERE Name='Vizio Partner Community Admin' Limit 1];
   	
        List<User> uList = new List<User>();
        User user1 = new User();
        user1.Email = 'user@123.com';
        user1.Username = 'user@12331.com';
        user1.ContactId = contact1.Id;
        user1.ProfileId = p.Id;
        user1.Alias = 'test123';
        user1.EmailEncodingKey = 'UTF-8';
        user1.LastName = 'Kumar';
        user1.CommunityNickname = 'test1';
        user1.TimeZoneSidKey = 'America/Los_Angeles';
        user1.LocaleSidKey = 'en_US';
        user1.LanguageLocaleKey = 'en_US';
        uList.add(user1);
        
        User user2 = new User();
        user2.Email = 'user2@123.com';
        user2.Username = 'user2@12331.com';
        user2.ContactId = contact2.Id;
        user2.ProfileId = p.Id;
        user2.Alias = 'test2123';
        user2.EmailEncodingKey = 'UTF-8';
        user2.LastName = 'Kumar';
        user2.CommunityNickname = 'test12';
        user2.TimeZoneSidKey = 'America/Los_Angeles';
        user2.LocaleSidKey = 'en_US';
        user2.LanguageLocaleKey = 'en_US';
        uList.add(user2);
        
        User user3 = new User();
        user3.Email = 'user3@123.com';
        user3.Username = 'user3@12331.com';
        user3.ContactId = contact3.Id;
        user3.ProfileId = p.Id;
        user3.Alias = 'test3123';
        user3.EmailEncodingKey = 'UTF-8';
        user3.LastName = 'Kumar';
        user3.CommunityNickname = 'test123';
        user3.TimeZoneSidKey = 'America/Los_Angeles';
        user3.LocaleSidKey = 'en_US';
        user3.LanguageLocaleKey = 'en_US';
        uList.add(user3);
        
        insert uList;
        
        List<AccountPartner__c> apList = new List<AccountPartner__c>();
		AccountPartner__c ap1 = new AccountPartner__c();
        ap1.Partner_Type__c = 'Distributor';
        ap1.Partner_AccountId__c = acc1.id;
        ap1.main_accountid__c = acc2.id;
        apList.add(ap1);
        
        AccountPartner__c ap2 = new AccountPartner__c();
        ap2.Partner_Type__c = 'VAR/Reseller';
        ap2.Partner_AccountId__c = acc2.id;
        ap2.main_accountid__c = acc1.id;
        ap2.distributor_contact__c = contact1.id;
        apList.add(ap2);
        
        insert apList;
 
        List<Control_Number__c> cnList = new List<Control_Number__c>();
        Control_Number__c cn1 = new Control_Number__c();
        cn1.Control__c = '1';
        cn1.Account__c = acc1.Id;
        cn1.BSTC_Amount__c = 0;
        cn1.PPSTC_Amount__c = 200;
        cn1.Event_Start_Date__c = system.today();
        cn1.Event_End_Date__c = system.today();
        cn1.Price_Type__c = 'ED';
        cn1.SKU__c = 'test';
        cnList.add(cn1);
        
        Control_Number__c cn2 = new Control_Number__c();
        cn2.Control__c = '2';
        cn2.Account__c = acc2.Id;
        cn2.BSTC_Amount__c = 100;
        cn2.PPSTC_Amount__c = 200;
        cn2.Event_Start_Date__c = system.today();
        cn2.Event_End_Date__c = system.today();
        cn2.Price_Type__c = 'LP';
        cn2.SKU__c = 'test';
        cnList.add(cn2);
        
        Control_Number__c cn3 = new Control_Number__c();
        cn3.Control__c = '3';
        cn3.Account__c = acc3.Id;
        cn3.BSTC_Amount__c = 100;
        cn3.PPSTC_Amount__c = 200;
        cn3.Event_Start_Date__c = system.today();
        cn3.Event_End_Date__c = system.today();
        cn3.Price_Type__c = 'EDNOP';
        cn3.SKU__c = 'test';
        cnList.add(cn3);
        
        Control_Number__c cn4 = new Control_Number__c();
        cn4.Control__c = '4';
        cn4.Account__c = acc4.Id;
        cn4.BSTC_Amount__c = 100;
        cn4.PPSTC_Amount__c = 200;
        cn4.Event_Start_Date__c = system.today();
        cn4.Event_End_Date__c = system.today();
        cn4.Price_Type__c = 'EDNOP';
        cn4.SKU__c = 'test';
        cnList.add(cn4);
        
		test.startTest();
		insert cnList;
		List<Control_Number__Share> cns1List = [SELECT id, ParentId, UserorGroupId FROM Control_Number__Share WHERE ParentId =: cn1.id];
        List<Control_Number__Share> cns2List = [SELECT id, ParentId, UserorGroupId FROM Control_Number__Share WHERE ParentId =: cn2.id];
        List<Control_Number__Share> cns3List = [SELECT id, ParentId, UserorGroupId FROM Control_Number__Share WHERE ParentId =: cn3.id];
        List<Control_Number__Share> cns4List = [SELECT id, ParentId, UserorGroupId FROM Control_Number__Share WHERE ParentId =: cn4.id];
        
        system.assertEquals(cns1List.size(), 2);
        system.assertEquals(cns2List.size(), 1);
        system.assertEquals(cns3List.size(), 1);
        system.assertEquals(cns4List.size(), 0);
        
        Control_Number__c updateCn = [SELECT Id, Account__c FROM Control_Number__c WHERE Id =: cn4.Id];
        updateCn.Account__c = acc2.Id;
        update updateCn;
             
        List<Control_Number__Share> cns5List = [SELECT id, ParentId, UserorGroupId FROM Control_Number__Share WHERE ParentId =: updateCn.id];
        List<Control_Number__Share> cns6List = [SELECT id, ParentId, UserorGroupId FROM Control_Number__Share WHERE ParentId =: cn1.id];
        system.assertEquals(cns5List.size(), 1);
        system.assertEquals(cns6List.size(), 2);
		test.stopTest();
	}
}