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
public with sharing class SelectControlNumberTest {

    static testMethod void externalUserNewClaim() {
        Account acc1 = new Account();
        acc1.Name = 'Name';
        acc1.Channel_Id__c = 'test';
        insert acc1;
        
        Contact contact1 = new Contact();
        contact1.FirstName = 'Test';
        contact1.Lastname = 'Last';
        contact1.AccountId = acc1.Id;
        contact1.Email = 'test@test.com';
        insert contact1;
        
        Profile p = [SELECT Id FROM Profile WHERE Name='Vizio Partner Community' Limit 1];
        
        User user1 = new User();
        user1.Email = 'user@123.com';
        user1.Username = 'user@1235.com';
        user1.ContactId = contact1.Id;
        user1.ProfileId = p.Id;
        user1.Alias = 'test123';
        user1.EmailEncodingKey = 'UTF-8';
        user1.LastName = 'Kumar';
        user1.CommunityNickname = 'test1';
        user1.TimeZoneSidKey = 'America/Los_Angeles';
        user1.LocaleSidKey = 'en_US';
        user1.LanguageLocaleKey = 'en_US';
        insert user1;
        
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
        cn1.Status__c = 'Accepted by Channel';
        cnList.add(cn1);
        
        Control_Number__c cn2 = new Control_Number__c();
        cn2.Control__c = '2';
        cn2.Account__c = acc1.Id;
        cn2.BSTC_Amount__c = 100;
        cn2.PPSTC_Amount__c = 200;
        cn2.Event_Start_Date__c = system.today();
        cn2.Event_End_Date__c = system.today();
        cn2.Price_Type__c = 'LP';
        cn2.SKU__c = 'test';
        cn2.Status__c = 'Accepted by Channel';
        cnList.add(cn2);
        
        Control_Number__c cn3 = new Control_Number__c();
        cn3.Control__c = '3';
        cn3.Account__c = acc1.Id;
        cn3.BSTC_Amount__c = 100;
        cn3.PPSTC_Amount__c = 200;
        cn3.Event_Start_Date__c = system.today();
        cn3.Event_End_Date__c = system.today();
        cn3.Price_Type__c = 'EDNOP';
        cn3.SKU__c = 'test';
        cn3.Status__c = 'Accepted by Channel';
        cnList.add(cn3);
        
        Control_Number__c cn4 = new Control_Number__c();
        cn4.Control__c = '4';
        cn4.Account__c = acc1.Id;
        cn4.BSTC_Amount__c = 100;
        cn4.PPSTC_Amount__c = 200;
        cn4.Event_Start_Date__c = system.today();
        cn4.Event_End_Date__c = system.today();
        cn4.Price_Type__c = 'STC';
        cn4.SKU__c = 'test';
        cn4.Status__c = 'Accepted by Channel';
        cnList.add(cn4);
        
        insert cnList;
        
        Claim__c claim = new Claim__c();
        claim.Account__c = acc1.Id;
        claim.Claim_Name__c = 'test Claim';
        claim.Claim_Start_Date__c = system.today();
        claim.Claim_End_Date__c = system.today();
        claim.Co_Op__c = '1';
        claim.status__c = 'Submitted';
        insert claim;
        
        //List<Claim__c> cList = [SELECT Id, Account__c FROM Claim__c];
            //system.assertEquals(cList.size(), 2);
        
        test.startTest();
        System.runAs(user1) {
            ApexPages.StandardController controller = new ApexPages.StandardController(claim);
            SelectControlNumber main = new SelectControlNumber(controller);
            main.getWrapperList();
            system.assertEquals(main.allWrapList.size(), 4);
            for (integer i=0; i< main.allWrapList.size(); i++) {
                main.allWrapList[i].isSelect = true;
            }
            //main.getWrapperList();
            main.goToClaimItemPage();
            
            main.claimItemList[0].Claim_Type_del__c = 'PP';
            main.claimItemList[1].Claim_Type_del__c = 'PP';
            main.claimItemList[2].Claim_Type_del__c = 'iVMP';
            main.claimItemList[3].Claim_Type_del__c = 'STC';
            //main.goNext();
            
            for (Claim_Item__c ci: main.claimItemList) {
                ci.Quantity_Claimed__c = 1;
                main.goNext();
            }

            main.claim.Claim_Start_Date__c = system.today();
            main.claim.Claim_End_Date__c = system.today();
            main.claim.Co_Op__c = '1';
            main.cancel();
            
            for (integer i=0; i< main.allWrapList.size(); i++) {
                main.allWrapList[i].isSelect = true;
            }
            //main.getWrapperList();
            main.goToClaimItemPage();
            
            main.claimItemList[0].Claim_Type_del__c = 'PP';
            main.claimItemList[1].Claim_Type_del__c = 'PP';
            main.claimItemList[2].Claim_Type_del__c = 'iVMP';
            main.claimItemList[3].Claim_Type_del__c = 'STC';
            //main.goNext();
            
            for (Claim_Item__c ci: main.claimItemList) {
                ci.Quantity_Claimed__c = 1;
                main.goNext();
            }

            main.claim.Claim_Start_Date__c = system.today();
            main.claim.Claim_End_Date__c = system.today();
            main.claim.Co_Op__c = '1';
            main.save();            
            
            /*
            //Scenario 2: Adding claim item to created claim
            //trying to add new claim items onto existing claim
            main.savedClaim = claim; 
            //main.goToClaimItemPage();
            
            //searching with no keyword
            main.gosearch();
            main.clickLink();
            
            //Search for 1 control number
            //SelectControlNumber main2 = new SelectControlNumber(controller);
            main.keyword='1';
            main.gosearch();
            //main.getWrapperList();
            //system.assertEquals(main.allWrapList.size(), 1);
            //main.clickLink();
            
            for (Claim_Item__c ci: main.claimItemList) {
                ci.Quantity_Claimed__c = 1;
                main.goNext();
            }

            main.gotoClaimItemPage();
            boolean test1 = main.hasNext;
            boolean test2 = main.hasPrevious;
            integer test3 = main.pageNumber;
            main.first();
            main.last();
            main.next();
            main.previous();
            */
        }
        List<Claim__c> cList = [SELECT Id, Account__c FROM Claim__c];
        system.assertEquals(cList.size(), 2);
        test.StopTest();
    }
    
    static testmethod void externalUserNewClaimItem(){
    	Account acc1 = new Account();
        acc1.Name = 'Name';
        acc1.Channel_Id__c = 'test';
        insert acc1;
        
        Contact contact1 = new Contact();
        contact1.FirstName = 'Test';
        contact1.Lastname = 'Last';
        contact1.AccountId = acc1.Id;
        contact1.Email = 'test@test.com';
        insert contact1;
        
        Profile p = [SELECT Id FROM Profile WHERE Name='Vizio Partner Community' Limit 1];
        
        User user1 = new User();
        user1.Email = 'user@123.com';
        user1.Username = 'user@1236.com';
        user1.ContactId = contact1.Id;
        user1.ProfileId = p.Id;
        user1.Alias = 'test123';
        user1.EmailEncodingKey = 'UTF-8';
        user1.LastName = 'Kumar';
        user1.CommunityNickname = 'test1';
        user1.TimeZoneSidKey = 'America/Los_Angeles';
        user1.LocaleSidKey = 'en_US';
        user1.LanguageLocaleKey = 'en_US';
        insert user1;
        
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
        cn1.Status__c = 'Accepted by Channel';
        cnList.add(cn1);
        
        Control_Number__c cn2 = new Control_Number__c();
        cn2.Control__c = '2';
        cn2.Account__c = acc1.Id;
        cn2.BSTC_Amount__c = 100;
        cn2.PPSTC_Amount__c = 200;
        cn2.Event_Start_Date__c = system.today();
        cn2.Event_End_Date__c = system.today();
        cn2.Price_Type__c = 'LP';
        cn2.SKU__c = 'test';
        cn2.Status__c = 'Accepted by Channel';
        cnList.add(cn2);
        
        Control_Number__c cn3 = new Control_Number__c();
        cn3.Control__c = '3';
        cn3.Account__c = acc1.Id;
        cn3.BSTC_Amount__c = 100;
        cn3.PPSTC_Amount__c = 200;
        cn3.Event_Start_Date__c = system.today();
        cn3.Event_End_Date__c = system.today();
        cn3.Price_Type__c = 'EDNOP';
        cn3.SKU__c = 'test';
        cn3.Status__c = 'Accepted by Channel';
        cnList.add(cn3);
        
        Control_Number__c cn4 = new Control_Number__c();
        cn4.Control__c = '4';
        cn4.Account__c = acc1.Id;
        cn4.BSTC_Amount__c = 100;
        cn4.PPSTC_Amount__c = 200;
        cn4.Event_Start_Date__c = system.today();
        cn4.Event_End_Date__c = system.today();
        cn4.Price_Type__c = 'STC';
        cn4.SKU__c = 'test';
        cn4.Status__c = 'Accepted by Channel';
        cnList.add(cn4);
        
        insert cnList;
        
        Claim__c claim = new Claim__c();
        claim.Account__c = acc1.Id;
        claim.Claim_Name__c = 'test Claim';
        claim.Claim_Start_Date__c = system.today();
        claim.Claim_End_Date__c = system.today();
        claim.Co_Op__c = '1';
        claim.status__c = 'Submitted';
        claim.claim_type__c = 'PP';
        insert claim;
        
        Claim_Item__c claimItem = new Claim_Item__c();
        claimItem.Control_Number__c = cn1.id;
        claimItem.Claim__c = claim.id;
        claimItem.Quantity_Claimed__c = 1;
        claimItem.claim_type_del__c = 'PP';
        insert claimItem;
        
    	test.startTest();
    	ApexPages.StandardController controller = new ApexPages.StandardController(claim);
        SelectControlNumber main = new SelectControlNumber(controller);
    	main.getWrapperList();
        system.assertEquals(main.allWrapList.size(), 4);
        for (integer i=0; i< main.allWrapList.size(); i++) {
             main.allWrapList[i].isSelect = true;
        }
        main.savedClaim = claim;        
        /*
        //searching with no keyword, then sorting
        main.gosearch();
        main.clickLink();
            
        boolean test1 = main.hasNext;
        boolean test2 = main.hasPrevious;
        integer test3 = main.pageNumber;
        main.first();
        main.last();
        main.next();
        main.previous();    
            
        //Search for 1 control number
        main.keyword='1';
        main.gosearch();
        */
        main.goToClaimItemPage();
		for (Claim_Item__c ci: main.claimItemList) {
        	ci.Quantity_Claimed__c = 1;
            main.goNext();
        }        
        list<claim_item__c> claimItemListTemp = main.claimItemList;
        for (claim_item__c ci: claimItemListTemp){
        	system.debug('test class claim item type: ' + ci.claim_type_Del__c);
        }
        main.save();
        List<Claim__c> cList = [SELECT Id FROM Claim__c];
        system.assertEquals(cList.size(), 1);
    	test.stopTest();
    }
    
    //testing internal user, adding new claim items to existing claim
    static testmethod void internalUserNewClaimItem() {
    	Account acc1 = new Account();
        acc1.Name = 'Name';
        acc1.Channel_Id__c = 'test';
        insert acc1;
        
        Contact contact1 = new Contact();
        contact1.FirstName = 'Test';
        contact1.Lastname = 'Last';
        contact1.AccountId = acc1.Id;
        contact1.Email = 'test@test.com';
        insert contact1;
        
    	Profile p = [SELECT Id FROM Profile WHERE Name='Vizio Sales User' Limit 1];
    	
    	User user1 = new User();
        user1.Email = 'user@123.com';
        user1.Username = 'user@1238.com';
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
        
        List<Control_Number__c> cnList = new List<Control_Number__c>();
        Control_Number__c cn1 = new Control_Number__c();
        cn1.Control__c = '1';
        cn1.Account__c = acc1.Id;
        cn1.BSTC_Amount__c = 100;
        cn1.PPSTC_Amount__c = 200;
        cn1.Event_Start_Date__c = system.today();
        cn1.Event_End_Date__c = system.today();
        cn1.Price_Type__c = 'ED';
        cn1.SKU__c = 'test';
        cn1.Status__c = 'Accepted by Channel';
        cnList.add(cn1);
        
        Control_Number__c cn2 = new Control_Number__c();
        cn2.Control__c = '2';
        cn2.Account__c = acc1.Id;
        cn2.BSTC_Amount__c = 0;
        cn2.PPSTC_Amount__c = 0;
        cn2.Event_Start_Date__c = system.today();
        cn2.Event_End_Date__c = system.today();
        cn2.Price_Type__c = 'LP';
        cn2.SKU__c = 'test';
        cn2.Status__c = 'Accepted by Channel';
        cnList.add(cn2);
        
        Control_Number__c cn3 = new Control_Number__c();
        cn3.Control__c = '3';
        cn3.Account__c = acc1.Id;
        cn3.BSTC_Amount__c = 0;
        cn3.PPSTC_Amount__c = 200;
        cn3.Event_Start_Date__c = system.today();
        cn3.Event_End_Date__c = system.today();
        cn3.Price_Type__c = 'EDNOP';
        cn3.SKU__c = 'test';
        cn3.Status__c = 'Accepted by Channel';
        cnList.add(cn3);
        
        Control_Number__c cn4 = new Control_Number__c();
        cn4.Control__c = '4';
        cn4.Account__c = acc1.Id;
        cn4.BSTC_Amount__c = 100;
        cn4.PPSTC_Amount__c = 0;
        cn4.Event_Start_Date__c = system.today();
        cn4.Event_End_Date__c = system.today();
        cn4.Price_Type__c = 'STC';
        cn4.SKU__c = 'test';
        cn4.Status__c = 'Accepted by Channel';
        cnList.add(cn4);
        
        insert cnList;
        
        Claim__c claim = new Claim__c();
        claim.Account__c = acc1.Id;
        claim.Claim_Name__c = 'test Claim';
        claim.Claim_Start_Date__c = system.today();
        claim.Claim_End_Date__c = system.today();
        claim.Co_Op__c = '1';
        claim.Status__c = 'Submitted';
        claim.Claim_Type__c = 'STC';
        insert claim;
        
        test.startTest();
        System.runAs(user1) {
            ApexPages.StandardController controller = new ApexPages.StandardController(claim);
            SelectControlNumber main = new SelectControlNumber(controller);
            main.getWrapperList();
            system.assertEquals(main.allWrapList.size(), 4);
            main.savedClaim = claim;
            /*
            main.setSortDirection(main.getSortDirection());				//sorting test
            //main.sortExpression='';
            //main.clickLink();
            main.sortExpression = 'Event_Start_Date__c';
            main.clickLink();
            main.sortExpression = 'Event_End_Date__c';
            main.clickLink();
            
            for (integer i=0; i< main.allWrapList.size(); i++) {
                main.allWrapList[i].isSelect = true;
            }
            main.goToClaimItemPage();
            for (Claim_Item__c ci: main.claimItemList) {
                ci.Quantity_Claimed__c = 1;
                main.goNext();
            }
            
            main.cancel();
            */
            List<Claim__c> cList = [SELECT Id, Account__c FROM Claim__c];
            system.assertEquals(cList.size(), 1);
            List<Claim_Item__c> ciList = [SELECT id FROM Claim_Item__c];
            system.assertEquals(ciList.size(),0);
            
            for (integer i=0; i< main.allWrapList.size(); i++) {
                main.allWrapList[i].isSelect = true;
            }
            
            main.goToClaimItemPage();
            main.claimItemList[0].Claim_Type_del__c = 'PP';
            main.claimItemList[1].Claim_Type_del__c = 'PP';
            main.claimItemList[2].Claim_Type_del__c = 'iVMP';
            main.claimItemList[3].Claim_Type_del__c = 'STC';    
            for (Claim_Item__c ci: main.claimItemList) {
                ci.Quantity_Claimed__c = 1;
                main.goNext();
            }
            main.goBack();
            main.goNext();
            
            //main.goNext();
            /*
            main.claim.Claim_Start_Date__c = system.today();
            main.claim.Claim_End_Date__c = system.today();
            main.claim.Co_Op__c = '1';
            */
            main.save();
            List<Claim_Item__c> itemsAdded = [SELECT id FROM claim_item__c WHERE claim__c=:claim.id];
            system.assertEquals(itemsAdded.size(), 4);   
            /*
            //new claim items being added to created claim
            
            system.assertEquals(main.claimItemList.size(), 4);
            for (Claim_Item__c ci: main.claimItemList) {
                ci.Quantity_Claimed__c = 1;
                main.goNext();
            }
            main.goBack();
            
            for (Claim_Item__c ci: main.claimItemList) {
                ci.Quantity_Claimed__c = 1;
                main.goNext();
            }
            main.save();
            List<Claim_Item__c> itemsAdded = [SELECT id FROM claim_item__c WHERE claim__c=:claim.id];
            system.assertEquals(itemsAdded.size(), 4);   
        	*/
        }
        List<Claim__c> cList = [SELECT Id, Account__c FROM Claim__c];
        system.assertEquals(cList.size(), 1);
        test.StopTest();
    }
    
    static testmethod void internalUserNewClaim() {
    	Account acc1 = new Account();
        acc1.Name = 'Name';
        acc1.Channel_Id__c = 'test';
        insert acc1;
        
        Contact contact1 = new Contact();
        contact1.FirstName = 'Test';
        contact1.Lastname = 'Last';
        contact1.AccountId = acc1.Id;
        contact1.Email = 'test@test.com';
        insert contact1;
        
    	Profile p = [SELECT Id FROM Profile WHERE Name='Vizio Sales User' Limit 1];
    	
    	User user1 = new User();
        user1.Email = 'user@123.com';
        user1.Username = 'user@1237.com';
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
        
        Control_Number__c cn1 = new Control_Number__c();
        cn1.Control__c = '1';
        cn1.Account__c = acc1.Id;
        cn1.BSTC_Amount__c = 100;
        cn1.PPSTC_Amount__c = 200;
        cn1.Event_Start_Date__c = system.today();
        cn1.Event_End_Date__c = system.today();
        cn1.Price_Type__c = 'ED';
        cn1.SKU__c = 'test';
        cn1.Status__c = 'Accepted by Channel';
        insert cn1;
        
        
        Claim__c claim = new Claim__c();
        claim.Account__c = acc1.Id;
        claim.Claim_Name__c = 'test Claim';
        claim.Claim_Start_Date__c = system.today();
        claim.Claim_End_Date__c = system.today();
        claim.Co_Op__c = '1';
        claim.Status__c = 'Submitted';
        claim.Claim_Type__c = 'STC';
        insert claim;
        
        Claim_Item__c claimItem = new Claim_Item__c();
        claimItem.Control_Number__c = cn1.id;
        claimItem.Claim__c = claim.id;
        claimItem.Quantity_Claimed__c = 1;
        claimItem.Claim_Type_del__c = 'PP';	
        insert claimItem;
        
        test.startTest();
         System.runAs(user1) {
         	ApexPages.StandardController controller = new ApexPages.StandardController(claim);
    	    SelectControlNumber main2 = new SelectControlNumber(controller);
            main2.getWrapperList();
            system.assertEquals(main2.allWrapList.size(), 1);
            //main.getSortDirection();
            for (integer i=0; i< main2.allWrapList.size(); i++) {
                main2.allWrapList[i].isSelect = true;
            }
            main2.goToClaimItemPage();
            
            for (Claim_Item__c ci: main2.claimItemList) {
                ci.Quantity_Claimed__c = 1;
                main2.goNext();
            }
            
            main2.claimItemList[0].Claim_Type_del__c = 'PP';
			
			main2.claim.Account__c = acc1.Id;
            main2.claim.Claim_Start_Date__c = system.today();
            main2.claim.Claim_End_Date__c = system.today();
            main2.claim.Co_Op__c = '1';
            main2.save();
         }
         List<Claim__c> ccList = [SELECT Id, Account__c FROM Claim__c];
         system.assertEquals(ccList.size(), 2);
         test.StopTest();
    }
    
    static testmethod void ctrlNumberPageTest() {
    	Account acc1 = new Account();
        acc1.Name = 'Name';
        acc1.Channel_Id__c = 'test';
        insert acc1;
        
        Contact contact1 = new Contact();
        contact1.FirstName = 'Test';
        contact1.Lastname = 'Last';
        contact1.AccountId = acc1.Id;
        contact1.Email = 'test@test.com';
        insert contact1;
        
    	Profile p = [SELECT Id FROM Profile WHERE Name='Vizio Sales User' Limit 1];
    	
    	User user1 = new User();
        user1.Email = 'user@123.com';
        user1.Username = 'user@1234.com';
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
        
        Control_Number__c cn1 = new Control_Number__c();
        cn1.Control__c = '1';
        cn1.Account__c = acc1.Id;
        cn1.BSTC_Amount__c = 100;
        cn1.PPSTC_Amount__c = 200;
        cn1.Event_Start_Date__c = system.today();
        cn1.Event_End_Date__c = system.today();
        cn1.Price_Type__c = 'ED';
        cn1.SKU__c = 'test';
        cn1.Status__c = 'Accepted by Channel';
        insert cn1;
        
        
        Claim__c claim = new Claim__c();
        claim.Account__c = acc1.Id;
        claim.Claim_Name__c = 'test Claim';
        claim.Claim_Start_Date__c = system.today();
        claim.Claim_End_Date__c = system.today();
        claim.Co_Op__c = '1';
        claim.Status__c = 'Submitted';
        claim.Claim_Type__c = 'STC';
        insert claim;
        
        Claim_Item__c claimItem = new Claim_Item__c();
        claimItem.Control_Number__c = cn1.id;
        claimItem.Claim__c = claim.id;
        claimItem.Quantity_Claimed__c = 1;
        claimItem.Claim_Type_del__c = 'PP';	
        insert claimItem;
        
        test.startTest();
        System.runAs(user1) {
            ApexPages.StandardController controller = new ApexPages.StandardController(claimItem);
            SelectControlNumber main = new SelectControlNumber(controller);
            main.keyword = '1';
            main.goSearch();
            /*
            main.keyword='';
            main.goSearch();
            */
            main.getWrapperList();

            boolean test1 = main.hasNext;
            boolean test2 = main.hasPrevious;
            integer test3 = main.pageNumber;
            main.first();
            main.last();
            main.previous();
            main.next();          
            
            main.setSortDirection(main.getSortDirection());
            main.clickLink();
            
            for (integer i=0; i< main.allWrapList.size(); i++) {
                main.allWrapList[i].isSelect = true;
            }
            main.goToClaimItemPage();
            for (Claim_Item__c ci: main.claimItemList) {
                ci.Quantity_Claimed__c = 0;
                main.goNext();
            }
            for (Claim_Item__c ci: main.claimItemList) {
                ci.Quantity_Claimed__c = 1;
                main.goBack();
            }
            main.goBack();						//going back at index=0
            
            for (integer i=0; i< main.allWrapList.size(); i++) {
                main.allWrapList[i].isSelect = false;
            }
            main.goToClaimItemPage();
            
        }
        List<Claim__c> claimList = [SELECT id FROM claim__c];
        system.assertEquals(claimList.size(), 1);
        
        test.stopTest();
    }
    
    
}