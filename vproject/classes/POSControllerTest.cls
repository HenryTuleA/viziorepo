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
private class POSControllerTest {
    static testMethod void myUnitTest() {
        Account acc1 = new Account();
        acc1.Name = 'Name';
        acc1.Channel_Id__c = 'TECD01';
        insert acc1;
        
        Contact contact1 = new Contact();
        contact1.FirstName = 'Test';
        contact1.Lastname = 'Last';
        contact1.AccountId = acc1.Id;
        contact1.Email = 'test@test.com';
        insert contact1;
        
        
        List<Control_Number__c> cnList = new List<Control_Number__c>();
        Control_Number__c cn1 = new Control_Number__c();
        cn1.Control__c = '1';
        cn1.Account__c = acc1.Id;
        cn1.BSTC_Amount__c = 0;
        cn1.PPSTC_Amount__c = 200;
        cn1.Event_Start_Date__c = system.today();
        cn1.Event_End_Date__c = system.today();
        cn1.Price_Type__c = 'ED';
        cn1.SKU__c = 'E420-A0';
        cnList.add(cn1);
        
        Control_Number__c cn2 = new Control_Number__c();
        cn2.Control__c = '2';
        cn2.Account__c = acc1.Id;
        cn2.BSTC_Amount__c = 0;
        cn2.PPSTC_Amount__c = 200;
        cn2.Event_Start_Date__c = system.today();
        cn2.Event_End_Date__c = system.today();
        cn2.Price_Type__c = 'ED';
        cn2.SKU__c = 'E320-A0';
        cnList.add(cn2);
        
        insert cnList;
        
        Claim__c claim = new Claim__c();
        claim.Account__c = acc1.Id;
        claim.Claim_Name__c = 'test Claim';
        claim.Claim_Start_Date__c = Date.newInstance( 2014, 1, 1 );
        claim.Claim_End_Date__c = system.today();
        claim.Co_Op__c = '1';
        claim.status__c = 'Draft';
        insert claim;
        
        List<Claim_Item__c> ciList = new List<Claim_Item__c>();
        Claim_Item__c claimItem = new Claim_Item__c();
        claimItem.Control_Number__c = cn1.id;
        claimItem.Claim__c = claim.id;
        claimItem.Quantity_Claimed__c = 1;
        ciList.add(claimItem);
        
        Claim_Item__c claimItem1 = new Claim_Item__c();
        claimItem1.Control_Number__c = cn2.id;
        claimItem1.Claim__c = claim.id;
        claimItem1.Quantity_Claimed__c = 1;
        ciList.add(claimItem1);
        
        insert ciList;
        
        
        
        POS_Custom_Setting__c posReq = new POS_Custom_Setting__c();
        posReq.Username__c = 'WebService';
        posReq.URL__c = 'https://partnerapitest.vizio.com/Service/POSService.svc/GetWeeklyPosDataByChannel';
        posReq.Password__c = 'V!zio123';
        posReq.Name = 'Request';
        insert posReq;
        
        test.startTest();
        ApexPages.StandardController controller = new ApexPages.StandardController(claim);
        POSController main = new POSController(controller);
        
        main.getSetCon();
        main.getShowList();
        
        main.getShowList();
        main.next();
        main.getTotalPages();
        integer pnumber = main.pageNumber;
        Boolean bool = main.hasPage;
        bool = main.hasPrevious;
        bool = main.hasNext;
        main.previous();
        
        main.sortExpression = 'Model';
        main.sortDirection = 'ASC';
        main.clickLink();
        main.setSortDirection('ASC');
        main.getSortDirection();
        main.getSortDirection();
        main.setSortDirection('DESC');
        main.sortDirection = 'DESC';
        main.clickLink();
        
        main.sortExpression = 'Start Date';
        main.sortDirection = 'ASC';
        main.clickLink();
        main.getSortDirection();
        main.setSortDirection('ASC');
        main.sortDirection = 'DESC';
        main.getSortDirection();
        main.setSortDirection('DESC');
        main.clickLink();
        
        main.sortExpression = 'End Date';
        main.sortDirection = 'ASC';
        main.clickLink();
        main.getSortDirection();
        main.setSortDirection('ASC');
        main.sortDirection = 'DESC';
        main.getSortDirection();
        main.setSortDirection('DESC');
        main.clickLink();
        
        main.sortExpression = 'Sell Through';
        main.sortDirection = 'ASC';
        main.clickLink();
        main.getSortDirection();
        main.setSortDirection('ASC');
        main.sortDirection = 'DESC';
        main.getSortDirection();
        main.setSortDirection('DESC');
        main.clickLink();
        
        main.sortExpression = 'On Hand Quantity';
        main.sortDirection = 'ASC';
        main.clickLink();
        main.getSortDirection();
        main.setSortDirection('ASC');
        main.sortDirection = 'DESC';
        main.getSortDirection();
        main.setSortDirection('DESC');
        main.clickLink();
        
        
        system.assertEquals(main.getShowList().size(), 10);
        
        posReq.Username__c = 'WebService';
        posReq.URL__c = 'https://partnerapitest.error.com';
        posReq.Password__c = 'V!zio123';
        posReq.Name = 'Request';
        update posReq;

        ApexPages.StandardController controller1 = new ApexPages.StandardController(claim);
        POSController main1 = new POSController(controller1);
        
        main1.getSetCon();
        main1.getShowList();
        system.assertEquals(main1.getShowList().size(), 0);
        test.stopTest();
        
    }
    
}