public without sharing class SubmitTriggerController {
	
	public static void handleBeforeTrigger(List<Claim__c> newList) {
		Set<Id> accIdSet = new Set<Id>();
		Set<Id> claimIdSet = new Set<Id>();
		Set<Id> conIdSet = new Set<Id>();
		List<Claim_Item__c> updateClaimItemList = new List<Claim_Item__c>();
		List<AccountPartner__c> apList = new List<AccountPartner__c>();
		for (Claim__c claim: newList) {
			if (claim.Status__c == 'Approved' || claim.Status__c == 'Rejected') {
				accIdSet.add(claim.Account__c);
				claimIdSet.add(claim.Id);
			}
		}
		if (!claimIdSet.isEmpty()) {
			try {
	        	apList = [SELECT Id, Main_AccountId__c, Partner_AccountId__c, Distributor_Contact__c FROM AccountPartner__c WHERE Partner_AccountId__c IN: accIdSet AND Partner_Type__c = 'VAR/Reseller'];
	        } catch (exception e) {
	        	apList = null;
	        }
	        for (AccountPartner__c ap: apList) {
	        	conIdSet.add(ap.Distributor_Contact__c);
	        }
	        Map<Id, Contact> conMap = new Map<ID, Contact>([SELECT Id, Email FROM Contact WHERE Id IN: conIdSet]);
	    	
	    	for (Claim__c claim: newList) {
	    		if (claim.Status__c == 'Approved' || claim.Status__c == 'Rejected') {
	    			claim.Distributor_Contact__c = '';
		    		for (AccountPartner__c accPartner: apList) {
		    			if (claim.Account__c == accPartner.Partner_AccountId__c) {
		    				if (conMap.get(accPartner.Distributor_Contact__c) != null) {
		    					claim.Distributor_Contact__c = conMap.get(accPartner.Distributor_Contact__c).Email;
		    				}
		    			}
		    		}
	    		}
	    		
	    	}
		}
	}
	
	public static void handleAfterTrigger(List<Claim__c> newList) {
		
		Set<Id> claimIdSet = new Set<Id>();
		for (Claim__c claim: newList) {
			if (claim.Status__c == 'Approved' || claim.Status__c == 'Rejected') {
				claimIdSet.add(claim.Id);
			}
		}
		
		if (!claimIdSet.isEmpty()) {
			List<Claim_Item__c> ciList = [SELECT Id, Claim__c, Amount__c, Amount_Approved__c, Amount_Claimed__c, Claim_Item_Amount_Approved__c, Claim_Item_Amount_Claimed__c, Quantity_Approved__c, Quantity_Approved_Calc__c, Quantity_Claimed__c FROM Claim_Item__c WHERE Claim__c IN: claimIdSet];
	        
	        List<Claim_Item__c> updateClaimItemList = new List<Claim_Item__c>();
			for (Claim_Item__c ci: ciList) {
				if (claimIdSet.contains(ci.Claim__c)) {
					ci.Claim_Item_Amount_Claimed__c = ci.Amount__c * ci.Quantity_Claimed__c;
					if (ci.Claim_Item_Amount_Approved__c == null) {
						ci.Claim_Item_Amount_Approved__c = ci.Amount_Approved__c;
					}
					if (ci.Quantity_Approved__c == null) {
						ci.Quantity_Approved__c = ci.Quantity_Claimed__c;
					}
					updateClaimItemList.add(ci);
	    		}
	    	}
	    	if (updateClaimItemList.size() != 0) {
	    		update updateClaimItemList;
	    	}
		}
    	
	}
}