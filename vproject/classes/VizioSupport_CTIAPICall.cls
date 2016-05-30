/**
 * VizioSupport_CTIAPICall. CTIAPI.
 *
 * @author              Stela Zhang
 * @version             1.0
 * @since               1.0
 */ 
 

public without sharing class VizioSupport_CTIAPICall {
	
	public String phoneNumber {get;set;}
	public String phoneNumberFormat1 {get;set;}
	public List <RecordType> supportContact {get;set;}
	public List <Contact> matchContactList {get;set;}
	
	/**
     * Definition of the constructor.
     * Initial all variables.
     *
     * @param      None
     * @return     None
     * @since      1.0
     */  
	public VizioSupport_CTIAPICall() {
		
		//  Get phonenumber from url
		phoneNumber = ApexPages.currentPage().getParameters().get('Con10');
		
		// If the phonenumber is 10 digits change the format
		if (phoneNumber.length() == 10) {
			phoneNumberFormat1 = '(' + phoneNumber.substring(0,3) + ') ' + phoneNumber.substring(3,6) + '-' + phoneNumber.substring(6,10);
		} else {
			phoneNumberFormat1 = phoneNumber;
		}
		supportContact = new List<RecordType>();
		matchContactList = new List<Contact>();
		
		QueryPhone();
	}
	
	/**
     * The QueryPhone fucntion, query contact object phone and other phone for record type = support 
     *
     * @param                   None
     * @return        PageReference          
     * @since                   1.0
     */ 
	public PageReference QueryPhone() {
		
		PageReference page;
		
		// Get Contact Support  record type Id
	    supportContact = [SELECT Id,Name,SobjectType FROM RecordType WHERE SobjectType ='Contact' AND Name ='Support'];
	    
	    // Query the match contact base on the phone number
	    matchContactList = [SELECT Phone, Name, OtherPhone, MailingStreet, MailingStateCode, MailingPostalCode, MailingCountryCode, MailingCity, 
                                  LastName, Id, FirstName, Email 
                            FROM Contact 
                            WHERE (RecordTypeId =: supportContact[0].Id) 
                             AND((Phone =: phoneNumber)OR (OtherPhone =: phoneNumber) OR (Phone =: phoneNumberFormat1)OR (OtherPhone =: phoneNumberFormat1))
                           ];
       
       // If there's no match create a new customer
       if (matchContactList.isEmpty()) {
       	 	
       	 	page = new PageReference('/apex/VizioSupport_USPSCreateCustomer?Con10='+phoneNumber);
       	 	page.setRedirect(true);
            return page;
        	
       } else if (matchContactList.size() == 1) {
       	
       // If there's only one match, open the contact detail page		
       		page = new ApexPages.StandardController(matchContactList[0]).view();
       		page.setRedirect(true);
            return page;
              	
       } 
       
       // If there are more than 1 match customers show the list of contact, let them select.	
       return null;
       
	}
}