/**
 * VizioSupport_USPSEditController. EditContact.
 *
 * @author              Stela Zhang
 * @version             1.0
 * @since               1.0
 */ 
 
public without sharing class VizioSupport_USPSEditController {

    // When this is set, it will trigger the lookup on the address to the USPS
    public string uspsUserIDCode {get; set;}

    public Boolean hasMatch {get;set;} // if there's any match contact
    public final Contact CurrentContact {get; set;} // get from standardController
    public Contact contactMoreInfo {get;set;} // do query get more standard and custom fields from contact
    public transient List<Contact> matchContactList {get;set;} // list of match contacts
    public String open {get;set;}
    public String caseID {get;set;}
    	
    
    /**
     * Definition of the constructor.
     * Initial all variables.
     *
     * @param      None
     * @return     None
     * @since      1.0
     */  
    public VizioSupport_USPSEditController (ApexPages.StandardController stdController) {
        
        hasMatch = false;
        matchContactList = new List<Contact>();
        USPSUserIDCode = '';
        this.CurrentContact = (Contact)stdController.getRecord();
    
        contactMoreInfo = [Select Name, Phone, OtherPhone, MailingStreet, MailingStateCode, MailingPostalCode, MailingCountryCode, MailingCity, 
                                  LastName, Id, FirstName, Fax, Email, Customer_Type__c,Extension__c 
                           From Contact 
                           Where Id =:  CurrentContact.Id];
        
    
         open = ApexPages.currentPage().getParameters().get('Open');
         caseID = ApexPages.currentPage().getParameters().get('CaseID');
         
         
    } // constructor 
    
  
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
            // w\Without an address, the component won't actually do anything
            if (contactMoreInfo.MailingStreet != '' && contactMoreInfo.MailingStreet != null) {               
                if ((contactMoreInfo.MailingPostalCode != '') || ((contactMoreInfo.MailingCity != '') && (contactMoreInfo.MailingStateCode != '')))  {
                    
                    //USPSUserIDCode  = '<<<<<< INSERT YOUR ID HERE >>>>>>';
                    //uspsUserIDCode  = '240UCINN1790';
                    uspsUserIDCode = USPS_User__c.getValues('USPSUserIDCode').UserId__c;
                    //return null;            
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
    public PageReference Save() {
    	
    	// Check if there's any match contact exist
    	// Name is different and (address or email or phone or otherphone are the same) 
    	List <RecordType> supportContact = new List<RecordType>();
        supportContact = [SELECT Id,Name,SobjectType FROM RecordType where SobjectType ='Contact' AND Name ='Support'];
        
    	matchContactList = [Select Phone, Name, OtherPhone, MailingStreet, MailingStateCode, MailingPostalCode, MailingCountryCode, MailingCity, 
                                  LastName, Id, FirstName, Email 
                           From Contact 
                           Where (RecordTypeId =: supportContact[0].Id) AND((Name <>: contactMoreInfo.Name) 
                            AND (((MailingStreet<> NULL AND MailingStreet =: contactMoreInfo.MailingStreet) AND (MailingCity<>NULL AND MailingCity =:contactMoreInfo.MailingCity) AND (MailingStateCode<> NULL AND MailingStateCode =: contactMoreInfo.MailingStateCode))
                                 OR (Phone<> null AND (Phone =: contactMoreInfo.Phone OR Phone =: contactMoreInfo.OtherPhone))
                                 OR (Email<> null AND Email =: contactMoreInfo.Email)
                                 OR (OtherPhone<> null AND (OtherPhone =: contactMoreInfo.OtherPhone OR OtherPhone =: contactMoreInfo.Phone))))
                            ];
        
        // If there's match show match list and error message
        if (matchContactList.isEmpty()) {
        	update contactMoreInfo;
        } else {
        	hasMatch = true;
        	ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Cannot update to duplicate information. Please enter other values'));
        	return null;
        }
        
        // It might open from 2 places, so we want to return to the previous page.
        pageReference page;
    	if (open == 'CreateSR') {
    		page = new PageReference('/apex/VizioSupport_CreateServiceRequest?CaseID='+ caseId);
    	} else {
        	page = new ApexPages.StandardController(contactMoreInfo).view(); 
    	}
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
    	pageReference page;
    	if (open == 'CreateSR') {
    		page = new PageReference('/apex/VizioSupport_CreateServiceRequest?CaseID='+ caseId);
    	} else {
        	page = new ApexPages.StandardController(contactMoreInfo).view(); 
    	}
        page.setRedirect(true);
        return page;
    }
    
} // end class USPSTest