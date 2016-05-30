/**
 * Test class to test the VizioSupport_CreateServiceRequest 
 * @author		Stela Zhang
 * @version		1.0
 * @since		1.0
 */
 
@isTest (SeeAllData=false)
private class TestClassCreateServiceRequest {
	
	/**
     * method to test Create SR 
     * @param			None	  
     * @return			None
     * @since			1.0
     */ 
	static testMethod void testSRWithCase() {
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
        
        Authorized_SRtype_for_SKU__c autoSRType = new Authorized_SRtype_for_SKU__c(SKU__c ='12312312312', ProductId__c = newProduct.Id, SRType__c = 'ACC');
        insert autoSRType;
        
        Service_Request__c insertnewSR = new Service_Request__c(AuthSRtype__c = autoSRType.Id, Case__c = newCase.Id, Error_Code__c = errorCode.Id, Service_Provider__c = autoSP.Id);
        insert insertnewSR;
    	
    	Service_Request_Information__c newSRInfo = new Service_Request_Information__c(ProductId__c = newProduct.Id, Country__c = 'US');
    	insert newSRInfo;
    	
    	
    	PageReference testCreateSR = Page.VizioSupport_CreateServiceRequest;    
    	
    	// Test Cancel
    	Test.setCurrentPage(testCreateSR);
    	ApexPages.currentPage().getParameters().put('CaseId',newCase.Id); 
    	VizioSupport_CreateServiceRequest createSR = new VizioSupport_CreateServiceRequest();  	   	
    	createSR.getSRInformation();
    	createSR.getErrorCodeList();
    	createSR.getsrTypeList();
    	createSR.cancelSR();
    	
    	// Test modelComparison
    	Test.setCurrentPage(testCreateSR);
    	ApexPages.currentPage().getParameters().put('CaseId',newCase.Id); 
    	createSR = new VizioSupport_CreateServiceRequest();   	
    	createSR.modelComparison();
    	
    	// Test editCustomer
    	Test.setCurrentPage(testCreateSR);
    	ApexPages.currentPage().getParameters().put('CaseId',newCase.Id); 
    	createSR = new VizioSupport_CreateServiceRequest();   	
    	createSR.editCustomer();
    	
    	// Test editAsset
    	Test.setCurrentPage(testCreateSR);
    	ApexPages.currentPage().getParameters().put('CaseId',newCase.Id); 
    	createSR = new VizioSupport_CreateServiceRequest();   	
    	createSR.editAsset();
    	
    	// Test Save
    	Test.setCurrentPage(testCreateSR);
    	ApexPages.currentPage().getParameters().put('CaseId',newCase.Id); 
    	createSR = new VizioSupport_CreateServiceRequest();
    	createSR.getErrorCodeList();
    	createSR.getsrTypeList();
    	createSR.getsvcProviderList();
    	createSR.selectedSRType = 'ACC';    	
    	createSR.selectedSVCProvider= 'ServiceP';
    	createSR.selectedErrorCode = 'A71-TV';
    	
    	createSR.saveSR();
    	
    	// Test Override with nothing
    	Test.setCurrentPage(testCreateSR);
    	ApexPages.currentPage().getParameters().put('CaseId',newCase.Id); 
    	createSR = new VizioSupport_CreateServiceRequest();   	
    	createSR.overrideSR();
    	
    	// Test Override with SR No.
    	Test.setCurrentPage(testCreateSR);
    	ApexPages.currentPage().getParameters().put('CaseId',newCase.Id); 
    	createSR = new VizioSupport_CreateServiceRequest();   	
    	createSR.getSRInformation();
    	createSR.getErrorCodeList();
    	createSR.getsrTypeList();
    	createSR.getsvcProviderList();
    	createSR.srNum = insertnewSR.Name;   
    	system.debug('srNum ' + createSR.srNum);	
    	createSR.overrideSR();
    	
    	
    	Test.setCurrentPage(testCreateSR);
    	ApexPages.currentPage().getParameters().put('CaseId',newCase.Id); 
    	createSR = new VizioSupport_CreateServiceRequest();
    	createSR.getSRInformation();
    	createSR.getErrorCodeList();
    	createSR.getsrTypeList();
    	createSR.getsvcProviderList();
    	createSR.overrideSR();
    	createSR.getErrorCodeList();
    	createSR.getsrTypeList();
    	createSR.getsvcProviderList();
    	createSR.addButton();
    	createSR.addButton();
    	createSR.addButton();
    	createSR.selectRowIndex = 1;
    	createSR.deleteButton();
    	
    	createSR.selectedSRType = 'ACC';
    	createSR.autoPopulate();
    	createSR.getSRInformation();
    	createSR.getErrorCodeList();
    	createSR.getsrTypeList();
    	createSR.selectedSRType = 'AR';
    	createSR.autoPopulate();
    	createSR.getSRInformation();
    	createSR.getErrorCodeList();
    	createSR.getsrTypeList();
    	createSR.selectedSRType = 'MRC';
    	createSR.autoPopulate();
    	createSR.getSRInformation();
    	createSR.getErrorCodeList();
    	createSR.getsrTypeList();
    	createSR.selectedSRType = 'OOW';
    	createSR.autoPopulate();
    	createSR.getSRInformation();
    	createSR.getErrorCodeList();
    	createSR.getsrTypeList();
    	createSR.selectedSRType = 'OSR';
    	createSR.autoPopulate();
    	createSR.getSRInformation();
    	createSR.getErrorCodeList();
    	createSR.getsrTypeList();
    	createSR.selectedSRType = 'OSS';
    	createSR.autoPopulate();
    	createSR.getSRInformation();
    	createSR.getErrorCodeList();
    	createSR.getsrTypeList();
    	createSR.selectedSRType = 'RC';
    	createSR.autoPopulate();
    	createSR.getSRInformation();
    	createSR.getErrorCodeList();
    	createSR.getsrTypeList();
    	createSR.selectedSRType = 'RR';
    	createSR.autoPopulate();
    	createSR.getSRInformation();
    	createSR.getErrorCodeList();
    	createSR.getsrTypeList();
    	createSR.selectedSRType = 'SBS';
    	createSR.autoPopulate();
    	createSR.getSRInformation();
    	createSR.getErrorCodeList();
    	createSR.getsrTypeList();
    	createSR.selectedSRType = 'SCR';
    	createSR.autoPopulate();
    	createSR.getSRInformation();
    	createSR.getErrorCodeList();
    	createSR.getsrTypeList();
    	createSR.selectedSRType = 'SR';
    	createSR.autoPopulate();
    	createSR.getSRInformation();
    	createSR.getErrorCodeList();
    	createSR.getsrTypeList();
    	createSR.selectedSRType = 'VCR';
    	createSR.autoPopulate();
    	createSR.getSRInformation();
    	createSR.getErrorCodeList();
    	createSR.getsrTypeList();
    	createSR.selectedSRType = 'RO';
    	createSR.autoPopulate();
    	createSR.getSRInformation();
    	createSR.getErrorCodeList();
    	createSR.getsrTypeList();
    	createSR.selectedSRType = 'CRC';
    	createSR.autoPopulate();
    	createSR.getSRInformation();
    	createSR.getErrorCodeList();
    	createSR.getsrTypeList();
    	createSR.selectedSRType = 'RNR';
    	createSR.autoPopulate();
    	createSR.getSRInformation();
    	createSR.getErrorCodeList();
    	createSR.getsrTypeList();
    	
    	createSR.selectedSVCProvider= 'ServiceP';
    	createSR.selectedErrorCode = 'A71-TV';
    	createSR.autoCreateSend();
    	createSR.autoCreateReceive();
    	
    	// Add line item
    	createSR.newSR.Box__c = true;
    	createSR.checkboxBox();
    	createSR.autoCreateDOASend();
    	createSR.newSR.Box__c = false;
    	createSR.checkboxBox();
    	createSR.autoCreateDOASend();
    	createSR.newSR.Label__c = true;
    	createSR.checkboxLabel();
    	createSR.autoCreateDOASend();
    	createSR.newSR.Label__c = false;
    	createSR.checkboxLabel();
    	createSR.autoCreateDOASend();
    	
    	// SP address
    	createSR.spAddress();
    	
    	
    	// Credit Card
    	createSR.getYearList();
    	
    	createSR.selectedSRType = 'AR';
    	createSR.autoPopulate();
    	createSR.getSRInformation();
    	createSR.getErrorCodeList();
    	createSR.getsrTypeList();
    	createSR.lineItemList[0].addLineItem.Price__c = 90;
    	createSR.checkCreditCard();
    	createSR.totalAmount = 100.00;
    	
        createSR.firstName = 'test';
    	createSR.lastName = 'test';
    	createSR.ccType = 'visa';
    	createSR.ccNumber = '1111222233334444';
    	createSR.expMonth = '12';
   	 	createSR.expYear = '2016';
   	 	createSR.cvvNumber = '000';
    	createSR.address = 'test test test';
    	createSR.city = 'Irvine';
    	createSR.state = 'CA';
    	createSR.zipCode = '12312';
        createSR.sameAsCustomer = true;
        createSR.countClickTime = 1;    	
    	createSR.uesSameAddress();
    	createSR.sameAsCustomer = false;
    	createSR.countClickTime = 2;   	
    	createSR.uesSameAddress();
    	createSR.verifyCreditCard();
    	
    
	}	
	
	/**
     * method to test Create SR with asset doa date >0 
     * @param			None	  
     * @return			None
     * @since			1.0
     */ 
	static testMethod void testSRWithCase1() {
		Account newAccount = new Account(Name = 'Testing');
		insert newAccount;
		
		Id contactRecotType = [Select Id From RecordType Where Name = 'Support' AND SobjectType = 'Contact'].get(0).Id;        
        Contact customer = new Contact(LastName = 'Customer', RecordTypeId = contactRecotType, MailingCountryCode = 'US', MailingStateCode = 'CA', AccountId = newAccount.Id);
        insert customer;
        
        Id contactRecotTypeSP = [Select Id From RecordType Where Name = 'Service Provider' AND SobjectType = 'Contact'].get(0).Id;       
        Contact serviceP = new Contact(LastName = 'ServiceP', RecordTypeId = contactRecotTypeSP, MailingCountryCode = 'US', MailingStateCode = 'CA');
        insert serviceP;
        
        Product2 newProduct = new Product2(Name = 'M60', SKU__c ='12312312312', SKUDesc__c = 'TV', isPart__c = true);
        insert newProduct;
        
        Asset newAsset = new Asset(Name = 'AAYWPLBP123456', SerialNumber = 'AAYWPLBP123456', Product2Id = newProduct.Id, ContactId = customer.Id, PurchaseDate = Date.newInstance(2016, 03, 16));
        insert newAsset;
        
        Case newCase = new Case(AssetId = newAsset.Id, ContactId = customer.Id); 
        insert newCase; 
        
        Error_Code__c errorCode = new Error_Code__c(Name = 'A71', Error_Category__c = 'TV', Description__c = 'No Audio');
        insert errorCode;
        
        Authorized_SP_for_SRtypenSKU__c autoSP= new Authorized_SP_for_SRtypenSKU__c(SKU__c ='12312312312', ProductId__c = newProduct.Id, ServiceProviderId__c = serviceP.Id );
        insert autoSP;
        
        Authorized_SRtype_for_SKU__c autoSRType = new Authorized_SRtype_for_SKU__c(SKU__c ='12312312312', ProductId__c = newProduct.Id, SRType__c = 'ACC');
        insert autoSRType;
        
        Service_Request__c insertnewSR = new Service_Request__c(AuthSRtype__c = autoSRType.Id, Case__c = newCase.Id, Error_Code__c = errorCode.Id, Service_Provider__c = autoSP.Id);
        insert insertnewSR;
    	
    	Service_Request_Information__c newSRInfo = new Service_Request_Information__c(ProductId__c = newProduct.Id, Country__c = 'US', SubModelDOA__c ='11111111111', SubModelOutDOA__c = '22222222222');
    	insert newSRInfo;
    	
    	
    	PageReference testCreateSR = Page.VizioSupport_CreateServiceRequest;    
    	  	
    	Test.setCurrentPage(testCreateSR);
    	ApexPages.currentPage().getParameters().put('CaseId',newCase.Id); 
    	VizioSupport_CreateServiceRequest createSR = new VizioSupport_CreateServiceRequest();
    	createSR.getSRInformation();
    	createSR.getErrorCodeList();
    	createSR.getsrTypeList();
    	createSR.getsvcProviderList();
    	createSR.overrideSR();
    	
    	createSR.selectedSRType = 'ACC';
    	createSR.autoPopulate();
    	createSR.autoCreateDOASend();
    	
    	createSR.selectedSRType = 'SR';
    	createSR.autoPopulate();
    	createSR.getSRInformation();
    	createSR.getErrorCodeList();
    	createSR.getsrTypeList();
    	
    	createSR.newSR.isSubstitution__c = false;
    	createSR.autoCreateDOASend();
    	createSR.newSR.isSubstitution__c = true;
    	createSR.autoCreateDOASend();
    
	}	
	
	/**
     * method to test Create SR with asset doa date <= 0 
     * @param			None	  
     * @return			None
     * @since			1.0
     */ 
	static testMethod void testSRWithCase2() {
		Account newAccount = new Account(Name = 'Testing');
		insert newAccount;
		
		Id contactRecotType = [Select Id From RecordType Where Name = 'Support' AND SobjectType = 'Contact'].get(0).Id;        
        Contact customer = new Contact(LastName = 'Customer', RecordTypeId = contactRecotType, MailingCountryCode = 'US', MailingStateCode = 'CA', AccountId = newAccount.Id);
        insert customer;
        
        Id contactRecotTypeSP = [Select Id From RecordType Where Name = 'Service Provider' AND SobjectType = 'Contact'].get(0).Id;       
        Contact serviceP = new Contact(LastName = 'ServiceP', RecordTypeId = contactRecotTypeSP, MailingCountryCode = 'US', MailingStateCode = 'CA');
        insert serviceP;
        
        Product2 newProduct = new Product2(Name = 'M60', SKU__c ='12312312312', SKUDesc__c = 'TV', isPart__c = false);
        insert newProduct;
        
        Asset newAsset = new Asset(Name = 'AAYWPLBP123456', SerialNumber = 'AAYWPLBP123456', Product2Id = newProduct.Id, ContactId = customer.Id, PurchaseDate = Date.newInstance(2015, 03, 16));
        insert newAsset;
        
        Case newCase = new Case(AssetId = newAsset.Id, ContactId = customer.Id); 
        insert newCase; 
        
        Error_Code__c errorCode = new Error_Code__c(Name = 'A71', Error_Category__c = 'TV', Description__c = 'No Audio');
        insert errorCode;
        
        Authorized_SP_for_SRtypenSKU__c autoSP= new Authorized_SP_for_SRtypenSKU__c(SKU__c ='12312312312', ProductId__c = newProduct.Id, ServiceProviderId__c = serviceP.Id );
        insert autoSP;
        
        Authorized_SRtype_for_SKU__c autoSRType = new Authorized_SRtype_for_SKU__c(SKU__c ='12312312312', ProductId__c = newProduct.Id, SRType__c = 'ACC');
        insert autoSRType;
        
        Service_Request__c insertnewSR = new Service_Request__c(AuthSRtype__c = autoSRType.Id, Case__c = newCase.Id, Error_Code__c = errorCode.Id, Service_Provider__c = autoSP.Id);
        insert insertnewSR;
    	
    	Service_Request_Information__c newSRInfo = new Service_Request_Information__c(ProductId__c = newProduct.Id, Country__c = 'US', SubModelDOA__c ='11111111111', SubModelOutDOA__c = '22222222222');
    	insert newSRInfo;
    	
    	
    	PageReference testCreateSR = Page.VizioSupport_CreateServiceRequest;    
    	  	
    	Test.setCurrentPage(testCreateSR);
    	ApexPages.currentPage().getParameters().put('CaseId',newCase.Id); 
    	VizioSupport_CreateServiceRequest createSR = new VizioSupport_CreateServiceRequest();
    	createSR.getSRInformation();
    	createSR.getErrorCodeList();
    	createSR.getsrTypeList();
    	createSR.getsvcProviderList();
    	createSR.overrideSR();
    	
    	createSR.selectedSRType = 'ACC';
    	createSR.autoPopulate();
    	createSR.autoCreateDOASend();
    	
    	createSR.selectedSRType = 'SR';
    	createSR.autoPopulate();
    	createSR.getSRInformation();
    	createSR.getErrorCodeList();
    	createSR.getsrTypeList();
    	
    	createSR.newSR.isSubstitution__c = false;
    	createSR.autoCreateDOASend();
    	createSR.newSR.isSubstitution__c = true;
    	createSR.autoCreateDOASend();
    
	}	
	
	
	
    /**
     * method to test Create SR, no sr info
     * @param			None	  
     * @return			None
     * @since			1.0
     */ 
	static testMethod void testSRWithCaseNoSRInfo() {
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
        
        Authorized_SRtype_for_SKU__c autoSRType = new Authorized_SRtype_for_SKU__c(SKU__c ='12312312312', ProductId__c = newProduct.Id, SRType__c = 'ACC');
        insert autoSRType;
        
    	   	
    	PageReference testCreateSR = Page.VizioSupport_CreateServiceRequest;    
    	
    	// Test Cancel
    	Test.setCurrentPage(testCreateSR);
    	ApexPages.currentPage().getParameters().put('CaseId',newCase.Id); 
    	VizioSupport_CreateServiceRequest createSR = new VizioSupport_CreateServiceRequest();  	   	
    	createSR.getSRInformation();
    	createSR.getErrorCodeList();
    	createSR.getsrTypeList();
    	createSR.cancelSR();
    	
    	
	}	
	/**
     * method to test Create SR with no case
     * @param			None	  
     * @return			None
     * @since			1.0
     */ 
	static testMethod void testSRNoCase() {
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
        
        Authorized_SRtype_for_SKU__c autoSRType = new Authorized_SRtype_for_SKU__c(SKU__c ='12312312312', ProductId__c = newProduct.Id, SRType__c = 'ACC');
        insert autoSRType;
        

    	Service_Request_Information__c newSRInfo = new Service_Request_Information__c(ProductId__c = newProduct.Id, Country__c = 'US');
    	insert newSRInfo;
    	
    	
    	PageReference testCreateSR = Page.VizioSupport_CreateServiceRequest;    
    	Test.setCurrentPage(testCreateSR);
    	VizioSupport_CreateServiceRequest createSR = new VizioSupport_CreateServiceRequest();
	}	
	
	/**
     * method to test Create SR with no Customer
     * @param			None	  
     * @return			None
     * @since			1.0
     */ 
	static testMethod void testSRNoCustomer() {
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
        
        Authorized_SRtype_for_SKU__c autoSRType = new Authorized_SRtype_for_SKU__c(SKU__c ='12312312312', ProductId__c = newProduct.Id, SRType__c = 'ACC');
        insert autoSRType;       
    	
    	Service_Request_Information__c newSRInfo = new Service_Request_Information__c(ProductId__c = newProduct.Id, Country__c = 'US');
    	insert newSRInfo;
    	
    	
    	PageReference testCreateSR = Page.VizioSupport_CreateServiceRequest;    
    	Test.setCurrentPage(testCreateSR); 	
    	ApexPages.currentPage().getParameters().put('CaseId',newCase.Id); 
    	VizioSupport_CreateServiceRequest createSR = new VizioSupport_CreateServiceRequest();
    	
     
	}	
	
	/**
     * method to test Create SR with no Asset
     * @param			None	  
     * @return			None
     * @since			1.0
     */ 
	static testMethod void testSRNoAsset() {
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
        
        Authorized_SRtype_for_SKU__c autoSRType = new Authorized_SRtype_for_SKU__c(SKU__c ='12312312312', ProductId__c = newProduct.Id, SRType__c = 'ACC');
        insert autoSRType;
    	
    	Service_Request_Information__c newSRInfo = new Service_Request_Information__c(ProductId__c = newProduct.Id, Country__c = 'US');
    	insert newSRInfo;
    	
    	
    	PageReference testCreateSR = Page.VizioSupport_CreateServiceRequest;    
    	Test.setCurrentPage(testCreateSR);
        ApexPages.currentPage().getParameters().put('CaseId',newCase.Id); 
    	VizioSupport_CreateServiceRequest createSR = new VizioSupport_CreateServiceRequest();  	
     
	}	
	
		/**
     * method to test Create SR with no Product
     * @param			None	  
     * @return			None
     * @since			1.0
     */ 
	static testMethod void testSRNoProduct() {
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
        
        Authorized_SRtype_for_SKU__c autoSRType = new Authorized_SRtype_for_SKU__c(SKU__c ='12312312312', ProductId__c = newProduct.Id, SRType__c = 'ACC');
        insert autoSRType;
    	
    	Service_Request_Information__c newSRInfo = new Service_Request_Information__c(ProductId__c = newProduct.Id, Country__c = 'US');
    	insert newSRInfo;
    	
    	
    	PageReference testCreateSR = Page.VizioSupport_CreateServiceRequest;    
    	Test.setCurrentPage(testCreateSR);
        ApexPages.currentPage().getParameters().put('CaseId',newCase.Id); 
    	VizioSupport_CreateServiceRequest createSR = new VizioSupport_CreateServiceRequest();  	
     
	}
	
	/**
     * method to test Create SR canada
     * @param			None	  
     * @return			None
     * @since			1.0
     */ 
	static testMethod void testSRWithCanada() {
		Account newAccount = new Account(Name = 'Testing');
		insert newAccount;
		
		Id contactRecotType = [Select Id From RecordType Where Name = 'Support' AND SobjectType = 'Contact'].get(0).Id;        
        Contact customer = new Contact(LastName = 'Customer', RecordTypeId = contactRecotType, MailingCountryCode = 'CA', AccountId = newAccount.Id);
        insert customer;
        
        Id contactRecotTypeSP = [Select Id From RecordType Where Name = 'Service Provider' AND SobjectType = 'Contact'].get(0).Id;       
        Contact serviceP = new Contact(LastName = 'Edtech Technology Inc.', RecordTypeId = contactRecotTypeSP, MailingCountryCode = 'US', MailingStateCode = 'CA');
        insert serviceP;
        
        Product2 newProduct = new Product2(Name = 'M60', SKU__c ='12312312312', SKUDesc__c = 'TV', isPart__c = false);
        insert newProduct;
        
        Asset newAsset = new Asset(Name = 'AAYWPLBP123456', SerialNumber = 'AAYWPLBP123456', Product2Id = newProduct.Id, ContactId = customer.Id, PurchaseDate = Date.newInstance(2015, 03, 16));
        insert newAsset;
        
        Case newCase = new Case(AssetId = newAsset.Id, ContactId = customer.Id); 
        insert newCase; 
        
        Error_Code__c errorCode = new Error_Code__c(Name = 'A71', Error_Category__c = 'TV', Description__c = 'No Audio');
        insert errorCode;
        
        Authorized_SP_for_SRtypenSKU__c autoSP= new Authorized_SP_for_SRtypenSKU__c(SKU__c ='12312312312', ProductId__c = newProduct.Id, ServiceProviderId__c = serviceP.Id );
        insert autoSP;

    	Service_Request_Information__c newSRInfo = new Service_Request_Information__c(ProductId__c = newProduct.Id, Country__c = 'US', SubModelDOA__c ='11111111111', SubModelOutDOA__c = '22222222222');
    	insert newSRInfo;
    	
    	
    	PageReference testCreateSR = Page.VizioSupport_CreateServiceRequest;    
    	  	
    	Test.setCurrentPage(testCreateSR);
    	ApexPages.currentPage().getParameters().put('CaseId',newCase.Id); 
    	VizioSupport_CreateServiceRequest createSR = new VizioSupport_CreateServiceRequest();

    	createSR.selectedSVCProvider = 'Edtech Technology Inc.';
    	
    	createSR.selectedSRType = 'OSS';
    	createSR.autoCreateDOASend();
    	createSR.spAddress();
    	
	}	
	

}