/**
 * Test class to test the VizioSupport_ServiceRequestList 
 * @author		Stela Zhang
 * @version		1.0
 * @since		1.0
 */
 
@isTest (SeeAllData=false)
private class TestClassServiceRequestList {
	/**
     * method to test the view SR list case status != Closed
     *
     * @param			None	  
     * @return			None 
     * @since			1.0
     */  
	static testMethod void testSRList() { 
		Account newAccount = new Account(Name = 'Testing');
		insert newAccount;
		
		Id contactRecotType = [Select Id From RecordType Where Name = 'Support' AND SobjectType = 'Contact'].get(0).Id;        
        Contact customer = new Contact(LastName = 'Customer', RecordTypeId = contactRecotType, MailingCountryCode = 'US', MailingStateCode = 'CA', AccountId = newAccount.Id);
        insert customer;
        
        Id contactRecotTypeSP = [Select Id From RecordType Where Name = 'Service Provider' AND SobjectType = 'Contact'].get(0).Id;       
        Contact serviceP = new Contact(LastName = 'ServiceP', RecordTypeId = contactRecotTypeSP, MailingCountryCode = 'US', MailingStateCode = 'CA');
        insert serviceP;
        
        Product2 newProduct = new Product2(Name = 'M60', SKU__c ='12312312312', SKUDesc__c = 'TV');
        insert newProduct;
        
        Asset newAsset = new Asset(Name = 'AAYWPLBP123456', SerialNumber = 'AAYWPLBP123456', Product2Id = newProduct.Id, ContactId = customer.Id);
        insert newAsset;
        
        Case newCase = new Case(AssetId = newAsset.Id, ContactId = customer.Id); 
        insert newCase;
        
        Error_Code__c errorCode = new Error_Code__c(Name = 'A71', Error_Category__c = 'TV', Description__c = 'No Audio');
        insert errorCode;
        
        Authorized_SP_for_SRtypenSKU__c autoSP= new Authorized_SP_for_SRtypenSKU__c(SKU__c ='12312312312', ProductId__c = newProduct.Id, ServiceProviderId__c = serviceP.Id );
        insert autoSP;
        
        Authorized_SRtype_for_SKU__c autoSRType = new Authorized_SRtype_for_SKU__c(SKU__c ='12312312312', ProductId__c = newProduct.Id, SRType__c = 'AR');
        insert autoSRType;
        
        Service_Request__c newSR = new Service_Request__c(AuthSRtype__c = autoSRType.Id, Case__c = newCase.Id, Error_Code__c = errorCode.Id, Service_Provider__c = autoSP.Id);
        insert newSR;
        
        PageReference srList  = Page.VizioSupport_ServiceRequestList;	    
    	 
    	// Open Case
    	Test.setCurrentPage(srList);
    	ApexPages.currentPage().getParameters().put('Id',newCase.Id);
    	ApexPages.Standardcontroller stdCase = new ApexPages.Standardcontroller(newCase);   
    	VizioSupport_ServiceRequestList testSRList = new VizioSupport_ServiceRequestList(stdCase);
    	testSRList.getRelatedSR();
    	testSRList.sortExpression = null;
    	testSRList.getSortDirection();
        testSRList.sortExpression ='Name';
        testSRList.setSortDirection('DESC');
    	
    	testSRList.getSortDirection();
    	testSRList.sortExpression ='Name';
    	testSRList.setSortDirection('ASC');
    	testSRList.getSortDirection(); 	
    	testSRList.first();
    	testSRList.last();
    	Integer pageNumber = testSRList.pageNumber;
    	Integer totalNumber = testSRList.totalNumber;
    	Boolean hasNext = testSRList.hasNext;
    	Boolean hasPrevious = testSRList.hasPrevious;  	
    	testSRList.next();
    	testSRList.previous();
    	testSRList.clickToSort();
  
	}

	
	/**
     * method to test the view SR list case Purchase location = canada, customer location = canada
     *
     * @param			None	  
     * @return			None
     * @since			1.0
     */ 
	static testMethod void testSRListCA() {
		Account newAccount = new Account(Name = 'Testing');
		insert newAccount;
		
		Id contactRecotType = [Select Id From RecordType Where Name = 'Support' AND SobjectType = 'Contact'].get(0).Id;        
        Contact customer = new Contact(LastName = 'Customer', RecordTypeId = contactRecotType, MailingCountryCode = 'CA', AccountId = newAccount.Id);
        insert customer;
        
        Id contactRecotTypeSP = [Select Id From RecordType Where Name = 'Service Provider' AND SobjectType = 'Contact'].get(0).Id;       
        Contact serviceP = new Contact(LastName = 'ServiceP', RecordTypeId = contactRecotTypeSP, MailingCountryCode = 'US', MailingStateCode = 'CA');
        insert serviceP;
        
        Product2 newProduct = new Product2(Name = 'M60', SKU__c ='12312312312', SKUDesc__c = 'TV');
        insert newProduct;
        
        Asset newAsset = new Asset(Name = 'AAYWPLBP123456', SerialNumber = 'AAYWPLBP123456', Product2Id = newProduct.Id, ContactId = customer.Id, Purchase_Location__c = 'Best Buy Canada');
        insert newAsset;
        
        Case newCase = new Case(AssetId = newAsset.Id, ContactId = customer.Id);
        insert newCase;
        
        Error_Code__c errorCode = new Error_Code__c(Name = 'A71', Error_Category__c = 'TV', Description__c = 'No Audio');
        insert errorCode;
        
        Authorized_SP_for_SRtypenSKU__c autoSP= new Authorized_SP_for_SRtypenSKU__c(SKU__c ='12312312312', ProductId__c = newProduct.Id, ServiceProviderId__c = serviceP.Id );
        insert autoSP;
        
        Authorized_SRtype_for_SKU__c autoSRType = new Authorized_SRtype_for_SKU__c(SKU__c ='12312312312', ProductId__c = newProduct.Id, SRType__c = 'AR');
        insert autoSRType;
        
        Service_Request__c newSR = new Service_Request__c(AuthSRtype__c = autoSRType.Id, Case__c = newCase.Id, Error_Code__c = errorCode.Id, Service_Provider__c = autoSP.Id);
        insert newSR;
        
        PageReference srList  = Page.VizioSupport_ServiceRequestList;	    
    	
    	// Open Case
    	Test.setCurrentPage(srList);
    	ApexPages.currentPage().getParameters().put('Id',newCase.Id);
    	ApexPages.Standardcontroller stdCase = new ApexPages.Standardcontroller(newCase);   
    	VizioSupport_ServiceRequestList testSRList = new VizioSupport_ServiceRequestList(stdCase);
    	testSRList.getRelatedSR();
    	testSRList.sortExpression = null;
    	testSRList.getSortDirection();
        testSRList.sortExpression ='Name';
        testSRList.setSortDirection('DESC');
    	
    	testSRList.getSortDirection();
    	testSRList.sortExpression ='Name';
    	testSRList.setSortDirection('ASC');
    	testSRList.getSortDirection(); 	
    	testSRList.first();
    	testSRList.last();
    	Integer pageNumber = testSRList.pageNumber;
    	Integer totalNumber = testSRList.totalNumber;
    	Boolean hasNext = testSRList.hasNext;
    	Boolean hasPrevious = testSRList.hasPrevious;  	
    	testSRList.next();
    	testSRList.previous();
    	testSRList.clickToSort();
  
	}

}