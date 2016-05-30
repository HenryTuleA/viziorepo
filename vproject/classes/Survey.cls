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
 * Submit the survey: link sent through email
 * 
 * This verion 
 *
 * @author             Hay Mun Win
 * @version             2.0
 * @since               1.0
 */ 



public without sharing class Survey {
	
	public Customer_Survey__c Survey {get;set;}
	public string caseid{get;set;}			//variable for case id
	public string casenum{get;set;}
	public string contactid{get;set;}		//variable for contact id
	public string contactEmail{get;set;}	//variable for contact email
	public string modelNum{get;set;}
	public string contactName{get;set;}	
    private String currentStep;
	
	public Survey(){		
		Survey = new Customer_Survey__c();											//new survey
		caseid = ApexPages.currentPage().getParameters().get('caseid');				//get case id from url parameter
		currentStep='1';															//current step
		
		/**Check if Survey is already created**/
		
		List<Customer_Survey__c> survey_list = [Select id from Customer_Survey__c where Case__c =: caseid];
		
		if (!survey_list.isEmpty()){
			currentStep ='2';			
		}
		
			
		/*Case query*/
		List<Case> CaseQ =[Select CaseNumber, Model__c, Contactid From Case where id =: caseid];	
		casenum = CaseQ[0].CaseNumber;			//query case number
		modelNum = CaseQ[0].Model__c;			//query model number
		contactid = CaseQ[0].contactid;			//query contact id from url parameter
		
		
		/*Contact query*/
		List<Contact> ContactQ =  [Select Name, Email FROM contact where Id =: contactid];
		contactName = ContactQ[0].Name;															//query contact name
		contactEmail = ContactQ[0].email;														//query contact email from url parameter
		
	}
	
	public PageReference submit(){
		Survey.Case__c = caseid;																	//case id field for survey object
		Survey.CustomerId__c = contactid;															//contact id for survey
		Survey.Contact_Email__c = contactEmail;														//contact email for survey
		Survey.Survey_Question1__c = ApexPages.currentPage().getParameters().get('response1');
		Survey.Survey_Question2__c = ApexPages.currentPage().getParameters().get('response2');
		Survey.Survey_Question3__c = ApexPages.currentPage().getParameters().get('response3');
		Survey.Survey_Question4__c = ApexPages.currentPage().getParameters().get('response4');
		Survey.Survey_Question5__c = ApexPages.currentPage().getParameters().get('response5');
		Survey.Survey_Question6__c = ApexPages.currentPage().getParameters().get('response6');
		Survey.Survey_Question7__c = ApexPages.currentPage().getParameters().get('response7');
		insert Survey;
		//PageReference pageRef = new PageReference('https://support.vizio.com/s/');	
		//return pageRef;
		currentStep='2';   	     
        return ApexPages.currentPage();
	}
	
	public String getStep() {
		return currentStep;
	}
	
	
	

}