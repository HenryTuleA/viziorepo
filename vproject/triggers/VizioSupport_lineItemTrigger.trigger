/*
 * Whenever a line item is created by all user (hard code the id)
 * Check if there is another line item with same SR AND sku AND part type (send, receive)
 * (whether creating new cases or updating existing ones), 
 * and places the attachments in the related list for the case
 *
 * @author      Stela Zhang
 * @version     1.0
 * @since       1.0
 */


trigger VizioSupport_lineItemTrigger on Line_Items__c (after insert) {
    
    List<Line_Items__c> existinglineItemList = new List<Line_Items__c>(); // Line Item query from salesforce based on the SRID
    List<Line_Items__c> updatelineItemList = new List<Line_Items__c>(); // Line Item will be updated
    List<Line_Items__c> deletelineItemList = new List<Line_Items__c>(); // Line Item will be deleted
    set<Id> lineItemIDSet = new set<Id>();
    
    List<Line_Items__c> newLineItemList = new List<Line_Items__c>();
    Set<String> serviceRequestId = new Set<String>();
    // Get current user Name
   // String userName = [Select Id, Name From User Where Id =: UserInfo.getUserId()].Name;
    
    // If the current user is Vizio API
    //if (userName == 'Vizio API') {
    	
    	
	    for (Line_Items__c newLineItem : trigger.New) {
	        serviceRequestId.add(newLineItem.Service_Request__c);
	        newLineItemList.add(newLineItem);        
	    }
	    
	    
	    
	    // Get existing Line Item
	    existinglineItemList = [Select Id, Service_Request__c, SKU__c, PartType__c From Line_Items__c Where Service_Request__c IN: serviceRequestId];
	    
	    for (Line_Items__c newLineItem : newLineItemList) {
	    	for (Line_Items__c existLineItem : existinglineItemList) {
	            
	            // If find match (Service_Request__c, SKU__c, PartType__c) and the line Item Id is not equal. Get the update list and the insert Line item Id          
	            if (newLineItem.Service_Request__c == existLineItem.Service_Request__c && newLineItem.SKU__c == existLineItem.SKU__c && newLineItem.PartType__c == existLineItem.PartType__c && newLineItem.Id != existLineItem.Id) {
	                
	                existLineItem.Carrier__c = newLineItem.Carrier__c;
	                existLineItem.Core__c= newLineItem.Core__c;
	                existLineItem.Grade__c= newLineItem.Grade__c;
	                existLineItem.isActive__c= newLineItem.isActive__c;
	                existLineItem.isEmailSent__c= newLineItem.isEmailSent__c;
	                existLineItem.Method__c= newLineItem.Method__c;
	                existLineItem.Notes__c= newLineItem.Notes__c;
	                existLineItem.Price__c= newLineItem.Price__c;
	                existLineItem.Quantity__c= newLineItem.Quantity__c;
	                existLineItem.Receive_Date__c= newLineItem.Receive_Date__c;
	                existLineItem.Product__c= newLineItem.Product__c;
	                existLineItem.Receive_Date__c= newLineItem.Receive_Date__c;
	                
	                existLineItem.Restocking_Fee__c = newLineItem.Restocking_Fee__c;
	                existLineItem.Sales_Order_No__c= newLineItem.Sales_Order_No__c;
	                existLineItem.Serial_No__c= newLineItem.Serial_No__c;
	                existLineItem.Ship_Date__c= newLineItem.Ship_Date__c;
	                existLineItem.Status__c= newLineItem.Status__c;
	                existLineItem.Tracking_Number__c= newLineItem.Tracking_Number__c;
	                existLineItem.Transaction_Date__c= newLineItem.Transaction_Date__c;
	               
	                updatelineItemList.add(existLineItem); 
	                lineItemIDSet.add(newLineItem.Id);
	                	                            
	            } 
	        }
	    }
	    
	    // Update the exsiting match list
	    update updatelineItemList;
	    
	    // Delete the insert LineItem which is create a duplicate one by Vizio API
	    deletelineItemList = [Select Id, Service_Request__c, SKU__c, PartType__c From Line_Items__c Where Id IN: lineItemIDSet];
	    delete deletelineItemList;
//	}
	    
}