public with sharing class InitialControlNumShareTriggerController {
	public static void handleInsertTrigger (List<Control_Number__c> newList) {
        Set<Id> allAccSet = new Set<Id>();
        Set<Id> cnSet = new Set<Id>();
        Set<Id> uRoleIdSet = new Set<Id>();
        Map<Id, Set<Id>> uRoleMap = new Map<Id, Set<Id>>();
        Map<Id, Id> accGroupMap = new Map<Id, Id>();
        Map<Id, Set<Id>> accPartnerpMap = new Map<Id, Set<Id>>();
        Boolean insertTimes = false;
        List<Control_Number__Share> cnsList = new List<Control_Number__Share>();
        List<Trigger_log__c> tlList = new List<Trigger_log__c>();
        
        System.debug(logginglevel.ERROR, '**** new control Number : ' + newList);
        
        try {
	        for (Control_Number__c cn: newList) {
	        	allAccSet.add(cn.Account__c);
	        }
	        List<AccountPartner__c> apList = [SELECT Id, Main_AccountId__c, Partner_AccountId__c, Partner_Type__c FROM AccountPartner__c WHERE Main_AccountId__c IN: allAccSet];
	        
	        for (AccountPartner__c ap: apList) {
	        	if (ap.Partner_Type__c == 'VAR/Reseller') {
		        	allAccSet.add(ap.Partner_AccountId__c);
		        	if (accPartnerpMap.keySet().contains(ap.Main_AccountId__c)) {
		        		accPartnerpMap.get(ap.Main_AccountId__c).add(ap.Partner_AccountId__c);
		        	} else {
		        		Set<Id> IdSet = new Set<Id>();
		                IdSet.add(ap.Partner_AccountId__c);
		                accPartnerpMap.put(ap.Main_AccountId__c, IdSet);
		        	}
	        	}
	        }
	
	        List<UserRole> uRoleList = [SELECT Id, PortalAccountId, PortalRole FROM UserRole WHERE PortalAccountId IN: allAccSet AND PortalRole = 'Manager'];
	        /*for (UserRole ur: uRoleList) {
	            uRoleMap.put(ur.Id, ur.PortalAccountId);
	        }*/
	        
	        for (AccountPartner__c ap: apList) {
	        	Set<Id> roleIdSet = new Set<Id>();
	        	for (UserRole ur: uRoleList) {
	        		if (ur.PortalAccountId == ap.Main_AccountId__c || (accPartnerpMap.keySet().contains(ap.Main_AccountId__c) && accPartnerpMap.get(ap.Main_AccountId__c).contains(ur.PortalAccountId))) {
	        			roleIdSet.add(ur.Id);
	        			uRoleIdSet.add(ur.Id);
	        		}
	        	}
	        	uRoleMap.put(ap.Main_AccountId__c, roleIdSet);
	        }
	        
	        for (Control_Number__c cn: newList) {
	        	if (!uRoleMap.keySet().contains(cn.Account__c)) {
	        		Set<Id> roleIdSet = new Set<Id>();
	        		for (UserRole ur: uRoleList) {
	        			if (ur.PortalAccountId == cn.Account__c) {
		        			roleIdSet.add(ur.Id);
		        			uRoleIdSet.add(ur.Id);
	        			}
	        		}
	        		uRoleMap.put(cn.Account__c, roleIdSet);
	        	}
	        }
	        
	        List<Group> groupList = [SELECT Id, RelatedId, Type FROM Group WHERE RelatedId IN: uRoleIdSet AND Type = 'RoleAndSubordinates'];
	        /*for (Group g: groupList) {
	            for (Id urId: uRoleMap.keySet()) {
	                if (g.RelatedId == urId) {
	                    accGroupMap.put(uRoleMap.get(urId), g.Id);
	                }
	            }
	        }*/
	        
	        for (Group g: groupList) {
	        	accGroupMap.put(g.RelatedId, g.Id);
	        }
	        
	        for (Control_Number__c cn: newList) {
	        	Boolean logged = true;
	        	if (!uRoleMap.get(cn.Account__c).isEmpty()) {
		        	for (Id uId: uRoleMap.get(cn.Account__c)){
		        		if (accGroupMap.get(uId) != null) {
			        		Control_Number__Share newCNS = new Control_Number__Share();
				            newCNS.UserOrGroupId = accGroupMap.get(uId);
				            newCNS.ParentId = cn.Id;
				            newCNS.AccessLevel = 'Read';
				            cnsList.add(newCNS);
				            logged = false;
		        		}
		        	}
	        	}
	        	
	        	if (logged == true) {
	        		Trigger_log__c tl = new Trigger_log__c();
		        	tl.Account_Id__c = cn.Account__c;
		        	tl.Control_Number_Id__c = cn.Id;
		        	tl.Trigger_Type__c = 'Insert Control Number Trigger';
		        	tl.name = 'Insert Control Number Trigger';
		        	tl.error_message__c = 'This account does not have user or user does not be acitve.';
		        	tlList.add(tl);
	        	}
	        }
	        //System.debug(Logginglevel.ERROR, 'search query ' + cnsList);
	        System.debug(logginglevel.ERROR, '**** insert control Number : ' + cnsList);
	        insert tlList;
	        insert cnsList;
        } catch (exception e) {
        	for (Control_Number__c cn: newList) {
        		Trigger_log__c tl = new Trigger_log__c();
	        	tl.Account_Id__c = cn.Account__c;
	        	tl.Control_Number_Id__c = cn.Id;
	        	tl.Trigger_Type__c = 'Insert Control Number Trigger';
	        	tl.name = 'Insert Control Number Trigger';
	        	tl.error_message__c = e.getMessage();
	        	tlList.add(tl);
        	}
        	insert tlList;
        }
    }
    
    public static void handleUpdateTrigger (List<Control_Number__c> oldList, List<Control_Number__c> newList) {
    	
        Set<Id> cnSet = new Set<Id>();
        List<Trigger_log__c> tlList = new List<Trigger_log__c>();
        List<Control_Number__c> deleteList = new List<Control_Number__c>();
        List<Control_Number__c> insertList = new List<Control_Number__c>();
        
        System.debug(logginglevel.ERROR, '**** update new control Number : ' + newList);
        System.debug(logginglevel.ERROR, '**** update old control Number : ' + oldList);
        
        for (Control_Number__c cno: oldList) {
    		for (Control_Number__c cnn: newList) {
    			if (cno.Id == cnn.Id && cno.Account__c != cnn.Account__c) {
    				deleteList.add(cno);
    				insertList.add(cnn);
    			}
    		}
    	}
        try {
        	if (!deleteList.isEmpty()) {
		        for (Control_Number__c cn: deleteList) {
		        	cnSet.add(cn.Id);
		        }
		        
		        List<Control_Number__Share> cnsList = [SELECT Id, ParentId FROM Control_Number__Share WHERE ParentId IN: cnSet];
		        System.debug(logginglevel.ERROR, '**** update delete control Number : ' + cnsList);
		        delete cnsList;
        	}
        	
	        if (!insertList.isEmpty()) {
	        	System.debug(logginglevel.ERROR, '**** update Run Insert ****** ');
	        	handleInsertTrigger(insertList);
	        }
	    } catch (exception e) {
        	for (Control_Number__c cn: newList) {
        		Trigger_log__c tl = new Trigger_log__c();
	        	tl.Account_Id__c = cn.Account__c;
	        	tl.Control_Number_Id__c = cn.Id;
	        	tl.Trigger_Type__c = 'Insert Control Number Trigger';
	        	tl.name = 'Insert Control Number Trigger';
	        	tl.error_message__c = e.getMessage();
	        	tlList.add(tl);
        	}
        	
        	insert tlList;
        }
    }
}