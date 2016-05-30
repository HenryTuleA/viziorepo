public class ClaimTypeTriggerController {

    public static void handleUpdateTrigger(List<Claim_Item__c> newList) {
        
        List<Claim__c> updateList = new List<Claim__c>();
        Set<Id> IdSet = new Set<Id>();
        Set<String> ctSet = new Set<String>();
        for(Claim_Item__c ct: newList) {
            if (!IdSet.contains(ct.Claim__c)) {
                IdSet.add(ct.Claim__c);
            }
        }
        List<Claim__c> cList = [SELECT Id, Claim_Type__c FROM Claim__c WHERE Id IN: IdSet];
        
        List<Claim_Item__c> ciList = [SELECT Id, Claim_Type_del__c, Claim__c FROM Claim_Item__c WHERE Claim__c IN: IdSet];
        
        for (Claim__c c: cList) {
            c.Claim_Type__c = '';
        }
        
        for (Claim__c c: cList) {
            for (Claim_Item__c ci: ciList) {
                if (c.Id == ci.Claim__c && !c.Claim_Type__c.contains(ci.Claim_Type_del__c)) {
                    c.Claim_Type__c = c.Claim_Type__c + ';' + ci.Claim_Type_del__c; 
                }
            }
            
            updateList.add(c);
        }
        update updateList;
    }
    
    /*public static void handleDeleteTrigger(List<Claim_Item__c> oldList) {
    
        List<Claim__c> updateList = new List<Claim__c>();
        Set<Id> IdSet = new Set<Id>();
        Set<String> ctSet = new Set<String>();
        for(Claim_Item__c ct: oldList) {
            IdSet.add(ct.Claim__c);
        }
        
        Set<Id> ciIdSet = new Set<Id>();
        List<Claim__c> cList = [SELECT Id, Claim_Type__c FROM Claim__c WHERE Id IN: ciIdSet];
        
        Map<Id, Claim__c> cMap = new Map<Id, Claim__c>([SELECT Id, Claim_Type__c FROM Claim__c WHERE Id IN: IdSet]);
        List<Claim_Type__c > ctList = [SELECT Id, Claim_Type_del__c, Claim__c FROM Claim_Type__c WHERE Claim__c IN: IdSet];
        
        for(Claim_Type__c c: ctList) {
            if (!ctSet.contains(ct.Claim_Type_del__c)) {
                ctSet.add(ct.Claim_Type_del__c);
            }
        }
    }*/

}