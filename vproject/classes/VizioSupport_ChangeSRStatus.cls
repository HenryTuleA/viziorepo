/**
 * VizioSupport_ChangeSRStatus. Change Service Request status
 *
 * @author              Stela Zhang
 * @version             1.0
 * @since               1.0
 */ 
public class VizioSupport_ChangeSRStatus{

	private ApexPages.StandardController standardController;
	public Service_Request__c currentSR{get;set;}    
    public List<Service_Request__c> srList {get;set;}
    public String selectedStatus {get;set;}
    
    /**
     * Definition of the constructor.
     * Initial all variables. 
     *
     * @param   stdController   ApexPages StandardController  
     * @return                                  None
     * @since                                   1.0
     */   
    public VizioSupport_ChangeSRStatus(ApexPages.StandardController standardController ){
    	srList = new List<Service_Request__c>();
    	this.standardController = standardController;
        currentSR =  (Service_Request__c)standardController.getRecord();
        srList = [Select Id, Status__c, StatusReason__c From Service_Request__c Where Id=: currentSR.Id];
    } 
    
    /**
     * Update the current SR status
     *      
     * @param           None      
     * @return          pageReference         current SR Detial Page  
     * @since           1.0
     */   
    public pageReference Submit() {   
    	srList[0].Status__c = selectedStatus;
    	update srList[0];
        PageReference page = new ApexPages.StandardController(currentSR).view(); 
        page.setRedirect(true);
        return page;
    }

    /**
     * Cancel
     *     
     * @param           None      
     * @return          pageReference         current SR Detial Page  
     * @since           1.0
     */   
    public pageReference Cancel() {   
    	
    	// Return SR detail page
        PageReference page = new ApexPages.StandardController(currentSR).view(); 
        page.setRedirect(true);
        return page;
    }
    
    /**
     * The status function, Cancel and Close
     *
     * @param                   None
     * @return        List<SelectOption>           
     * @since                   1.0
     */ 
    public List<SelectOption> getStatusList() {
    	
    	// Only Allow user choose Closed or Cancelled
    	List<SelectOption> statusSelectList = new List<SelectOption>();
    	statusSelectList.add(new SelectOption('CANCELLED ','CANCELLED'));
    	statusSelectList.add(new SelectOption('CLOSED','CLOSED'));   	
    	return statusSelectList;
    }
}