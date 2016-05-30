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

public class vfKeywordSearchController {

 	//Page Size
 	private Static Final Integer PAGE_NUMBER = 10;
 
  	//Search String used in ArticleList tag
 	public String searchstring { get; set; }
 	public Boolean showList {get;set;}
 	public String            selectLanguage{get;set;} 
 	//Keeps track of current page & max size of article list
 	Integer currentPage = 1;
 	Integer maxSize = 1;
 	public Boolean selecten_US {get;set;}
	public Boolean selecten_CA {get;set;}
	public Boolean selectfr_CA {get;set;}
	public Boolean selectes_MX {get;set;}
 
 	/**
     * Definition of the constructor.
     * Initial all variables.
     *
     * @param      None
     * @return     None
     * @since      1.0
     */    
 	public vfKeywordSearchController() {
 		selectLanguage = ApexPages.currentPage().getParameters().get('language');
 		
 		/* Set the language */
		if (selectLanguage == 'en_us' || selectLanguage == 'en_US') {
 			selectLanguage = 'en_US';
 			selecten_US = true;
 		} else if (selectLanguage == 'en_ca' || selectLanguage == 'en_CA') {
 			selectLanguage = 'en_CA';
 			selecten_CA = true;
 		} else if (selectLanguage == 'fr_ca' || selectLanguage == 'fr_CA') {
 			selectLanguage = 'fr_CA';
 			selectfr_CA = true;
 		} else if (selectLanguage == 'es_mx' || selectLanguage == 'es_MX') {
 			selectLanguage = 'es_MX';
 			selectes_MX = true;
 		} else {
 			selectLanguage = 'en_US';
 			selecten_US = true;
 		}
 		
 		String qryString = 'SELECT Id, title, UrlName, LastPublishedDate,LastModifiedById FROM KnowledgeArticleVersion WHERE (PublishStatus = \'online\' and Language = \'' + selectLanguage + '\')'; 
  		List<KnowledgeArticleVersion> articleList= Database.query(qryString);
  		maxSize = articleList.size() ;
  		showList = false;
    }
 
 	/**
     * Has previous page or not
     *
     * @param                   None
     * @return   Boolean        currentPage > 1
     * @since                   1.0
     */
 	public boolean getPrevRequired() {
  		return currentPage > 1;
 	}

 	/**
     * Has next page or not
     *
     * @param                   None
     * @return   Boolean        currentPage * PAGE_NUMBER < maxSize
     * @since                   1.0
     */
 	public boolean getNextRequired() {
  		return currentPage * PAGE_NUMBER < maxSize;
 	}
 
 	/**
     * Get current page number
     *
     * @param                   None
     * @return   Decimal        this.currentPage
     * @since                   1.0
     */
 	public Decimal getCurrentPageNumber() {
  		return this.currentPage;
 	}

 	/**
     * The action of button next 
     *
     * @param                   None
     * @return                  None
     * @since                   1.0
     */
 	public PageReference next() {
  		if(maxSize > this.currentPage * PAGE_NUMBER) {
   			this.currentPage = this.currentPage + 1;
  		}
  		return null;
 	}    
 
 	/**
     * The action of button previous 
     *
     * @param                   None
     * @return                  None
     * @since                   1.0
     */  
 	public PageReference previous() {        
  		if(this.currentPage > 1) {
   			this.currentPage = this.currentPage - 1;
  		}
  		return null;
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
}