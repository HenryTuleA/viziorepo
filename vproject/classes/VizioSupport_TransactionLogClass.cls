public class VizioSupport_TransactionLogClass{
 
    String xml = '<?xml version="1.0" encoding="utf-8"?><ServiceRequest><Header><ServiceRequestInformation><Action>Update</Action><CreateDate>20151215</CreateDate><ServiceRequestNumber>SR1608602</ServiceRequestNumber><ServiceRequestType>SR</ServiceRequestType><ServiceProviderID>PRB</ServiceProviderID></ServiceRequestInformation></Header><LineItems><LineItem><SKU>00000000015</SKU><SerialNumber></SerialNumber><Qty>1</Qty><LineItemType>Send</LineItemType><Grade></Grade><TrackingNumber>1ZA846Y89090348801</TrackingNumber><ErrorCode></ErrorCode><Carrier>UPS</Carrier><Method>UPS Ground</Method><Status>Sent</Status><Note></Note><TransactionDate>2015-12-15</TransactionDate></LineItem><LineItem><SKU>00000000015</SKU><SerialNumber></SerialNumber><Qty>1</Qty><LineItemType>Send</LineItemType><Grade></Grade><TrackingNumber>1ZA846Y89090348801</TrackingNumber><ErrorCode></ErrorCode><Carrier>UPS</Carrier><Method>UPS Ground</Method><Status>Sent</Status><Note></Note><TransactionDate>2015-12-15</TransactionDate></LineItem></LineItems><Footer><Status/></Footer></ServiceRequest>';


    public string TLogBody     ;
    public string TLogSource   ;
    public string TLogStatus   ; 
    public string TLogTarget   ; 
    public string TLogType     ;  
    
    public void insertLog(Transaction_Log__c tLog){

   
        try {
            insert tLog;
        } catch (DmlException e) {
            // Process exception here
            System.debug(e);
        }
    }
     
    public void insertListLog(List<Transaction_Log__c> tLog){

        try {
            insert tLog;
        } catch (DmlException e) {
            // Process exception here
            System.debug(e);
        }
    }
}