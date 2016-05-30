/**
 * Get Quick Text Name and message table
 *
 * @author              Xin Zhang
 * @version             1.0
 * @since               1.0
 */ 
public with sharing class GetQuickText {
	public Integer           noOfRecords{get; set;}         // amount of cases
    public Integer           size{get;set;}                 // how many cases will show per page
    private String           sortDirection = 'ASC';         //initial order by expression
    private String           sortExp = 'Name';               //initial order by expression
    public String            sortFullExp{get;set;} 
    public String            keyword{get;set;}              //get search keyword
    
    
    /**
     * Definition of the constructor.
     * Initial all variables.
     *
     * @param                None
     * @return               None
     * @since                 1.0
     */ 
	public GetQuickText () {
        size = 4;
    }	
    
    
    /**
     * Get standardSetController from database
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
        		 if (keyword == null) {
            	 	 searchquery = 'SELECT Id, Name, Message, Quick_Text_Channel__c FROM QuickText ORDER BY ' + sortFullExp; 
        		 } else {
        		     searchquery = 'SELECT Id, Name, Message, Quick_Text_Channel__c FROM QuickText ' +
        		 	               'WHERE (Name LIKE \'%' + keyword +'%\') ' + 
        		 	               'ORDER BY ' + sortFullExp; 
        		 } 	       		 
         		 setCon =   new ApexPages.StandardSetController(Database.getQueryLocator(searchquery));  
        	 	 setCon.setPageSize(size);
        	 	 noOfRecords = setCon.getResultSize(); 	
             }
        	 	 return setCon;
        }     	        
     	set; 
    }
    
    /**
     * Initialize setCon and return a list of records
     *
     * @param                                        None      
     * @return     List               return List<QuickText>      
     * @since                                                                            
     */ 
    public List<QuickText> getQuickText() {
        return (List<QuickText>) setCon.getRecords();
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
                sortDirection = (sortDirection == 'ASC')? 'DESC' : 'ASC';
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
        if ((sortExpression == null) || (sortExpression == ''))
                return 'ASC';
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
            if (math.mod(noOfRecords, size) > 0)
                    return noOfRecords/size + 1;
            else 
                        return (noOfRecords/size);
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
    
    /**
     * The goSearch method is what will happen when you click the Search button.
     * It will go searching, show you the information of the quick text you enter. 
     *
     * @param                   None      
     * @return                  None            
     * @since                   1.0
     */     
    public PageReference goSearch() {
    	setCon = null;
		setCon.setPageNumber(1);
	    return null;
    }
    
    /**
     * The clearSearch method is what will happen when you click the Clear Search button.
     * It will go back the PortalCustomerMain page. 
     *
     * @param                                                   None      
     * @return                  page              If you click the Clear Search buttom it will go back the PortalCustomerMain             
     * @since
     */    
    public PageReference clearSearch() {
        keyword = null;
        setCon = null;
        setCon.setPageNumber(1);
        return null;  
    }
    
}