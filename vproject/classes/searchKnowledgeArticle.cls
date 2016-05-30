/*
 * Copyright (c) 2013, UC Innovation, Inc.  All Rights Reserved.
 *                     http://www.ucinnovation.com
 *
 * This source code is licensed, not sold, and is subject to a written
 * license agreement.  Among other things, no portion of this source
 * code may be copied, transmitted, disclosed, displayed, distributed,
 * translated, used as the basis for a derivative work, or used, in
 * whole or in part, for any program or purpose other than its intended
 * use in compliance with the license agreement as part of UC Innovation's
 * software.  This source code and certain of the algorithms contained
 * within it are confidential trade secrets of UC Innovation, Inc.
 * and may not be used as the basis for any other
 * software, hardware, product or service.
 */

/**
 * Search the article then show the list of the search results.
 *
 * @author              Xin Zhang
 * @version             1.0
 * @since               1.0
 */ 

public class searchKnowledgeArticle {

 	
  	//Search String used in ArticleList tag
 	public String searchstring { get; set; }
 	public Boolean showList {get;set;}
 	
 	public Integer           noOfRecords{get; set;}         // amount of cases
    public Integer           size{get;set;}                 // how many cases will show per page
    public String            selectLanguage{get;set;}       // different language
    public List<Integer>     allPageNumber {get;set;}
    public String            clickPage{get;set;}
 	/**
     * Definition of the constructor.
     * Initial all variables.
     *
     * @param      None
     * @return     None
     * @since      1.0
     */    
 	public searchKnowledgeArticle() {
 		selectLanguage = ApexPages.currentPage().getParameters().get('language');
 		if (selectLanguage == null || (selectLanguage != 'en_US' &&selectLanguage != 'en_CA' && selectLanguage != 'fr_CA' && selectLanguage != 'es_MX')) {
 			selectLanguage = 'en_US';
 		}
  		showList = false;
  		size = 10;
  		allPageNumber = new List<Integer>();
    }
 

	/**
     * The action of button Next(Search article)
     *
     * @param                   None
     * @return                  None
     * @since                   1.0
     */  
  	public Void searchArticle() {
    	showList = true;
  	}
  
 
  	
  	
  	/**
     * Get standardSetController from database
     *
     * @param                                      None   
     * @return          setCon                StandardSetController 
     * @since                                      1.0
     */    
     public ApexPages.StandardSetController setCon {
         get{   
     	     
              if(setCon == null) {
        
                 String searchquery;          	         
        		 if ((searchstring == null) || (searchstring.Length() < 1)) {
            	 	 searchquery = 'SELECT Id, title, UrlName, LastPublishedDate,LastModifiedById,Summary FROM KnowledgeArticleVersion WHERE (PublishStatus = \'online\' and Language = \'' + selectLanguage + '\')';   	 
        		 }
        		 else {
            		 searchquery = 'SELECT Id, title, UrlName, LastPublishedDate,LastModifiedById,Summary ' + 
            			 		   'FROM KnowledgeArticleVersion ' + 
            			 		   'WHERE (PublishStatus = \'online\' AND Language = \'' + selectLanguage + '\' )' +
            			 		   'AND ((title LIKE \'%' + searchstring +'%\')' + 
            			 		   'OR (Summary LIKE \'%' + searchstring +'%\')' +           			 		         		 		   
            			 		   'OR (UrlName LIKE \'%' + searchstring +'%\'))'; 
            			 		  
       			 }           
         		 setCon =   new ApexPages.StandardSetController(Database.getQueryLocator(searchquery));  
        	 	 setCon.setPageSize(size);
        	 	 noOfRecords = setCon.getResultSize(); 
        	 	 
        	 	 
        	 	 Integer i;
        	 	 for(i = 1; i<=totalNumber; i++) {
        	 	 	allPageNumber.add(i);
        	 	 }
        	 	 
        	 	 
              }
        	 	 return setCon;
             }
          	
        
     	set; 
    }
    
    /**
     * Initialize setCon and return a list of records
     *
     * @param                                        None      
     * @return     List               return List<KnowledgeArticleVersion>        
     * @since                                                                            
     */ 
    public List<KnowledgeArticleVersion> getArticles() {

        return (List<KnowledgeArticleVersion>) setCon.getRecords();
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
     *  Get value from visualforce page
     *
     * @param   None.
     * @return  None.
     * @since   1.0
     */
    public void clickPageNum() {
    	
    	system.debug('clickPage' + clickPage);
    	Integer numberClicked = Integer.valueOf(clickPage);
    	
    	setCon.setPageNumber(allPageNumber[numberClicked-1]);
    }
    
    
    
    
}