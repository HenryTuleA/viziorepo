@isTest(SeeAllData=true)
global class MakeMockHttpResponse implements HttpCallOutMock{
    global HTTPResponse respond (HTTPRequest request){

        System.assertEquals('http://cookie.jsontest.com/', request.getEndpoint());
        System.assertEquals('GET', request.getMethod());

        HttpResponse response = new HttpResponse();
        response.setHeader('Content-Type', '');
        response.setStatusCode(204);
        return response;
    }
}