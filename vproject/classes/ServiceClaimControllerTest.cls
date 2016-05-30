@IsTest public with sharing class ServiceClaimControllerTest {

     @isTest static void testServiceClaimController(){
        Service_Claim__c sc= new Service_Claim__c();
        sc.Serial_No__c='LAQKMBBN3203164';
    
        insert(sc);
        System.debug(sc.Serial_No__c);
        PageReference pref = Page.ServiceClaim_Edit;
        
        String wcrt = [SELECT Id from RecordType WHERE DeveloperName = 'Warranty_Claim'].Id;
        
        Test.setCurrentPage(pref);
        //ApexPages.currentPage().getParameters().put('RecordType', '012q00000008wVm');
        ApexPages.currentPage().getParameters().put('RecordType', wcrt);
        
        ApexPages.StandardController apsc = new ApexPages.StandardController(sc);
        ServiceClaimController scc= new ServiceClaimController(apsc);
        String testData='{"GetSerialWithRegistrationsResult":[{"Address":"Po box 548","AssetNotes":"","City":"Point Roberts","Country":"US",'+
        '"CustName":"Costco Sumner Depot - Dry","DCDate":"20120928","DCNo":"8500336377","Email":"rhterf@hotmail.com","FirstName":"Rick",'+
        '"IsStolen":0,"ItemNo":"10240301022","LastName":"Hoole","MfgPartNo":"M470SL","Model":"M470SL","ODM":"AMTRAN","PONo":"001710921711",'+
        '"Phone":"3609454631","PostalCode":"98281","PurchaseDate":"09/28/2012","PurchasePrice":"627.89","SKUGroup":"M470SL",'+
        '"SalesOrderNo":"5100315421","SerialNo":"LAQKMBBN3203164","ShipDate":null,"ShipTo":"9CWDC07","SoldTo":"COSTWH","State":"WA"}]}';
        
        List<Object> lstObj= ServiceClaimController.GetJsonStringResult(testData);
        System.assertEquals(1,lstObj.size());
        
         for (Object obj : lstObj) {
                Map<String, Object> objAttributes = (Map<String, Object>)obj;
                for (String attributeName : objAttributes.keyset()) {
                    Object s= objAttributes.get(attributeName);
                    // assisgn data to fields
                    scc.setVal(attributeName,s);
                }
            }
            
        System.assertEquals(sc.Serial_No__c,'LAQKMBBN3203164');
        System.assertEquals(sc.Customer_City__c,'Point Roberts');
        System.assertEquals(sc.Customer_Address__c,'Po box 548');
        System.assertEquals(sc.Customer_Country__c,'US');
        System.assertEquals(sc.Customer_Email__c,'rhterf@hotmail.com');
        System.assertEquals(sc.Customer_First_Name__c,'Rick');
        System.assertEquals(sc.Customer_Last_Name__c,'Hoole');
        System.assertEquals(sc.Customer_State__c,'WA');
        System.assertEquals(sc.Ship_Date__c,null);
        System.assertEquals(sc.Purchased_Date__c,date.parse('09/28/2012'));
        System.assertEquals(sc.Sold_To__c,'COSTWH');
         
        
         scc.clearVal();
          System.assertEquals(sc.Serial_No__c,'LAQKMBBN3203164');
          System.assertEquals(sc.ODM_Partner__c,Null);
          System.assertEquals(sc.Customer_Address__c,Null);
          System.assertEquals(sc.Customer_City__c,Null);
          System.assertEquals(sc.Customer_Country__c,Null);
          System.assertEquals(sc.Customer_First_Name__c,Null);
          System.assertEquals(sc.Customer_Last_Name__c,Null);
          System.assertEquals(sc.Customer_State__c,Null);
          System.assertEquals(sc.Customer_Email__c,Null);
          System.assertEquals(sc.Ship_Date__c,Null);
          System.assertEquals(sc.Purchased_Date__c,Null);
          System.assertEquals(sc.Sales_Order__c,Null);
          System.assertEquals(sc.Sold_To__c,Null);
          System.assertEquals(sc.PO_Number__c,Null);
          System.assertEquals(sc.Unit_Price__c,Null);
          System.assertEquals(sc.Model_No__c,Null);
          
         boolean result= scc.validateFields();
          System.assertEquals(false,result);
        
    }
    
   
    
    
    @isTest static void testCallout(){
         Test.setMock(HttpCalloutMock.class, new RestMock());
        //Test.startTest();
        // Invoke web service
        //Test.stopTest();
        // Assertions
        String url='https://partnerapitest.vizio.com/Service/SeriaNoService.svc/GetSerialWithRegistrations';
        
        HttpResponse res= ServiceClaimController.CallWebService(url,'LAQKMBBN3203164','WebService','V!zio123');
        
        String contentType = res.getHeader('Content-Type');
        System.assert(contentType == 'application/json');
        String actualValue = res.getBody();
        System.debug(actualValue);
        String expectedValue = '{"foo":"bar"}';
        System.assertEquals(actualValue, expectedValue);
        System.assertEquals(200, res.getStatusCode());
    }

    static testmethod void recordTest(){

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
      cList.add(claim1);

      // set up RMA 2
      Service_Claim__c claim2 = new Service_Claim__c();
      claim2.Account__c = acc1.Id;
      claim2.Contact__c = contact1.Id;
      claim2.ODM_Partner__c = ap1.Id;
      claim2.Serial_No__c = 'LAQKMBBN3203164';
      claim2.Model_No__c = prod1.Id;
      claim2.RecordTypeId = sRecType_RMA;
      claim2.StoreNumber__c = store.Id;
      claim2.Lease_Date__c = system.today();
      claim2.Problem_Type__c = 'Television';
      claim2.Problem_Description__c = 'Safety';
      claim2.Status__c = 'Approved';
      cList.add(claim2);

      // set up RMA 3
      Service_Claim__c claim3 = new Service_Claim__c();
      claim3.Account__c = acc1.Id;
      claim3.Contact__c = contact1.Id;
      claim3.ODM_Partner__c = ap1.Id;
      claim3.Serial_No__c = 'LAQKMBBN3203164';
      claim3.Model_No__c = prod1.Id;
      claim3.RecordTypeId = sRecType_RMA;
      claim3.StoreNumber__c = store.Id;
      claim3.Lease_Date__c = system.today();
      claim3.Problem_Type__c = 'Television';
      claim3.Problem_Description__c = 'Safety';
      claim3.Status__c = 'Rejected';
      cList.add(claim3);

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
        ServiceClaimController main1 = new ServiceClaimController(controller);
        claim1.Problem_Description__c = 'Inputs/Outputs';
        main1.save();

        ApexPages.StandardController controller2 = new ApexPages.StandardController(claim2);
        ServiceClaimController main2 = new ServiceClaimController(controller2);
        claim2.Serial_No__c = NULL;
        claim2.Problem_Type__c = NULL;
        claim2.Problem_Description__c = NULL;
        main2.save();

        ApexPages.StandardController controller3 = new ApexPages.StandardController(claim3);
        ServiceClaimController main3 = new ServiceClaimController(controller3);
        //claim3.Serial_No__c = NULL;
        claim3.Problem_Type__c = NULL;
        claim3.Problem_Description__c = NULL;
        update claim3;
        main3.save();
        main3.deleteCancel();

      }
      test.stopTest();

      Service_Claim__c resultClaim = [SELECT Id, Problem_Description__c FROM Service_Claim__c WHERE Id =: Claim1.Id];
      system.assertEquals(resultClaim.Problem_Description__c, 'Inputs/Outputs');
      Service_Claim__c resultClaim2 = [SELECT Id, Serial_No__c, Problem_Type__c, Problem_Description__c FROM Service_Claim__c WHERE Id =: Claim2.Id];
      system.assertEquals(resultClaim2.Serial_No__c, 'LAQKMBBN3203164');
      system.assertEquals(resultClaim2.Problem_Type__c, 'Television');
      system.assertEquals(resultClaim2.Problem_Description__c, 'Safety');

    }
    
    private class RestMock implements HttpCalloutMock {
       
        public HTTPResponse respond(HTTPRequest req) {
            // Can assert that the request is correct here
            // Generate a typical response
            String fullJson = '{"foo":"bar"}';
            HTTPResponse res = new HTTPResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setBody(fullJson);
            res.setStatusCode(200);
            return res;
        }
    }
}