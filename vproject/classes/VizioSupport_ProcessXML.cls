/***************************************************************************
Created By : Henry Akpala
Created Date : 03/14/2016
    
    Class to parse the xml that is received from AWS S3
    Triggered from a Scheduled Job 
    Input:     
            n/a
            
    Output:
           create new SR line items.
   
***************************************************************************/

public class VizioSupport_ProcessXML{

    
    public VizioSupport_AWSIntegration vaws;
    public XmlStreamReader reader;
    public List <String> fileObjList;
    public List <Transaction_Log__c> tListLog ;
    public VizioSupport_ProcessXML(){}
    public VizioSupport_TransactionLogClass tlCls ;
    //public List <FileObject> bucketObjList;
    
     
    /**
     * Method is used to get the list of files in the Vhub/inbox/ location on AWS
     *
     * @param         none
     * @return        XmlStreamReader data       
     * @since         1.0
    **/ 
    @future(callout=true)
    public static void readGetFromStaticVirtualS3 (){
        VizioSupport_ProcessXML x  = new VizioSupport_ProcessXML();
        x.readGetFromVirtualS3 ();
    
    }
    
    
    /**
     * Method is used to get the list of files in the Vhub/inbox/ location on AWS
     *
     * @param         none
     * @return        XmlStreamReader data       
     * @since         1.0
    **/ 
    public void readGetFromVirtualS3 (){
        vaws = new VizioSupport_AWSIntegration();
        List <FileObject> bucketObjList;
        
        // call the integration class to get the List of xml files in AWS
        reader = vaws.readGetFilesFromAmazonS3();
        
        if (reader != null){
           
           bucketObjList = parseFiles(reader);     //create an object record for record in the list.
           
           bucketObjList = readGetFileAmazonS3(bucketObjList);    // get each file in the list
           
           bucketObjList = readXMLFile(bucketObjList);            // convert the xml file to object records for each file in the list
          
           bucketObjList  = goDeleteFilesFromAWSS3(bucketObjList);    // call delete from AWS method
           
           createSRLineItemRecords(bucketObjList);   // find SR record and create line items
          
           updateTransLog(bucketObjList);       // insert into transaction log object 
          
            
        } 
    }
    
   /**
     *     Parse through the XML, determine the key(file name) & 
     *         the size(to tell if it is a folder or actual file)
     *     @param         XmlStreamReader
     *     @return        List of FileObject with key & size          
     *     @since         1.0
    **/         
    public FileObject[] parseFiles(XmlStreamReader reader) {
            FileObject[] files = new FileObject[0];
            boolean isSafeToGetNextXmlElement = true;
            while(isSafeToGetNextXmlElement) {
                // Start at the beginning of the file and make sure that it is a file
                if (reader.getEventType() == XmlTag.START_ELEMENT) {
                    if ('Contents' == reader.getLocalName()) {
                        // Pass the file to the parsefile method (below) 
                        FileObject file = parseFile(reader);
                        if(file.size >0 ){
                            files.add(file);
                        }
                    }
                }
                // Always use hasNext() before calling next() to confirm 
                // that we have not reached the end of the stream
                if (reader.hasNext()) {
                    reader.next();
                } else {
                    isSafeToGetNextXmlElement = false;
                    break;
                }
            }
            return files;
    }
    
    /**
     *     Parse through the XML, determine the key(file name) & 
     *         the size(to tell if it is a folder or actual file)
     *     @param         XmlStreamReader
     *     @return        FileObject with key & size          
     *     @since         1.0
    **/     
    FileObject parseFile(XmlStreamReader reader) {
        FileObject file    = new FileObject();
        boolean isSafeToGetNextXmlElement = true;
        while(isSafeToGetNextXmlElement) {
            //check if Contents end element then break
            if (reader.getEventType() == XmlTag.END_ELEMENT) {
                if(reader.getLocalName() =='Contents'){
                    break;
                }
            } else if( reader.getEventType() == XmlTag.START_ELEMENT){
                    //check if key element then get value
                    if(reader.getLocalName() == 'Key') {           
                        reader.next() ;
                        if (reader.getEventType() == XmlTag.CHARACTERS) {
                             file.Key = reader.getText();
                         }   
                      }
                      //check if size element then get value
                      if(reader.getLocalName() == 'Size') {         
                            reader.next() ;
                            if (reader.getEventType() == XmlTag.CHARACTERS) {
                                String val = reader.getText();
                                file.Size = (val != null ? Integer.valueOf(val) : 0);
                             }          
                       }
               }
                     
                // Always use hasNext() before calling next() to confirm 
                // that we have not reached the end of the stream
                if (reader.hasNext()) {
                    reader.next();
                } else {
                    isSafeToGetNextXmlElement = false;
                    break;
                }
            }
            return file;
    }
    
    
    /**
     *     Method is used to retreive xml message for each XML file in the Vhub/inbox/ location on AWS
     *     @param         List of FileObject with file names and path
     *     @return        List of FileObject with XML file included          
     *     @since                   1.0
    **/     
    public FileObject[] readGetFileAmazonS3 (FileObject[] bucketObjList){
        List <FileObject> bucketObjListCpy = new List <FileObject>();
        Integer count = 0;
       if (bucketObjList.size() > 0){
            for (FileObject obj:  bucketObjList){
                String xml = vaws.saveGetFileFromVirtualS3(obj.Key);
                obj.xmlfile = xml;         // add the file content to the object                             
                bucketObjListCpy.add(obj);
                count = count+1;
                if(count>45){
                    
                    break;
                }
             }
         }
         return bucketObjListCpy;
    }
 
     
    /**
     * Method is used to convert the xml files in the Vhub/inbox/ location on AWS to Object records in SFDC
     *
     * @param         List of FileObject
     * @return        List of FileObject with values on VizioSupport_ServiceRequestXMLObj updated         
     * @since         1.0
    **/ 
   public FileObject[]  readXMLFile(FileObject[] fObjList ){
        
        VizioSupport_ServiceRequestXMLObj xmlToSRObj;

        VizioSupport_ServiceRequestXMLObj.Footer footer = new VizioSupport_ServiceRequestXMLObj.Footer();
        VizioSupport_ServiceRequestXMLObj.LineItem lineItemObj = new VizioSupport_ServiceRequestXMLObj.LineItem();
        List<VizioSupport_ServiceRequestXMLObj.LineItem> lineTListObj = new List<VizioSupport_ServiceRequestXMLObj.LineItem>();
        string prefix = null;
        
        Dom.Document doc; 
         for (FileObject fObj :  fObjList){  
                doc  =   new Dom.Document();
                doc.load(fObj.xmlfile);
                Dom.XmlNode xmlNode  =   doc.getRootElement(); 
                    List<Dom.XmlNode> xmlSRNode  =  xmlNode.getChildElements();
                    lineTListObj = new List<VizioSupport_ServiceRequestXMLObj.LineItem>();
                    
                    for(dom.XmlNode node : doc.getRootElement().getChildElements()) { 
                          if(node.getName()=='Header') {
                            xmlToSRObj = new VizioSupport_ServiceRequestXMLObj();
                            dom.XmlNode cnode = node.getChildElement('ServiceRequestInformation', null);
                            xmlToSRObj.Action = (cnode.getChildElement('Action', null) != null ? cnode.getChildElement('Action', null).getText() : ''); 
                            xmlToSRObj.CreateDate = (cnode.getChildElement('CreateDate', null) != null ? cnode.getChildElement('CreateDate', null).getText() : ''); 
                            xmlToSRObj.ServiceRequestNumber = (cnode.getChildElement('ServiceRequestNumber', null) != null ? cnode.getChildElement('ServiceRequestNumber', null).getText() : ''); 
                            xmlToSRObj.ServiceRequestType = (cnode.getChildElement('ServiceRequestType', null) != null ? cnode.getChildElement('ServiceRequestType', null).getText() : ''); 
                            xmlToSRObj.ServiceProviderID = (cnode.getChildElement('ServiceProviderID', null) != null ? cnode.getChildElement('ServiceProviderID', null).getText() : '');        
                       }else if(node.getName()=='Footer') {
                            footer = new VizioSupport_ServiceRequestXMLObj.Footer();
                            dom.XmlNode cnode = node.getChildElement('Status', null);
                            footer.status = (cnode.getChildElement('Status', null) != null ? cnode.getChildElement('Status', null).getText() : '');        
                            xmlToSRObj.FooterObj = footer;
                    
                       } else  if(node.getName()=='LineItems') {
                              lineItemObj = new VizioSupport_ServiceRequestXMLObj.LineItem();
                              for(dom.XmlNode cnode : node.getChildElements()) {
                                   lineItemObj  =  new VizioSupport_ServiceRequestXMLObj.LineItem();
                                   lineItemObj.SKU = (cnode.getChildElement('SKU', null) != null ? cnode.getChildElement('SKU', null).getText() : '');        
                                   lineItemObj.SerialNumber = (cnode.getChildElement('SerialNumber', null) != null ? cnode.getChildElement('SerialNumber', null).getText() : '');                                          
                                   lineItemObj.Qty = (cnode.getChildElement('Qty', null) != null ? cnode.getChildElement('Qty', null).getText() : '');        
                                   lineItemObj.Core = (cnode.getChildElement('Core', null) != null ? cnode.getChildElement('Core', null).getText() : '');        
                                   lineItemObj.Price = (cnode.getChildElement('Price', null) != null ? cnode.getChildElement('Price', null).getText() : '');        
                                   lineItemObj.LineItemType = (cnode.getChildElement('LineItemType', null) != null ? cnode.getChildElement('LineItemType', null).getText() : '');        
                                   lineItemObj.Grade = (cnode.getChildElement('Grade', null) != null ? cnode.getChildElement('Grade', null).getText() : '');        
                                   lineItemObj.TrackingNumber = (cnode.getChildElement('TrackingNumber', null) != null ? cnode.getChildElement('TrackingNumber', null).getText() : '');        
                                   lineItemObj.ErrorCode = (cnode.getChildElement('ErrorCode', null) != null ? cnode.getChildElement('ErrorCode', null).getText() : '');        
                                   lineItemObj.Carrier = (cnode.getChildElement('Carrier', null) != null ? cnode.getChildElement('Carrier', null).getText() : '');        
                                   lineItemObj.Method = (cnode.getChildElement('Method', null) != null ? cnode.getChildElement('Method', null).getText() : '');        
                                   lineItemObj.Status = (cnode.getChildElement('Status', null) != null ? cnode.getChildElement('Status', null).getText() : '');        
                                   lineItemObj.Note = (cnode.getChildElement('Note', null) != null ? cnode.getChildElement('Note', null).getText() : '');        
                                   lineItemObj.TransactionDate = (cnode.getChildElement('TransactionDate', null) != null ? cnode.getChildElement('TransactionDate', null).getText() : '');        
                                   lineTListObj.add(lineItemObj);                      
                            }
                            xmlToSRObj.ListLineItemObj = lineTListObj;   // add line(s) to SR object        
                       }         
                 }
                fObj.srXmlObj = xmlToSRObj;  // add to file object
         }
        return fObjList;
   }   
    /**
     * Method is used to delete files in the Vhub/inbox/[filename] location on AWS after updating lines
     *
     * @param         List of FileObject
     * @return        List of FileObject with status code        
     * @since         1.0
    **/ 
    public FileObject[] goDeleteFilesFromAWSS3 (FileObject[] bucketObjList){
        Integer intRes =0;
         if (bucketObjList.size() > 0){
            for (FileObject obj:  bucketObjList){
                    intRes = vaws.deleteFromS3('',obj.Key);
                    obj.delStatus =  intRes;
            }   
         }  
         return  bucketObjList;     
    }
    
    /**
     * Method is used to get the integer part of the srnumber 
     * @param         srnumber string
     * @return        srnumber string       
     * @since         1.0**/
    public string srGetNumberString(String srnum){
        String tempChec;
        String tempVal ;
        String tempNum = '';
        Integer srLen = srnum.length();
        
        for(integer i = 0 ; i< srLen; i++){
            tempChec = srnum.subString(i, i+1);
            if (tempChec.isNumeric()){
                tempVal = srnum.subString(i);
                break;
            }
        }
        return tempVal;
    }
    
    /**
     * Method is used to search for record in the SR object and line items
     *
     * @param         List of FileObject with file names and path
     * @return        n/a          
     * @since         1.0
    **/ 
    public void createSRLineItemRecords (FileObject[] bucketObjList){
        List <Service_Request__c> currentSR ;
        List <Line_Items__c> lineItList = new List<Line_Items__c>();
        
        VizioSupport_ServiceRequestXMLObj.LineItem lineItemObj = new VizioSupport_ServiceRequestXMLObj.LineItem();
        Set<String> srnumber = new Set<String>();
        
        Map<String, FileObject> mapObj = new Map<String, FileObject>();
        //get list of objects to create a map
        for (FileObject obj:  bucketObjList){
            String srN = srGetNumberString(obj.srXmlObj.ServiceRequestNumber);
            srnumber.add(srN);
            mapObj.put(srN, obj);
            
        }
        //query for list of service request that meet the set condition
        currentSR = [Select Id, Name, Service_Provider__c,  Status__c,Error_Code__r.Name, CreatedDate     
                        From Service_Request__c
                       Where Name =: srnumber];
                       
        //loop through the SR and create a list of Line Items               
        for(Service_Request__c sr : currentSR){   
                 FileObject fileObjmapObj = mapObj.get(sr.name);
                 for ( VizioSupport_ServiceRequestXMLObj.LineItem ltem : fileObjmapObj.srXmlObj.ListLineItemObj  ) {
                        Line_Items__c lItem          =   new Line_Items__c();
                        lItem.SKU__c                 =   ltem.SKU; 
                        lItem.Serial_No__c           =   ltem.SerialNumber;
                        lItem.Quantity__c            =   Integer.ValueOf(ltem.Qty);
                        lItem.Core__c                =   ltem.Core;
                        lItem.Price__c               =   Decimal.ValueOf(ltem.Price);
                        lItem.PartType__c            =   ltem.LineItemType;
                        lItem.Grade__c               =   ltem.Grade;
                        lItem.Tracking_Number__c     =   ltem.TrackingNumber;
                        lItem.Carrier__c             =   ltem.Carrier; 
                        lItem.Method__c              =   ltem.Method;
                        lItem.Status__c              =   ltem.Status;
                        lItem.Notes__c               =   ltem.Note;
                        lItem.Transaction_Date__c    =   Date.ValueOf(ltem.TransactionDate);
                        lItem.Service_Request__c     =   sr.Id ; 
                        lItem.Source_Field__c        =   'Integration';
                        lineItList.add(lItem);
               }
                       
         }
         
         //Call insert method to perform dml operation of creating new line items.
         if (lineItList.size()> 0){
             insert lineItList;
         }      
    }
        
    /**
     * Method is used to create record in the transaction log for audit trail
     *  for each FileObject record
     *
     * @param         List of FileObject with file names and path
     * @return        n/a          
     * @since         1.0
     */    
    public void updateTransLog (FileObject[] bucketObjList){
       tListLog = new List <Transaction_Log__c>();
        Transaction_Log__c tLog ;
        if (bucketObjList.size() > 0){
            for (FileObject obj:  bucketObjList){
                tLog = new Transaction_Log__c();
                tLog.TLog_Body__c       =   obj.xmlfile;
                tLog.TLog_Source__c     =   'AmazonS3';
                tLog.TLog_Status__c     =   'New';
                tLog.TLog_Target__c     =   'Salesforce';
                tLog.TLog_Type__c       =   'Inbound';
                tLog.TLog_FolderName__c =   obj.key;
                tLog.TLog_Delete_Status__c    =   String.valueOf(obj.delstatus);
                tListLog.add(tLog);            
             }
         }
         try{   
                 tlCls = new VizioSupport_TransactionLogClass();
                 tlCls.insertListLog(tListLog);       // insert into transaction log object   
         }catch(System.Exception e) {
            system.debug('Error:: '+ e.getMessage());
         }
                    
    }

     /**
     * Inner class object used to process data
     *
     * @param         List of FileObject with file names and path
     * @return        n/a          
     * @since         1.0
     */   
     public class FileObject {
        public String key;
        public Long size;
        public String xmlfile;
        public Integer delStatus;
        public VizioSupport_ServiceRequestXMLObj srXmlObj; // Instance of the Object
     }
    
}