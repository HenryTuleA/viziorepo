/***************************************************************************
Created By : Henry Akpala
Created Date : 02/14/2016
    
    This class supports the following operations, related to  Document upload to AWS s3:
        1. Policy generate for AWS .
        2. Generate The HMAC-SHA256 hash of the security policy. 
    Input:     
            n/a
            
    Output:
           create Document__c record object and redirect to the upload page.
 
******************************************************************************/
global class VizioSupport_AWS_Upload {

    

   public Document__c newDocument{get;set;}
   public static AWS_Keys__c awsKeySet{get;set;}
   public string ForRedirect{get;set;}  
   public static string appParentId{get;set;}
   public string Content_Type {get;set;}  
   Public String acessType{get;set;}
   public String objectCode{get;set;}
   public String fileName{get;set;}
   public String folderName{get;set;}
   public String caseNumber{get;set;}
   
   public String bucket = 'forceunleashed';
   
   private Case case1{get;set;}
   
   Datetime expire = system.now().addDays(1);
   String formattedexpire = expire.formatGmt('yyyy-MM-dd')+'T'+ expire.formatGmt('HH:mm:ss')+'.'+expire.formatGMT('SSS')+'Z';           
    
   //json string used to generate the parameters for the policy.   
   String policy { 
       get {
           return 
            '{ "expiration": "'+formattedexpire+'","conditions": [ {"bucket": "'+
             awsKeySet.Name +'" } ,{ "acl": "'+acessType+'" },'+
            '{"content-type":"'+Content_Type+'"},'+
            '{"success_action_redirect": "'+ForRedirect+'"},' +
            '["starts-with", "$key", ""] ]}';   
           } 
        } 
    

   
   public VizioSupport_AWS_Upload(ApexPages.StandardController controller){
       this.case1 = (Case)controller.getRecord();
   }
   
   /**
     * Constructor class to get the caseNumber and Case Object Code (500)
     *
     * @param         none
     * @return        XmlStreamReader data       
     * @since         1.0
    **/ 
   public VizioSupport_AWS_Upload(){
       appParentId = ApexPages.currentPage().getParameters().get('parentIdForRedirect');
       caseNumber = ApexPages.currentPage().getParameters().get('caseNumber');
       
       objectCode = appParentId.substring(0, 3);
       folderName = appParentId;
       
       newDocument = new Document__c();
       awsKeySet= AWS_Keys__c.getInstance(bucket);
       
       //URL redirect to VFPage with case Id
       ForRedirect = URL.getSalesforceBaseUrl().toExternalForm()+'/'+'apex/VizioSupport_AWS_SucessRedirectPage?parentIdForRedirect='+appParentId;
       Content_Type ='multipart/form-data';
       acessType ='public-read';
      
   }
       
       
   public String getPolicy() {
        return EncodingUtil.base64Encode(Blob.valueOf(policy));
   }
   public String getObjectName() {
        return objectCode;
   }
   public String getFolderName() {
        return objectCode+'/'+folderName;
   }
   public String getCasenumber() {
        return objectCode+'/'+caseNumber;
   }
   public String getSignedPolicy() {    
        return make_sig(EncodingUtil.base64Encode(Blob.valueOf(policy)));        
   }
    
   /**
     * method that will sign the message
     *
     * @param         string
     * @return        string      
     * @since         1.0
    **/ 
    private String make_sig(string canonicalBuffer) {        
        String macUrl ;
        Blob mac = Crypto.generateMac('HMacSHA1', blob.valueof(canonicalBuffer),blob.valueof(awsKeySet.AWS_Secret_Key__c)); 
        macUrl = EncodingUtil.base64Encode(mac);                
        return macUrl;
    }


   /**
     * Method to redirect back to case
     *
     * @param         none
     * @return        PageReference      
     * @since         1.0
    **/ 
    public PageReference backtoCase() {
        appParentId = ApexPages.currentPage().getParameters().get('parentIdForRedirect');
        PageReference pageRef = new PageReference('/'+ appParentId);
        pageRef.setRedirect(true);
        return pageRef;
    }
   
   /**
     * Static method to create a new Document__c record 
     *
     * @param         String [Case#, filename, bucketName]
     * @return        none       
     * @since         1.0
    **/   
    @RemoteAction
    global static Document__c createNewDocument(string appID, string uploadedFilename,string bucketName){
            Document__c newDocument = new Document__c();
            newDocument.Case__c = appID;
            newDocument.Application__c = appID;
            
            integer indx  = uploadedFilename.lastIndexOf('/');
            string nameurl = uploadedFilename.substring(indx+1);
            
            newDocument.Name = nameurl;
            newDocument.Document_Name__c = nameurl.replace(' ','+');
            newDocument.Document_URL__c =  'https://s3-us-west-2.amazonaws.com/'+bucketName+'/'+uploadedFilename.replace(' ','+');
            newDocument.Status__c ='Uploaded';
            newDocument.Document_FilePath__c = uploadedFilename.replace(' ','+');
            insert  newDocument;
         
            return newDocument;     
    }
           
   /**
     * Static method to redirect to case record 
     *
     * @param         String [Case#]
     * @return        none       
     * @since         1.0
    **/   
    @RemoteAction
    global static  PageReference reDirect(String appID){
       PageReference pageRef = new PageReference('/'+ appID);
       pageRef.setRedirect(false);
       return pageRef;
    }
   
}