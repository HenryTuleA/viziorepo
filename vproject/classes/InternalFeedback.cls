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
 * Create Internal Feedback from each article
 *
 * @author              Xin Zhang
 * @version             1.0
 * @since               1.0
 */ 

public with sharing class InternalFeedback {
    
    public Article_Feedback__c       newFeedback {get;set;} 
    public List<KnowledgeArticle>    theArticle {get;set;}
    public List<KnowledgeArticleVersion> articleVersion {get;set;}
    public Id                        loginUserId {get;set;} 
    public Id                        articleId {get;set;} 
    public Boolean                   showMessage {get;set;}
      
    
    /**
     * Definition of the constructor.
     * Initial all variables.
     *
     * @param      None
     * @return     None
     * @since      1.0
     */    
    public InternalFeedback() {
        newFeedback = new Article_Feedback__c(); 
        theArticle = new List<KnowledgeArticle>();
        articleVersion = new List<KnowledgeArticleVersion>();
        loginUserId = Userinfo.getUserId();
        articleId = ApexPages.currentPage().getParameters().get('id'); 
        showMessage = false;
        newFeedback.Feedback_Type__c = 'Internal';      
        newFeedback.User__c = loginUserId;
        
        // Select the article from database based on the articleId
        theArticle = [SELECT Id, ArticleNumber FROM KnowledgeArticle WHERE Id=:articleId];
        
        // Get the article number and version number.
        if (!theArticle .isEmpty()) {
            articleVersion = [SELECT Id, VersionNumber FROM KnowledgeArticleVersion WHERE PublishStatus = 'online' AND KnowledgeArticleId=:articleId ];
            newFeedback.Article_Number__c = theArticle[0].ArticleNumber;
            if(!articleVersion .isEmpty()) {
                newFeedback.Version_Number__c = String.valueOf(articleVersion[0].VersionNumber);
            } else {
                newFeedback.Version_Number__c = '0';
            }
        } else {      
            newFeedback.Article_Number__c = 'Default';
            newFeedback.Version_Number__c = '0';
        }        
    }
    
    /**
     * The action of button Submit
     *
     * @param                   None
     * @return                  None
     * @since                   1.0
     */  
    public void Submit() {        
        insert newFeedback;
        showMessage=true;        
    }
}