public class ClaimTypeTrigger {

    public static void handleUpdateTrigger(List<Claim_Item__c> newList, List<Claim_Item__c> oldList) {
        
        List<Claim__c> updateList = new List<Claim__c>();
        Set<Id> IdSet = new Set<Id>();
        Set<String> ctSet = new Set<String>();
        for(Claim_Item__c ct: newList) {
            if (!IdSet.contains(ct.Claim__c)) {
                IdSet.add(ct.Claim__c);
            }
        }
        Map<Id, Claim__c> cMap = new Map<Id, Claim__c>([SELECT Id, Claim_Type__c FROM Claim__c WHERE Id IN: IdSet]);
        
        for(Claim_Item__c ct: newList) {
            if (!cMap.get(ct.Claim__c).Claim_Type__c.contains(ct.Claim_Type_del__c)) {
                cMap.get(ct.Claim__c).Claim_Type__c = cMap.get(ct.Claim__c).Claim_Type__c + ';' + ct.Claim_Type_del__c; 
                updateList.add(cMap.get(ct.Claim__c));
            }
        }
        
        update updateList;
    }
    
    /*public static void handleDeleteTrigger(List<Claim_Item__c> newList, List<Claim_Item__c> oldList) {
    
        List<Claim__c> updateList = new List<Claim__c>();
        Set<Id> IdSet = new Set<Id>();
        Set<String> ctSet = new Set<String>();
        for(Claim_Item__c ct: oldList) {
            if (!IdSet.contains(ct.Claim__c)) {
                IdSet.add(ct.Claim__c);
            }
        }
        Map<Id, Claim__c> cMap = new Map<Id, Claim__c>([SELECT Id, Claim_Type__c FROM Claim__c WHERE Id IN: IdSet]);
        List<Claim_Type__c > ctList = [SELECT Id, Claim_Type_del__c, Claim__c FROM Claim_Type__c WHERE Claim__c IN: IdSet];
        
        for(Claim_Type__c c: ctList) {
            if (!ctSet.contains(ct.Claim_Type_del__c)) {
                ctSet.add(ct.Claim_Type_del__c);
            }
        }
    }*/

}