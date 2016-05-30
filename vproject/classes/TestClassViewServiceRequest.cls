/**
 * Test class to test the VizioSupport_ViewServiceRequest 
 * @author		Stela Zhang
 * @version		1.0
 * @since		1.0
 */
 
@isTest (SeeAllData=false)
private class TestClassViewServiceRequest {
	/**
     * method to test the view SR has SRInfo
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
        
        Line_Items__c  newLineItem = new Line_Items__c (PartType__c = 'Sent', SKU__c ='12312312312', Quantity__c = 1, Service_Request__c = newSR.Id );
        insert newLineItem;
    	
    	Service_Request_Information__c newSRInfo = new Service_Request_Information__c(ProductId__c = newProduct.Id, Country__c = 'US');
    	insert newSRInfo;
    	
    	PageReference srDetailView  = Page.VizioSupport_ViewServiceRequest;	
    	Test.setCurrentPage(srDetailView);
    	ApexPages.currentPage().getParameters().put('Id',newSR.Id);
    	ApexPages.Standardcontroller stdSR = new ApexPages.Standardcontroller(newSR);   
    	VizioSupport_ViewServiceRequest testSRView = new VizioSupport_ViewServiceRequest(stdSR);
    	
    	
    	testSRView.getRelatedLineItem();
    	testSRView.sortExpression = null;
    	testSRView.getSortDirection(); 
        testSRView.sortExpression ='Name';
        testSRView.setSortDirection('DESC');
    	
    	testSRView.getSortDirection();
    	testSRView.sortExpression ='Name';
    	testSRView.setSortDirection('ASC');
    	testSRView.getSortDirection(); 	
    	testSRView.first();
    	testSRView.last();
    	Integer pageNumber = testSRView.pageNumber;
    	Integer totalNumber = testSRView.totalNumber;
    	Boolean hasNext = testSRView.hasNext;
    	Boolean hasPrevious = testSRView.hasPrevious;  	
    	testSRView.next();
    	testSRView.previous();
    	testSRView.clickToSort();
  
    	
    
	}
	
	/**
     * method to test the view SR no customer
     * @param			None	  
     * @return			None
     * @since			1.0
     */ 
	static testMethod void testSRList2() {
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
        
        Case newCase = new Case(AssetId = newAsset.Id); 
        insert newCase;
        
        Error_Code__c errorCode = new Error_Code__c(Name = 'A71', Error_Category__c = 'TV', Description__c = 'No Audio');
        insert errorCode;
        
        Authorized_SP_for_SRtypenSKU__c autoSP= new Authorized_SP_for_SRtypenSKU__c(SKU__c ='12312312312', ProductId__c = newProduct.Id, ServiceProviderId__c = serviceP.Id );
        insert autoSP;
        
        Authorized_SRtype_for_SKU__c autoSRType = new Authorized_SRtype_for_SKU__c(SKU__c ='12312312312', ProductId__c = newProduct.Id, SRType__c = 'AR');
        insert autoSRType;
        
        Service_Request__c newSR = new Service_Request__c(AuthSRtype__c = autoSRType.Id, Case__c = newCase.Id, Error_Code__c = errorCode.Id, Service_Provider__c = autoSP.Id);
        insert newSR;
        
            
        PageReference srDetailView  = Page.VizioSupport_ViewServiceRequest;	    
    		
    	Test.setCurrentPage(srDetailView);
    	ApexPages.currentPage().getParameters().put('Id',newSR.Id);
    	ApexPages.Standardcontroller stdSR = new ApexPages.Standardcontroller(newSR);   
    	VizioSupport_ViewServiceRequest testSRView = new VizioSupport_ViewServiceRequest(stdSR);
    
	}
	
	/**
     * method to test the view SR no Asset
     * @param			None	  
     * @return			None
     * @since			1.0
     */ 
	static testMethod void testSRList3() {
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
        
        Case newCase = new Case(ContactId = customer.Id); 
        insert newCase;
        
        Error_Code__c errorCode = new Error_Code__c(Name = 'A71', Error_Category__c = 'TV', Description__c = 'No Audio');
        insert errorCode;
        
        Authorized_SP_for_SRtypenSKU__c autoSP= new Authorized_SP_for_SRtypenSKU__c(SKU__c ='12312312312', ProductId__c = newProduct.Id, ServiceProviderId__c = serviceP.Id );
        insert autoSP;
        
        Authorized_SRtype_for_SKU__c autoSRType = new Authorized_SRtype_for_SKU__c(SKU__c ='12312312312', ProductId__c = newProduct.Id, SRType__c = 'AR');
        insert autoSRType;
        
        Service_Request__c newSR = new Service_Request__c(AuthSRtype__c = autoSRType.Id, Case__c = newCase.Id, Error_Code__c = errorCode.Id, Service_Provider__c = autoSP.Id);
        insert newSR;
        
       
        PageReference srDetailView  = Page.VizioSupport_ViewServiceRequest;	    
    		
    	Test.setCurrentPage(srDetailView);
    	ApexPages.currentPage().getParameters().put('Id',newSR.Id);
    	ApexPages.Standardcontroller stdSR = new ApexPages.Standardcontroller(newSR);   
    	VizioSupport_ViewServiceRequest testSRView = new VizioSupport_ViewServiceRequest(stdSR);
    
	}
	
	/**
     * method to test the view SR no Product
     * @param			None	  
     * @return			None
     * @since			1.0
     */ 
	static testMethod void testSRList4() {
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
        
        Asset newAsset = new Asset(Name = 'AAYWPLBP123456', SerialNumber = 'AAYWPLBP123456', ContactId = customer.Id);
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
        
       
        PageReference srDetailView  = Page.VizioSupport_ViewServiceRequest;	    
    		
    	Test.setCurrentPage(srDetailView);
    	ApexPages.currentPage().getParameters().put('Id',newSR.Id);
    	ApexPages.Standardcontroller stdSR = new ApexPages.Standardcontroller(newSR);   
    	VizioSupport_ViewServiceRequest testSRView = new VizioSupport_ViewServiceRequest(stdSR);
    
	}
	
	
	/**
     * method to test the view SR No SRInfo
     * @param			None	  
     * @return			None
     * @since			1.0
     */ 
	static testMethod void testSRList5() {
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
        
       
        PageReference srDetailView  = Page.VizioSupport_ViewServiceRequest;	    
    	  	
    	Test.setCurrentPage(srDetailView);
    	ApexPages.currentPage().getParameters().put('Id',newSR.Id);
    	ApexPages.Standardcontroller stdSR = new ApexPages.Standardcontroller(newSR);   
    	VizioSupport_ViewServiceRequest testSRView = new VizioSupport_ViewServiceRequest(stdSR);
    	
	} 
	
}