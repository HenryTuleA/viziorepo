/**
 * Test class to test the class named Web2Case.cls
 *
 * @author		Xin Zhang
 * @version		1.0
 * @since		1.0
 */
 
@isTest (SeeAllData=false)
private class TestClassWeb2Case {
	
	/**
     * method to test the Web2Case no contact no attachment
     *
     * @param			None	  
     * @return			None
     * @since			1.0
     */
	static testMethod void myTestNoContact() { 
		
		Support_Setting__c getCaseContactOwner = new Support_Setting__c (Name = 'Web2CaseContactOwner', Value__c = '0051a000000HJgl');
    	insert getCaseContactOwner; 
    	
	    PageReference testWeb2CasePage = Page.Web2Case;
	    
    	Test.setCurrentPage(testWeb2CasePage);
    	ApexPages.currentPage().getParameters().put('language','en_CA'); 
    	Web2Case testWeb2Caseen_CA = new Web2Case();
    	testWeb2Caseen_CA.webToCase.Subject = 'Test';
    	testWeb2Caseen_CA.submit();
    	testWeb2Caseen_CA.webToCase.Description = 'Test';
    	testWeb2Caseen_CA.webToCase.Product_Model_Number__c = '123';
    	testWeb2Caseen_CA.caseContact.FirstName = 'Test';
    	testWeb2Caseen_CA.lastName = 'Web';
    	testWeb2Caseen_CA.submit();
    	testWeb2Caseen_CA.emailAddress = 'test@123.';
    	testWeb2Caseen_CA.caseContact.Phone = '1231231';
    	testWeb2Caseen_CA.submit();
    	testWeb2Caseen_CA.emailAddress = 'test@123.com';
    	testWeb2Caseen_CA.caseContact.Phone = '1231231';
    	testWeb2Caseen_CA.submit();
    	testWeb2Caseen_CA.caseContact.Phone = '1231231234';
    	testWeb2Caseen_CA.userAttachment.Name='test.txt' ;
    	testWeb2Caseen_CA.submit();
    	Test.setCurrentPage(testWeb2CasePage);
    	ApexPages.currentPage().getParameters().put('language','en_ca'); 
    	Web2Case testWeb2Caseen_ca1 = new Web2Case();
    	Test.setCurrentPage(testWeb2CasePage);
    	ApexPages.currentPage().getParameters().put('language','fr_ca'); 
    	Web2Case testWeb2Casefr_ca = new Web2Case();
    	Test.setCurrentPage(testWeb2CasePage);
    	ApexPages.currentPage().getParameters().put('language','fr_CA'); 
    	Web2Case testWeb2Casefr_CA1 = new Web2Case();
    	testWeb2Casefr_CA1.webToCase.Subject = 'Test';
    	testWeb2Casefr_CA1.submit();
    	testWeb2Casefr_CA1.webToCase.Description = 'Test';
    	testWeb2Casefr_CA1.webToCase.Product_Model_Number__c = '123';
    	testWeb2Casefr_CA1.caseContact.FirstName = 'Test';
    	testWeb2Casefr_CA1.lastName = 'Web';
    	testWeb2Casefr_CA1.submit();
    	testWeb2Casefr_CA1.emailAddress = 'test@123.';
    	testWeb2Casefr_CA1.caseContact.Phone = '1231231';
    	testWeb2Casefr_CA1.submit();
    	testWeb2Casefr_CA1.emailAddress = 'test@123.com';
    	testWeb2Casefr_CA1.caseContact.Phone = '1231231';
    	testWeb2Casefr_CA1.submit();
    	testWeb2Casefr_CA1.caseContact.Phone = '1231231234';
    	testWeb2Casefr_CA1.userAttachment.Name='test.txt' ;
    	testWeb2Casefr_CA1.submit();
    	Test.setCurrentPage(testWeb2CasePage);
    	ApexPages.currentPage().getParameters().put('language','es_MX'); 
    	Web2Case testWeb2Casees_MX = new Web2Case();
    	Test.setCurrentPage(testWeb2CasePage);
    	ApexPages.currentPage().getParameters().put('language','es_mx'); 
    	Web2Case testWeb2Casees_mx1 = new Web2Case();
    	testWeb2Casees_mx1.webToCase.Subject = 'Test';
    	testWeb2Casees_mx1.submit();
    	testWeb2Casees_mx1.webToCase.Description = 'Test';
    	testWeb2Casees_mx1.webToCase.Product_Model_Number__c = '123';
    	testWeb2Casees_mx1.caseContact.FirstName = 'Test';
    	testWeb2Casees_mx1.lastName = 'Web';
    	testWeb2Casees_mx1.submit();
    	testWeb2Casees_mx1.emailAddress = 'test@123.';
    	testWeb2Casees_mx1.caseContact.Phone = '1231231';
    	testWeb2Casees_mx1.submit();
    	testWeb2Casees_mx1.emailAddress = 'test@123.com';
    	testWeb2Casees_mx1.caseContact.Phone = '1231231';
    	testWeb2Casees_mx1.submit();
    	testWeb2Casees_mx1.caseContact.Phone = '1231231234';
    	testWeb2Casees_mx1.userAttachment.Name='test.txt' ;
    	testWeb2Casees_mx1.submit();
    	Test.setCurrentPage(testWeb2CasePage);
    	ApexPages.currentPage().getParameters().put('language','en_us'); 
    	Web2Case testWeb2Caseen_us = new Web2Case();
    	Test.setCurrentPage(testWeb2CasePage);
    	ApexPages.currentPage().getParameters().put('language','en_US'); 
    	Web2Case testWeb2Caseen_US1 = new Web2Case();
    	
    	
    	testWeb2Caseen_US1.webToCase.Subject = 'Test';
    	testWeb2Caseen_US1.submit();
    	testWeb2Caseen_US1.webToCase.Description = 'Test';
    	testWeb2Caseen_US1.webToCase.Product_Model_Number__c = '123';
    	testWeb2Caseen_US1.caseContact.FirstName = 'Test';
    	testWeb2Caseen_US1.lastName = 'Web';
    	testWeb2Caseen_US1.submit();
    	testWeb2Caseen_US1.emailAddress = 'test@123.';
    	testWeb2Caseen_US1.caseContact.Phone = '1231231';
    	testWeb2Caseen_US1.submit();
    	testWeb2Caseen_US1.emailAddress = 'test@123.com';
    	testWeb2Caseen_US1.caseContact.Phone = '1231231';
    	testWeb2Caseen_US1.submit();
    	testWeb2Caseen_US1.caseContact.Phone = '1231231234';
    	testWeb2Caseen_US1.submit();
    	
	}
	
	/**
     * method to test the Web2Case with contact with acceptable attachment has attach body
     *
     * @param			None	  
     * @return			None
     * @since			1.0
     */
	static testMethod void myTestWithContactAndAttachBody() { 
	    
	    Support_Setting__c getCaseContactOwner = new Support_Setting__c (Name = 'Web2CaseContactOwner', Value__c = '0051a000000HJgl');
    	insert getCaseContactOwner; 	    
	    Id contactRecordType = [Select Id From RecordType Where Name = 'Support' AND SobjectType = 'Contact'].get(0).Id;
	    Contact newContact = new Contact(RecordTypeId = contactRecordType, LastName = 'Tester', FirstName = 'Test', Email = 'test@123.com');
        insert newContact;
	    
    	PageReference testWeb2CasePage = Page.Web2Case;
    	Web2Case testWeb2Case = new Web2Case();
    	    	
    	Test.setCurrentPage(testWeb2CasePage);   	
    	testWeb2Case.webToCase.Subject = 'Test';
    	testWeb2Case.webToCase.Description = 'Test';
    	testWeb2Case.webToCase.Product_Model_Number__c = '123';
    	testWeb2Case.caseContact.FirstName = 'Test';
    	testWeb2Case.lastName = 'Tester';
    	testWeb2Case.emailAddress = 'test@123.com'; 
    	testWeb2Case.caseContact.Phone = '1231231234'; 
    	testWeb2Case.userAttachment.Name='test.zip' ; 
    	Blob bodyBlob=Blob.valueOf('Unit Test Attachment Body');
        testWeb2Case.userAttachment.Body=bodyBlob; 
        
        testWeb2Case.userAttachment2.Name='test.pdf' ;     	
        testWeb2Case.userAttachment2.Body=bodyBlob; 
        
        testWeb2Case.userAttachment3.Name='test1.zip' ;     	
        testWeb2Case.userAttachment3.Body=bodyBlob; 
        
        testWeb2Case.userAttachment4.Name='test2.zip' ;    	
        testWeb2Case.userAttachment4.Body=bodyBlob; 
        
        testWeb2Case.userAttachment5.Name='test3.zip' ;     	
        testWeb2Case.userAttachment5.Body=bodyBlob; 
         		
    	testWeb2Case.submit();   	
	}
	
	/**
     * method to test the Web2Case with contact with acceptable attachment doesn't have attach body
     *
     * @param			None	  
     * @return			None
     * @since			1.0
     */
	static testMethod void myTestWithContactNoAttachBody() { 
	    Support_Setting__c getCaseContactOwner = new Support_Setting__c (Name = 'Web2CaseContactOwner', Value__c = '0051a000000HJgl');
    	insert getCaseContactOwner; 	    
	    Id contactRecordType = [Select Id From RecordType Where Name = 'Support' AND SobjectType = 'Contact'].get(0).Id;
	    Contact newContact = new Contact(RecordTypeId = contactRecordType, LastName = 'Tester', FirstName = 'Test', Email = 'test@123.com');
        insert newContact;
	    
    	PageReference testWeb2CasePage = Page.Web2Case;
    	Web2Case testWeb2Case = new Web2Case();
    	    	
    	Test.setCurrentPage(testWeb2CasePage);
    	ApexPages.currentPage().getParameters().put('language','en_MX');
    	testWeb2Case.submit();
    	testWeb2Case.webToCase.Subject = 'Test';
    	testWeb2Case.webToCase.Description = 'Test';
    	testWeb2Case.webToCase.Product_Model_Number__c = '123';
    	testWeb2Case.caseContact.FirstName = 'Test';
    	testWeb2Case.lastName = 'Tester';
    	testWeb2Case.submit();
    	testWeb2Case.emailAddress = 'test@123.com'; 
    	testWeb2Case.caseContact.Phone = '123123';
    	testWeb2Case.submit(); 
    	testWeb2Case.caseContact.Phone = '1231231234';
    	testWeb2Case.userAttachment.Name='test.zip' ; 		
    	testWeb2Case.submit();   	
	}
	
	/**
     * method to test the Web2Case with contact with unacceptable attachment 
     *
     * @param			None	  
     * @return			None
     * @since			1.0
     */
	static testMethod void myTestWithWrongAttachType() { 
	    Support_Setting__c getCaseContactOwner = new Support_Setting__c (Name = 'Web2CaseContactOwner', Value__c = '0051a000000HJgl');
    	insert getCaseContactOwner; 	    
	    Id contactRecordType = [Select Id From RecordType Where Name = 'Support' AND SobjectType = 'Contact'].get(0).Id;
	    Contact newContact = new Contact(RecordTypeId = contactRecordType, LastName = 'Tester', FirstName = 'Test', Email = 'test@123.com');
        insert newContact;
	    
    	PageReference testWeb2CasePage = Page.Web2Case;
    	Web2Case testWeb2Case = new Web2Case();
    	    	
    	Test.setCurrentPage(testWeb2CasePage);
    	testWeb2Case.submit(); 
    	testWeb2Case.webToCase.Subject = 'Test';
    	testWeb2Case.webToCase.Description = 'Test';
    	testWeb2Case.webToCase.Product_Model_Number__c = '123';
    	testWeb2Case.caseContact.FirstName = 'Test';
    	testWeb2Case.lastName = 'Tester';
    	testWeb2Case.emailAddress = 'test@123.com';  
    	testWeb2Case.caseContact.Phone = '1231234';
    	testWeb2Case.userAttachment.Name='test.txt' ;
    	testWeb2Case.submit();  
    	testWeb2Case.caseContact.Phone = '1231231234a';
    	testWeb2Case.submit(); 
    	testWeb2Case.caseContact.Phone = '1231231234';
    	testWeb2Case.submit(); 
    	 	
	}
}