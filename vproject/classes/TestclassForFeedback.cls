/**
 * Test class to test the class named TestFeedback
 *
 * @author		Xin Zhang
 * @version		1.0
 * @since		1.0
 */

@isTest (SeeAllData=false)
private class TestclassForFeedback {
    
    /**
     * method to test the FeedbackSubmit
     *
     * @param			None	  
     * @return			None
     * @since			1.0
     */
    static testMethod void myTestSearch() { 
        
        TestFeedback feedback = new TestFeedback();  
        PageReference testFeedbackPage = Page.TestFeedback;       
        Test.setCurrentPage(testFeedbackPage);        
        feedback.submit();       
    } 
}