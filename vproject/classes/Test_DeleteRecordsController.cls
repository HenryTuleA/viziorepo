@isTest(SeeAllData=true)

private class Test_DeleteRecordsController {

  static Document__c document;
  static List<Document__c> documents = new List<Document__c>();
  
  static Case cas;
  
  static {
    cas = [Select Id, casenumber from case limit 1];   
    document = new Document__c();
    document.Document_URL__c = 'https://testing.s3.amazon.com/';
    document.Case__c = cas.Id;
    document.Document_Name__c = 'my_document';
    document.Name = 'My Document';
    insert document;   
    documents.add(document);
  }


  static testMethod void testVizioSupport_DeleteRecordController() {
    Test.setMock(HttpCalloutMock.class, new MakeMockHttpResponse());
    ApexPages.StandardController sc = new ApexPages.StandardController(document);
    VizioSupport_DeleteRecordsController con = new VizioSupport_DeleteRecordsController(sc);    
    con.doDeleteDocument();
  }
  
  
  static testMethod void testVizioSupport_DeleteListController() {
    Test.setMock(HttpCalloutMock.class, new MakeMockHttpResponse());
    ApexPages.StandardSetController sc = new ApexPages.StandardSetController(documents);
    VizioSupport_DeleteRecordsController con = new VizioSupport_DeleteRecordsController(sc);    
    con.doDeleteListDocuments();
    
  }
  
    
    @isTest static void testCallout(){
        Test.setMock(HttpCalloutMock.class, new MakeMockHttpResponse());
        VizioSupport_AWSIntegration x = new VizioSupport_AWSIntegration();
        Integer y = x.deleteFromS3('Previous+statementsMAY+2011.pdf','500/500A0000000ztBE/Previous+statementsMAY+2011.pdf');
  
    }
    
}