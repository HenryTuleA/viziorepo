@isTest(SeeAllData=true)
global class XMLGeneratorHttpResponse implements HttpCallOutMock{
    global HTTPResponse respond (HTTPRequest request){
       
        //System.assertEquals('GET', request.getMethod());
        HttpResponse response = new HttpResponse();
        response.setStatusCode(200);
        response.setBody('OK');
        return response;
    }
}