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
private class CloneControllerTest {

	static testMethod void cloneTest(){
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
        insert claim;
        
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
        cnList.add(cn2);
        
        Control_Number__c cn5 = new Control_Number__c();
        cn5.Control__c = '5';
        cn5.Account__c = acc1.Id;
        cn5.BSTC_Amount__c = 0;
        cn5.PPSTC_Amount__c = 0;
        cn5.Event_Start_Date__c = system.today();
        cn5.Event_End_Date__c = system.today();
        cn5.Price_Type__c = 'STC';
        cn5.SKU__c = 'test';
        cnList.add(cn5);
        
        insert cnList;
        
        Claim_Item__c ci1 = new Claim_Item__c();
        //ci1.Claim_Type_del__c = 'STC';
        ci1.Control_Number__c = cnList[0].id;
        ci1.Claim__c = claim.id;
        ci1.Quantity_Claimed__c = 1;
        insert ci1;
        
		Test.startTest();
		CloneController cc = new CloneController(new ApexPages.StandardController(claim));
		cc.claimClone();
			
		cc.cancel();
		List<Claim__c> ccList = [SELECT Id, Account__c FROM Claim__c];
		List<Claim_Item__c> itemList = [SELECT id FROM Claim_Item__c];
		system.assertEquals(itemList.size(), 1);
		system.assertEquals(ccList.size(),1);
	
		cc.save();
		ccList = [SELECT Id, Account__c FROM Claim__c];
		itemList = [SELECT id FROM Claim_Item__c];
		system.assertEquals(itemList.size(), 2);
		system.assertEquals(ccList.size(), 2);
		
		Test.stopTest();
	}
}