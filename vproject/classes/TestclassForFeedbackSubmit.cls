/**
 * Test class to test the class named FeedbackSubmit
 *
 * @author		Xin Zhang
 * @version		1.0
 * @since		1.0
 */
 
@isTest (SeeAllData=false)
private class TestclassForFeedbackSubmit {
    
    /**
     * method to test the FeedbackSubmit
     *
     * @param			None	  
     * @return			None
     * @since			1.0
     */
    static testMethod void myTestFeedbackSubmit() {         
        FeedbackSubmit feedback = new FeedbackSubmit ();
        PageReference testFeedbackSubmit = Page.FeedbackSubmit ;       
        Test.setCurrentPage(testFeedbackSubmit );            
        feedback.submit();        
    } 
}