/**
 * Test class to test the VizioSupport_USPSCreateController and VizioSupport_USPSEditController
 *
 * @author		Stela Zhang
 * @version		1.0
 * @since		1.0
 */
 
@isTest (SeeAllData=false)
private class TestClassCreateEditCustomer {
	
	/**
     * method to test the VizioSupport_CTIAPICall.cls: no match, one match, multi-match
     *
     * @param			None	  
     * @return			None
     * @since			1.0 
     */ 
	static testMethod void testCTIAPICallMatch() {
		
        Id contactRecotType = [Select Id From RecordType Where Name = 'Support' AND SobjectType = 'Contact'].get(0).Id;
        
        Contact insertContact1 = new Contact(LastName = 'Test1', Phone = '1112223333', OtherPhone = '3332221111', RecordTypeId = contactRecotType);
        insert insertContact1;
        
        Contact insertContact2 = new Contact(LastName = 'Test2', Phone = '1231231122', OtherPhone = '3332221111', RecordTypeId = contactRecotType);
        insert insertContact2;
        
        PageReference testCTIAPICall = Page.VizioSupport_CTIAPICall;
	    
	    // One match
    	Test.setCurrentPage(testCTIAPICall);
    	ApexPages.currentPage().getParameters().put('Con10','1112223333');  
    	VizioSupport_CTIAPICall testCTIAPICallOneMatch = new VizioSupport_CTIAPICall();
        
        // Two matches
        Test.setCurrentPage(testCTIAPICall);
    	ApexPages.currentPage().getParameters().put('Con10','3332221111'); 
    	VizioSupport_CTIAPICall testCTIAPICallTwoMatch = new VizioSupport_CTIAPICall();
    	
    	// No match
    	Test.setCurrentPage(testCTIAPICall);
    	ApexPages.currentPage().getParameters().put('Con10','111122223'); 
    	VizioSupport_CTIAPICall testCTIAPICallNoMatch = new VizioSupport_CTIAPICall();
           
	}
	
	
	/**
     * method to test the VizioSupport_CreateController.cls
     *
     * @param			None	  
     * @return			None
     * @since			1.0
     */ 
	static testMethod void testCreateCustomer() {
		
		USPS_User__c userName = new USPS_User__c(Name = 'USPSUserIDCode', UserId__c = '240UCINN1790');
		Test.setMock(HttpCalloutMock.class, new SearchMockHttpResponse());
		Id contactRecotType = [Select Id From RecordType Where Name = 'Support' AND SobjectType = 'Contact'].get(0).Id;
        
        Contact insertContact1 = new Contact(LastName = 'Test1', Phone = '1112223333', OtherPhone = '3332221111', RecordTypeId = contactRecotType);
        insert insertContact1;
        
        Contact insertContact2 = new Contact(LastName = 'Test2', Phone = '5556667777', Email='Test@123.com', RecordTypeId = contactRecotType);
        insert insertContact2;
        
        WhitePagesSearch__c wpage = new WhitePagesSearch__c (Name = 'whitepagesfield', zip__c = 'con19zip', street__c = 'con19street', state__c = 'con19state',
                                                             recordtype__c = '0121a0000001qoz', phone__c = 'con10', lastname__c = 'name_lastcon2',
                                                             firstname__c = 'name_firstcon2', city__c = 'con19city', 
                                                             apiurl__c = 'http://proapi.whitepages.com/reverse_phone/1.0?outputtype=json&api_key=86453bd784ec9750718a00d22a001c52&phone_number=');
        
        insert wpage;
                    
        PageReference createCustomer  = Page.VizioSupport_USPSCreateCustomer;	    
    	Test.setCurrentPage(createCustomer);
    	ApexPages.currentPage().getParameters().put('Con10','4166911562'); 
    	ApexPages.Standardcontroller stdContact = new ApexPages.Standardcontroller(insertContact1);   
    	
       
    	// No match
    	VizioSupport_USPSCreateController testCreate1 = new VizioSupport_USPSCreateController(stdContact);
    	testCreate1.wp = wpage;
    	testCreate1.crtContact();
        String data = testCreate1.search('4166911562');   
        testCreate1.contactMoreInfo.LastName = 'Test1';
        testCreate1.contactMoreInfo.OtherPhone = '9498887777';
          
        testCreate1.FindRetail();
        testCreate1.Cancel(); 
        
        Test.setCurrentPage(createCustomer);
        testCreate1 = new VizioSupport_USPSCreateController(stdContact);
        testCreate1.contactMoreInfo.LastName = 'Test1';     
        testCreate1.Cancel(); 
        
        Test.setCurrentPage(createCustomer);
        ApexPages.currentPage().getParameters().put('Con10','9497897897'); 
    	testCreate1 = new VizioSupport_USPSCreateController(stdContact);  
        testCreate1.contactMoreInfo.LastName = 'Test3';
        testCreate1.contactMoreInfo.OtherPhone = '9498887777';
        testCreate1.contactMoreInfo.MailingCity = 'Irvine';
        testCreate1.contactMoreInfo.MailingStreet = '17300 redhill';
        testCreate1.contactMoreInfo.MailingPostalCode = '92614';
        testCreate1.contactMoreInfo.MailingStateCode = 'CA';
        
        testCreate1.FindRetail();
            
     
        Test.setCurrentPage(createCustomer);
        ApexPages.currentPage().getParameters().put('Con10','9497897897'); 
    	testCreate1 = new VizioSupport_USPSCreateController(stdContact);
        testCreate1.contactMoreInfo.LastName = 'Test3';
        testCreate1.contactMoreInfo.OtherPhone = '9498887777';
        testCreate1.contactMoreInfo.MailingCity = 'Irvine';
        testCreate1.contactMoreInfo.MailingStreet = '17300 redhill';
        testCreate1.contactMoreInfo.MailingPostalCode = '92614';
        testCreate1.contactMoreInfo.MailingStateCode = 'CA'; 
        testCreate1.uspsUserIDCode = userName.UserId__c;
        testCreate1.validate();         
        testCreate1.Save(); 
        
        
        // Has match open from contact Detail page    	
        Test.setCurrentPage(createCustomer);
        ApexPages.currentPage().getParameters().put('Con10','9497897897'); 
    	testCreate1 = new VizioSupport_USPSCreateController(stdContact);
    	testCreate1.contactMoreInfo.LastName = 'Test4';
        testCreate1.contactMoreInfo.OtherPhone = '9498887777';
        testCreate1.contactMoreInfo.MailingCity = 'Irvine';
        testCreate1.contactMoreInfo.MailingStreet = '17300 redhill';
        testCreate1.contactMoreInfo.MailingPostalCode = '92614';
        testCreate1.contactMoreInfo.MailingStateCode = 'CA';
        testCreate1.contactMoreInfo.Email='Test@123.com';
        testCreate1.crtContact();
        testCreate1.uspsUserIDCode = userName.UserId__c;
        testCreate1.validate();      
        testCreate1.Save();  

	}
	
	/**
     * method to test the VizioSupport_EditController.cls
     *
     * @param			None	  
     * @return			None
     * @since			1.0
     */ 
	static testMethod void testEditCustomer() {
		
		USPS_User__c userName = new USPS_User__c(Name = 'USPSUserIDCode', UserId__c = '240UCINN1790');
		Id contactRecotType = [Select Id From RecordType Where Name = 'Support' AND SobjectType = 'Contact'].get(0).Id;
        
        Contact insertContact1 = new Contact(LastName = 'Test1', Phone = '1112223333', OtherPhone = '3332221111',  RecordTypeId = contactRecotType);
        insert insertContact1;
        
        Contact insertContact2 = new Contact(LastName = 'Test2', Phone = '5556667777', Email='Test@123.com', RecordTypeId = contactRecotType);
        insert insertContact2;
        
                    
        PageReference editCustomer  = Page.VizioSupport_USPSEditCustomer;	    
    	Test.setCurrentPage(editCustomer);
    	ApexPages.currentPage().getParameters().put('Con10','9497897897'); 
    	ApexPages.Standardcontroller stdContact = new ApexPages.Standardcontroller(insertContact1);   
    	
    	// No match open from contact Detail page
    	VizioSupport_USPSEditController testEdit1 = new VizioSupport_USPSEditController(stdContact);
        testEdit1.Cancel(); 
    
        Test.setCurrentPage(editCustomer);
        ApexPages.currentPage().getParameters().put('Con10','9497897897'); 
    	testEdit1 = new VizioSupport_USPSEditController(stdContact);
        testEdit1.contactMoreInfo.OtherPhone = '9498887777';
        testEdit1.contactMoreInfo.MailingCity = 'Irvine';
        testEdit1.contactMoreInfo.MailingStreet = '17300 redhill';
        testEdit1.contactMoreInfo.MailingPostalCode = '92614';
        testEdit1.contactMoreInfo.MailingStateCode = 'CA';
        testEdit1.uspsUserIDCode = userName.UserId__c;
        testEdit1.validate();      
        testEdit1.Save(); 
        
        // No match open from Create Service Request page
        Test.setCurrentPage(editCustomer);
    	ApexPages.currentPage().getParameters().put('Con10','9497897897'); 
    	ApexPages.currentPage().getParameters().put('Open','CreateSR'); 
    	testEdit1 = new VizioSupport_USPSEditController(stdContact); 
    	testEdit1.Cancel(); 
    	
    	Test.setCurrentPage(editCustomer);
        ApexPages.currentPage().getParameters().put('Con10','9497897897'); 
        ApexPages.currentPage().getParameters().put('Open','CreateSR'); 
    	testEdit1 = new VizioSupport_USPSEditController(stdContact); 
    	testEdit1.Save(); 
    	
    	// Has match open from contact Detail page
    	
        Test.setCurrentPage(editCustomer);
        ApexPages.currentPage().getParameters().put('Con10','9497897897'); 
    	testEdit1 = new VizioSupport_USPSEditController(stdContact);
        testEdit1.contactMoreInfo.OtherPhone = '9498887777';
        testEdit1.contactMoreInfo.MailingCity = 'Irvine';
        testEdit1.contactMoreInfo.MailingStreet = '17300 redhill';
        testEdit1.contactMoreInfo.MailingPostalCode = '92614';
        testEdit1.contactMoreInfo.MailingStateCode = 'CA';
        testEdit1.contactMoreInfo.Email='Test@123.com';
        testEdit1.uspsUserIDCode = userName.UserId__c;
        testEdit1.validate();      
        testEdit1.Save(); 
           
	}
}