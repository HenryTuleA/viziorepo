/***************************************************************************
Created By : Henry Akpala
Created Date : 02/20/2016
    Class that allows you to select one or more records and delete from salesforce
    and should also call VizioSupport_AWSIntegration to delete from AWS S2

    Input:     
            standardController or standardListController
    Output:
            none.

****************************************************************************/
 public with sharing class VizioSupport_DeleteRecordsController {

    public VizioSupport_AWSIntegration awsX;
    public Integer intRes;
    private ApexPages.StandardController standardController;
 
    private ApexPages.StandardSetController standardSetController;
 
    public VizioSupport_DeleteRecordsController(ApexPages.StandardController standardController)
    {
        this.standardController = standardController;
    }
    
    public VizioSupport_DeleteRecordsController(ApexPages.StandardSetController standardSetController)
    {
        this.standardSetController = standardSetController;
    }
 
    /**
     * Method to delete multiple files from the Amazon S3  
     *
     * @param         none
     * @return        PageReference       
     * @since         1.0
    **/     
    public PageReference doDeleteListDocuments()
    {
        intRes  = 0;
        // Apex code for handling records from a List View goes here
        List<Document__c> listViewRecords = (List<Document__c>) standardSetController.getRecords();
        List<Document__c> selectedListViewRecords = (List<Document__c>) standardSetController.getSelected();
        List<Document__c> selectedListViewDetailRecords = [Select Document_URL__c, Case__c,Document_FilePath__c,  Document_Name__c, Type__c from Document__c Where Id=: selectedListViewRecords];
        List<Document__c> selectedListToDeleteRecords = new List<Document__c>();
        Boolean deleteRecs = false;
        
        Id caseId ;
        awsX = new VizioSupport_AWSIntegration();
        
        //loop through the list and delete each record from Amazon S3
        for(Document__c doc : selectedListViewDetailRecords){
            caseId = doc.Case__c;
           // call the VizioSupport_AWSIntegration Class to delete records
           intRes = awsX.deleteFromS3(doc.Document_Name__c , doc.Document_FilePath__c ); 
           if(intRes == 204) {
               selectedListToDeleteRecords.add(doc);
               deleteRecs = true;     //flag to check if it is deleted.
           }                             
        }
        
        if (deleteRecs){
            delete selectedListToDeleteRecords;     //delete list of records
        }
        PageReference pageRef = new PageReference('/' + caseId);
        pageRef.setRedirect(true);       
        return pageRef;
    }

    /**
     * Method to delete single file from the Amazon S3  
     *
     * @param         none
     * @return        PageReference       
     * @since         1.0
    **/   
    public PageReference doDeleteDocument()
    {
        intRes  = 0;
        // Apex code for handling record from a Detail page goes here
        Id recordId = standardController.getId();
        
        Document__c record = (Document__c) standardController.getRecord();
        record = [Select Document_URL__c, Case__c,Document_FilePath__c,  Document_Name__c, Type__c from Document__c Where Id=: recordId];
        awsX = new VizioSupport_AWSIntegration();
        if(record.Document_Name__c != null || record.Document_Name__c !=''){
            
            //call method to delete file from Amazon S3
            intRes = awsX.deleteFromS3(record.Document_Name__c ,record.Document_FilePath__c );
            if(intRes == 204) {
                   delete record;
            }
        }      
        PageReference pageRef = new PageReference('/' + record.Case__c);
        pageRef.setRedirect(true);
        return pageRef;
    }
}