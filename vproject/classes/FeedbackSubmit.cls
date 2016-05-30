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
 * Submit the feedback from external
 *
 * @author             Hay Mun Win
 * @version             1.0
 * @since               1.0
 */ 

public class FeedbackSubmit {
    
    public Article_Feedback__c       newFeedback_test    {get;set;} 
    
    /**
     * Definition of the constructor.
     * Initial all variables.
     *
     * @param      None
     * @return     None
     * @since      1.0
     */    
    public FeedbackSubmit() {
        newFeedback_test = new Article_Feedback__c(); 
    }
   
    /**
      * Insert tne new feedback after click submit 
      *
      * @param                     None      
      * @return                    None          
      * @since                                                                            
     */  
    public void Submit() {     
        newFeedback_test.Article_Number__c= ApexPages.currentPage().getParameters().get('article_number');
        newFeedback_test.Version_Number__c= ApexPages.currentPage().getParameters().get('version_number');
        newFeedback_test.Article_Name__c= ApexPages.currentPage().getParameters().get('article_name');
        newFeedback_test.External_Feedback_Reason__c= ApexPages.currentPage().getParameters().get('response');
        newFeedback_test.Ext__c= ApexPages.currentPage().getParameters().get('ext_response_result');
        newFeedback_test.Feedback_Type__c= ApexPages.currentPage().getParameters().get('feedback_type');
        newFeedback_test.External_Feedback_Comment__c= ApexPages.currentPage().getParameters().get('comment');
        insert newFeedback_test;  
    }
}