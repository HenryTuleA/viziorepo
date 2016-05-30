/**
 * VizioSupport_ViewServiceRequest. View Service Request.
 *
 * @author              Stela Zhang
 * @version             1.0
 * @since               1.0
 */ 
 

public without sharing class VizioSupport_ViewServiceRequest{
    
   
   // private ApexPages.StandardController standardController;
	
	// For pagination
	public Integer           noOfRecords{get; set;}         // amount of cases
    public Integer           size{get;set;}                 // how many SR will show per page
    private String           sortDirection = 'DESC';         //initial order by expression
    private String           sortExp = 'Name';               //initial order by expression
    public String            sortFullExp{get;set;} 
   
    // For current SR
    public String srId {get;set;}
    //public Service_Request__c getSRId{get;set;}
    public List<Service_Request__c> currentSR {get;set;}
    
    // For all relationships
    public List<Case> relatedCase{get;set;}
    public List<Asset> relatedAsset {get;set;}
    public List<Product2> relatedProduct {get;set;}
    public List<Contact> relatedContact {get;set;}
    public List <Service_Request_Information__c> srInfo{get;set;}
     
    public Boolean showSRinformation{get;set;}
         
    public Boolean showPageBlock {get;set;}
    
    
    
    

    /**
     * Definition of the constructor.
     * Initial all variables.
     *
     * @param      None
     * @return     None
     * @since      1.0
     */  
    public VizioSupport_ViewServiceRequest(ApexPages.StandardController standardController ){
        
        //this.standardController = standardController;
        //getSRId=  (Service_Request__c)standardController.getRecord();
        //srId = getSRId.Id;
        srId = ApexPages.currentPage().getParameters().get('id');
        relatedCase = new List<Case>();
        relatedAsset = new List<Asset>();
        relatedProduct = new List<Product2>();
        relatedContact = new List<Contact>(); 
        srInfo = new List<Service_Request_Information__c>();  
        currentSR = new List<Service_Request__c>();
        showPageBlock = true;
        showSRinformation = false;   
        size = 3;    
        getInformation();      
    }
    
    /**
     * The GetInformation function, get the basic related objects information
     *
     * @param                   None
     * @return       PageReference           None
     * @since                   1.0
     */ 
    public PageReference getInformation() {
        
        // Get service Request's data
        currentSR = [Select Id, Name, Shipping_Notes__c, Internal_Notes__c, Box__c, isWallMount__c, isWhiteGlove__c, isSubstitution__c, Label__c,
        	                Error_Code__c, AuthSRtype__c, Service_Provider__c, Service_Provider__r.ServiceProviderName__c, RelatedSRNo__r.Name, Status__c,
        	                Error_Code__r.Name, Error_Code__r.Description__c, AuthSRtype__r.SRType__c, Case__r.AssetId,Case__r.ContactId,
        	                Service_Provider__r.ServiceProviderID__r.MailingStreet, Service_Provider__r.ServiceProviderID__r.MailingStateCode, 
        	                Service_Provider__r.ServiceProviderID__r.MailingCountryCode,
	    			       Service_Provider__r.ServiceProviderID__r.MailingPostalCode, Service_Provider__r.ServiceProviderID__r.MailingCity  
        	         From Service_Request__c
        	         Where Id =: srId];
        if (currentSR.isEmpty()) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Service Request does not exist.'));
            showPageBlock = false;
            return null;
        }
        
        // Get the case's related Customer
        relatedContact = [Select Id, OtherPhone, Extension__c, MailingPostalCode,MailingStreet, Phone,  
        				         MailingStateCode, MailingCountryCode, MailingCity, MailingAddress, LastName, FirstName, Fax, Email
                          From Contact 
                          Where Id=: currentSR[0].Case__r.ContactId];
        if (relatedContact.isEmpty()) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Customer does not exist.'));
            showPageBlock = false;
            return null;            
        }
       
        // Get the case's related Asset
        relatedAsset = [Select Id, Product2Id, PurchaseDate, SerialNumber, Purchase_Location__c, DOA_Date__c From Asset Where Id=: currentSR[0].Case__r.AssetId];
        if (relatedAsset.isEmpty()) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Asset does not exist.'));
            showPageBlock = false;
            return null;
        }
        
        // Get the Asset's related Product
        relatedProduct = [Select Id, Description, Model__c, SKU__c, SKUDesc__c, isPart__c  From Product2 Where Id=: relatedAsset[0].Product2Id];
        if (relatedProduct.isEmpty()) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Product does not exist.'));
            showPageBlock = false;
            return null;
        }
       
        // Get Service Request Information
        srInfo = [Select isActive__c, SubModelOutDOA__c, SubModelOutDOASKU__c, SubModelDOA__c, SubModelDOASKU__c,
        				 SpecialInstructions__c, SR__c, RepairableBacklight__c, RepairableBacklightModels__c, RR__c, RNR__c, RC__c, 
        				 ProductId__c, OSS__c, OSR__c, Country__c, ODM__c, ContactODM__r.LastName, AR__c, ACC__c 
        		  From Service_Request_Information__c
        		  Where ProductId__c =: relatedProduct[0].Id AND Country__c =: relatedContact[0].MailingCountryCode];
        if (srInfo.isEmpty()) {
        	showSRinformation = false;      	
        } else {
        	showSRinformation = true;
        }

        return null; 
    }
    
   
      /**
     * Get standardSetController from pagenation
     *
     * @param                                      None   
     * @return          setCon                StandardSetController 
     * @since                                      1.0
     */    
     public ApexPages.StandardSetController setCon {
         get {   
     	         	     
     	     // Query from SR object
             if (setCon == null) {       
                 String searchquery;          	         
        		 sortFullExp = sortExpression  + ' ' + sortDirection;
                 searchquery = 'Select Id, Name, PartType__c, Service_Request__c, SKU__c, Quantity__c, Grade__c, Core__c, Serial_No__c,'+
                               'Price__c, Restocking_Fee__c, Sales_Order_No__c, Notes__c ' +
        					   'From Line_Items__c Where Quantity__c != 0 AND Service_Request__c =: srId ORDER BY ' + sortFullExp; 
	       		 
         		 setCon =   new ApexPages.StandardSetController(Database.getQueryLocator(searchquery));  
        	 	 setCon.setPageSize(size);
        	 	 noOfRecords = setCon.getResultSize(); 	
             }
        	 return setCon;
        }     	        
     	set; 
    }
    
    
    /**
     * Get Line Item from database
     *
     * @param                                      None   
     * @return                                     list of Line_Items__c 
     * @since                                      1.0
     */    
     public List<Line_Items__c> getRelatedLineItem() {
     	
    	return (List<Line_Items__c>) setCon.getRecords();
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
            }  else {
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