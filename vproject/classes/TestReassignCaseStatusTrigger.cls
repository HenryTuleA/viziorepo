/**
 * Test class to test the ReassignCaseStatusByTranscriptEvent.trigger
 *
 * @author		Xin Zhang
 * @version		1.0
 * @since		1.0
 */
 
@isTest (SeeAllData=false)
private class TestReassignCaseStatusTrigger {
	/**
     * method to test the task related to case 
     *
     * @param			None	  
     * @return			None
     * @since			1.0
     */
	static testMethod void testTranscriptEvent1() {
		Id caseRecordType = [Select Id From RecordType Where Name = 'Support Chat' AND SobjectType = 'Case'].get(0).Id;
						
		Case insertCase1 = new Case(status = 'New', RecordTypeId = caseRecordType);
		insert insertCase1;
		
		LiveChatVisitor newVisitor = new LiveChatVisitor();
		insert newVisitor;
	
		LiveChatTranscript newTranscript = new LiveChatTranscript(caseId = insertCase1.Id, LiveChatVisitorId=newVisitor.Id);
		
        insert newTranscript;
        
        LiveChatTranscriptEvent newTranscriptEvent1 = new LiveChatTranscriptEvent(LiveChatTranscriptId = newTranscript.Id, Type = 'Transfer', Time = Datetime.now());
        
        insert newTranscriptEvent1;
        
        LiveChatTranscriptEvent newTranscriptEvent2 = new LiveChatTranscriptEvent(LiveChatTranscriptId = newTranscript.Id, Type = 'LeaveVisitor', Time = Datetime.now());
        
        insert newTranscriptEvent2;
	} 
	
	static testMethod void testTranscriptEvent2() {
		Id caseRecordType = [Select Id From RecordType Where Name = 'Support Chat' AND SobjectType = 'Case'].get(0).Id;
						
		Case insertCase1 = new Case(status = 'New', RecordTypeId = caseRecordType);
		insert insertCase1;
		
		LiveChatVisitor newVisitor = new LiveChatVisitor();
		insert newVisitor;
	
		LiveChatTranscript newTranscript = new LiveChatTranscript(caseId = insertCase1.Id, LiveChatVisitorId=newVisitor.Id);
		
        insert newTranscript;
        
         LiveChatTranscriptEvent newTranscriptEvent1 = new LiveChatTranscriptEvent(LiveChatTranscriptId = newTranscript.Id, Type = 'Accept', Time = Datetime.now());
        
        insert newTranscriptEvent1;
        
        LiveChatTranscriptEvent newTranscriptEvent2 = new LiveChatTranscriptEvent(LiveChatTranscriptId = newTranscript.Id, Type = 'LeaveVisitor', Time = Datetime.now());
        
        insert newTranscriptEvent2;
	} 
}