/**
 * SafetyNotice. Create a new case if the serial number is not fullfilled.
 *
 * @author              Xin Zhang
 * @version             1.0
 * @since               1.0
 */ 

public without sharing class SafetyNotice {
	
	public Case webToCase {get;set;}	
	public Contact caseContact {get;set;}
	public List<Asset> assetList {get;set;}
	public List<Contact> contactList {get;set;}
	public List<Product2> productList {get;set;}
	public List<RecordType> caseRecordType {get;set;}
	public List<RecordType> contactRecordType {get;set;}
	public String  selectLanguage{get;set;} 
	public String  serialNumber {get;set;}
	public Boolean selecten_US {get;set;}
	public Boolean selecten_CA {get;set;}
	public Boolean selectfr_CA {get;set;}
	public Boolean selectes_MX {get;set;}
	public Database.DMLOptions dmlOpts {get;set;}
	
	public String firstName {get;set;}
	public String lastName {get;set;}
	public String phone {get;set;}
	public String email {get;set;}
	public String address {get;set;}
	public String address2 {get;set;}
	public String city {get;set;}
	public String state {get;set;}
	public String zip {get;set;}
	
	/**
     * Definition of the constructor.
     * Initial all variables.
     *
     * @param      None
     * @return     None
     * @since      1.0
     */  
	public SafetyNotice() {
        
		selectLanguage = ApexPages.currentPage().getParameters().get('language');
		serialNumber = ApexPages.currentPage().getParameters().get('serial');
		
		selecten_US = false;
	    selecten_CA = false;
	    selectfr_CA = false;
	    selectes_MX = false;
	    
		/* Set the language */
		if (selectLanguage == 'en_us' || selectLanguage == 'en_US') {
 			selectLanguage = 'en_US';
 			selecten_US = true;
 		} else if (selectLanguage == 'en_ca' || selectLanguage == 'en_CA') {
 			selectLanguage = 'en_CA';
 			selecten_CA = true;
 		} else if (selectLanguage == 'fr_ca' || selectLanguage == 'fr_CA') {
 			selectLanguage = 'fr_CA';
 			selectfr_CA = true;
 		} else if (selectLanguage == 'es_mx' || selectLanguage == 'es_MX') {
 			selectLanguage = 'es_MX';
 			selectes_MX = true;
 		} else {
 			selectLanguage = 'en_US';
 			selecten_US = true;
 		}
 		
		webToCase = new Case();
		caseContact = new Contact();		
		contactList = new List<Contact>();
		assetList = new List<Asset>();
		productList = new List<Product2>();		
		caseRecordType = new List<RecordType>();
		contactRecordType = new List<RecordType>();
		webToCase.Language__c = selectLanguage; 
		assetList = [SELECT Id, SerialNumber,Product2Id FROM Asset WHERE SerialNumber =: serialNumber And Status =: null];
		if (!assetList.isEmpty()) {	
			productList = [SELECT Id, ProductCode FROM Product2 WHERE Id=: assetList[0].Product2Id];
			if (!productList.isEmpty()) {
				webToCase.Product_Model_Number__c = productList[0].ProductCode;
			}	
		}
	}
	
	/**
     * The action of button Submit
     *
     * @param                   None
     * @return                  PageReference   URL
     * @since                   1.0
     */ 
	public PageReference submit() {		
        PageReference pageRef;
		
		caseContact.Email = email;			
	    contactList = [SELECT Id, Name, Email FROM Contact WHERE Email=:caseContact.Email ]; 	    
	    caseRecordType = [SELECT Id FROM RecordType WHERE SobjectType=:'Case' AND Name=:'Support'];
		contactRecordType = [SELECT Id FROM RecordType WHERE SobjectType=:'Contact' AND Name=:'Support'];
		webToCase.RecordTypeId = caseRecordType[0].Id;				
		
        /* if the asset is not empty insert the contact and case */
		if (!assetList.isEmpty()) {	
			
			/* if the contact is not empty use the contact with the same email as the case contact and update the mail informaion; */
			/* if the contact is empty insert the new contact */
			if (!contactList.isEmpty()) {
			    webToCase.ContactId = contactList[0].Id ;
			    contactList[0].Phone = phone;
			    contactList[0].MailingCity = city;
			    contactList[0].MailingPostalCode = zip;
			    contactList[0].MailingCountryCode ='US';
			    contactList[0].MailingStateCode = state;
			    contactList[0].MailingStreet = address + ' ' + address2;			    
			    update contactList[0];
			} else {	
				caseContact.RecordTypeId = contactRecordType[0].Id;	
				caseContact.FirstName = firstName;
		        caseContact.LastName = lastName;
		        caseContact.Phone = phone;
				caseContact.MailingCountryCode ='US';
		        caseContact.MailingCity = city;
		        caseContact.MailingPostalCode = zip;
		        caseContact.MailingStateCode = state;
		        caseContact.MailingStreet = address + ' ' + address2;		
				insert caseContact;
				webToCase.ContactId = caseContact.Id;
			}
		   
		    /* Fetching the assignment rules on case */
	       /* List<AssignmentRule> assRule = new List<AssignmentRule>();
	        assRule = [SELECT Id FROM AssignmentRule WHERE SobjectType = 'Case' AND Active = true LIMIT 1];
	       
	        if (!assRule.isEmpty()) {   */
	        	      
	       	    /* Creating the DMLOptions for "Assign using active assignment rules" checkbox */
	          /*  Database.DMLOptions dmlOpts = new Database.DMLOptions();
	            dmlOpts.assignmentRuleHeader.assignmentRuleId = assRule[0].id;
	            dmlOpts.EmailHeader.TriggerUserEmail = true;
	            webToCase.setOptions(dmlOpts);
       	    }*/
        
			/* Create a new case */
			webToCase.Safety_Notice__c = assetList[0].Id;
			webToCase.Origin = 'Web';
			insert webToCase;
			assetList[0].Status = 'Registered';
			update assetList[0];
			pageRef = new PageReference('/s/SafetyNotice_Submitted?language='+selectLanguage);	
			return pageRef;
		}
        return null ;
	}
}