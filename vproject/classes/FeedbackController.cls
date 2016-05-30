public without sharing class FeedbackController {
    public String articleId {get; set;}
    
    public FeedbackController() {

    }
    
    public void sendFeedback() {
		System.debug('Here is the feedback');        
    }
}