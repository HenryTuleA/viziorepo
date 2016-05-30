/**
 * Test class to test the class named TestInternalFeedback
 *
 * @author		Xin Zhang
 * @version		1.0
 * @since		1.0
 */

@isTest (SeeAllData=true)
private class TestInternalFeedback {
    
    /**
     * method to test the FeedbackSubmit
     *
     * @param			None	  
     * @return			None
     * @since			1.0
     */
    static testMethod void myTestSearch() { 
        
        InternalFeedback feedback = new InternalFeedback();
        PageReference testFeedbackPage = Page.InternalFeedback;       
        Test.setCurrentPage(testFeedbackPage);        
        feedback.submit();       
    } 
}