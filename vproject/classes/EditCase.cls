/**
 * EditCase. Edit case Page same as the page in Voogle.
 *
 * @author              Hay Win, Stela Zhang
 * @version             1.0
 * @since               1.0
 */ 
public class EditCase{

	private ApexPages.StandardController standardController;
	public Case currentCase{get;set;}
    public CaseComment currentCaseComment {get;set;} // new case comment
    public List<Case> caseList {get;set;}
    public Case_Log__c  newCaseLog {get;set;}// new case log
    
    /**
     * Definition of the constructor.
     * Initial all variables.
     *
     * @param   stdController   ApexPages StandardController  
     * @return                                  None
     * @since                                   1.0
     */   
    public EditCase(ApexPages.StandardController standardController ){
    	caseList = new List<Case>();
        currentCaseComment = new CaseComment();
        newCaseLog = new Case_Log__c();
    	this.standardController = standardController;
        currentCase =  (Case)standardController.getRecord();
        caseList = [Select Id, Status, Ownerid, Action_Code__c, CaseNumber From Case Where Id=: currentCase.Id];
    } 
    
    /**
     * Update the current case and create a new casecomment
     * 
     *
     * @param           None      
     * @return          pageReference         current Case Detial Page  
     * @since           1.0
     */   
    public pageReference Submit() {   
    	
    	// Update case
    	update caseList[0];
    	
    	List<User> userList= new List<User>(); // list of user
	    userList = [SELECT Id, Name FROM User];
	    List<Group> groupList = new List<Group>(); //list of queue
	    groupList = [SELECT Id, Name FROM Group WHERE type=:'Queue'];
	    
	    newCaseLog.CaseID__c = caseList[0].Id;
		newCaseLog.ActionCode_c__c = caseList[0].Action_Code__c;
		
		// Assign to could be User or QUEUE
		for (User userName: userList) {
		 	if (userName.Id == caseList[0].OwnerId)
		    	newCaseLog.AssignedUser__c = userName.Name;
		}
		for (Group queueName: groupList) {
		    if (queueName.Id == caseList[0].OwnerId)
		 		 newCaseLog.AssignedUser__c = queueName.Name;
		}
		 		
		newCaseLog.CaseNumber__c = caseList[0].CaseNumber;
		newCaseLog.CaseStatus__c = caseList[0].Status;
	 
	    // Create case comment & case Log
        currentCaseComment.ParentId = caseList[0].Id; 
        if (currentCaseComment.CommentBody != null) {
        	insert currentCaseComment; 
        	newCaseLog.Notes__c = currentCaseComment.CommentBody;
        }
        insert newCaseLog;
        currentCaseComment.CommentBody = null;
        PageReference page = new ApexPages.StandardController(currentCase).view(); 
        page.setRedirect(true);
        return page;
    }


}