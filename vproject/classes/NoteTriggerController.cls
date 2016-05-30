public with sharing class NoteTriggerController {
	public class CommonException extends Exception {}
	
	public static void handleDeleteTrigger (List<Note> newList) {
		Set<Id> claimIdSet = new Set<Id>();
		List<Claim__c> claimList = [SELECT Id FROM Claim__c WHERE Status__c = 'Submitted' 
									OR Status__c = 'Pending Customer Approval' 
									OR Status__c = 'Customer Approved' 
									OR Status__c = 'Customer Rejected' 
									OR Status__c = 'Pending Sales Approval' 
									OR Status__c = 'Sales Approved' 
									OR Status__c = 'Sales Rejected' 
									OR Status__c = 'Pending Accounting Approval' 
									OR Status__c = 'Accounting Approved' 
									OR Status__c = 'Accounting Rejected' 
									OR Status__c = 'Approved' 
									OR Status__c = 'Rejected'];
		
		for (Claim__c c: claimList) {
			claimIdSet.add(c.Id);
		}
		
		for (Note a: newList) {
			if (claimIdSet.contains(a.ParentId)) {
				a.addError('You cannot edit or delete a Note associated to a Claim in an approval process');
			}
		}
		
	}
	
	public static void handleUpdateTrigger (List<Note> newList) {
		Set<Id> claimIdSet = new Set<Id>();
		List<Claim__c> claimList = [SELECT Id FROM Claim__c WHERE Status__c = 'Submitted' 
									OR Status__c = 'Pending Customer Approval' 
									OR Status__c = 'Customer Approved' 
									OR Status__c = 'Customer Rejected' 
									OR Status__c = 'Pending Sales Approval' 
									OR Status__c = 'Sales Approved' 
									OR Status__c = 'Sales Rejected' 
									OR Status__c = 'Pending Accounting Approval' 
									OR Status__c = 'Accounting Approved' 
									OR Status__c = 'Accounting Rejected' 
									OR Status__c = 'Approved' 
									OR Status__c = 'Rejected'];
		
		for (Claim__c c: claimList) {
			claimIdSet.add(c.Id);
		}
		
		for (Note a: newList) {
			if (claimIdSet.contains(a.ParentId)) {
				a.addError('You cannot edit or delete a Note associated to a Claim in an approval process');
			}
		}
		
	}
	
	public static void handleInsertTrigger (List<Note> newList) {
		Set<Id> claimIdSet = new Set<Id>();
		List<Claim__c> claimList = [SELECT Id FROM Claim__c WHERE Status__c = 'Approved' OR Status__c = 'Rejected'];
		
		for (Claim__c c: claimList) {
			claimIdSet.add(c.Id);
		}
		
		for (Note a: newList) {
			if (claimIdSet.contains(a.ParentId)) {
				a.addError('You cannot add a new note to an approved/rejected Claim');
			}
		}
		
	}
}