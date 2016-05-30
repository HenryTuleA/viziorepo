global class deleteControlNumberShare implements Database.Batchable<Sobject> {
	global final String Query;
	global final Set<Id> oldCnSet = new Set<Id>();
	global final List<conNumWrapper> cnWrapList = new List<conNumWrapper>();
	global final Map<Id, Id> accGroupMap = new Map<Id, Id>();
	global deleteControlNumberShare(String q, Set<Id> cnSet, List<conNumWrapper> cnList, Map<Id, Id> idMap) {
		Query = q;
		oldCnSet.addAll(cnSet);
		cnWrapList.addAll(cnList);
		accGroupMap.putAll(idMap);
	}
	 
	global Database.QueryLocator start(Database.BatchableContext BC) {
		//System.debug(Logginglevel.ERROR, 'search query ' + query);
		return Database.getQueryLocator(query);
	}
	 
	global void execute(Database.BatchableContext BC, List<Control_Number__Share> scope) {
		
		Set<Control_Number__Share> deleteSet = new Set<Control_Number__Share>();
		for(Control_Number__Share cns : scope) {
			for (conNumWrapper snw: cnWrapList) {
				if (cns.UserOrGroupId == accGroupMap.get(snw.acc)) {
					deleteSet.add(cns);
				}
			}
		}
		List<Control_Number__Share> deleteList = new List<Control_Number__Share>();
		for (Control_Number__Share cns: deleteSet) {
			deleteList.add(cns);
		}
		
		/*List<Control_Number__Share> deleteList = new List<Control_Number__Share>();
		
		for(Sobject s : scope) {
			Control_Number__Share a = (Control_Number__Share)s;
			deleteList.add(a);
		}*/
		delete deleteList;
	}
	 
	global void finish(Database.BatchableContext BC)
	{
	              
	}
	
	global class conNumWrapper {
        
        public Control_Number__c conNum {get;set;}    
        public Id acc {get;set;}                     

        public conNumWrapper(Id acId, Control_Number__c cn) {
        	conNum = cn;
            acc = acId;
        }
    }
}