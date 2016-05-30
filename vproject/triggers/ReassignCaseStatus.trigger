/**
 * Trigger to reassign the case status
 * When agent select a case and send email to the client, if the case owner is Support Queue
 * Or Mexico Support Queue reassign the case owner as the this agent (The first agent reply this case).
 *
 * @author		Xin Zhang
 * @version		1.0
 * @since		1.0
 */

trigger ReassignCaseStatus on LiveChatTranscript (before insert) {
	
/*	//List<RecordType> caseRecordType = new List<RecordType>();	 
	List<Case> caseList = new List<Case>();
	caseList = [SELECT Id, caseNumber FROM Case];
	//caseRecordType = [SELECT Id FROM RecordType WHERE SobjectType=:'Case' AND Name=:'Support'];
	
	for (LiveChatTranscript newTranscript : trigger.new) {
    	
    	
    		
	        Id theCaseId = newTranscript.CaseId;
	        for (Case updateCase: caseList) {
	        	if (updateCase.Id == theCaseId) {
	        		updateCase.Status = 'Closed';
	        	//	updateCase.RecordTypeId = caseRecordType[0].Id;
	        		update updateCase;
	        	}
	        }
    	    
    }*/
}