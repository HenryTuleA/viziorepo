@isTest(SeeAllData=true)
global class SearchMockHttpResponse implements HttpCallOutMock{
    global HTTPResponse respond (HTTPRequest request){
     //   string resbody = '{"listings":[ { "people":[ { "firstname":"Bobby", "lastname":"Boblast", "middlename":"T", "age_range":"40-44", "rank":"primary" }, { "firstname":"Kelly", "lastname":"LastKelly", "middlename":"C", "age_range":"40-44", "rank":"secondary" } ], { "phonenumbers":[ { "fullphone":"(416) 691-1562", "areacode":"416", "exchange":"691", "linenumber":"1562", "rank":"primary", "do_not_call":"false", "carrier":"Bell Canada", "reputation":{ "spamscore":2 }, "type":"landline", "zip_code":"unknown", "contact_creation_date":"unknown" } ], "address":{ "city":"Toronto", "state":"ON", "zip":"M9N 2Y9", "country":"CA", "deliverable":"false", "contact_creation_date":"unknown", "receiving_mail":"false", "not_receiving_mail_reason":"other", "type":"unknown" }, "geodata":{ "latitude":"43.7061", "longitude":"-79.5152", "geoprecision":"3" }, "listingmeta":{ "type":"unknown" } } ], "meta":{ "recordrange":{ "firstrecord":"1", "lastrecord":"1", "totalavailable":1 }, "apiversion":"1.0", "searchlinks":{ "self":{ "linktext":"Link to this api call", "url":"http://proapi.whitepages.com/reverse_phone/1.0?outputtype=json&api_key=86453bd784ec9750718a00d22a001c52&phone_number=4166911562&" } } }, "result":{ "type":"success", "code":"Found Data", "message":" ", "billable":"false" } }';
       
   string resbody =      
       '{"listings":[{"phonenumbers":[{"fullphone":"(416) 691-1562","areacode":"416","exchange":"691","linenumber":"1562","rank":"primary","do_not_call":"false",'+
       '"carrier":"Bell Canada","reputation":{"spamscore":2},"type":"landline","zip_code":"unknown","contact_creation_date":"unknown"}],"address":{"city":"Toronto","state":"ON",'+
       '"zip":"M9N 2Y9","country":"CA","deliverable":"false","contact_creation_date":"unknown","receiving_mail":"false","not_receiving_mail_reason":"other",'+
       '"type":"unknown"},"geodata":{"latitude":"43.7061","longitude":"-79.5152","geoprecision":"3"},"listingmeta":{"type":"unknown"}}],'+
       '"meta":{"recordrange":{"firstrecord":"1","lastrecord":"1", "totalavailable":1},"apiversion":"1.0","searchlinks":{"self":{"linktext":"Link to this api call",'+
       '"url":"http://proapi.whitepages.com/reverse_phone/1.0?outputtype=json&api_key=86453bd784ec9750718a00d22a001c52&phone_number=4166911562"}}},"result":{"type":"success","code":"Found Data","message":" ", "billable":"false"}}';
       
       // System.assertEquals('http://proapi.whitepages.com/reverse_phone/1.0?outputtype=json&api_key=86453bd784ec9750718a00d22a001c52&phone_number=null&', request.getEndpoint());
        System.assertEquals('GET', request.getMethod());

        HttpResponse response = new HttpResponse();
        response.setHeader('Content-Type', '');
        response.setStatusCode(200);
        response.setBody(resbody);
        return response;
    }
}