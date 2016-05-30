/**
 * Trigger to change the case status
 * When the transcriptEvent is transferred then end set the case status to transferred/closed.
 * When the chat end without transferred set the case status to closed.
 *
 * @author		Xin Zhang
 * @version		1.0
 * @since		1.0
 */

trigger ReassignCaseStatusByTranscriptEvent on LiveChatTranscriptEvent (after insert) {
		
	List<RecordType> caseRecordTypeList = new List<RecordType>();   //case record type list 
	List<Case> updateCaseList = new List<Case>(); // list with all the update cases
	List<LiveChatTranscript> transcriptList = new List<LiveChatTranscript>(); //transcriptLst
	List<LiveChatTranscriptEvent> transferTranscriptList = new List<LiveChatTranscriptEvent>(); //transfered transcriptevent list
    Map<Id, Id> transcriptIdToCaseIdMap = new Map<Id, Id>(); // map with transcriptId and CaseId
	Set<Id> updateCaseSet = new Set<Id>(); //set contains case Id
	Set<Id> transcriptIdSet = new Set<Id>(); //set contains transcript Id 
		
	Id transcriptId;
	Id caseId;
	String transcriptType;
	Integer countEvent = 0;
	
	// caseRecordTypeList with Name is Support Chat
	caseRecordTypeList = [SELECT Id FROM RecordType WHERE SobjectType=:'Case' AND Name=:'Support Chat'];
			
    // add all the LiveChatTranscriptEvent' LiveChatTranscriptId into the transcriptIdSet
	for (LiveChatTranscriptEvent newTranscriptEvent : trigger.new) {
		transcriptIdSet.add(newTranscriptEvent.LiveChatTranscriptId);
	}
	
	// query the transcripList based on the Id. Create a map with transcript Id and CaseId
	transcriptList = [SELECT Id, caseId FROM LiveChatTranscript WHERE Id IN : transcriptIdSet];
	
	// query the trancriptEvent type is transfer and LiveChatTrnascriptId in the transcriptIdSet
	transferTranscriptList = [SELECT Id, Type, LiveChatTranscriptId FROM LiveChatTranscriptEvent WHERE Type=:'Transfer' AND LiveChatTranscriptId IN: transcriptIdSet];
	
	// geth the updateCaseSet and transcriptIdToCaseIdMap
	for (LiveChatTranscript updateTranscript : transcriptList) {
		transcriptIdToCaseIdMap.put(updateTranscript.Id, updateTranscript.caseId);
		updateCaseSet.add(updateTranscript.caseId);
	} 
	
	// case map with the case which record type is support chat and the case Id is in the updateCaseSet
	Map<Id, Case> caseMap = new Map<Id, Case>([SELECT Id, OwnerId, Status 
	                                           FROM Case 
	                                           WHERE RecordTypeId =: caseRecordTypeList[0].Id
	                                           AND Id IN :updateCaseSet]);
	                                        
	
	for (LiveChatTranscriptEvent newTranscriptEvent : trigger.new) {
    	transcriptId = newTranscriptEvent.LiveChatTranscriptId;
    	transcriptType = newTranscriptEvent.Type; 
    	
    	// Get the caseId from the transcriptIdToCaseIdMap
    	caseId = transcriptIdToCaseIdMap.get(transcriptId);
    	
    	// get the case from caseMap
        Case updateCase = caseMap.get(caseId);       
		
		if (updateCase != null) {
			// if transcript event Type is 'transfer' set the case status to transferred
			if (transcriptType == 'Transfer') {
		    	updateCase.Status = 'Transferred';
		    	updateCaseList.add(updateCase);
			} else {
			 	for (LiveChatTranscriptEvent transferEvent: transferTranscriptList) {
			 		
		    		// if the transcript have transcript event type as 'transfer' before and the new transcritp event type is 'LeaveVisior'
		    		// set the case status as 'Transferred/Closed'
		    		if (transcriptId == transferEvent.LiveChatTranscriptId && transcriptType == 'LeaveVisitor') {  
		    			countEvent ++;      	     
		       		 updateCase.Status = 'Transferred/Closed';
		       		 updateCaseList.add(updateCase);	
		       		 break;	            		 
		    		} 
			 	}
			 	// if the transcript never has transcript event type as transfer before and the new transcript event type is 'LeaveVisior'
		    	// seht the case status as 'Closed'
				if (countEvent == 0 && transcriptType == 'LeaveVisitor') {	    		
		        	updateCase.Status = 'Closed';  
		        	updateCaseList.add(updateCase);      
		          			
		    	}			                  			
			}		       	 	        
    	}	
	}  
	system.debug('updateCaseList '+updateCaseList);
	update updateCaseList;   
}