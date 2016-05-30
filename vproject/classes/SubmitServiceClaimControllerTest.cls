/*
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
private class SubmitServiceClaimControllerTest {

    static testmethod void unitTest(){

        // set up record types
        Id sRecType_RMA = NULL;
        Id sRecType_WC = NULL;
        Id aRecType = NULL;
        Id cRecType = NULL;
        Id pRecType_Prod = NULL;

        List<RecordType> recTypes = [SELECT Id,DeveloperName,SobjectType FROM RecordType WHERE DeveloperName
                                    IN ('RMA','Warranty_Claim','Support','Product') AND SobjectType
                                    IN ('Account','Contact','Service_Claim__c','Product2')];
    
        for(Integer j = 0; j < recTypes.size(); j++) {
            if (recTypes.get(j).DeveloperName == 'RMA' && recTypes.get(j).SobjectType == 'Service_Claim__c') {
                sRecType_RMA = recTypes.get(j).Id;
            }
            else if (recTypes.get(j).DeveloperName == 'Warranty_Claim' && recTypes.get(j).SobjectType == 'Service_Claim__c') {
                sRecType_WC = recTypes.get(j).Id;
            }
            else if (recTypes.get(j).DeveloperName == 'Support' && recTypes.get(j).SobjectType == 'Account') {
                aRecType = recTypes.get(j).Id;
            }
            else if (recTypes.get(j).DeveloperName == 'Support' && recTypes.get(j).SobjectType == 'Contact') {
                cRecType = recTypes.get(j).Id;
            }
            else if (recTypes.get(j).DeveloperName == 'Product' && recTypes.get(j).SobjectType == 'Product2') {
                pRecType_Prod = recTypes.get(j).Id;
            }
        }

        // init VASP account
        List<Account> accList = new List<Account>();
        Account acc1 = new Account();
        acc1.Name = 'VASP Account';
        acc1.Type = 'VASP';
        acc1.RecordTypeId = aRecType;
        accList.add(acc1);
        
        // init ODM account
        Account acc2 = new Account();
        acc2.Name = 'ODM Account';
        acc2.Type = 'ODM';
        acc2.ODM_Code__c = 'A';
        acc2.RecordTypeId = aRecType;
        accList.add(acc2);
        insert accList;

        // set up contacts
        List<Contact> conList = new List<Contact>();
        Contact contact1 = new Contact();
        contact1.FirstName = 'Test';
        contact1.Lastname = 'Last';
        contact1.AccountId = acc1.Id;
        contact1.RecordTypeId = cRecType;
        contact1.Email = 'test@test.com';
        conList.add(contact1);
        
        Contact contact2 = new Contact();
        contact2.FirstName = 'Test';
        contact2.Lastname = 'Last';
        contact2.AccountId = acc2.Id;
        contact2.RecordTypeId = cRecType;
        contact2.Email = 'test@test.com';
        conList.add(contact2);
        insert conList;

        // build VASP/ODM relationship
        List<ODM_Partner__c> apList = new List<ODM_Partner__c>();
        ODM_Partner__c ap1 = new ODM_Partner__c();
        ap1.VASP_Partner__c = acc1.id;
        ap1.ODM_Partner__c = acc2.id;
        ap1.Mark_Up_Percentage__c = 20;
        apList.add(ap1);
        insert apList;

        // init Product
        List<Product2> prodList = new List<Product2>();
        Product2 prod1 = new Product2();
        prod1.Name = 'Test Product';
        prod1.ProductCode = 'ABC123';
        prod1.ODM_Account__c = acc2.Id;
        prod1.RecordTypeId = pRecType_Prod;
        prodList.add(prod1);
        insert prodList;
        
        // init Store record
        List<StoreLocation__c> storeList = new List<StoreLocation__c>();
        StoreLocation__c store = new StoreLocation__c();
        store.Name = 'Test Store';
        store.VASPAccount__c = acc1.Id;
        insert store;

        // init serviceClaim1 (rma)
        // set up RMA 1
        List<Service_Claim__c> cList = new List<Service_Claim__c>();
        Service_Claim__c claim1 = new Service_Claim__c();
        claim1.Account__c = acc1.Id;
        claim1.Contact__c = contact1.Id;
        claim1.ODM_Partner__c = ap1.Id;
        claim1.Serial_No__c = 'LAQKMBBN3203164';
        claim1.Model_No__c = prod1.Id;
        claim1.RecordTypeId = sRecType_RMA;
        claim1.StoreNumber__c = store.Id;
        claim1.Lease_Date__c = system.today();
        claim1.Problem_Type__c = 'Television';
        claim1.Problem_Description__c = 'Safety';
        claim1.Status__c = 'Draft';
        claim1.ValidSerialNumber__c = true;
        cList.add(claim1);

        // set up RMA 2
        Service_Claim__c claim2 = new Service_Claim__c();
        claim2.Account__c = acc1.Id;
        claim2.Contact__c = contact1.Id;
        claim2.ODM_Partner__c = ap1.Id;
        claim2.Serial_No__c = 'LAQKMBBN3203165';
        claim2.Model_No__c = prod1.Id;
        claim2.RecordTypeId = sRecType_RMA;
        claim2.StoreNumber__c = store.Id;
        claim2.Lease_Date__c = system.today();
        claim2.Problem_Type__c = 'Television';
        claim2.Problem_Description__c = 'Safety';
        claim2.Status__c = 'Draft';
        claim2.ValidSerialNumber__c = true;
        cList.add(claim2);

        // set up RMA 2
        Service_Claim__c claim3 = new Service_Claim__c();
        claim3.Account__c = acc1.Id;
        claim3.Contact__c = contact1.Id;
        claim3.ODM_Partner__c = ap1.Id;
        claim3.Serial_No__c = 'LAQKMBBN3203166';
        claim3.Model_No__c = prod1.Id;
        claim3.RecordTypeId = sRecType_RMA;
        claim3.StoreNumber__c = store.Id;
        claim3.Lease_Date__c = system.today();
        claim3.Problem_Type__c = 'Television';
        claim3.Problem_Description__c = 'No Video/ Backlight Issues (pictures required)';
        claim3.Status__c = 'Draft';
        claim3.ValidSerialNumber__c = true;
        cList.add(claim3);

        // set up Warranty Claim with no children
        Service_Claim__c claim4 = new Service_Claim__c();
        claim4.Account__c = acc1.Id;
        claim4.Contact__c = contact1.Id;
        claim4.ODM_Partner__c = ap1.Id;
        claim4.Serial_No__c = 'LAQKMBBN3203167';
        claim4.Model_No__c = prod1.Id;
        claim4.RecordTypeId = sRecType_WC;
        claim4.StoreNumber__c = store.Id;
        claim4.Lease_Date__c = system.today();
        claim4.Service_In_Date__c = system.today();
        claim4.Service_Completed__c = system.today();
        claim4.Defect_Type__c = 'Power';
        claim4.Defect_Code__c = 'DEAD - No Power';
        claim4.Resolution_Code__c = 'RECO - Reconnect';
        claim4.Customer_First_Name__c = 'Joe';
        claim4.Customer_Last_Name__c = 'Blow';
        claim4.Customer_Address__c = '123 Main';
        claim4.Customer_City__c = 'Anytown';
        claim4.Customer_Country__c = 'US';
        claim4.Customer_State__c = 'CA';
        claim4.Customer_Postal_Code__c = '12345';
        claim4.Customer_Phone__c = '555-1212';
        claim4.Customer_Email__c = 'j@j.net';
        claim4.Status__c = 'Draft';
        claim4.ValidSerialNumber__c = true;
        cList.add(claim4);

        insert cList;

        // select profile & set up users to test as
        Profile p = [SELECT Id FROM Profile WHERE Name='VIZIO Support Claims' Limit 1];

        User user1 = new User();
        user1.Email = 'user@123.com';
        user1.Username = 'john.doe@1239.com';
        user1.ProfileId = p.Id;
        user1.Alias = 'test123';
        user1.EmailEncodingKey = 'UTF-8';
        user1.LastName = 'Doe';
        user1.CommunityNickname = 'test2';
        user1.TimeZoneSidKey = 'America/Los_Angeles';
        user1.LocaleSidKey = 'en_US';
        user1.LanguageLocaleKey = 'en_US';
        insert user1;
        
        test.startTest();
            system.runAs(user1){
                ApexPages.StandardController controller = new ApexPages.StandardController(claim1);
                SubmitServiceClaimController main1 = new SubmitServiceClaimController(controller);
                main1.submit();
                claim1.status__c = 'Approved';
                update claim1;
                main1.submit();

                ApexPages.StandardController controller2 = new ApexPages.StandardController(claim2);
                SubmitServiceClaimController main2 = new SubmitServiceClaimController(controller2);
                main2.submit();
                main2.okButton();   
                
                ApexPages.StandardController controller3 = new ApexPages.StandardController(claim3);
                SubmitServiceClaimController main3 = new SubmitServiceClaimController(controller3);
                main3.submit();
                main3.okButton();

                ApexPages.StandardController controller4 = new ApexPages.StandardController(claim4);
                SubmitServiceClaimController main4 = new SubmitServiceClaimController(controller4);
                main4.submit();
                main4.okButton();
            }
            test.stopTest();

            Service_Claim__c resultClaim = [SELECT Id, status__c FROM Service_Claim__c WHERE Id =: Claim1.Id];
            system.assertEquals(resultClaim.status__c, 'Approved');
            Service_Claim__c resultClaim2 = [SELECT Id, status__c FROM Service_Claim__c WHERE Id =: Claim2.Id];
            system.assertEquals(resultClaim2.status__c, 'Pending Review');
            Service_Claim__c resultClaim3 = [SELECT Id, status__c FROM Service_Claim__c WHERE Id =: Claim3.Id];
            system.assertEquals(resultClaim3.status__c, 'Draft');
            Service_Claim__c resultClaim4 = [SELECT Id, status__c FROM Service_Claim__c WHERE Id =: Claim4.Id];
            system.assertEquals(resultClaim4.status__c, 'Draft');
    }

}