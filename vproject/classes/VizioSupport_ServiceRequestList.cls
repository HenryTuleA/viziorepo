/**
 * Get Service Request List
 *
 * @author              Stela Zhang
 * @version             1.0
 * @since               1.0
 */ 
public with sharing class VizioSupport_ServiceRequestList {
	
	//private ApexPages.StandardController standardController;
	public Integer           noOfRecords{get; set;}         // amount of SR
    public Integer           size{get;set;}                 // how many SR will show per page
    private String           sortDirection = 'DESC';         //initial order by expression
    private String           sortExp = 'Name';               //initial order by expression
    public String            sortFullExp{get;set;} 
    // public Case getCaseId{get;set;}
    public String CaseId {get;set;}
    public Boolean createOrNot {get;set;}
    public Case currentCase {get;set;}
    public Boolean isCanada {get;set;}
    
    /**
     * Definition of the constructor.
     * Initial all variables.
     *
     * @param                None
     * @return               None
     * @since                 1.0
     */ 
	public VizioSupport_ServiceRequestList(ApexPages.StandardController standardController ){
        
       // this.standardController = standardController;
       // getCaseId=  (Case)standardController.getRecord();
       // CaseId = getCaseId.Id;
        CaseId = ApexPages.currentPage().getParameters().get('id');
        currentCase = [Select Id,Status, AssetId, Asset.Product2Id, Asset.Purchase_Location__c, Contact.MailingCountryCode From Case Where Id=:CaseId];
        isCanada = false;
        createOrNot = true;
        // If case Status is closed will not allow them create SR
        if (currentCase.Status == 'Closed' || currentCase.AssetId == null || Asset.Product2Id == null) {
        	createOrNot = false;
        } else {
        	createOrNot = true;
        }
        
        // If Asset purchase location is Best Buy Canada or Future Shop. And Customer's address country is Canada, show the message. 
        if ((currentCase.Asset.Purchase_Location__c == 'Best Buy Canada' || currentCase.Asset.Purchase_Location__c == 'Future Shop') &&  currentCase.Contact.MailingCountryCode == 'CA') {
        	isCanada = true;
        	createOrNot = false;
        }
        size = 7;
    }	
    
    
    /**
     * Get standardSetController for pagenation
     *
     * @param                                      None   
     * @return          setCon                StandardSetController 
     * @since                                      1.0
     */    
     public ApexPages.StandardSetController setCon {
         get {   
     	     
             if (setCon == null) {       
                 String searchquery;          	         
        		 sortFullExp = sortExpression  + ' ' + sortDirection;
                 searchquery = 'SELECT Id, Name, SRType__c, Error_Code__r.Name,Error_Code__r.Description__c,Service_Provider__r.ServiceProviderName__c, Status__c,StatusReason__c,CreatedDate, CreatedBy.Name, Convert_CreateDate__c FROM Service_Request__c WHERE  Case__c =: caseId ORDER BY ' + sortFullExp; 
	       		 
         		 setCon =   new ApexPages.StandardSetController(Database.getQueryLocator(searchquery));  
        	 	 setCon.setPageSize(size);
        	 	 noOfRecords = setCon.getResultSize(); 	
             }
        	 	 return setCon;
        }     	        
     	set; 
    }
    
    
    /**
     * Get Service Request from database
     *
     * @param                                      None   
     * @return          wapList                Get the cases from database Case 
     * @since                                      1.0
     */    
     public List<Service_Request__c> getRelatedSR() {
    	return (List<Service_Request__c>) setCon.getRecords();
    }
    
    /**
     * The clickToSort method is what will happen when you click the column label.
     * It will go sorting.
     *
     * @param                   None      
     * @return                  None            
     * @since                   1.0
     */ 
    public void clickToSort() {
    	Integer currentPageNumber = setCon.getPageNumber();
    	setCon = null;
    	setCon.setPageNumber(currentPageNumber);
    }
    
  	/**
     * Get order by expression function.
     * Ascending or Descending
     *
     * @param           None      
     * @return          sortExp         Ascending or Descending                         
     * @since           1.0
     */    
    public String sortExpression {
        get {
            return sortExp;
        }
        set {
            /* if the column is clicked on then switch between Ascending and Descending modes */
            if (value == sortExp) {
            	if (sortDirection == 'ASC') {
            		sortDirection = 'DESC';
            	} else {
            		sortDirection = 'ASC';
            	}
               // sortDirection = (sortDirection == 'ASC')? 'DESC' : 'ASC';
            } else {
                sortDirection = 'ASC';
            }
            sortExp = value;
        }
    }

    /**
     * Get order by expression function.
     * if no column is selected
     *
     * @param           None      
     * @return          String          value or 'ASC'                  
     * @since           1.0
     */      
    public String getSortDirection() {
        /* if not column is selected */
        if ((sortExpression == null) || (sortExpression == '')) {
            return 'ASC';
        }
        return sortDirection;
    }

    /**
     * Get order by expression function.
     * Set the sortDirection  to value 
     *
     * @param                   None      
     * @return                  None            
     * @since                   1.0
     */         
    public void setSortDirection(String value) {  
       sortDirection = value;
    }
    
  	/**
     * The Boolean type method hasNext is used to check it has next page or not 
     *
     * @param                                        None      
     * @return     Boolean               return setCon.getHasNext()           
     * @since                                                                            
     */  
    public Boolean hasNext {
        get {
            return setCon.getHasNext();
        }
        set;
    }
    
    /**
     * The Boolean type method hasNext is used to check it has previous page or not 
     *
     * @param                                        None      
     * @return     Boolean               return setCon.getHasPrevious()           
     * @since                                                                            1
     */ 
    public Boolean hasPrevious {
        get {
            return setCon.getHasPrevious();
        }
        set;
    }
  
    /**
     * The Integer type method pageNumber is used to get the current page number 
     *
     * @param                                        None      
     * @return     Integer               return setCon.getPageNumber()           
     * @since                                                                            1
     */ 
    public Integer pageNumber {
        get {
            return setCon.getPageNumber();
        }
        set;
    }
    
    /**
     * The Integer type method totalNumber is used to calculate the total page number 
     *
     * @param                                        None      
     * @return     Integer               return the value of total page number          
     * @since                                                                            1
     */ 
    public Integer totalNumber {
        get {
            if (math.mod(noOfRecords, size) > 0) {
                return noOfRecords/size + 1;
            } else  {
                return (noOfRecords/size);
            }
        }
        set;
    }
    
    /**
     * The void type method first is used to get the first page 
     *
     * @param      None      
     * @return     None      
     * @since      1
     */ 
    public void first() {
        setCon.first();
    }
    
    /**
     * The void type method last is used to get the last page 
     *
     * @param      None      
     * @return     None      
     * @since      1
     */ 
    public void last() {
        setCon.last();
    }
    
    /**
     * The void type method previous is used to get the previous page 
     *
     * @param      None      
     * @return     None      
     * @since      1
     */ 
    public void previous() {
        setCon.previous();
    }
    
    /**
     * The void type method next is used to get the next page 
     *
     * @param      None      
     * @return     None      
     * @since      1
     */ 
    public void next() {
        setCon.next();
    }
    
}