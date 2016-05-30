@IsTest
public with sharing class ODM_Edit_Controller_Test {
    static testmethod void unitTest() {
        
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

        List<ODM_Partner__c> odmList = new List<ODM_Partner__c>();
        
        // build VASP/ODM relationship 1
        ODM_Partner__c odm1 = new ODM_Partner__c();
        odm1.VASP_Partner__c = acc1.id;
        odm1.ODM_Partner__c = acc2.id;
        odm1.Mark_Up_Percentage__c = 20;
        odmList.add(odm1);
        
        insert odmList;
        
        system.assertEquals(odm1.Mark_Up_Percentage__c, 20);

        test.StartTest();
        
        ApexPages.StandardController controller1 = new ApexPages.StandardController(odm1);
        ODM_Edit_Controller main1 = new ODM_Edit_Controller(controller1);
        odm1.Mark_Up_Percentage__c = NULL;
        odm1.Margin_Percentage__c = NULL;
        main1.save();
        
        ODM_Partner__c resultList1 = [SELECT Id, Mark_Up_Percentage__c, Margin_Percentage__c FROM ODM_Partner__c WHERE Id = :odm1.Id];
        system.assertEquals(resultList1.Mark_Up_Percentage__c, 20);
        
        ApexPages.StandardController controller2 = new ApexPages.StandardController(odm1);
        ODM_Edit_Controller main2 = new ODM_Edit_Controller(controller2);
        odm1.Mark_Up_Percentage__c = 40;
        odm1.Margin_Percentage__c = NULL;
        main2.save();
        
        ODM_Partner__c resultList2 = [SELECT Id, Mark_Up_Percentage__c, Margin_Percentage__c FROM ODM_Partner__c WHERE Id = :odm1.Id];
        system.assertEquals(resultList2.Mark_Up_Percentage__c, 40);
        
        ApexPages.StandardController controller3 = new ApexPages.StandardController(odm1);
        ODM_Edit_Controller main3 = new ODM_Edit_Controller(controller3);
        odm1.Margin_Percentage__c = 40;
        odm1.Mark_Up_Percentage__c = 40;
        main3.save();
        
        ODM_Partner__c resultList3 = [SELECT Id, Mark_Up_Percentage__c, Margin_Percentage__c FROM ODM_Partner__c WHERE Id = :odm1.Id];
        system.assertEquals(resultList3.Mark_Up_Percentage__c, 40);
        system.assertEquals(resultList3.Margin_Percentage__c, NULL);
        
        ApexPages.StandardController controller4 = new ApexPages.StandardController(odm1);
        ODM_Edit_Controller main4 = new ODM_Edit_Controller(controller4);
        odm1.Margin_Percentage__c = 40;
        odm1.Mark_Up_Percentage__c = NULL;
        main4.save();
        
        ODM_Partner__c resultList4 = [SELECT Id, Mark_Up_Percentage__c, Margin_Percentage__c FROM ODM_Partner__c WHERE Id = :odm1.Id];
        system.assertEquals(resultList4.Margin_Percentage__c, 40);
        system.assertEquals(resultList4.Mark_Up_Percentage__c, NULL);
        
        test.StopTest();
        
    }
}