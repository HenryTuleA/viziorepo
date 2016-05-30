/**
 * Test class to test the class named SerialNumberCheck
 *
 * @author		Xin Zhang
 * @version		1.0
 * @since		1.0
 */
 
@isTest (SeeAllData=false)
private class TestclassSerialNumberCheck {
    
    /**
     * method to test the SerialNumberCheck
     *
     * @param			None	  
     * @return			None
     * @since			1.0
     */
    static testMethod void myTestSerialNumCheck() {  
    	
    	
        Account newAccount = new Account(Name='test');
        insert newAccount;
        
        Product2 newProduct = new Product2(Name='E60', ProductCode='E60' );
        insert newProduct;
             
        Asset newAsset1 = new Asset(Name='LATAPSAQ1300563', Status=null, Product2Id=newProduct.Id, AccountId=newAccount.Id, SerialNumber='LATAPSAQ1300563');
        insert newAsset1;
        Asset newAsset2 = new Asset(Name='LATAPSAQ1300566', Status='Registered', Product2Id=newProduct.Id, AccountId=newAccount.Id, SerialNumber='LATAPSAQ1300566');
        insert newAsset2;
        
    	PageReference testSerialNumCheck = Page.SerialNumberCheck ;
    	
    	Test.setCurrentPage(testSerialNumCheck );           
        SerialNumberCheck SerialNumCheck = new SerialNumberCheck();                             
        SerialNumCheck.submit(); 
        
        
	    
    	Test.setCurrentPage(testSerialNumCheck );  
    	ApexPages.currentPage().getParameters().put('serial-number','LATAPSAQ1300563'); 
    	SerialNumberCheck SerialNumCheckNotFullFilled = new SerialNumberCheck();
    	SerialNumCheckNotFullFilled.submit();
    	
    	Test.setCurrentPage(testSerialNumCheck );  
    	ApexPages.currentPage().getParameters().put('serial-number','LATAPSAQ1300566'); 
    	SerialNumberCheck SerialNumCheckFullFilled = new SerialNumberCheck();
    	SerialNumCheckFullFilled.submit();
    	
    	Test.setCurrentPage(testSerialNumCheck );  
    	ApexPages.currentPage().getParameters().put('serial-number','LATAPSAQ1300565'); 
    	SerialNumberCheck SerialNumCheckNull = new SerialNumberCheck();
    	SerialNumCheckNull.submit();
    	     
    } 
}