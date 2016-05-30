/**
 * Test class to test the VizioSupport_ChangeSRStatus 
 * @author		Stela Zhang
 * @version		1.0
 * @since		1.0
 */
 
@isTest (SeeAllData=false)
private class TestClassChangeSRStatus {
	/**
     * method to test the Edit SR
     *
     * @param			None	  
     * @return			None
     * @since			1.0
     */ 
	static testMethod void testEditSR() {
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
        
        Service_Request__c newSR = new Service_Request__c(AuthSRtype__c = autoSRType.Id, Case__c = newCase.Id, Error_Code__c = errorCode.Id, Service_Provider__c = autoSP.Id);
        insert newSR;
        
        PageReference editSRStatus  = Page.VizioSupport_ChangeSRStatus;	    
    	Test.setCurrentPage(editSRStatus);
    	ApexPages.Standardcontroller stdSR = new ApexPages.Standardcontroller(newSR);   
    	VizioSupport_ChangeSRStatus editTheStatus = new VizioSupport_ChangeSRStatus(stdSR);
    	editTheStatus.getStatusList();
    	editTheStatus.selectedStatus = 'CANCELLED';
    	editTheStatus.Cancel();
    	Test.setCurrentPage(editSRStatus);
    	editTheStatus = new VizioSupport_ChangeSRStatus(stdSR);
    	editTheStatus.selectedStatus = 'CANCELLED';
    	editTheStatus.srList[0].StatusReason__c = 'TEST';
    	editTheStatus.Submit();
    	
	}

}