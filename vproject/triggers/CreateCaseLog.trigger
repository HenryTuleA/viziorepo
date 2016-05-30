/**
 * Trigger to create case log
 * Every time create a Support record type Case
 * Create a CaseLog record
 *
 * @author      Xin Zhang
 * @version     1.0
 * @since       1.0
 */

trigger CreateCaseLog on Case (after insert) {
     
     List<Case_Log__c> caseLogList = new List<Case_Log__c>(); 
     List<RecordType> caseRecordTypeList = new List<RecordType>();   //case record type list 
     caseRecordTypeList = [SELECT Id FROM RecordType WHERE SobjectType=:'Case' AND Name=:'Support'];
     Case_Log__c newCaseLog = new Case_Log__c(); // new case log
     
     
     
     for (Case theCase : trigger.new) {
         if (theCase.RecordTypeId == caseRecordTypeList[0].Id) {
             newCaseLog = new Case_Log__c(); 
             newCaseLog.CaseID__c = theCase.Id;
             newCaseLog.ActionCode_c__c = theCase.Action_Code__c;
             
             newCaseLog.CaseNumber__c = theCase.CaseNumber;
             newCaseLog.CaseStatus__c = theCase.Status;
             caseLogList.add(newCaseLog);       
             
         }
     }
     

     
     // create Case Log
     insert caseLogList;
     
}