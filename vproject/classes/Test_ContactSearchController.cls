@isTest(SeeAllData=true)

private class Test_ContactSearchController {

  static Contact con;
  
  static string resultURL;
  
  static {
    con = [Select Id, lastname from contact limit 1];  
  }


  static testMethod void testContactSearchMethod() {
        Test.setMock(HttpCalloutMock.class, new SearchMockHttpResponse());
        ApexPages.StandardController sc = new ApexPages.StandardController(con);
        VizioSupport_USPSCreateController consch = new VizioSupport_USPSCreateController(sc);    
        consch.crtContact();
        String data = consch.search('4166911562');

  }
  
 
  @isTest static void testContactSearch(){
        Test.setMock(HttpCalloutMock.class, new SearchMockHttpResponse());
        ApexPages.StandardController sc = new ApexPages.StandardController(con);       
        Contact c = new Contact();
   
    }

}