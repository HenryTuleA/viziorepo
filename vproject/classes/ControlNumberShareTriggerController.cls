public with sharing class ControlNumberShareTriggerController {
    
    public class CommonException extends Exception {}
    
    public static void handleInsertTrigger (List<AccountPartner__c> newList) {
        List<deleteControlNumberShare.conNumWrapper> cnWrap = new List<deleteControlNumberShare.conNumWrapper>();
        Set<Id> allAccSet = new Set<Id>();
        Set<Id> cnSet = new Set<Id>();
        Map<Id, Id> uRoleMap = new Map<Id, Id>();
        Map<Id, Set<Id>> accIdMap = new Map<Id, Set<Id>>();
        Map<Id, Id> accGroupMap = new Map<Id, Id>();
        Boolean insertTimes = false;
        List<Control_Number__Share> cnsList = new List<Control_Number__Share>();
        List<AccountPartner__c> apList = new List<AccountPartner__c>();
        List<Trigger_log__c> tlList = new List<Trigger_log__c>();
        
        
        List<AccountPartner__c> allApList = [SELECT Id, Partner_AccountId__c, Main_AccountId__c, Partner_Type__c FROM AccountPartner__c];
        for (AccountPartner__c a: newList) {
            for (AccountPartner__c p: allApList) {
                if (a.Partner_AccountId__c == p.Partner_AccountId__c && a.Partner_Type__c == 'VAR/Reseller' && p.Partner_Type__c == 'VAR/Reseller' && a.Id != p.Id) {
                    a.addError('There are duplicate Account Partner record. Please check your input and try again.');
                    //System.assert(false);
                }
            }
        }
	    try {   
	        for (AccountPartner__c p: newList) {
	            if (p.Partner_Type__c == 'VAR/Reseller') {
	                if (accIdMap.keySet().contains(p.Partner_AccountId__c)) {
	                    accIdMap.get(p.Partner_AccountId__c).add(p.Main_AccountId__c);
	                } else {
	                    Set<Id> IdSet = new Set<Id>();
	                    IdSet.add(p.Main_AccountId__c);
	                    accIdMap.put(p.Partner_AccountId__c, IdSet);
	                }
	                if (!allAccSet.contains(p.Main_AccountId__c)) {
	                    allAccSet.add(p.Main_AccountId__c);
	                }
	                AccountPartner__c cnsNord = new AccountPartner__c();
	                cnsNord.Partner_Type__c = 'Distributor';
	                cnsNord.Partner_AccountId__c = p.Main_AccountId__c;
	                cnsNord.Main_AccountId__c = p.Partner_AccountId__c;
	                apList.add(cnsNord);
	            } else if (p.Partner_Type__c == 'Distributor') {
	                if (accIdMap.keySet().contains(p.Main_AccountId__c)) {
	                    accIdMap.get(p.Main_AccountId__c).add(p.Partner_AccountId__c);
	                } else {
	                    Set<Id> IdSet = new Set<Id>();
	                    IdSet.add(p.Partner_AccountId__c);
	                    accIdMap.put(p.Main_AccountId__c, IdSet);
	                }
	                if (!allAccSet.contains(p.Partner_AccountId__c)) {
	                    allAccSet.add(p.Partner_AccountId__c);
	                }
	                AccountPartner__c cnsNord = new AccountPartner__c();
	                cnsNord.Partner_Type__c = 'VAR/Reseller';
	                cnsNord.Partner_AccountId__c = p.Main_AccountId__c;
	                cnsNord.Main_AccountId__c = p.Partner_AccountId__c;
	                apList.add(cnsNord);
	            }
	        }
	        if (!apList.isEmpty()) {
	            insert apList;
	        }
	
	        List<UserRole> uRoleList = [SELECT Id, PortalAccountId, PortalRole FROM UserRole WHERE PortalAccountId IN: accIdMap.keySet() AND PortalRole = 'Manager'];
	        for (UserRole ur: uRoleList) {
	            uRoleMap.put(ur.Id, ur.PortalAccountId);
	        }
	        
	        List<Group> groupList = [SELECT Id, RelatedId, Type FROM Group WHERE RelatedId IN: uRoleMap.keySet() AND Type = 'RoleAndSubordinates'];
	        for (Group g: groupList) {
	            for (Id urId: uRoleMap.keySet()) {
	                if (g.RelatedId == urId) {
	                    accGroupMap.put(uRoleMap.get(urId), g.Id);
	                }
	            }
	        }
	        
	        List<Control_Number__c> controlNumList = [SELECT Id, Account__c FROM Control_Number__c WHERE Account__c IN: allAccSet];
	        for (Control_Number__c cn: controlNumList) {
	            cnSet.add(cn.Id);
	        }
	        
	        for (Id accId: accIdMap.keySet()) {
	            for (Control_Number__c cn: controlNumList) {
	                if (accIdMap.get(accId).contains(cn.Account__c)) {
	                    cnWrap.add(new deleteControlNumberShare.conNumWrapper(accId, cn));
	                }
	            }
	        }
	        
	        for (deleteControlNumberShare.conNumWrapper snw: cnWrap) {
	            if (accGroupMap.get(snw.acc) == null) {
	            	Trigger_log__c tl = new Trigger_log__c();
		        	tl.Account_Id__c = snw.acc;
		        	tl.Control_Number_Id__c = snw.conNum.Id;
		        	tl.Trigger_Type__c = 'Control Number Sharing Trigger';
		        	tl.name = 'Control Number Sharing Trigger';
		        	tlList.add(tl);
	            	//throw new CommonException('The Portal Role cannot be found. Please contact your System Administrator.');
	            } else {
	            	Control_Number__Share newCNS = new Control_Number__Share();
	            	newCNS.UserOrGroupId = accGroupMap.get(snw.acc);
		            newCNS.ParentId = snw.conNum.Id;
		            newCNS.AccessLevel = 'Read';
		            cnsList.add(newCNS);
	            }
	        }
	        
	        system.debug(Logginglevel.ERROR, 'trigger log ' + tlList);
	        
	    	insert tlList;
	    	insert cnsList;
        } catch (exception e) {
        	for (AccountPartner__c a: newList) {
        		Trigger_log__c tl = new Trigger_log__c();
	        	tl.Account_Id__c = a.Main_AccountId__c;
	        	tl.Trigger_Type__c = 'Control Number Sharing Trigger';
	        	tl.name = 'Control Number Sharing Trigger';
	        	tl.error_message__c = e.getMessage();
	        	tl.Partner_Account_Id__c = a.Partner_AccountId__c;
	        	tlList.add(tl);
        	}
        	insert tlList;
        }
    }
    
    public static void handleDeleteTrigger (List<AccountPartner__c> oldList) {
        List<deleteControlNumberShare.conNumWrapper> cnWrap = new List<deleteControlNumberShare.conNumWrapper>();
        Set<Id> oldAllAccSet = new Set<Id>();
        Set<Id> cnSet = new Set<Id>();
        Set<Id> apSet = new Set<Id>();
        Set<Id> oldCnSet = new Set<Id>();
        Boolean insertTimes = false;
        Map<Id, Id> uRoleMap = new Map<Id, Id>();
        Map<Id, Set<Id>> oldAccIdMap = new Map<Id, Set<Id>>();
        Map<Id, Id> accGroupMap = new Map<Id, Id>();
        List<AccountPartner__c> apList = new List<AccountPartner__c>();
        List<AccountPartner__c> allApList = [SELECT Id, Partner_AccountId__c, Main_AccountId__c, Partner_Type__c FROM AccountPartner__c];
        List<Trigger_log__c> tlList = new List<Trigger_log__c>();
        
        try {
	        for (AccountPartner__c p: oldList) {
	            if (p.Partner_Type__c == 'VAR/Reseller') {
	                if (oldAccIdMap.keySet().contains(p.Partner_AccountId__c)) {
	                    oldAccIdMap.get(p.Partner_AccountId__c).add(p.Main_AccountId__c);
	                } else {
	                    Set<Id> IdSet = new Set<Id>();
	                    IdSet.add(p.Main_AccountId__c);
	                    oldAccIdMap.put(p.Partner_AccountId__c, IdSet);
	                }
	                if (!oldAllAccSet.contains(p.Main_AccountId__c)) {
	                    oldAllAccSet.add(p.Main_AccountId__c);
	                }
	                for (AccountPartner__c ap: allApList) {
	                    if (ap.Partner_Type__c == 'Distributor' && ap.Partner_AccountId__c == p.Main_AccountId__c && ap.Main_AccountId__c == p.Partner_AccountId__c) {
	                        apList.add(ap);
	                    }
	                }
	            } else if (p.Partner_Type__c == 'Distributor') {
	                if (oldAccIdMap.keySet().contains(p.Main_AccountId__c)) {
	                    oldAccIdMap.get(p.Main_AccountId__c).add(p.Partner_AccountId__c);
	                } else {
	                    Set<Id> IdSet = new Set<Id>();
	                    IdSet.add(p.Partner_AccountId__c);
	                    oldAccIdMap.put(p.Main_AccountId__c, IdSet);
	                }
	                if (!oldAllAccSet.contains(p.Partner_AccountId__c)) {
	                    oldAllAccSet.add(p.Partner_AccountId__c);
	                }
	                for (AccountPartner__c ap: allApList) {
	                    if (ap.Partner_Type__c == 'VAR/Reseller' && ap.Partner_AccountId__c == p.Main_AccountId__c && ap.Main_AccountId__c == p.Partner_AccountId__c) {
	                        apList.add(ap);
	                    }
	                }
	            }
	        }
	        if (!apList.isEmpty()) {
	            delete apList;
	        }
	
	        List<UserRole> uRoleList = [SELECT Id, PortalAccountId, PortalRole FROM UserRole WHERE PortalAccountId IN: oldAccIdMap.keySet() AND PortalRole = 'Manager'];
	        for (UserRole ur: uRoleList) {
	            uRoleMap.put(ur.Id, ur.PortalAccountId);
	        }
	        
	        List<Group> groupList = [SELECT Id, RelatedId FROM Group WHERE RelatedId IN: uRoleMap.keySet()];
	        for (Group g: groupList) {
	            for (Id urId: uRoleMap.keySet()) {
	                if (g.RelatedId == urId) {
	                    accGroupMap.put(uRoleMap.get(urId), g.Id);
	                }
	            }
	        }
	        
	        List<Control_Number__c> oldControlNumList = [SELECT Id, Account__c FROM Control_Number__c WHERE Account__c IN: oldAllAccSet];
	        
	        for (Control_Number__c cn: oldControlNumList) {
	            oldCnSet.add(cn.Id);
	        }
	        
	        for (Id accId: oldAccIdMap.keySet()) {
	            for (Control_Number__c cn: oldControlNumList) {
	                if (oldAccIdMap.get(accId).contains(cn.Account__c)) {
	                    cnWrap.add(new deleteControlNumberShare.conNumWrapper(accId, cn));
	                }
	            }
	        }
	        /*List<Control_Number__Share> oldCnsList = [SELECT Id, UserOrGroupId, ParentId FROM Control_Number__Share WHERE ParentId IN: oldCnSet];
	        
	        List<Control_Number__Share> deleteList = new List<Control_Number__Share>();
	        for (Control_Number__Share cns: oldCnsList) {
	            for (conNumWrapper snw: cnWrap) {
	                if (cns.UserOrGroupId == accGroupMap.get(snw.acc)) {
	                    deleteList.add(cns);
	                }
	            }
	        }*/
	        id batchinstanceid = database.executeBatch(new deleteControlNumberShare('SELECT Id, UserOrGroupId, ParentId FROM Control_Number__Share WHERE ParentId IN: oldCnSet', oldCnSet, cnWrap, accGroupMap));
	    } catch (exception e) {
        	for (AccountPartner__c a: oldList) {
        		Trigger_log__c tl = new Trigger_log__c();
	        	tl.Account_Id__c = a.Main_AccountId__c;
	        	tl.Trigger_Type__c = 'Control Number Sharing Trigger';
	        	tl.name = 'Control Number Sharing Trigger';
	        	tl.Partner_Account_Id__c = a.Partner_AccountId__c;
	        	tl.error_message__c = e.getMessage();
	        	tlList.add(tl);
        	}
        	insert tlList;
        }
    }
    
    public static void handleUpdateTrigger (List<AccountPartner__c> oldList, List<AccountPartner__c> newList) {
    	List<AccountPartner__c> deleteList = new List<AccountPartner__c>();
    	List<AccountPartner__c> insertList = new List<AccountPartner__c>();
    	for (AccountPartner__c ap1: oldList) {
    		for (AccountPartner__c ap2: newList) {
    			if (ap1.Id == ap2.Id && (ap1.Main_AccountId__c != ap2.Main_AccountId__c || ap1.Partner_AccountId__c != ap2.Partner_AccountId__c || ap1.Partner_Type__c != ap2.Partner_Type__c)) {
    				deleteList.add(ap1);
    				insertList.add(ap2);
    			} else {
    				System.debug(Logginglevel.ERROR, 'search same node ' + ap1);
    			}
    		}
    	}
    	if (!deleteList.isEmpty()) {
    		handleDeleteTrigger(deleteList);
    		System.debug(Logginglevel.ERROR, 'called1 ');
    	}
    	if (!insertList.isEmpty()) {
	    	handleInsertTrigger(insertList);
	    	System.debug(Logginglevel.ERROR, 'called2 ');
    	}
    }
    
}