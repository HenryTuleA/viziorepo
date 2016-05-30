/**
 * Whenever a record is created in USA800CallData__c object
 * Get the PhoneNumber__c, Call_Started__c from that record
 * Query case. ContactPhone or case. ContactMobile = PhoneNumber__c and LastModifydate is the same day asCall_Started__c, if you find a match
 * Populate lookup ID in case. USA800CallData__c
 *
 * @author		Stela Zhang
 * @version		1.0
 * @since		1.0
 */
 
 trigger VizioSupport_USA800Call on USA800CallData__c (after insert) {
	 
	 // Get the Support record type Id
	 List<RecordType> caseRecordTypeList = new List<RecordType>();   
	 caseRecordTypeList = [SELECT Id FROM RecordType WHERE SobjectType=:'Case' AND Name=:'Support'];
	 
	 // Get the list of Support Case
	 List<Case> caseList = new List<Case>();
	 caseList = [SELECT Id, USA800CallData__c, ContactId, Contact.Phone, Contact.OtherPhone, LastModifiedDate  FROM Case WHERE RecordTypeId =: caseRecordTypeList[0].Id];
	 
	 // Update Case List
	 List<Case> updateCaseList = new List<Case>();
	 
	 Set<Case> caseSet = new Set<Case>();
	 
	 date caseLastModify;
	 date callStart;
	 boolean sameDay = false;
	 
	 for (USA800CallData__c theCallDate : trigger.new) {
	 	
	 	// Find the case
	 	for (Case theCase : caseList) { 
	 		
	 		// Compare the Case Last modify date and USA800Call start date
	 		caseLastModify = thecase.LastModifiedDate.date();	 		
	 		callStart = theCallDate.Call_Started__c.date();
	 		sameDay = caseLastModify.isSameDay(callStart);
	 		
	 		// If the date are the same, if the case.Contact.Phone or other phone much the phoneNumber__c update
	 		if ((theCase.Contact.Phone == theCallDate.PhoneNumber__c || theCase.Contact.OtherPhone == theCallDate.PhoneNumber__c) && sameDay == true) {
	 			
	 			// Why not use list: because it will have duplicate case error, Map will auto upsert if there are duplicate keys.	
	 			theCase.USA800CallData__c = theCallDate.Id;
	 			caseSet.add(theCase); 			
	 		}
	 	}
	 }
	
     updateCaseList.addAll(caseSet);
	 update updateCaseList;
	
 }