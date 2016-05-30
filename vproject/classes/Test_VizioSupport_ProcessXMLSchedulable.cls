@isTest(SeeAllData=true)
public class Test_VizioSupport_ProcessXMLSchedulable{
   static testMethod void testSchedule(){
      Test.startTest();
          Test.setMock(HttpCalloutMock.class, new MakeMockHttpResponse());
        
          System.schedule('Test Apex Schedule', '0 0 0 1 1 ? *', new VizioSupport_ProcessXMLSchedulableClass());
      Test.stopTest();
  
  }
}