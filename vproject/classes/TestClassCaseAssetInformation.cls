/**
 * Test class to VizioSupport_CaseAssetInformation
 *
 * @author      Stela Zhang
 * @version     1.0
 * @since       1.0
 */
 
@isTest (SeeAllData=false)
private class TestClassCaseAssetInformation {
    
    
    /**
     * method to test the No Asset
     *
     * @param           None      
     * @return          None
     * @since           1.0
     */ 
    static testMethod void testNoAsset() {
        
        Case newCase = new Case(); 
        insert newCase;    
                
        PageReference caseAssetInfo  = Page.VizioSupport_CaseAssetInformation;      
        
        
        Test.setCurrentPage(caseAssetInfo);
        ApexPages.currentPage().getParameters().put('id',newCase.Id); 
        ApexPages.Standardcontroller stdCase = new ApexPages.Standardcontroller(newCase);   
        VizioSupport_CaseAssetInformation testInfo = new VizioSupport_CaseAssetInformation(stdCase);
        
          
    } 
    
    
    /** 
     * method to test the No Product
     *
     * @param           None      
     * @return          None
     * @since           1.0
     */ 
    static testMethod void testNoProduct() {
        
        Account newAccount = new Account(Name = 'Testing');
        insert newAccount;
        
        Id contactRecotType = [Select Id From RecordType Where Name = 'Support' AND SobjectType = 'Contact'].get(0).Id;        
        Contact customer = new Contact(LastName = 'Customer', RecordTypeId = contactRecotType, MailingCountryCode = 'US', MailingStateCode = 'CA', AccountId = newAccount.Id);
        insert customer;
        
        Asset newAsset = new Asset(Name = 'AAYWPLBP123456', SerialNumber = 'AAYWPLBP123456', ContactId = customer.Id);
        insert newAsset;
        
        Case newCase = new Case(AssetId = newAsset.Id, ContactId = customer.Id);
        insert newCase;   
           
                
        PageReference caseAssetInfo  = Page.VizioSupport_CaseAssetInformation;      
      
        Test.setCurrentPage(caseAssetInfo);
        ApexPages.currentPage().getParameters().put('id',newCase.Id); 
        ApexPages.Standardcontroller stdCase = new ApexPages.Standardcontroller(newCase);   
        VizioSupport_CaseAssetInformation testInfo = new VizioSupport_CaseAssetInformation(stdCase);
        
    }   
    
    /**
     * method to test the testCaseAsset Not verify pop, no PurchaseDate, no last return date, getRetailId = empty
     *
     * @param           None      
     * @return          None
     * @since           1.0
     */ 
    static testMethod void testCaseAssetEmptylist() {

        Account newAccount = new Account(Name = 'Testing');
        insert newAccount;
        
        Id contactRecotType = [Select Id From RecordType Where Name = 'Support' AND SobjectType = 'Contact'].get(0).Id;        
        Contact customer = new Contact(LastName = 'Customer', RecordTypeId = contactRecotType, MailingCountryCode = 'US', MailingStateCode = 'CA', AccountId = newAccount.Id);
        insert customer;
        
        Id contactRecotTypeRetailer = [Select Id From RecordType Where Name = 'Retailer' AND SobjectType = 'Contact'].get(0).Id;       
        Contact retailer = new Contact(LastName = 'ServiceP', RecordTypeId = contactRecotTypeRetailer);
        insert retailer;
        
        Product2 newProduct = new Product2(Name = 'M60', SKU__c ='12312312312', SKUDesc__c = 'TV');
        insert newProduct;
        
        Product2 newProduct2 = new Product2(Name = 'M60', SKU__c ='33322211100', SKUDesc__c = 'TV');
        insert newProduct2;
        
        Authorized_Retailer_for_SKU__c authRetailer = new Authorized_Retailer_for_SKU__c(ProductId__c = newProduct2.Id, RetailerId_del__c = retailer.Id);
        insert authRetailer;
        
        Asset newAsset = new Asset(Name = 'AAYWPLBP123456', SerialNumber = 'AAYWPLBP123456', Product2Id = newProduct.Id, ContactId = customer.Id);
        insert newAsset;
        
        Asset newAsset2 = new Asset(Name = 'AAYWPLBP123458', SerialNumber = 'AAYWPLBP123458', Product2Id = newProduct2.Id, ContactId = customer.Id);
        insert newAsset2;
        
        Case newCase = new Case(AssetId = newAsset.Id, ContactId = customer.Id);
        insert newCase;   
        
        
        Product_Warranty__c proWarranty2= new Product_Warranty__c(AssetId__c = newAsset2.Id, RetailerId__c = retailer.Id, WarrantyLength__c = 1);
        insert proWarranty2;
         
        
        PageReference caseAssetInfo  = Page.VizioSupport_CaseAssetInformation;      
         
        Test.setCurrentPage(caseAssetInfo);
        ApexPages.currentPage().getParameters().put('id',newCase.Id); 
        ApexPages.Standardcontroller stdCase = new ApexPages.Standardcontroller(newCase);   
        VizioSupport_CaseAssetInformation testInfo = new VizioSupport_CaseAssetInformation(stdCase);
        
          
    }     
    
    /**
     * method to test the testCaseAsset Not verify pop, no PurchaseDate, no last return date, getLastReturnDate = empty
     *
     * @param           None      
     * @return          None
     * @since           1.0
     */ 
    static testMethod void testCaseAssetNo() {

        Account newAccount = new Account(Name = 'Testing');
        insert newAccount;
        
        Id contactRecotType = [Select Id From RecordType Where Name = 'Support' AND SobjectType = 'Contact'].get(0).Id;        
        Contact customer = new Contact(LastName = 'Customer', RecordTypeId = contactRecotType, MailingCountryCode = 'US', MailingStateCode = 'CA', AccountId = newAccount.Id);
        insert customer;
        
        Id contactRecotTypeRetailer = [Select Id From RecordType Where Name = 'Retailer' AND SobjectType = 'Contact'].get(0).Id;       
        Contact retailer = new Contact(LastName = 'ServiceP', RecordTypeId = contactRecotTypeRetailer);
        insert retailer;
        
        Product2 newProduct = new Product2(Name = 'M60', SKU__c ='12312312312', SKUDesc__c = 'TV');
        insert newProduct;
        
        Product2 newProduct2 = new Product2(Name = 'M60', SKU__c ='33322211100', SKUDesc__c = 'TV');
        insert newProduct2;
        
        Authorized_Retailer_for_SKU__c authRetailer = new Authorized_Retailer_for_SKU__c(ProductId__c = newProduct2.Id, RetailerId_del__c = retailer.Id);
        insert authRetailer;
        
        Asset newAsset = new Asset(Name = 'AAYWPLBP123456', SerialNumber = 'AAYWPLBP123456', Product2Id = newProduct.Id, ContactId = customer.Id);
        insert newAsset;
        
        Case newCase = new Case(AssetId = newAsset.Id, ContactId = customer.Id);
        insert newCase;   
        
        Product_Warranty__c proWarranty= new Product_Warranty__c(AssetId__c = newAsset.Id, RetailerId__c = retailer.Id, WarrantyLength__c = 1);
        insert proWarranty;
         
        
        PageReference caseAssetInfo  = Page.VizioSupport_CaseAssetInformation;      
       
        Test.setCurrentPage(caseAssetInfo);
        ApexPages.currentPage().getParameters().put('id',newCase.Id); 
        ApexPages.Standardcontroller stdCase = new ApexPages.Standardcontroller(newCase);   
        VizioSupport_CaseAssetInformation testInfo = new VizioSupport_CaseAssetInformation(stdCase);
        
          
    }
    
    /**
     * method to test the testCaseAsset Pop verify, has PurchaseDate and last return date, warrantylength = 1
     *
     * @param           None      
     * @return          None
     * @since           1.0
     */ 
    static testMethod void testCaseAssetHasPurchaseDate1() {

        Account newAccount = new Account(Name = 'Testing');
        insert newAccount;
        
        Id contactRecotType = [Select Id From RecordType Where Name = 'Support' AND SobjectType = 'Contact'].get(0).Id;        
        Contact customer = new Contact(LastName = 'Customer', RecordTypeId = contactRecotType, MailingCountryCode = 'US', MailingStateCode = 'CA', AccountId = newAccount.Id);
        insert customer;
        
        Id contactRecotTypeRetailer = [Select Id From RecordType Where Name = 'Retailer' AND SobjectType = 'Contact'].get(0).Id;       
        Contact retailer = new Contact(LastName = 'ServiceP', RecordTypeId = contactRecotTypeRetailer);
        insert retailer;
        
              
        Product2 newProduct = new Product2(Name = 'M60', SKU__c ='12312312312', SKUDesc__c = 'TV');
        insert newProduct;
        
        Authorized_Retailer_for_SKU__c authRetailer = new Authorized_Retailer_for_SKU__c(ProductId__c = newProduct.Id, RetailerId_del__c = retailer.Id, Last_Return_Date__c = Date.newInstance(2016, 03, 12));
        insert authRetailer;
        
        Asset newAsset = new Asset(Name = 'AAYWPLBP123456', SerialNumber = 'AAYWPLBP123456', Product2Id = newProduct.Id, ContactId = customer.Id, isPOPVerify__c = true, PurchaseDate = Date.newInstance(2016, 03, 16));
        insert newAsset;
        
        Case newCase = new Case(AssetId = newAsset.Id, ContactId = customer.Id);
        insert newCase;   
        
        Product_Warranty__c proWarranty= new Product_Warranty__c(AssetId__c = newAsset.Id, RetailerId__c = retailer.Id, WarrantyLength__c = 1);
        insert proWarranty;
         
        
        PageReference caseAssetInfo  = Page.VizioSupport_CaseAssetInformation;      
        
        Test.setCurrentPage(caseAssetInfo);
        ApexPages.currentPage().getParameters().put('id',newCase.Id); 
        ApexPages.Standardcontroller stdCase = new ApexPages.Standardcontroller(newCase);   
        VizioSupport_CaseAssetInformation testInfo = new VizioSupport_CaseAssetInformation(stdCase);
        
          
    }
    
    /**
     * method to test the testCaseAsset Pop verify, has PurchaseDate and last return date, warrantylength = 30, location doesn't match
     *
     * @param           None      
     * @return          None
     * @since           1.0
     */ 
    static testMethod void testCaseAssetHasPurchaseDate2() {

        Account newAccount = new Account(Name = 'Testing');
        insert newAccount;
        
        Id contactRecotType = [Select Id From RecordType Where Name = 'Support' AND SobjectType = 'Contact'].get(0).Id;        
        Contact customer = new Contact(LastName = 'Customer', RecordTypeId = contactRecotType, MailingCountryCode = 'US', MailingStateCode = 'CA', AccountId = newAccount.Id);
        insert customer;
        
        Id contactRecotTypeRetailer = [Select Id From RecordType Where Name = 'Retailer' AND SobjectType = 'Contact'].get(0).Id;       
        Contact retailer = new Contact(LastName = 'ServiceP', RecordTypeId = contactRecotTypeRetailer);
        insert retailer;
        
              
        Product2 newProduct = new Product2(Name = 'M60', SKU__c ='12312312312', SKUDesc__c = 'TV');
        insert newProduct;
        
        Authorized_Retailer_for_SKU__c authRetailer = new Authorized_Retailer_for_SKU__c(ProductId__c = newProduct.Id, RetailerId_del__c = retailer.Id, Last_Return_Date__c = Date.newInstance(2016, 03, 12));
        insert authRetailer;
        
        Asset newAsset = new Asset(Name = 'AAYWPLBP123456', SerialNumber = 'AAYWPLBP123456', Product2Id = newProduct.Id, ContactId = customer.Id, isPOPVerify__c = true, PurchaseDate = Date.newInstance(2016, 03, 16), Purchase_Location__c = 'Groupon');
        insert newAsset;
        
        Case newCase = new Case(AssetId = newAsset.Id, ContactId = customer.Id);
        insert newCase;   
        
        Product_Warranty__c proWarranty= new Product_Warranty__c(AssetId__c = newAsset.Id, RetailerId__c = retailer.Id, WarrantyLength__c = 30);
        insert proWarranty;
         
        
        PageReference caseAssetInfo  = Page.VizioSupport_CaseAssetInformation;      
       
        Test.setCurrentPage(caseAssetInfo);
        ApexPages.currentPage().getParameters().put('id',newCase.Id); 
        ApexPages.Standardcontroller stdCase = new ApexPages.Standardcontroller(newCase);   
        VizioSupport_CaseAssetInformation testInfo = new VizioSupport_CaseAssetInformation(stdCase);
        
          
    }
    
    /**
     * method to test the testCaseAsset Pop verify, has PurchaseDate and last return date, warrantylength = 30, location match, asset doesn't match
     *
     * @param           None      
     * @return          None 
     * @since           1.0
     */ 
    static testMethod void testCaseAssetHasPurchaseDate3() { 

        Account newAccount = new Account(Name = 'Testing');
        insert newAccount;
        
        Id contactRecotType = [Select Id From RecordType Where Name = 'Support' AND SobjectType = 'Contact'].get(0).Id;        
        Contact customer = new Contact(LastName = 'Customer', RecordTypeId = contactRecotType, MailingCountryCode = 'US', MailingStateCode = 'CA', AccountId = newAccount.Id);
        insert customer;
        
        Id contactRecotTypeRetailer = [Select Id From RecordType Where Name = 'Retailer' AND SobjectType = 'Contact'].get(0).Id;       
        Contact retailer = new Contact(LastName = 'ServiceP', RecordTypeId = contactRecotTypeRetailer);
        insert retailer;
        
              
        Product2 newProduct = new Product2(Name = 'M60', SKU__c ='12312312312', SKUDesc__c = 'TV');
        insert newProduct;
        
        Authorized_Retailer_for_SKU__c authRetailer = new Authorized_Retailer_for_SKU__c(ProductId__c = newProduct.Id, RetailerId_del__c = retailer.Id, Last_Return_Date__c = Date.newInstance(2016, 03, 12));
        insert authRetailer;
        
        Asset newAsset = new Asset(Name = 'AAYWPLBP123456', SerialNumber = 'AAYWPLBP123456', Product2Id = newProduct.Id, ContactId = customer.Id, isPOPVerify__c = true, PurchaseDate = Date.newInstance(2016, 03, 16), Purchase_Location__c = 'Groupon');
        insert newAsset;
        
        Asset newAsset2 = new Asset(Name = 'AAYWPLBP123457', SerialNumber = 'AAYWPLBP123457', Product2Id = newProduct.Id, ContactId = customer.Id, isPOPVerify__c = true, PurchaseDate = Date.newInstance(2016, 03, 16), Purchase_Location__c = 'Groupon');
        insert newAsset2;
        
        Case newCase = new Case(AssetId = newAsset.Id, ContactId = customer.Id);
        insert newCase;   
        
        Product_Warranty__c proWarranty= new Product_Warranty__c(AssetId__c = newAsset2.Id, RetailerId__c = retailer.Id, WarrantyLength__c = 30);
        insert proWarranty;
         
        
        PageReference caseAssetInfo  = Page.VizioSupport_CaseAssetInformation;      
         
        Test.setCurrentPage(caseAssetInfo);
        ApexPages.currentPage().getParameters().put('id',newCase.Id); 
        ApexPages.Standardcontroller stdCase = new ApexPages.Standardcontroller(newCase);   
        VizioSupport_CaseAssetInformation testInfo = new VizioSupport_CaseAssetInformation(stdCase);
        
          
    }

    /**
     * method to test the testCaseAsset Pop verify, has PurchaseDate and last return date, warrantylength = 30, location doesn't match, asset doesn't match, sku doesn't match
     *
     * @param           None      
     * @return          None 
     * @since           1.0
     */ 
    static testMethod void testCaseAssetHasPurchaseDate4() { 

        Account newAccount = new Account(Name = 'Testing');
        insert newAccount;
        
        Id contactRecotType = [Select Id From RecordType Where Name = 'Support' AND SobjectType = 'Contact'].get(0).Id;        
        Contact customer = new Contact(LastName = 'Customer', RecordTypeId = contactRecotType, MailingCountryCode = 'US', MailingStateCode = 'CA', AccountId = newAccount.Id);
        insert customer;
        
        Id contactRecotTypeRetailer = [Select Id From RecordType Where Name = 'Retailer' AND SobjectType = 'Contact'].get(0).Id;       
        Contact retailer = new Contact(LastName = 'ServiceP', RecordTypeId = contactRecotTypeRetailer);
        insert retailer;
        
              
        Product2 newProduct = new Product2(Name = 'M60', SKU__c ='12312312312', SKUDesc__c = 'TV');
        insert newProduct;
        
        Authorized_Retailer_for_SKU__c authRetailer = new Authorized_Retailer_for_SKU__c(ProductId__c = newProduct.Id, RetailerId_del__c = retailer.Id, Last_Return_Date__c = Date.newInstance(2016, 03, 12));
        insert authRetailer;
        
        Asset newAsset = new Asset(Name = 'AAYWPLBP123456', SerialNumber = 'AAYWPLBP123456', Product2Id = newProduct.Id, ContactId = customer.Id, isPOPVerify__c = true, PurchaseDate = Date.newInstance(2016, 03, 16), Purchase_Location__c = 'Groupon');
        insert newAsset;
        
        Asset newAsset2 = new Asset(Name = 'AAYWPLBP123457', SerialNumber = 'AAYWPLBP123457', Product2Id = newProduct.Id, ContactId = customer.Id, isPOPVerify__c = true, PurchaseDate = Date.newInstance(2016, 03, 16), Purchase_Location__c = 'Groupon');
        insert newAsset2;
        
        Case newCase = new Case(AssetId = newAsset.Id, ContactId = customer.Id);
        insert newCase;   
        
        Product_Warranty__c proWarranty= new Product_Warranty__c(AssetId__c = newAsset2.Id, RetailerId__c = retailer.Id, WarrantyLength__c = 30);
        insert proWarranty;
         
        
        PageReference caseAssetInfo  = Page.VizioSupport_CaseAssetInformation;      
       
        Test.setCurrentPage(caseAssetInfo);
        ApexPages.currentPage().getParameters().put('id',newCase.Id); 
        ApexPages.Standardcontroller stdCase = new ApexPages.Standardcontroller(newCase);   
        VizioSupport_CaseAssetInformation testInfo = new VizioSupport_CaseAssetInformation(stdCase);
        
          
    }
    
    /**
     * method to test the testCaseAsset Pop verify, has PurchaseDate and last return date, warrantylength = 30, location doesn't match, asset doesn't match, no product
     *
     * @param           None      
     * @return          None 
     * @since           1.0
     */ 
    static testMethod void testCaseAssetHasPurchaseDate5() { 

        Account newAccount = new Account(Name = 'Testing');
        insert newAccount;
        
        Id contactRecotType = [Select Id From RecordType Where Name = 'Support' AND SobjectType = 'Contact'].get(0).Id;        
        Contact customer = new Contact(LastName = 'Customer', RecordTypeId = contactRecotType, MailingCountryCode = 'US', MailingStateCode = 'CA', AccountId = newAccount.Id);
        insert customer;
        
        Id contactRecotTypeRetailer = [Select Id From RecordType Where Name = 'Retailer' AND SobjectType = 'Contact'].get(0).Id;       
        Contact retailer = new Contact(LastName = 'ServiceP', RecordTypeId = contactRecotTypeRetailer);
        insert retailer;
        
               
      
        Authorized_Retailer_for_SKU__c authRetailer = new Authorized_Retailer_for_SKU__c( RetailerId_del__c = retailer.Id, Last_Return_Date__c = Date.newInstance(2016, 03, 12));
        insert authRetailer;
        
        Asset newAsset = new Asset(Name = 'AAYWPLBP123456', SerialNumber = 'AAYWPLBP123456',  ContactId = customer.Id, isPOPVerify__c = true, PurchaseDate = Date.newInstance(2016, 03, 16), Purchase_Location__c = 'Groupon');
        insert newAsset;
        
        Asset newAsset2 = new Asset(Name = 'AAYWPLBP123457', SerialNumber = 'AAYWPLBP123457',  ContactId = customer.Id, isPOPVerify__c = true, PurchaseDate = Date.newInstance(2016, 03, 16), Purchase_Location__c = 'Groupon');
        insert newAsset2;
        
        Case newCase = new Case(AssetId = newAsset.Id, ContactId = customer.Id);
        insert newCase;   
        
        Product_Warranty__c proWarranty= new Product_Warranty__c(AssetId__c = newAsset2.Id, RetailerId__c = retailer.Id, WarrantyLength__c = 30);
        insert proWarranty;
         
        
        PageReference caseAssetInfo  = Page.VizioSupport_CaseAssetInformation;      
         
        Test.setCurrentPage(caseAssetInfo);
        ApexPages.currentPage().getParameters().put('id',newCase.Id); 
        ApexPages.Standardcontroller stdCase = new ApexPages.Standardcontroller(newCase);   
        VizioSupport_CaseAssetInformation testInfo = new VizioSupport_CaseAssetInformation(stdCase);
        
          
    }

}