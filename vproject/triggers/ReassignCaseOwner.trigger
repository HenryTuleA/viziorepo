/**
 * Trigger to reassign the case owner
 * When agent select a case which record type is Support Email and send email to the client, change the case owner as the user.
 * Update the case status to Response sent.
 *
 * @author		Xin Zhang
 * @version		1.0
 * @since		1.0
 */ 

trigger ReassignCaseOwner on Task (before insert) {
	
    List<Case> updateCaseList = new List<Case>(); //case list contains cases will be updated
	List<RecordType> caseRecordTypeList = new List<RecordType>();   //case record type list 
	caseRecordTypeList = [SELECT Id FROM RecordType WHERE SobjectType=:'Case' AND Name=:'Support Email'];
	Set<Id> updateCaseSet = new Set<Id>(); //set contains case Id
	
    // add all the tasks' whatId into the updateCaseSet
	for (Task recentInsert : trigger.new) {
		updateCaseSet.add(recentInsert.whatId);
	}
	
	// case map with the case which record type is support email and the case Id is in the updateCaseSet
	Map<Id, Case> caseMap = new Map<Id, Case>([SELECT Id, OwnerId, Status 
	                                           FROM Case 
	                                           WHERE RecordTypeId =: caseRecordTypeList[0].Id
	                                           AND Id IN :updateCaseSet]);
	
	for (Task recentInsert : trigger.new) {
    	
    	//if the task subject is start with Email
    	if (recentInsert.Subject.startswith('Email:')) {
    		
    		// get the OwnerId and What Id from the task 
	        Id taskOwnerId = recentInsert.OwnerId;
	        Id whatId = recentInsert.WhatId;
	        Case updateCase = caseMap.get(whatId); 
	        
	        if (updateCase != null) {	
	        	// update case owner and case status	       
	        	updateCase.OwnerId = taskOwnerId;  
	        	updateCase.Status = 'Response sent';	        		
	        	updateCaseList.add(updateCase);	  
	        }      	     
    	}
	}
    update updateCaseList;
}