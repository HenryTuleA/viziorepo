/**
 * VizioSupport_USPSCreateController. Create Contact.
 *
 * @author              Stela Zhang
 * @version             1.0
 * @since               1.0
 */ 
 
public without sharing class VizioSupport_USPSCreateController {

    // When this is set, it will trigger the lookup on the address to the USPS
    public string uspsUserIDCode {get; set;}

    public Boolean hasMatch {get;set;} // if there's any match contact
   
    public Contact contactMoreInfo {get;set;} // do query get more standard and custom fields from contact
    public transient List<Contact> matchContactList {get;set;} // list of match contacts
    public String phoneNumber {get;set;}
    public transient List<Contact> retailerList {get;set;}
    public String retailerId{get;set;}
     
   
    public string phonenum {get;set;}
    public String firstname = '';
    public String lastname = '';
    public String fulladdress = '';
    public String city = '';
    public String state = '';
    public String zip = '';
    public String country = '';
    // public String objfname, objlname, objcity, objstr, objzip, objstate, objphone, objrectypeId;
    public PageReference parseData ;
    public WhitePagesSearch__c   wp ;
    // ublic Contact contactMoreInfo {get;set;}
    public PageReference pageT;

    
    /**
     * Definition of the constructor.
     * Initial all variables.
     *
     * @param      None
     * @return     None
     * @since      1.0
     */  
    public VizioSupport_USPSCreateController (ApexPages.StandardController stdController) {
        
        phoneNumber = ApexPages.currentPage().getParameters().get('Con10');
        hasMatch = false;
        matchContactList = new List<Contact>();
        retailerList = new List<Contact>();
        uspsUserIDCode = '';
        retailerId ='';
        contactMoreInfo = new Contact();
        crtContact();
      
    } 
    
    /**
     * The validate button, validate the address by USPS API
     *
     * @param                   None
     * @return        PageReference          
     * @since                   1.0
     */ 
    public pagereference validate() {
        hasMatch = false;
        
        // If the address validation hasn't been triggered, trigger it here
        if (uspsUserIDCode == '') {

            // Confirm you have an address before setting the code
            // Without an address, the component won't actually do anything
            if (contactMoreInfo.MailingStreet != '' && contactMoreInfo.MailingStreet != null) {               
                if ((contactMoreInfo.MailingPostalCode != '') || ((contactMoreInfo.MailingCity != '') && (contactMoreInfo.MailingStateCode != '')))  {
                    
                    //USPSUserIDCode  = '<<<<<< INSERT YOUR ID HERE >>>>>>';
                    //uspsUserIDCode  = '240UCINN1790';
                    uspsUserIDCode = USPS_User__c.getValues('USPSUserIDCode').UserId__c;
                  //  return null;            
                }                                  
            }            
        } 
        return null;
                        
    } // validate
    
    /**
     * The Save button, Save the update of the customer information (maybe have duplicate value)
     *
     * @param                   None
     * @return        PageReference          
     * @since                   1.0 
     */ 
    public PageReference save() {
        
        // Check if there's any match contact exist
        // Name is different and (address or email or phone or otherphone are the same) 
        List <RecordType> supportContact = new List<RecordType>();
        supportContact = [SELECT Id,Name,SobjectType FROM RecordType where SobjectType ='Contact' AND Name ='Support'];
        
        if (!supportContact.isEmpty()) {
            contactMoreInfo.RecordTypeId = supportContact[0].Id;
        }
        
        if (phoneNumber != null ) {
            if (phoneNumber.length() == 10) {
                phoneNumber = '(' + phoneNumber.substring(0,3) + ') ' + phoneNumber.substring(3,6) + '-' + phoneNumber.substring(6,10);
            }
        }
        contactMoreInfo.Phone = phoneNumber;
        matchContactList = [Select Phone, Name, OtherPhone, MailingStreet, MailingStateCode, MailingPostalCode, MailingCountryCode, MailingCity, 
                                  LastName, Id, FirstName, Email 
                           From Contact 
                           Where RecordTypeId =: supportContact[0].Id 
                              AND (((FirstName<> NULL AND FirstName =: contactMoreInfo.FirstName AND LastName<> NULL AND LastName =: contactMoreInfo.LastName)
                              OR ((MailingStreet<> NULL AND MailingStreet =: contactMoreInfo.MailingStreet) AND (MailingCity<>NULL AND MailingCity =:contactMoreInfo.MailingCity) AND (MailingStateCode<> NULL AND MailingStateCode =: contactMoreInfo.MailingStateCode))
                              OR (Phone<> null AND (Phone =: contactMoreInfo.Phone OR Phone =: contactMoreInfo.OtherPhone))
                              OR (Email<> null AND Email =: contactMoreInfo.Email)
                              OR (OtherPhone<> null AND (OtherPhone =: contactMoreInfo.OtherPhone OR OtherPhone =: contactMoreInfo.Phone))))
                            ];

        // If there's match show match contacts list. If not create one
        if (matchContactList.isEmpty()) {
            insert contactMoreInfo;
        } else {
            hasMatch = true;
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Cannot create duplicate customer. Choose an existing customer or change the entered information.'));
            return null;
        }
        PageReference page = new ApexPages.StandardController(contactMoreInfo).view(); 
        page.setRedirect(true);
        return page;
    }
    
    /**
     * The Cancle button, return the contact detail page
     *
     * @param                   None
     * @return        PageReference          
     * @since                   1.0
     */ 
    public PageReference Cancel() {
        PageReference page ;
        page = new PageReference('/');
          
        page.setRedirect(true);
        return page;
    }
    
    /**
     * The find retailer id
     *
     * @param                   None
     * @return        PageReference          
     * @since                   1.0
     */ 
    public PageReference FindRetail() {
        system.debug(contactMoreInfo.Retailer__c);      
        retailerList = [Select Id, Account.Voogle_RetailerID__c From Contact Where Id =: contactMoreInfo.Retailer__c];
        if(!retailerList.isEmpty()) {
            retailerId = retailerList[0].Account.Voogle_RetailerID__c;
        }
        return null;
    }
    
    
     /**
     * The crtContact called when the page is loaded
     *
     * @param                   None
     * @return        PageReference          
     * @since                   1.0
     */ 
    public void crtContact() {
            
        contactMoreInfo = new Contact();
            
        wp = WhitePagesSearch__c.getInstance('whitepagesfield');   
        String jsonstring = search(phoneNumber);
        system.debug(jsonstring);    
        if (jsonstring != null) {               
             parseContact(jsonstring, phonenum);
        }                  
        ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.Warning, 'phonenum => '+ phonenum);                     
    }
    
    
    /**
     *  The parseContact method deserializes the json string,
     *
     * @param                   phoneNumber
     * @return        pageReference          
     * @since                   1.0
     */ 
    
     public PageReference parseContact(String jstring, string fullphone){
   
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
               
                
                //set the values of the contact object fields
                contactMoreInfo.FirstName         =    firstname;
                contactMoreInfo.Lastname          =    lastname;
                contactMoreInfo.MailingStreet     =    fulladdress;
                contactMoreInfo.Mailingcity       =    city;
                contactMoreInfo.Mailingstate      =    state;
                contactMoreInfo.MailingPostalCode =    zip;
                
                //return contact page reference with the values filled in.
                pageT = new ApexPages.StandardController(contactMoreInfo).view(); 
                pageT.setRedirect(true);
                return pageT;
                
            } catch(System.Exception e) {
                //return contact page reference with no values
                PageReference acctPage = new PageReference('/003');
                return acctPage;
            
            }
     } 
 
      /**
     * The search function, callout whitepage
     *
     * @param                   phonenumber
     * @return                  json string          
     * @since                   1.0
     */ 
    
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
             ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.Warning, e.getMessage());
             return null;        
        }
    }  
   
}