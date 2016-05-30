/**
 * Test class to test the ReassignCaseStatus.trigger
 *
 * @author		Xin Zhang
 * @version		1.0
 * @since		1.0
 */
 
@isTest (SeeAllData=false)
private class TestClassReassignCaseStatus {
	/**
     * method to test the task related to case 
     *
     * @param			None	  
     * @return			None
     * @since			1.0
     */
	static testMethod void testTask() {
						
		Case insertCase1 = new Case();
		insert insertCase1;
		
		LiveChatVisitor newVisitor = new LiveChatVisitor();
		insert newVisitor;
	
		LiveChatTranscript newTranscript = new LiveChatTranscript(caseId = insertCase1.Id, LiveChatVisitorId=newVisitor.Id);
		
        insert newTranscript;
	} 
}