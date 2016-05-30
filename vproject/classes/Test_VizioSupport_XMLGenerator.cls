@isTest(SeeAllData=true)
public class Test_VizioSupport_XMLGenerator{
    static Service_Request__c sr;

    static string resultURL;
      
    static {
        sr = [Select Id from Service_Request__c Where Status__c = 'APPROVED' limit 1];  
    }
        
    @isTest
    static void testXMLGenerator(){
        Test.setMock(HttpCalloutMock.class, new XMLGeneratorHttpResponse());
       
       // VizioSupport_XMLGenerator xmlG = new VizioSupport_XMLGenerator();
        
          VizioSupport_XMLGenerator.GetInformation(sr.Id);
        
        
    }
}

/*
 HTTPResponse res = http.send(req);
                    vErrObj.ErrCode     = res.getStatusCode();
                    vErrObj.ErrStatus   = res.getStatus();
                    vErrObj.ErrBody     = res.getBody();
                    vErrObj.ErrFolder   = filename;
                    return vErrObj;
*/