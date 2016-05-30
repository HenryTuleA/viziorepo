/***************************************************************************
Created By : Henry Akpala
Created Date : 03/14/2016
    
    Class to generate the xml that will be sent to AWS S3 
    Input:     
            srId => Service Request Id
            
    Output:
            n/a
   
***************************************************************************/

public class VizioSupport_XMLGenerator{   
      
      public VizioSupport_XMLGenerator(){}
      
       @Future(callout=true)
      public static void GetInformation(String srId) {
              //ServiceRequestInformation ;
          String Action = 'Create' ;
           String CreatedDate ;
           String CreatedDateTime ;
           String ServiceRequestNumber ;
           String ServiceRequestType ;
           String ServiceProviderID ;
           String ServiceRequestStatus ;
           String ErrorCode ;
           String ReferenceOrderNumber ;
           String ScheduleDate ;
           String ScheduleTimeSlot ;  
           String FolderName;
           String FolderPath;
          
          //CustomerInformation;
           String FirstName ;
           String LastName ;
           String PrimaryPhone ;
           String AlternatePhone; 
           String Extension;
           String FaxNumber;
           String EmailAddress;
           String Address1;
           String Address2; 
           String Address3;
           String City ; 
           String State ;
           String ZipCode ;
           String Country ;
           String Note ;
           String CustomerCode  ;
           String SAPCustomerID  ;
           String CustomerType ;
           String StoreNumber ;
           String Company ;
          
    
          // ShippingInformation>
           String   ShipName  ;
           String   ShipAddress1;
           String   ShipAddress2;
           String   ShipAddress3;
           String   ShipCity;
           String   ShipState;
           String   ShipZipCode;
           String   ShipCountry;
           String   ShipPhone;
           String   ShipAlternatePhone;
           String   ShipNote ;
           String   ShipCarrier ;
           String   ShipMethod ;
           String   ShipStoreNumber ;
          
          //ProductInformation ;
           String   ProductID ;
           String   PurchaseDate ;
           String   SKU ;
           String   SKU2 ;
           String   Model ;
           String   SerialNumber ;
           String   PlaceOfPurchase ;
           String   CustomerNotes ;
           String   InternalNotes  ;
           String   ProofOfPurchase ;
          
          //LineItems Information
           String LineItems ;          
           String LineItem   ;        
           String LineProductID   ;                
           String LineSKU ;          
           String LineQty ;            
           String LineCore ;             
           String LineSerialNumber ;           
           String LineReferenceOrderNumber ;          
           String LineItemStatus ;    
           String LineItemType ;  
           String LineGrade  ;  
           String LineSKU2  ; 
           String LineDescription   ;              
           String LineModel         ;   
           String LinePrice;      
           String LineRestockingFee;           
          
          //Footer Information          
           String Footer ;
           String Status ;
           String Error ;
           String ErrorMessage  ;
          
          
           String    XmlName;
           String    prefix = null;
              
          // for current SR
           List<Service_Request__c> currentSRB; // {get;set;}
            
          // for all relationships
           List<Case> relatedCase ;//{get;set;}
           List<Asset> relatedAssetB ;//{get;set;}
           List<Product2> relatedProduct ;// {get;set;}
           List<Contact> relatedContactB ;//{get;set;}
           Contact relatedContact;
           List <Service_Request_Information__c> srInfo  ; //{get;set;}
           Service_Request__c currentSR ;
           Asset relatedAsset;
          
           VizioSupport_TransactionLogClass tclass ;
                        
           VizioSupport_AWSIntegration vaws ;
          
          
            Dom.Document doc          =  new Dom.Document();
            Dom.XmlNode xmlSRNode     =  doc.createRootElement('ServiceRequest', null, prefix);
            Dom.XmlNode xmlHeaderNode =  xmlSRNode.addChildElement('Header', null, prefix);
        
            // Get service Request's data including lines
            currentSRB = [Select Id, Name, Shipping_Notes__c, Unit_Carrier__c,Unit_Ship_Method__c, Internal_Notes__c, Box__c, isWallMount__c, isWhiteGlove__c,  Error_Code__c, 
                            AuthSRtype__c, Service_Provider__c, Service_Provider__r.ServiceProviderName__c, RelatedSRNo__r.Name, Status__c,Error_Code__r.Name,  Label__c,
                            Error_Code__r.Description__c, AuthSRtype__r.SRType__c, Case__r.AssetId,Case__r.ContactId , CreatedDate, ScheduleDate__c,isSubstitution__c,
                            Voogle_Service_Provider_Id__c, Voogle_SRID__c,RelatedSRNo__r.Voogle_SRID__c, ScheduleTimeSlot__c, ErrorCode__c, SRType__c, XML_Folder__c,
                            (
                                Select Carrier__c, Core__c, Grade__c, Id, isActive__c,  isEmailSent__c, Method__c, Name, Notes__c, PartType__c, 
                                    Price__c, Product__c, Quantity__c, Receive_Date__c, Restocking_Fee__c, Sales_Order_No__c, Serial_No__c, 
                                    Service_Request__c, Ship_Date__c, SKU__c, Status__c,  Tracking_Number__c from Service_Request__c.Line_Items__r
                            ),
                            Case__r.Asset.PID__c,Case__r.Asset.PurchaseDate,Case__r.Asset.Product2.SKU__c,Case__r.Asset.Model__c,Case__r.Asset.SerialNumber,
                            Case__r.Asset.Purchase_Location__c,Case__r.Asset.Internal_Notes__c,Case__r.Asset.isPOPVerify__c, Case__r.Asset.Voogle_AssetID__c,
                            Case__r.Contact.Id,Case__r.Contact.OtherPhone,Case__r.Contact.Extension__c,Case__r.Contact.MailingPostalCode,
                            Case__r.Contact.MailingStreet,Case__r.Contact.Phone,Case__r.Contact.MailingStateCode,Case__r.Contact.MailingCountryCode,
                            Case__r.Contact.MailingState,Case__r.Contact.MailingCountry,Case__r.Contact.MailingCity,Case__r.Contact.MailingAddress,
                            Case__r.Contact.LastName,Case__r.Contact.FirstName,Case__r.Contact.Fax,Case__r.Contact.Email,Case__r.Contact.Customer_Type__c,
                            Case__r.Contact.Voogle_SAPID__c,Case__r.Contact.Store_Name__c,Case__r.Contact.Store_Number__c, Case__r.Contact.Retail_Name__c,
                            Case__r.Contact.SAPID__c,Case__r.Contact.Internal_Notes__c, Case__r.Contact.Voogle_Cust_ID__c, Case__r.Contact.MobilePhone 
                       From Service_Request__c
                       Where Id =: srId];
                       

            if (!currentSRB.isEmpty()) {
                
                currentSR                  =     currentSRB[0];
                DateTime createdDateX      =     currentSR.CreatedDate;
                String cmonth              =     String.valueOf(createdDateX.month());
                String cday                =     String.valueOf(createdDateX.day());
                String cyear               =     String.valueOf(createdDateX.year());
                String chour               =     String.valueOf(createdDateX.hour());
                String cmin                =     String.valueOf(createdDateX.minute());
                String csecs               =     String.valueOf(createdDateX.second());                
                
                cday   = (cday.length()    ==    1 ? '0'+ cday : cday);
                cmonth = (cmonth.length()  ==    1 ? '0'+ cmonth : cmonth);
                
                chour  = (chour.length()   ==    1 ? '0'+ chour : chour);
                cmin   = (cmin.length()    ==    1 ? '0'+ cmin : cmin);
                csecs  = (csecs.length()   ==    1 ? '0'+ csecs : csecs);
                
                
                DateTime scheduleDateX     =     currentSR.CreatedDate;
                String smonth;
                String sday ;
                String syear;
                if(scheduleDateX != null){
                     smonth              =     String.valueOf(scheduleDateX.month());
                     sday                =     String.valueOf(scheduleDateX.day());
                     syear               =     String.valueOf(scheduleDateX.year());
                     sday                =     (sday.length()  ==    1 ? '0'+sday : sday);
                     smonth              =     (smonth.length()==    1 ? '0'+smonth : smonth);
                }
                
                CreatedDateTime    = cyear+cmonth+cday+chour+cmin+csecs; 
                
                
                //ServiceRequestInformation 
                Action                =     'Create';
                CreatedDate           =      cyear+cmonth+cday; 
                ScheduleDate          =      syear+smonth+sday; 
                
                ServiceRequestNumber  = (currentSR.Voogle_SRID__c == null ? '':currentSR.Voogle_SRID__c); 
                ServiceRequestType    = (currentSR.AuthSRtype__r.SRType__c == null ? '':currentSR.AuthSRtype__r.SRType__c);
                ServiceProviderID     = (currentSR.Voogle_Service_Provider_Id__c == null ? '':currentSR.Voogle_Service_Provider_Id__c); 
                ServiceRequestStatus  = (currentSR.Status__c == null ? '':currentSR.Status__c); 
                ErrorCode             = (currentSR.Error_Code__c == null ? '':currentSR.Error_Code__c); 
                ReferenceOrderNumber  = (currentSR.RelatedSRNo__r.Voogle_SRID__c == null ? '':currentSR.RelatedSRNo__r.Voogle_SRID__c); 
                ScheduleDate          = (ScheduleDate == null ? '':ScheduleDate ); 
                ScheduleTimeSlot      = (currentSR.ScheduleTimeSlot__c == null ? '':currentSR.ScheduleTimeSlot__c); 
                
                FolderPath            = (currentSR.XML_Folder__c == null ? '':currentSR.XML_Folder__c); 
                FolderName            = (currentSR.Voogle_Service_Provider_Id__c == null ? 'ERROR':currentSR.Voogle_Service_Provider_Id__c); 
                ShipNote              = (currentSR.Internal_Notes__c == null ? 'ERROR':currentSR.Internal_Notes__c); 
                ShipCarrier           = (currentSR.Unit_Carrier__c == null ? '':currentSR.Unit_Carrier__c); 
                ShipMethod            = (currentSR.Unit_Ship_Method__c == null ? '':currentSR.Unit_Ship_Method__c); 
                  
                
                //Generate ServiceRequestInformation XML
                Dom.XmlNode xmlSRInfoNode = xmlHeaderNode.addChildElement('ServiceRequestInformation', null, prefix);
                xmlSRInfoNode.addChildElement('Action', null, prefix).addTextNode(Action);
                xmlSRInfoNode.addChildElement('CreateDate', null, prefix).addTextNode(CreatedDate);
                xmlSRInfoNode.addChildElement('ServiceRequestNumber', null, prefix).addTextNode(ServiceRequestNumber);
                xmlSRInfoNode.addChildElement('ServiceRequestType', null, prefix).addTextNode(ServiceRequestType);
                xmlSRInfoNode.addChildElement('ServiceProviderID', null, prefix).addTextNode(ServiceProviderID);
                xmlSRInfoNode.addChildElement('ServiceRequestStatus', null, prefix).addTextNode(ServiceRequestStatus);
                xmlSRInfoNode.addChildElement('ErrorCode', null, prefix).addTextNode(ErrorCode);
                xmlSRInfoNode.addChildElement('ReferenceOrderNumber', null, prefix).addTextNode(ReferenceOrderNumber);
                xmlSRInfoNode.addChildElement('ScheduleDate', null, prefix).addTextNode(ScheduleDate);
                xmlSRInfoNode.addChildElement('ScheduleTimeSlot', null, prefix).addTextNode(ScheduleTimeSlot);
                
                DateTime scheduleDatePd     =     currentSR.Case__r.Asset.PurchaseDate ;
                String smonthPd;
                String sdayPd ;
                String syearPd;
                if(scheduleDatePd != null){
                     smonthPd            =     String.valueOf(scheduleDatePd.month());
                     sdayPd              =     String.valueOf(scheduleDatePd.day());
                     syearPd             =     String.valueOf(scheduleDatePd.year());
                }
                
                
                 //ProductInformation ;
                 ProductID         =    (String.valueOf(currentSR.Case__r.Asset.PID__c) == null ? '': String.valueOf(currentSR.Case__r.Asset.PID__c)); 
                 PurchaseDate      =    (scheduleDatePd == null ? '': syearPd+smonthPd+sdayPd) ; 
                 SKU               =    (currentSR.Case__r.Asset.Product2.SKU__c == null ? '': currentSR.Case__r.Asset.Product2.SKU__c);
                 SKU2              =    (currentSR.ErrorCode__c == null ? '': currentSR.ErrorCode__c);
                 Model             =    (currentSR.Case__r.Asset.Model__c == null ? '': currentSR.Case__r.Asset.Model__c); 
                 SerialNumber      =    (currentSR.Case__r.Asset.SerialNumber == null ? '': currentSR.Case__r.Asset.SerialNumber );
                 PlaceOfPurchase   =    (currentSR.Case__r.Asset.Purchase_Location__c == null ? '': currentSR.Case__r.Asset.Purchase_Location__c );
                 CustomerNotes     =    (currentSR.Case__r.Asset.Internal_Notes__c == null ? '': currentSR.Case__r.Asset.Internal_Notes__c );
                 InternalNotes     =    (currentSR.Internal_Notes__c == null ? '': currentSR.Internal_Notes__c );
                 ProofOfPurchase =      String.valueOf(currentSR.Case__r.Asset.isPOPVerify__c == null ? False: currentSR.Case__r.Asset.isPOPVerify__c);

                 //Generate ProductInformation XML
                Dom.Document productInfoDom    =  new Dom.Document();
                Dom.XmlNode xmlProductInfoNode =  xmlHeaderNode.addChildElement('ProductInformation', null, prefix);
                xmlProductInfoNode.addChildElement('ProductID', null, prefix).addTextNode(ProductID);
                xmlProductInfoNode.addChildElement('PurchaseDate', null, prefix).addTextNode(PurchaseDate);
                xmlProductInfoNode.addChildElement('SKU', null, prefix).addTextNode(SKU);
                xmlProductInfoNode.addChildElement('SKU2', null, prefix).addTextNode(SKU2);
                xmlProductInfoNode.addChildElement('Model', null, prefix).addTextNode(Model);
                xmlProductInfoNode.addChildElement('SerialNumber', null, prefix).addTextNode(SerialNumber);
                xmlProductInfoNode.addChildElement('PlaceOfPurchase', null, prefix).addTextNode(PlaceOfPurchase);
                xmlProductInfoNode.addChildElement('CustomerNotes', null, prefix).addTextNode(CustomerNotes);
                xmlProductInfoNode.addChildElement('InternalNotes', null, prefix).addTextNode(InternalNotes);
                xmlProductInfoNode.addChildElement('ProofOfPurchase', null, prefix).addTextNode(ProofOfPurchase);
               
               //CustomerInformation
               FirstName        = (currentSR.Case__r.Contact.FirstName == null ? '':currentSR.Case__r.Contact.FirstName); 
               LastName         = (currentSR.Case__r.Contact.LastName == null  ? '':currentSR.Case__r.Contact.LastName); 
               PrimaryPhone     = (currentSR.Case__r.Contact.Phone == null ? '':currentSR.Case__r.Contact.Phone); 
               AlternatePhone   = (currentSR.Case__r.Contact.MobilePhone == null ? '':currentSR.Case__r.Contact.MobilePhone); 
               Extension        = String.ValueOf(currentSR.Case__r.Contact.Extension__c == null ? 0:currentSR.Case__r.Contact.Extension__c); 
               FaxNumber        = (currentSR.Case__r.Contact.Fax == null ? '':currentSR.Case__r.Contact.Fax); 
               EmailAddress     = (currentSR.Case__r.Contact.Email == null ? '':currentSR.Case__r.Contact.Email); 
               Address1         = (currentSR.Case__r.Contact.MailingStreet == null ? '':currentSR.Case__r.Contact.MailingStreet); 
               Address2         = ''; //(currentSR.Case__r.Contact.Address2Address2 == null ? '':currentSR.Case__r.Contact.Address2); 
               Address3         = ''; //(currentSR.Case__r.Contact.Address3 == null ? '':currentSR.Case__r.Contact.Address3); 
               City             = (currentSR.Case__r.Contact.MailingCity == null ? '':currentSR.Case__r.Contact.MailingCity); 
               State            = (currentSR.Case__r.Contact.MailingStateCode == null ? '':currentSR.Case__r.Contact.MailingStateCode); 
               ZipCode          = (currentSR.Case__r.Contact.MailingPostalCode == null ? '':currentSR.Case__r.Contact.MailingPostalCode); 
               Country          = (currentSR.Case__r.Contact.MailingCountryCode == null ? '':currentSR.Case__r.Contact.MailingCountryCode); 
               Note             = (currentSR.Case__r.Contact.Internal_Notes__c == null ? '':currentSR.Case__r.Contact.Internal_Notes__c); 
               CustomerCode     = (currentSR.Case__r.Contact.Id == null ? '':currentSR.Case__r.Contact.Id); 
               SAPCustomerID    = (currentSR.Case__r.Contact.SAPID__c == null ? '':currentSR.Case__r.Contact.SAPID__c); 
               CustomerType     = (currentSR.Case__r.Contact.Customer_Type__c == null ? '':currentSR.Case__r.Contact.Customer_Type__c); 
               StoreNumber      = String.valueOf(currentSR.Case__r.Contact.Store_Number__c == null ? 0:currentSR.Case__r.Contact.Store_Number__c); 
               Company          = (currentSR.Case__r.Contact.Retail_Name__c == null ? '':currentSR.Case__r.Contact.Retail_Name__c);  
               
               StoreNumber      =  StoreNumber == '0' ? '' : StoreNumber;

              
                //Generate CustomerInformation XML 
                Dom.Document customerInfoDom    =  new Dom.Document();
                Dom.XmlNode xmlCustomerInfoNode =  xmlHeaderNode.addChildElement('CustomerInformation', null, prefix);
                xmlCustomerInfoNode.addChildElement('FirstName', null, prefix).addTextNode(FirstName);
                xmlCustomerInfoNode.addChildElement('LastName', null, prefix).addTextNode(LastName);
                xmlCustomerInfoNode.addChildElement('PrimaryPhone', null, prefix).addTextNode(PrimaryPhone);
                xmlCustomerInfoNode.addChildElement('AlternatePhone', null, prefix).addTextNode(AlternatePhone);
                xmlCustomerInfoNode.addChildElement('Extension', null, prefix).addTextNode(Extension);
                xmlCustomerInfoNode.addChildElement('FaxNumber', null, prefix).addTextNode(FaxNumber);
                xmlCustomerInfoNode.addChildElement('EmailAddress', null, prefix).addTextNode(EmailAddress);
                xmlCustomerInfoNode.addChildElement('Address1', null, prefix).addTextNode(Address1);
                xmlCustomerInfoNode.addChildElement('Address2', null, prefix).addTextNode(Address2);
                xmlCustomerInfoNode.addChildElement('Address3', null, prefix).addTextNode(Address3);
                xmlCustomerInfoNode.addChildElement('City', null, prefix).addTextNode(City);
                xmlCustomerInfoNode.addChildElement('State', null, prefix).addTextNode(State);
                xmlCustomerInfoNode.addChildElement('ZipCode', null, prefix).addTextNode(ZipCode);
                xmlCustomerInfoNode.addChildElement('Country', null, prefix).addTextNode(Country);
                xmlCustomerInfoNode.addChildElement('Note', null, prefix).addTextNode(Note);
                xmlCustomerInfoNode.addChildElement('CustomerCode', null, prefix).addTextNode(CustomerCode);
                xmlCustomerInfoNode.addChildElement('SAPCustomerID', null, prefix).addTextNode(SAPCustomerID);
                xmlCustomerInfoNode.addChildElement('CustomerType', null, prefix).addTextNode(CustomerType);
                xmlCustomerInfoNode.addChildElement('StoreNumber', null, prefix).addTextNode(StoreNumber);
                xmlCustomerInfoNode.addChildElement('Company', null, prefix).addTextNode(Company);

               
                // ShippingInformation>
                ShipName           =  FirstName + LastName;
                ShipAddress1       =  Address1 ;
                ShipAddress2       =  '';
                ShipAddress3       =  '';
                ShipCity           =  City;
                ShipState          =  State;
                ShipZipCode        =  ZipCode;
                ShipCountry        =  Country   ;
                ShipPhone          =  PrimaryPhone;
                ShipAlternatePhone =  (currentSR.Case__r.Contact.MobilePhone == null? '':currentSR.Case__r.Contact.MobilePhone); 
                ShipStoreNumber    =  StoreNumber == '0'? '' : StoreNumber;

                //Generate ShippingInformation XML 
                Dom.Document shippingInfoDom    =  new Dom.Document();
                Dom.XmlNode xmlShippingInfoNode =  xmlHeaderNode.addChildElement('ShippingInformation', null, prefix);
                xmlShippingInfoNode.addChildElement('Name', null, prefix).addTextNode(ShipName);
                xmlShippingInfoNode.addChildElement('Address1', null, prefix).addTextNode(ShipAddress1);
                xmlShippingInfoNode.addChildElement('Address2', null, prefix).addTextNode(ShipAddress2);
                xmlShippingInfoNode.addChildElement('Address3', null, prefix).addTextNode(ShipAddress3);
                xmlShippingInfoNode.addChildElement('City', null, prefix).addTextNode(ShipCity);
                xmlShippingInfoNode.addChildElement('State', null, prefix).addTextNode(ShipState);
                xmlShippingInfoNode.addChildElement('ZipCode', null, prefix).addTextNode(ShipZipCode);
                xmlShippingInfoNode.addChildElement('Country', null, prefix).addTextNode(ShipCountry);
                xmlShippingInfoNode.addChildElement('Phone', null, prefix).addTextNode(ShipPhone);
                xmlShippingInfoNode.addChildElement('AlternatePhone', null, prefix).addTextNode(ShipAlternatePhone);
                xmlShippingInfoNode.addChildElement('Note', null, prefix).addTextNode(ShipNote);
                xmlShippingInfoNode.addChildElement('Carrier', null, prefix).addTextNode(ShipCarrier);
                xmlShippingInfoNode.addChildElement('Method', null, prefix).addTextNode(ShipMethod);
                xmlShippingInfoNode.addChildElement('StoreNumber', null, prefix).addTextNode(ShipStoreNumber);
                
     
                if(!currentSR.Line_Items__r.isEmpty()){
                
                    //Generate LineItems node for XML 
                    Dom.XmlNode xmlLineItemsNode  =  xmlSRNode.addChildElement('LineItems', null, prefix);
                     
                    for (Line_Items__c lineL :  currentSR.Line_Items__r){
                            
                            //LineItem                                       
                            LineProductID             = (lineL.name == null ? '':lineL.name);          
                            LineSKU                   = (lineL.SKU__c == null ? '':lineL.SKU__c);     
                            LineQty                   = String.valueOf(lineL.Quantity__c == null ? 0:lineL.Quantity__c);    
                            LineCore                  = (lineL.Core__c == null ? '':lineL.Core__c);      
                            LineSerialNumber          = (lineL.Serial_No__c == null ? '':lineL.Serial_No__c);     
                            LineReferenceOrderNumber  = (lineL.Sales_Order_No__c == null ? '':lineL.Sales_Order_No__c);          
                            LineItemStatus            = (lineL.Status__c == null ? '':lineL.Status__c);    
                            LineItemType              = (lineL.PartType__c == null ? '':lineL.PartType__c);   
                            LineGrade                 = (lineL.Grade__c == null ? '':lineL.Grade__c); 
                            LineSKU2                  = '';//(lineL.SKU__c == null ? '':lineL.SKU__c); 
                            LineDescription           = (lineL.Notes__c == null ? '':lineL.Notes__c);       
                            LinePrice                 = String.valueOf(lineL.Price__c == null ? 0:lineL.Price__c); 
                            LineRestockingFee         = String.valueOf(lineL.Restocking_Fee__c == null ? 0:lineL.Restocking_Fee__c);              
                            LineModel                 = '';//(lineL.Model__c == null ? '':lineL.Model__c); 
                            
                            LineRestockingFee         =  LineRestockingFee == '0' ? '' : LineRestockingFee;
              
                            //Generate LineItem XML 
                            Dom.XmlNode xmlLineItemNode   =  xmlLineItemsNode.addChildElement('LineItem', null, prefix);
                            xmlLineItemNode.addChildElement('ProductID', null, prefix).addTextNode(LineProductID);
                            xmlLineItemNode.addChildElement('SKU', null, prefix).addTextNode(LineSKU);
                            xmlLineItemNode.addChildElement('Qty', null, prefix).addTextNode(LineQty);
                            xmlLineItemNode.addChildElement('Core', null, prefix).addTextNode(LineCore);
                            xmlLineItemNode.addChildElement('SerialNumber', null, prefix).addTextNode(LineSerialNumber);
                            xmlLineItemNode.addChildElement('ReferenceOrderNumber', null, prefix).addTextNode(LineReferenceOrderNumber);
                            xmlLineItemNode.addChildElement('LineItemStatus', null, prefix).addTextNode(LineItemStatus);
                            xmlLineItemNode.addChildElement('LineItemType', null, prefix).addTextNode(LineItemType);
                            xmlLineItemNode.addChildElement('Grade', null, prefix).addTextNode(LineGrade);
                            xmlLineItemNode.addChildElement('SKU2', null, prefix).addTextNode(LineSKU2);
                            xmlLineItemNode.addChildElement('Description', null, prefix).addTextNode(LineDescription);
                            xmlLineItemNode.addChildElement('Model', null, prefix).addTextNode(LineModel);
                            xmlLineItemNode.addChildElement('Price', null, prefix).addTextNode(LinePrice);
                            xmlLineItemNode.addChildElement('RestockingFee', null, prefix).addTextNode(LineRestockingFee);         
                    }
                }
            }   

            //Generate Footer node for XML 
            Dom.XmlNode xmlFooterNode   =  xmlSRNode.addChildElement('Footer', null, prefix);
            Dom.XmlNode xmlStatusNode   =  xmlFooterNode.addChildElement('Status', null, prefix);
            
            xmlStatusNode.addChildElement('Error', null, prefix).addTextNode('');
            xmlStatusNode.addChildElement('ErrorMessage', null, prefix).addTextNode('');
            
            //construct xml file name
            XmlName ='HELIX-A-' +CreatedDateTime+'_'+ FolderName +'_'+ ServiceRequestNumber + '.xml';
            
            
            String FPath ;
            if( FolderPath.length()>1){
                FPath = FolderPath.replace('\\','/');
                FPath = FPath.replace('//', '/');         
            }else{
                FPath = '/Vhub/error/';
            }
            //System.debug('FPath  = '  + FPath);
            
            vaws = new VizioSupport_AWSIntegration();
            //call AWS integration class and create trasaction log object for audit trail
            VizioSupport_ErrorObj vErrObj = vaws.saveXMLToVirtualS3(XmlName,doc.toXmlString(),FPath);
            
            Transaction_Log__c tLog =   new Transaction_Log__c();
            tLog.TLog_Body__c       =   doc.toXmlString();
            tLog.TLog_Source__c     =   'SalesForce';
            tLog.TLog_Target__c     =   'AmazonS3';
            tLog.TLog_Type__c       =   'Outbound';
            tLog.TLog_XmlName__c    =   XmlName;
                           
            if(vErrObj.ErrCode == 200){
                    tclass = new VizioSupport_TransactionLogClass();
                    tLog.TLog_Status__c         =  'Closed';
                    tLog.TLog_ErrMessage__c     =   vErrObj.ErrBody;
                    tLog.TLog_FolderName__c     =   vErrObj.ErrFolder ;
                    tclass.insertLog(tLog);
                
            }else {
                //Call Transaction log
                    tclass = new VizioSupport_TransactionLogClass();
                    tLog.TLog_Status__c         =   'Error';
                    tLog.TLog_ErrMessage__c     =   (vErrObj.ErrBody == null  || vErrObj.ErrBody=='' ? vErrObj.ErrMsg: vErrObj.ErrBody ); 
                    tLog.TLog_FolderName__c     =   vErrObj.ErrFolder ;
                    tclass.insertLog(tLog);                
            }
    }
}