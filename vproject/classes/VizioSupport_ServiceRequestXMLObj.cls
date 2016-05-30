/***************************************************************************
Created By : Henry Akpala
Created Date : 
Description : This is a class object for managing xml file and detais
                 pulled from Amazon S3
****************************************************************************/

public class VizioSupport_ServiceRequestXMLObj{    
    
    
        public string   Action;
        public string   CreateDate;
        public string   ServiceRequestNumber;
        public string   ServiceRequestType;
        public string   ServiceProviderID;
        public List<LineItem> ListLineItemObj;
        public Footer    FooterObj;
        public VizioSupport_ServiceRequestXMLObj(){
        }
   
    public class LineItem {
        public string   SKU;
        public string   SerialNumber;
        public string   Qty;
        public string   Core;
        public string   Price;
        public string   LineItemType;
        public string   Grade;
        public string   TrackingNumber;
        public string   ErrorCode;
        public string   Carrier;
        public string   Method;
        public string   Status;
        public string   Note;
        public string   TransactionDate  ;
        
        public LineItem(){
        }
    }
    public class Footer{
        public string   status;
        public Footer(){
        }
    }
}