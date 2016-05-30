/**
 * Test class to test the class named SafetyNotice
 *
 * @author		Xin Zhang
 * @version		1.0
 * @since		1.0
 */
 
@isTest (SeeAllData=false)
private class TestclassSafetyNotice {
    
    /**
     * method to test the SafetyNotice
     *
     * @param			None	  
     * @return			None
     * @since			1.0
     */
    static testMethod void myTestSafetyNoticeNoContact() {  
    	   	
        Account newAccount = new Account(Name='test');
        insert newAccount;
        
        Product2 newProduct = new Product2(Name='E60', ProductCode='E60' );
        insert newProduct;
             
        Asset newAsset1 = new Asset(Name='LATAPSAQ1300563', Status=null, Product2Id=newProduct.Id, AccountId=newAccount.Id, SerialNumber='LATAPSAQ1300563');
        insert newAsset1;
        Asset newAsset2 = new Asset(Name='LATAPSAQ1300566', Status='Registered', Product2Id=newProduct.Id, AccountId=newAccount.Id, SerialNumber='LATAPSAQ1300566');
        insert newAsset2;
        
    	PageReference testSafetyNotice = Page.SafetyNotice;
	    
	    /* language part */
    	Test.setCurrentPage(testSafetyNotice);
    	ApexPages.currentPage().getParameters().put('language','en_CA'); 
    	SafetyNotice testeen_CA = new SafetyNotice();
    	Test.setCurrentPage(testSafetyNotice);
    	ApexPages.currentPage().getParameters().put('language','en_ca'); 
    	SafetyNotice testen_ca1 = new SafetyNotice();
    	Test.setCurrentPage(testSafetyNotice);
    	ApexPages.currentPage().getParameters().put('language','fr_ca'); 
    	SafetyNotice testfr_ca = new SafetyNotice();
    	Test.setCurrentPage(testSafetyNotice);
    	ApexPages.currentPage().getParameters().put('language','fr_CA'); 
    	SafetyNotice testfr_CA1 = new SafetyNotice();
    	Test.setCurrentPage(testSafetyNotice);
    	ApexPages.currentPage().getParameters().put('language','es_MX'); 
    	SafetyNotice testes_MX = new SafetyNotice();
    	Test.setCurrentPage(testSafetyNotice);
    	ApexPages.currentPage().getParameters().put('language','es_mx'); 
    	SafetyNotice testes_mx1 = new SafetyNotice();
    	Test.setCurrentPage(testSafetyNotice);
    	ApexPages.currentPage().getParameters().put('language','en_us'); 
    	SafetyNotice testen_us = new SafetyNotice();
    	Test.setCurrentPage(testSafetyNotice);
    	ApexPages.currentPage().getParameters().put('language','en_US'); 
    	SafetyNotice testen_US1 = new SafetyNotice();
    	Test.setCurrentPage(testSafetyNotice);
    	ApexPages.currentPage().getParameters().put('language','ee_US'); 
    	SafetyNotice testWrong = new SafetyNotice();
    	
    	/* No contact */
    	Test.setCurrentPage(testSafetyNotice);  
    	ApexPages.currentPage().getParameters().put('serial','LATAPSAQ1300563'); 
    	SafetyNotice SafetyNoticeCheck = new SafetyNotice();
    	SafetyNoticeCheck.firstName = 'test';
    	SafetyNoticeCheck.lastName = 'TEST';
    	SafetyNoticeCheck.phone = '1231231234';
    	SafetyNoticeCheck.email = 'test@123.com';
    	SafetyNoticeCheck.address = '17310Red';
    	SafetyNoticeCheck.address2 = 'Hills';
    	SafetyNoticeCheck.city = 'Irvin';
    	SafetyNoticeCheck.state='CA';
    	SafetyNoticeCheck.zip ='91414';
    	SafetyNoticeCheck.submit();
    	
    	/* wrong state */
    /*	Test.setCurrentPage(testSafetyNotice);  
    	ApexPages.currentPage().getParameters().put('serial','LATAPSAQ1300563'); 
    	SafetyNotice SafetyNoticeCheckState = new SafetyNotice();
    	SafetyNoticeCheckState.firstName = 'test';
    	SafetyNoticeCheckState.lastName = 'TEST';
    	SafetyNoticeCheckState.phone = '1231231234';
    	SafetyNoticeCheckState.email = 'test@123.com';
    	SafetyNoticeCheckState.address = '17310Red';
    	SafetyNoticeCheckState.address2 = 'Hills';
    	SafetyNoticeCheckState.city = 'Irvin';
    	SafetyNoticeCheckState.state='QQ';
    	SafetyNoticeCheckState.zip ='91414';
    	SafetyNoticeCheckState.submit();*/
	     
    } 
    
    static testMethod void myTestSafetyNoticeWithContact() {  
    	
        Account newAccount = new Account(Name='test');
        insert newAccount;
        
        Product2 newProduct = new Product2(Name='E60', ProductCode='E60' );
        insert newProduct;
             
        Asset newAsset1 = new Asset(Name='LATAPSAQ1300563', Status=null, Product2Id=newProduct.Id, AccountId=newAccount.Id, SerialNumber='LATAPSAQ1300563');
        insert newAsset1;
        Asset newAsset2 = new Asset(Name='LATAPSAQ1300566', Status='Registered', Product2Id=newProduct.Id, AccountId=newAccount.Id, SerialNumber='LATAPSAQ1300566');
        insert newAsset2;
        
         Id contactRecordType = [Select Id From RecordType Where Name = 'Support' AND SobjectType = 'Contact'].get(0).Id;
        Contact newContact = new Contact(RecordTypeId = contactRecordType,LastName = 'Tester', FirstName = 'Test', Email = 'test@123.com');
        insert newContact;
        
    	PageReference testSafetyNotice = Page.SafetyNotice;
    	
    	/* With contact */
    	Test.setCurrentPage(testSafetyNotice);  
    	ApexPages.currentPage().getParameters().put('serial','LATAPSAQ1300563'); 
    	SafetyNotice SafetyNoticeCheck = new SafetyNotice();
    	SafetyNoticeCheck.firstName = 'test';
    	SafetyNoticeCheck.lastName = 'TEST';
    	SafetyNoticeCheck.phone = '1231231234';
    	SafetyNoticeCheck.email = 'test@123.com';
    	SafetyNoticeCheck.address = '17310Red';
    	SafetyNoticeCheck.address2 = 'Hills';
    	SafetyNoticeCheck.city = 'Irvin';
    	SafetyNoticeCheck.state='CA';
    	SafetyNoticeCheck.zip ='91414';
    	SafetyNoticeCheck.submit();	
	     
    } 
}