public class Vizio_BrainTreeClass{

    //public String ParentIdForRedirect { get; set; }
    
    public String phonenum { get; set; }
    public String firstname { get; set; }
    public String lastname { get; set; }
    public String mailingcity { get; set; }
    public String mailingstate { get; set; }
    public String mailingcountry { get; set; }
    public String mailingaddress { get; set; }
    public String cardholdername { get; set; }
    public String cvv { get; set; }
    public String tempamount { get; set; }
    public String amount { get; set; }
    public String cardnumber { get; set; }
    public String cardexpiremonth { get; set; }
    public String cardexpireyear { get; set; }
    public String cardToken { get; set; }
    public String paymentToken { get; set; }
    public String srid { get; set; }
       
     
  
       
    /**
     * Constructor called on page load, call the method to get the token from server
     *
     * @param         none
     * @return        PageReference      
     * @since         1.0
    **/
    public Vizio_BrainTreeClass(){
        amount = ApexPages.currentPage().getParameters().get('amt'); // hope to use for amount passed to page.
        srid   = ApexPages.currentPage().getParameters().get('srid');
        cardToken = returnToken();
        //cardToken = 'eyJ2ZXJzaW9uIjoyLCJhdXRob3JpemF0aW9uRmluZ2VycHJpbnQiOiJmNTI5NjhlZDlhY2ExYzI0ZTEwNDIwNTE0MTcwYWZjMzIyOTE3OWMzM2IzZjYxNmQ0ZjQxMzMwYjFkNTM1YzFifGNyZWF0ZWRfYXQ9MjAxNi0wNC0wOFQwNjozMjo0MS4zMjA2MDY4NjkrMDAwMFx1MDAyNm1lcmNoYW50X2lkPXk1bjlwODQ0amtwMno0MjZcdTAwMjZwdWJsaWNfa2V5PTl6NXg2d3F2bWozeG5yeXQiLCJjb25maWdVcmwiOiJodHRwczovL2FwaS5zYW5kYm94LmJyYWludHJlZWdhdGV3YXkuY29tOjQ0My9tZXJjaGFudHMveTVuOXA4NDRqa3AyejQyNi9jbGllbnRfYXBpL3YxL2NvbmZpZ3VyYXRpb24iLCJjaGFsbGVuZ2VzIjpbXSwiZW52aXJvbm1lbnQiOiJzYW5kYm94IiwiY2xpZW50QXBpVXJsIjoiaHR0cHM6Ly9hcGkuc2FuZGJveC5icmFpbnRyZWVnYXRld2F5LmNvbTo0NDMvbWVyY2hhbnRzL3k1bjlwODQ0amtwMno0MjYvY2xpZW50X2FwaSIsImFzc2V0c1VybCI6Imh0dHBzOi8vYXNzZXRzLmJyYWludHJlZWdhdGV3YXkuY29tIiwiYXV0aFVybCI6Imh0dHBzOi8vYXV0aC52ZW5tby5zYW5kYm94LmJyYWludHJlZWdhdGV3YXkuY29tIiwiYW5hbHl0aWNzIjp7InVybCI6Imh0dHBzOi8vY2xpZW50LWFuYWx5dGljcy5zYW5kYm94LmJyYWludHJlZWdhdGV3YXkuY29tL3k1bjlwODQ0amtwMno0MjYifSwidGhyZWVEU2VjdXJlRW5hYmxlZCI6dHJ1ZSwicGF5cGFsRW5hYmxlZCI6dHJ1ZSwicGF5cGFsIjp7ImRpc3BsYXlOYW1lIjoiSGFycnkgWHVlIiwiY2xpZW50SWQiOm51bGwsInByaXZhY3lVcmwiOiJodHRwOi8vZXhhbXBsZS5jb20vcHAiLCJ1c2VyQWdyZWVtZW50VXJsIjoiaHR0cDovL2V4YW1wbGUuY29tL3RvcyIsImJhc2VVcmwiOiJodHRwczovL2Fzc2V0cy5icmFpbnRyZWVnYXRld2F5LmNvbSIsImFzc2V0c1VybCI6Imh0dHBzOi8vY2hlY2tvdXQucGF5cGFsLmNvbSIsImRpcmVjdEJhc2VVcmwiOm51bGwsImFsbG93SHR0cCI6dHJ1ZSwiZW52aXJvbm1lbnROb05ldHdvcmsiOnRydWUsImVudmlyb25tZW50Ijoib2ZmbGluZSIsInVudmV0dGVkTWVyY2hhbnQiOmZhbHNlLCJicmFpbnRyZWVDbGllbnRJZCI6Im1hc3RlcmNsaWVudDMiLCJiaWxsaW5nQWdyZWVtZW50c0VuYWJsZWQiOmZhbHNlLCJtZXJjaGFudEFjY291bnRJZCI6InkzamY4NzRuc3F4Y2RmOGQiLCJjdXJyZW5jeUlzb0NvZGUiOiJVU0QifSwiY29pbmJhc2VFbmFibGVkIjpmYWxzZSwibWVyY2hhbnRJZCI6Ink1bjlwODQ0amtwMno0MjYiLCJ2ZW5tbyI6Im9mZiJ9';
        // to validate that a token is returned message on page
      //  ApexPages.addMessage(new ApexPages.message(ApexPages.severity.INFO,'Loading page!!' + cardToken));
            
    }
    
    public PageReference backtoCase() {
        String myFaram1 = ApexPages.currentPage().getParameters().get('myFaram1');
        String myFaram2 = ApexPages.currentPage().getParameters().get('myFaram2');
        
        
        System.debug(' myFaram1=  ' + myFaram1 + '   myFaram2  = ' + myFaram2);
        ApexPages.addMessage(new ApexPages.message(ApexPages.severity.INFO, myFaram1 + ' === '+ myFaram2 ));
        sendNonceTokenToServer(myFaram1, myFaram2);
        List<Service_Request__c> SR1 = [Select Id,Name From Service_Request__c Where Name=:myFaram2];
        String appID = SR1[0].Id;
        PageReference pageRef = new PageReference('/'+ appID);
        pageRef.setRedirect(false);
        return pageRef;    
        //return null;
    }

   /**
     * Method called from the callback of BrainTree.Setup after the Pay button is clicked. 
     *
     * @param         none
     * @return        PageReference      
     * @since         1.0
    **/ 
     public PageReference sendNonceToken() {
    
        String myNonce   = ApexPages.currentPage().getParameters().get('myNonce');
        String myOrderId = ApexPages.currentPage().getParameters().get('myOrderId');
        
        ApexPages.addMessage(new ApexPages.message(ApexPages.severity.INFO, myNonce + ' === '+ myOrderId ));
        
        sendNonceTokenToServer(myNonce, myOrderId);
        
        List<Service_Request__c> SR1 = [Select Id,Name From Service_Request__c Where Name=:myOrderId];
        String appID = SR1[0].Id;
        PageReference pageRef = new PageReference('/'+ appID);
        pageRef.setRedirect(false);
        return pageRef;    
        
    }
    
    
   /**
     * Method to call the Vizio Server with the Nonce, Amount and OrderId, 
     * **NOTE: Method is not full functional.
     * @param         nonce, orderId, [Amount]*
     * @return        Transaction Id*      
     * @since         1.0
    **/ 
 
    public string sendNonceTokenToServer(String nonc ,String srid ){
            
         // GenerateClientToken test script
            String uname = '';
            String token = '';
            String nonce = nonc ; 
            String amount = '200.00';
            String order = srid; 
            String js =  '{"nonce" : "' + nonce + '", "amount": ' + amount + ', "order":"' + order + '"}';
            system.debug(js);
            
           // ApexPages.addMessage(new ApexPages.message(ApexPages.severity.INFO, 'nonce=>  ' + nonce + ' === !  order=  '+ order));
            
            HttpRequest req = new HttpRequest();
            req.setEndpoint('https://partnerapitest.vizio.com/Service/Payment.svc/Authorize');
            req.setMethod('POST');
            req.setHeader('Content-Type', 'application/json');
            req.setHeader('Content-Length', '0');
            req.setBody( js);
            Blob headerValue = Blob.valueOf( uname+ ':' + token); 
            String authorizationHeader = 'BASIC ' +
            EncodingUtil.base64Encode(headerValue);
            req.setHeader('Authorization', authorizationHeader);
            
             
            Http http = new Http();
            HTTPResponse res = http.send(req);
            
            String jsonString = res.getBody();
            System.debug(jsonString);
            System.JSON j = new System.JSON();
            PaymentResponse r = (PaymentResponse)JSON.deserialize(jsonString, PaymentResponse.class);
            
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.INFO,String.ValueOf(r.d)));
            
            return null;  
            
    }
    
   /**
     * Method to call the Vizio Server to get the Token from the server
     *
     * @param         none
     * @return        String with Token from Vizio Server      
     * @since         1.0
    **/ 
 
    public string returnToken(){
         // GenerateClientToken script
            String uname = '';
            String token = '';
            
            HttpRequest req = new HttpRequest();
            req.setEndpoint('https://partnerapitest.vizio.com/Service/Payment.svc/GenerateClientToken');
            req.setMethod('POST');
            req.setHeader('Content-Type', 'application/json');
            req.setHeader('Content-Length', '0');
            
            Blob headerValue = Blob.valueOf(uname + ':' + token);
            String authorizationHeader = 'BASIC ' +
            EncodingUtil.base64Encode(headerValue);
            req.setHeader('Authorization', authorizationHeader);
            
            Http http = new Http();
            HTTPResponse res = http.send(req);
            
            String jsonString = res.getBody();
            System.debug(jsonString);
            System.JSON j = new System.JSON();
            PaymentResponse r = (PaymentResponse)JSON.deserialize(jsonString, PaymentResponse.class);
            return r.d.Token;  
    }


}