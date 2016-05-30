public class Vizio_ContactSearch{ 
     // public String URLString = 'http://proapi.whitepages.com/reverse_phone/1.0?outputtype=json&phone_number=9496487690&api_key=86453bd784ec9750718a00d22a001c52&';
     
      public string phonenum {get;set;}
      public String firstname = '';
      public String lastname = '';
      public String fulladdress = '';
      public String city = '';
      public String state = '';
      public String zip = '';
      public String objfname, objlname, objcity, objstr, objzip, objstate, objphone, objrectypeId;
      public PageReference parseData ;
      public WhitePagesSearch__c   wp ;
      public Contact contactMoreInfo {get;set;}
      public PageReference pageT;
              
    private ApexPages.StandardController standardController;
 
    
    public Vizio_ContactSearch(ApexPages.StandardController standardController)
    {
        this.standardController = standardController;
        phonenum = ApexPages.currentPage().getParameters().get('Con10');
        crtContact();
        
    }
    public PageReference crtContact(){
            
            contactMoreInfo = new Contact();
            
            wp = WhitePagesSearch__c.getInstance('whitepagesfield');   
            
            String jsonstring = search(phonenum);  // call the search method  and return a strings
            
            if(jsonstring != null){
                // parse the json string to get the details from the string
                parseData =  parseContactT(jsonstring, phonenum);
                return parseData;
            }
           
            parseData = Page.VizioSupport_USPSCreateCustomer;
            parseData.setRedirect(true);
            return parseData;
    }

   public PageReference parseContactT(String jstring, string fullphone){
   
        try{    
                //deserialize the json string to map
                Map<String, Object> m =  (Map<String, Object>)JSON.deserializeUntyped(jstring);  
                contactMoreInfo = new Contact();
                
                List<Object> alistObj = (List<Object>)m.get('listings');
                
                for(Object childalistObj : alistObj){ 
                    Map<String, Object> grandChildMap = (Map<String, Object>)childalistObj;    //map of string and object list
                    if(grandChildMap != null){
                    
                        //get the child elements of address
                        Map<String, Object> gGrandChildMap = (Map<String, Object>)grandChildMap.get('address');
                        if(gGrandChildMap != null){
                           city = (String)gGrandChildMap.get('city');  
                           zip = (String)gGrandChildMap.get('zip');  
                           state = (String)gGrandChildMap.get('state');            
                           fulladdress = (String)gGrandChildMap.get('fullstreet');            
                           //break;
                        }
                        
                        //get the child element of phone numbers
                        List<Object> listgGrandChild = (List<Object>)grandChildMap.get('phonenumbers');
                        
                        if(listgGrandChild!= null){
                           
                            for(Object ph: listgGrandChild){
                                Map<String, Object> phonenumbers = (Map<String, Object>) ph;
                                if(phonenumbers.get('rank') == 'primary'){
                                    fullphone = (String)phonenumbers.get('fullphone');
                                    break;
                                } 
                            }
                            
                        }
                        
                        //get the child elements of People
                        List<Object> listgGrandChildPeople = (List<Object>)grandChildMap.get('people');
                        
                        if(listgGrandChildPeople!=null){
                            for(Object ph: listgGrandChildPeople){
                                Map<String, Object> people = (Map<String, Object>)ph;
                                if(people.get('rank') == 'primary'){
                                    
                                    firstname =(String)people.get('firstname');
                                    lastname = (String)people.get('lastname');
                                    break;
                                }                    
                            }
                        }
                    }
                    break;
                }
                //don't set the value of the fields if the last name is empty
                if(lastname =='' || lastname==null ){
                    firstname = '';
                    fulladdress = '';
                    city = '';
                    state = '';
                    zip = '';
                }
                //don't set the address fields if full address is empty
                if(fulladdress == ''|| fulladdress== null){
                    city = '';
                    state = '';
                    zip = '';
                    fulladdress = '';
                }
                /*    No longer needed, used for defaulting the values of the fields.
                String detail;
                objfname = wp.firstname__c;
                objlname = wp.lastname__c;
                objstr   = wp.street__c;
                objcity  = wp.city__c;
                objzip   = wp.zip__c;
                objstate = wp.state__c;
                objphone = wp.phone__c;
                objrectypeId  = wp.recordtype__c;
                
                detail = objfname+'='+firstname+'&';
                detail = detail + objlname+'='+lastname+'&';
                detail = detail + objstr+'='+fulladdress+'&';
                detail = detail + objcity+'='+city+'&';
                detail = detail + objstate+'='+state+'&';
                detail = detail + objzip+'='+zip+'&';
                detail = detail + objphone+'='+fullphone+'&';
                detail = detail + 'RecordType='+objrectypeId;
                */
                
                //set the values of the contact object fields
                contactMoreInfo.FirstName         =    firstname;
                contactMoreInfo.Lastname          =    lastname;
                contactMoreInfo.MailingStreet     =    fulladdress;
                contactMoreInfo.Mailingcity       =    city;
                contactMoreInfo.Mailingstate      =    state;
                contactMoreInfo.MailingPostalCode =    zip;
                
                pageT = new ApexPages.StandardController(contactMoreInfo).view(); 
                pageT.setRedirect(true);
                return pageT;
                
            } catch(System.Exception e) {
                //system.debug('MYDEBUG: AWS Service Callout Exception on ERROR: ' + e.getMessage());
                PageReference acctPage = new PageReference('/003');
                return acctPage;
            
            }
     } 
 
     // method to call the whitepages api and searh for phone number details
     public string search(String phonenumber){
        String URLString = wp.apiurl__c +phonenumber+'&';
     
        HttpRequest req = new HttpRequest();
        Http http = new Http();
        req.setHeader('Content-Type', '');
        req.setMethod('GET');
        req.setEndpoint(URLString);   
        try{
            HTTPResponse res = http.send(req);
            string resbody = res.getBody();
            return resbody;
            
        } catch(System.CalloutException e) {
            //system.debug('MYDEBUG: AWS Service Callout Exception on ERROR: ' + e.getMessage());
            return null;
        
        }
    }
}

/*
    
    public PageReference parseContact(String jstring, string fullphone){
        try{
                Map<String, Object> m =  (Map<String, Object>)JSON.deserializeUntyped(jstring);  
                //System.debug('MYDEBUG:mappM '  + m);
                List<Object> a = (List<Object>)m.get('listings');
                
//                System.debug('MYDEBUG:lista**a.SIZE '  + a.size());
                //System.debug('MYDEBUG:lista2 '  + a2);
                for(Object b : a){ 
//                    System.debug('FOR LOOP: '  + b);
        
                    Map<String, Object> a2 = (Map<String, Object>)b;
                    if(a2 != null){
                        Map<String, Object> a3 = (Map<String, Object>)a2.get('address');
                        if(a3 != null){
                           city = (String)a3.get('city');  
                           zip = (String)a3.get('zip');  
                           state = (String)a3.get('state');            
                           fulladdress = (String)a3.get('fullstreet');            
                           //break;
                        }
                        //System.debug('***********MYDEBUG:phonenumbers:=>************');
                        List<Object> a4 = (List<Object>)a2.get('phonenumbers');
                        //System.debug('MYDEBUG:phonenumbers:::> '  + a4);
                        if(a4!= null){
                           //System.debug('***********for loop:phonenumbers:=>************');
                            for(Object ph: a4){
                                //System.debug('***********INSIDE FOR LOOP:phonenumbers:=>************');
                                Map<String, Object> phonenumbers = (Map<String, Object>) ph;
                               // System.debug('MYDEBUG:rank:=:> '  + phonenumbers.get('rank'));
                                if(phonenumbers.get('rank') == 'primary'){
                                    fullphone = (String)phonenumbers.get('fullphone');
                                    break;
                                } 
                            }
                            //System.debug('***********end for loop:phonenumbers:=>************');
                            
                        }
                        //System.debug('***********MYDEBUG:people::=>************');
                        List<Object> a5 = (List<Object>)a2.get('people');
                        //System.debug('MYDEBUG:people::=>'  + a5);
                        if(a5!=null){
                            for(Object ph: a5){
                                Map<String, Object> people = (Map<String, Object>)ph;
                                if(people.get('rank') == 'primary'){
                                    //System.debug('MYDEBUG:people '  + people);
                                    firstname =(String)people.get('firstname');
                                    lastname = (String)people.get('lastname');
                                    break;
                                }                    
                            }
                        }
                    }
                    break;
                }
         
                if(lastname =='' || lastname==null ){
                    firstname = '';
                    fulladdress = '';
                    city = '';
                    state = '';
                    zip = '';
                }
                if(fulladdress == ''|| fulladdress== null){
                    city = '';
                    state = '';
                    zip = '';
                    fulladdress = '';
                }
                
                String detail;
                objfname = wp.firstname__c;
                objlname = wp.lastname__c;
                objstr   = wp.street__c;
                objcity  = wp.city__c;
                objzip   = wp.zip__c;
                objstate = wp.state__c;
                objphone = wp.phone__c;
                objrectypeId  = wp.recordtype__c;
                
                detail = objfname+'='+firstname+'&';
                detail = detail + objlname+'='+lastname+'&';
                detail = detail + objstr+'='+fulladdress+'&';
                detail = detail + objcity+'='+city+'&';
                detail = detail + objstate+'='+state+'&';
                detail = detail + objzip+'='+zip+'&';
                detail = detail + objphone+'='+fullphone+'&';
                detail = detail + 'RecordType='+objrectypeId;
               
                
                PageReference page = new PageReference('/003/e?'+detail+'&retURL=/003/');
                
                page.setRedirect(true);
                return page;
            } catch(System.Exception e) {
                system.debug('MYDEBUG: AWS Service Callout Exception on ERROR: ' + e.getMessage());
                PageReference acctPage = new PageReference('/003');
                return acctPage;
            
            }
 } 
 */