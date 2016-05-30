@IsTest
public with sharing class RelatedClaimTriggerControllerTest {
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
        claim1.Serial_No__c = 'LAQKMBBN3203165';
        claim1.Model_No__c = prod1.Id;
        claim1.RecordTypeId = sRecType_RMA;
        claim1.StoreNumber__c = store.Id;
        claim1.Lease_Date__c = system.today();
        claim1.Problem_Type__c = 'Television';
        claim1.Problem_Description__c = 'Safety';
        claim1.Status__c = 'Approved';
        claim1.ValidSerialNumber__c = true;
        //cList.add(claim1);
        insert claim1;

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
        claim2.Status__c = 'Approved';
        claim2.ValidSerialNumber__c = true;
        //cList.add(claim2);
        insert claim2;

        claim2.Status__c = 'Draft';

        update claim2;

        delete claim2;
	}
}