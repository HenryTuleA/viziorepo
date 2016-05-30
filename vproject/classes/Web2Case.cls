/*
 * Copyright (c) 2013, UC Innovation, Inc.  All Rights Reserved.
 *                     http://www.ucinnovation.com
 *
 * This source code is licensed, not sold, and is subject to a written
 * license agreement.  Among other things, no portion of this source
 * code may be copied, transmitted, disclosed, displayed, distributed,
 * translated, used as the basis for a derivative work, or used, in
 * whole or in part, for any program or purpose other than its intended
 * use in compliance with the license agreement as part of UC Innovation's
 * software.  This source code and certain of the algorithms contained
 * within it are confidential trade secrets of UC Innovation, Inc.
 * and may not be used as the basis for any other
 * software, hardware, product or service.
 */

/**
 * Web to case. Create a new case after click send Email.
 *
 * @author              Xin Zhang
 * @version             1.0
 * @since               1.0
 */ 

public without sharing class Web2Case {
    
    public String searchString {get;set;}
    public Case webToCase {get;set;}
    public Boolean showThanks {get;set;}
    public Contact caseContact {get;set;}
    public List<RecordType> caseRecordType {get;set;}
    public List<RecordType> contactRecordType {get;set;}
    public List<Contact> contactList {get;set;}
    public String  selectLanguage{get;set;} 
    public Boolean selecten_US {get;set;}
    public Boolean selecten_CA {get;set;}
    public Boolean selectfr_CA {get;set;}
    public Boolean selectes_MX {get;set;}
    public Database.DMLOptions dmlOpts{get;set;}
    public Attachment userAttachment{get;set;}
    public Attachment userAttachment2{get;set;}
    public Attachment userAttachment3{get;set;}
    public Attachment userAttachment4{get;set;}
    public Attachment userAttachment5{get;set;}
    public List<String> fileType {get;set;}
    public String caseContactOwnerId {get;set;}
    public String lastName {get;set;}
    public String emailAddress {get;set;}

    /**
     * Definition of the constructor.
     * Initial all variables.
     *
     * @param      None
     * @return     None
     * @since      1.0
     */  
    public Web2Case() {
        searchString = ApexPages.currentPage().getParameters().get('subject');
        selectLanguage = ApexPages.currentPage().getParameters().get('language');
        
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
        caseRecordType = new List<RecordType>();
        contactRecordType = new List<RecordType>();
        contactList = new List<Contact>();
        userAttachment = new Attachment();
        userAttachment2 = new Attachment();
        userAttachment3 = new Attachment();
        userAttachment4 = new Attachment();
        userAttachment5 = new Attachment();
        showThanks = false;
        webToCase.subject = searchString;
        webToCase.Origin = 'Email'; 
        webToCase.Language__c = selectLanguage; 
        fileType = new List<String> {'.jpg','.jpeg','.gif','.png','.pdf','.zip','.avi','.mov'};   
        
        // Get value from custom setting: Support Setting 
        Support_Setting__c  getCaseContactOwner = [SELECT Id, Value__c 
                                                   FROM Support_Setting__c  
                                                   WHERE Name =: 'Web2CaseContactOwner']; 
        caseContactOwnerId = getCaseContactOwner.Value__c;
    }
    
    /**
     * The action of button Submit
     *
     * @param                   None
     * @return       PageReference           None
     * @since                   1.0
     */ 
    public pageReference submit() { 
        
        /* Get Record Type */   
        caseRecordType = [SELECT Id FROM RecordType WHERE SobjectType=:'Case' AND Name=:'Support Email'];
        contactRecordType = [SELECT Id FROM RecordType WHERE SobjectType=:'Contact' AND Name=:'Support'];
        webToCase.RecordTypeId = caseRecordType[0].Id;              
  
        
        // check complete all the requiered field
		if (webToCase.Description == null || caseContact.FirstName == null || lastName == null || webToCase.subject == null || emailAddress == null || caseContact.Phone == null) {
			if (selecten_US == true) {
    			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Please complete all required fields.'));
			} else if (selecten_CA == true) {
				ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Please complete all required fields.'));
			} else if (selectfr_CA == true) {
				ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Veuillez remplir tous les champs obligatoires.'));
			} else if (selectes_MX == true) {
				ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Completa todos los campos obligatorios.'));
			}
			
            return null;
		}
		
		// check the email validation
		Boolean emailValidation = checkEmail(emailAddress);
		if (emailValidation == false) {
			if (selecten_US == true) {
    			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Invalid Email.'));
			} else if (selecten_CA == true) {
				ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Invalid Email.'));
			} else if (selectfr_CA == true) {
				ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Email invalide.'));
			} else if (selectes_MX == true) {
				ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Email inválido.'));
			}
			return null;
		}
		
		// check the phone number validation
		integer numberOfAt = 0;
		integer numberOfNum = 0;
    	integer notNum = 0 ;
        for (integer i = 0; i < caseContact.Phone.length(); i++) {
            String chara = caseContact.Phone.substring(i,i+1);
        	if(chara>='0'&&chara<='9') {
        		numberOfNum ++;
        	} else if(chara!='('&& chara!=')' && chara != '-' && chara != ' '){
        		notNum ++;
        	}
        }
        
		if(notNum != 0 || numberOfNum < 10){
			if (selecten_US == true) {
    			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Invalid Phone Number.'));
			} else if (selecten_CA == true) {
				ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Invalid Phone Number.'));
			} else if (selectfr_CA == true) {
				ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Numero de telephone invalide.'));
			} else if (selectes_MX == true) {
				ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Numero de telefono invalido.'));
			}
            return null;
		} else {
			 
            contactList = [SELECT Id, Name, Email FROM Contact WHERE Email=: emailAddress];
	        if (!contactList.isEmpty()) {
	           webToCase.ContactId = contactList[0].Id ;
	        } else {   
	        	caseContact.LastName = lastName; 
	        	caseContact.Email = emailAddress;
	            caseContact.RecordTypeId = contactRecordType[0].Id; 
	            
	            // set the new contact's owner as 'Agent VIZIO'
	            // sandbox 00517000000tjgh   production 0051a000000HJgl   
	            caseContact.OwnerId = caseContactOwnerId;   
	            insert caseContact;
	            webToCase.ContactId = caseContact.Id;
	        }
	       
	        /* Fetching the assignment rules on case */
	        List<AssignmentRule> assRule = new List<AssignmentRule>();
	        assRule = [SELECT Id FROM AssignmentRule WHERE SobjectType = 'Case' AND Active = true LIMIT 1];
	       
	        if (!assRule.isEmpty()) {   
	                  
	            /* Creating the DMLOptions for "Assign using active assignment rules" checkbox */
	            Database.DMLOptions dmlOpts = new Database.DMLOptions();
	            dmlOpts.assignmentRuleHeader.assignmentRuleId = assRule[0].id;
	            dmlOpts.EmailHeader.TriggerUserEmail = true;
	            webToCase.setOptions(dmlOpts);
	        }
	               
	        
	        /* No attachment */
	        if (userAttachment.Name == null && userAttachment2.Name == null && userAttachment3.Name == null &&
	            userAttachment4.Name == null && userAttachment5.Name == null) {
	            insert webToCase;
	            showThanks=true; 
	            return null;
	        }
	        
	        /* Check the attachment file type */ 
	        Boolean typeAcceptable1;
	        typeAcceptable1 = false;
	        Boolean typeAcceptable2;
	        typeAcceptable2 = false;
	        Boolean typeAcceptable3;
	        typeAcceptable3 = false;
	        Boolean typeAcceptable4;
	        typeAcceptable4 = false;
	        Boolean typeAcceptable5;
	        typeAcceptable5 = false;
	        for (String attType : fileType) {
	            if (userAttachment.Name == null || (userAttachment.Name.toLowerCase()).endsWith(attType)) {
	                typeAcceptable1 = true;
	            }
	            if (userAttachment2.Name == null || (userAttachment2.Name.toLowerCase()).endsWith(attType)) {
	                typeAcceptable2 = true;
	            }
	            if (userAttachment3.Name == null || (userAttachment3.Name.toLowerCase()).endsWith(attType)) {
	                typeAcceptable3 = true;
	            }
	            if (userAttachment4.Name == null || (userAttachment4.Name.toLowerCase()).endsWith(attType)) {
	                typeAcceptable4 = true;
	            }
	            if (userAttachment5.Name == null || (userAttachment5.Name.toLowerCase()).endsWith(attType)) {
	                typeAcceptable5 = true;
	            }
	        }
	        
	        /* Add attachment */
	        if (typeAcceptable1 == true && typeAcceptable2 == true && typeAcceptable3 == true &&
	            typeAcceptable4 == true && typeAcceptable5 == true) {
	            insert webToCase;
	            if (userAttachment.Body != null ) {                     
	                userAttachment.ParentId = webToCase.Id;                  
	                insert userAttachment;              
	                userAttachment.body = null;
	                userAttachment.Name = null;                                                                    
	            }  
	            if (userAttachment2.Body != null ) {                     
	                userAttachment2.ParentId = webToCase.Id;                  
	                insert userAttachment2;              
	                userAttachment2.body = null;
	                userAttachment2.Name = null;                                                                    
	            }  
	            if (userAttachment3.Body != null ) {                     
	                userAttachment3.ParentId = webToCase.Id;                  
	                insert userAttachment3;              
	                userAttachment3.body = null;
	                userAttachment3.Name = null;                                                                    
	            }  
	            if (userAttachment4.Body != null ) {                     
	                userAttachment4.ParentId = webToCase.Id;                  
	                insert userAttachment4;              
	                userAttachment4.body = null;
	                userAttachment4.Name = null;                                                                    
	            }  
	            if (userAttachment5.Body != null ) {                     
	                userAttachment5.ParentId = webToCase.Id;                  
	                insert userAttachment5;              
	                userAttachment5.body = null;
	                userAttachment5.Name = null;                                                                    
	            }  
	        } else{
	        	  if (selecten_US == true) {
    			      ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Only image and video files such as .jpg, .jpeg, .zip, .pdf, .mov, .avi, .png or .gif file extensions are accepted.'));
				  } else if (selecten_CA == true) {
				      ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Only image and video files such as .jpg, .jpeg, .zip, .pdf, .mov, .avi, .png or .gif file extensions are accepted.'));
			      } else if (selectfr_CA == true) {
				      ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Seuls les fichiers image et vidéo tels que .jpg, .jpeg , .zip , .pdf , .mov , .avi , .png ou .gif extensions de fichiers sont acceptés.'));
			      } else if (selectes_MX == true) {
				      ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Sólo se aceptan archivos de imagen y vídeo , como .jpg , .jpeg , .zip , .pdf , .mov , .avi , .png o .gif extensiones de archivo.'));
			      }
	              
	              userAttachment.body = null;
	              userAttachment.Name = null;
	              userAttachment2.body = null;
	              userAttachment2.Name = null;
	              userAttachment3.body = null;
	              userAttachment3.Name = null;
	              userAttachment4.body = null;
	              userAttachment4.Name = null;
	              userAttachment5.body = null;
	              userAttachment5.Name = null;
	              return null;
	       }
	       showThanks=true; 
		}       
        return null;
    }
    
    public static Boolean checkEmail (String semail) {
		String InputString = semail;
		String emailRegex = '([a-zA-Z0-9_\\-\\.]+)@((\\[a-z]{1,3}\\.[a-z]{1,3}\\.[a-z]{1,3}\\.)|(([a-zA-Z0-9\\-]+\\.)+))([a-zA-Z]{2,4}|[0-9]{1,3})';
		Pattern MyPattern = Pattern.compile(emailRegex);

		// Then instantiate a new Matcher object "MyMatcher"
		Matcher MyMatcher = MyPattern.matcher(InputString);

		if (!MyMatcher.matches()) {
			return false;
		} else {
			return true;
		}
	} //end email check
}