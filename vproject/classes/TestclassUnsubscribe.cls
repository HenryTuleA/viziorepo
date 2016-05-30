@isTest
private class TestclassUnsubscribe {
    // The following test methods provide adequate code coverage 
    // for the unsubscribe email class.
    // There are two methods, one that does the testing
    // with a valid "unsubcribe" in the subject line
    // and one the does not contain "unsubscribe" in the
    // subject line.        
    static testMethod void testUnsubscribe() {
    
       // Create a new email and envelope object.
       Messaging.InboundEmail email = new Messaging.InboundEmail() ;
       Messaging.InboundEnvelope env    = new Messaging.InboundEnvelope();
    
       // Create a new test lead and insert it in the test method.
       Lead l = new lead(firstName='John', 
                lastName='Smith',
                Company='Salesforce', 
                Email='user@acme.com', 
                HasOptedOutOfEmail=false);
       insert l;
    
       // Create a new test contact and insert it in the test method.
       Contact c = new Contact(firstName='john', 
                    lastName='smith', 
                    Email='user@acme.com', 
                    HasOptedOutOfEmail=false);
       insert c;
       
       // Test with the subject that matches the unsubscribe statement.
       email.subject = 'test unsubscribe test';
       env.fromAddress = 'user@acme.com';
       
       // Call the class and test it with the data in the testMethod.
       unsubscribe unsubscribeObj = new unsubscribe();
       unsubscribeObj.handleInboundEmail(email, env );
                            
    }
     
    static testMethod void testUnsubscribe2() {
    
       // Create a new email and envelope object.
       Messaging.InboundEmail email = new Messaging.InboundEmail();
       Messaging.InboundEnvelope env = new Messaging.InboundEnvelope();
    
       // Create a new test lead and insert it in the test method.        
       Lead l = new lead(firstName='john', 
                lastName='smith',
                Company='Salesforce', 
                Email='user@acme.com', 
                HasOptedOutOfEmail=false);
       insert l;
    
       // Create a new test contact and insert it in the test method.    
       Contact c = new Contact(firstName='john', 
                    lastName='smith', 
                    Email='user@acme.com', 
                    HasOptedOutOfEmail=false);
       insert c;
       
       // Test with a subject that does not contain "unsubscribe."
       email.subject = 'test';
       env.fromAddress = 'user@acme.com';
    
       // Call the class and test it with the data in the test method.
       unsubscribe unsubscribeObj = new unsubscribe();
       unsubscribeObj.handleInboundEmail(email, env );                      
    }     
}