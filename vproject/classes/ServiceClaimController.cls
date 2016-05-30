public with sharing class ServiceClaimController {

    private ApexPages.StandardController std;
    private Boolean result {get; set;}
    private Boolean allowSave {get; set;}
    
    public Id wcRecType {get; set;}
    public Id rmaRecType {get; set;}
    public Service_Claim__c sc {get; set;}
    public String userProfile {get; set;}
    public String recId = ApexPages.currentpage().getParameters().get('Id');
    public String recTypeId = ApexPages.currentPage().getParameters().get('RecordType');
    public String recTypeName = ApexPages.currentPage().getParameters().get('RecordType.DeveloperName');
        
    public ServiceClaimController(ApexPages.StandardController stdCtrl) {
        
        wcRecType = [SELECT Id FROM RecordType WHERE DeveloperName = 'Warranty_Claim'].Id;
        rmaRecType = [SELECT Id FROM RecordType WHERE DeveloperName = 'RMA'].Id;
        userProfile = [SELECT u.Profile.Name FROM User u WHERE u.id = :Userinfo.getUserId()].Profile.Name;
    
        std = stdCtrl;
        sc = (Service_Claim__c)std.getRecord();
        sc.RecordTypeId = recTypeId;
        
        //* Create a short list of User attributes so we can autofill certain fields if the user is a Partner...
        List<User> usr = new List<User>([SELECT Id, ContactId, Contact.AccountId FROM User WHERE Id = :UserInfo.getUserId()]);
        
        //* If the user is a portal user, fill in the AccountId and ContactId
        if (usr[0].ContactId != NULL && sc.Contact__c == NULL) {
            if (sc.Account__c == NULL) sc.Account__c = usr[0].Contact.AccountId;
            if (sc.Contact__c == NULL) sc.Contact__c = usr[0].ContactId;
        }
    }
    
    public Service_Claim__c getServiceClaim() {
        sc = (Service_Claim__c)std.getRecord();
        sc.RecordTypeId = recTypeId;
        return sc;
    }
        
    //* add custom save method to validate fields that must be filled out...
    public pageReference save() {
        
        result = validateFields();
        allowSave = checkSerial(sc.Id, sc.Serial_No__c);
        
        if (result && allowSave) {
            return std.save();
        }
        else {
            return NULL;
        }
    }

    public pageReference deleteCancel() {
        return std.cancel();
    }
    
    public pageReference getResults() {
        
        if (sc.Account__c == NULL) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Please select a VASP Account and Contact before validating a serial number.'));
            return NULL;
        }

        else if (sc.Serial_No__c == NULL)
        {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Please enter a valid serial number.'));
            return NULL;
        }

        // Perform serial number checks...
        checkSerial(sc.Id, sc.Serial_No__c);

        //* Build a map of the custom settings: URL, Username, Password
        Map<String, Service_Claim_Custom_Setting__c> scMap = Service_Claim_Custom_Setting__c.getAll();
        Service_Claim_Custom_Setting__c scReq = scMap.get('Request');
    
        String uname = scReq.Username__c;
        String token = scReq.Password__c;
        String url = scReq.URL__c;
        String serialNo = sc.Serial_No__c;

        // if any data exists in fields, clear it out first
        clearVal(); 
        
        // Call API to get json data
        try {
            HttpResponse res= CallWebService(url,serialNo, uname, token);
            String resp = res.getBody();
            System.debug('FINAL RESP IS:'+EncodingUtil.urlDecode(resp, 'UTF-8'));
   
            //Deserialize json 
        
            List<Object> lstObj = GetJsonStringResult(resp);

            System.debug(lstObj.size());

            if (lstObj.size() > 0) {
                for (Object obj : lstObj) {
                    Map<String, Object> objAttributes = (Map<String, Object>)obj;
                    for (String attributeName : objAttributes.keyset()) {
                        Object s = objAttributes.get(attributeName);
                        // assign data to fields
                        setVal(attributeName, s);
                    }
                }
            }
            else if (lstObj.isEmpty()) {
                sc.ValidSerialNumber__c = false;
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'The serial number entered was not found.'));
            }
        } catch (Exception e) {
            sc.ValidSerialNumber__c = false;
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.WARNING, 'The system took too long to respond. Please try again.'));
        }
        return NULL;
    }
    
    public static List<Object> GetJsonStringResult(String resp) {
        Map<String, Object> results = (Map<String, Object>)JSON.deserializeUntyped(resp);
        System.debug(results.size());
        List<Object> lstObj = (List<Object>)results.get('GetSerialWithRegistrationsResult');
        
        System.debug(lstObj.size());
        return lstObj;
    }
    
    public static HttpResponse CallWebService(String url, String serialNo, String uname, String token){
        
        System.debug(serialNo);
        String data='{"serialNo":"'+serialNo+'"}';
        System.HttpRequest request= new System.HttpRequest();
        request.setBody(data);
        request.setMethod('POST');
        request.setEndpoint(url);
        
        Blob headerValue = Blob.valueOf(uname + ':' + token);
        String authorizationHeader = 'BASIC ' +
        EncodingUtil.base64Encode(headerValue);
        request.setHeader('Authorization', authorizationHeader);
        request.setHeader('Content-Type','application/json');
        request.setTimeout(60000);
        Http h = new Http();
        HttpResponse res = h.send(request);
        
        return res;
    
    }
    
    public void setVal(String attrName, Object attrValue) {
        if (sc.recordType.DeveloperName == 'Warranty_Claim' || sc.recordTypeId == wcRecType) {
            if ( attrName=='Address' ) {
                sc.Customer_Address__c = (String)attrValue;
            }
            if (attrName=='City') {
                sc.Customer_City__c= (String)attrValue;
            }
            if (attrName=='Country') {
                sc.Customer_Country__c= (String)attrValue;
                
            }
            if (attrName=='FirstName') {
                sc.Customer_First_Name__c = (String)attrValue;
            }
            if (attrName=='LastName') {
                sc.Customer_Last_Name__c = (String)attrValue;
            }
            if (attrName=='State') {
                sc.Customer_State__c = (String)attrValue;
            }
            if (attrName=='PostalCode') {
                sc.Customer_Postal_Code__c = (String)attrValue;
            }
            if (attrName=='Phone') {
                sc.Customer_Phone__c = (String)attrValue;
            }
            if (attrName=='Email') {
                sc.Customer_Email__c = (String)attrValue;
            }
        }
        if (attrName=='ShipDate') {
            if ((String)attrValue==NULL) {
                 sc.Ship_Date__c = NULL;
            }
            else {
                sc.Ship_Date__c=date.parse((String)attrValue);
            }
        }
        if (attrName=='PurchaseDate') {
            if ((String)attrValue==NULL) {
                 sc.Purchased_Date__c = NULL;
            }
            else {
                sc.Purchased_Date__c=date.parse((String)attrValue);
            }
        }
        if (attrName=='SoldTo') {
            sc.Sold_To__c = (String)attrValue;
        }
        if (attrName=='SalesOrderNo') {
            sc.Sales_Order__c = (String)attrValue;
        }
        if (attrName=='PONo') {
            sc.PO_Number__c  = (String)attrValue;
        }
        if (attrName=='PurchasePrice') {
            if ((String)attrValue=='') {
                 sc.Unit_Price__c = NULL;
            }
            else {
                sc.Unit_Price__c=double.valueOf((String)attrValue);
            }
        }
        if (attrName=='Model') {
            if ((String)attrValue!='') {
                String v = (String)attrValue;
                System.debug(v);
                
                Product2[] ps=[SELECT Id FROM Product2 WHERE ProductCode = :v AND Family = 'Warranty Claim Items'];
                System.debug('Product2 query count:'+ps.size());
                if (ps.size()>0) {
                    sc.Model_No__c = ps[0].Id;
                }
            }
        }
        if (attrName=='ODM') {
            System.debug((String)attrValue);
            if ((String)attrValue!='') {
                String v = (String)attrValue;
                System.debug(v);
                ODM_Partner__c[] ops = [SELECT Id FROM ODM_Partner__c WHERE VASP_Partner__c = :sc.Account__c AND ODM_Partner__r.Name = :v];
                system.debug('ODM_Partner query count'+ops.size());
                if (ops.size()>0) {
                    sc.ODM_Partner__c= ops[0].Id;
                }
            }
            else {
                String v = sc.Serial_No__c.mid(1,1);
                ODM_Partner__c[] ops = [SELECT Id FROM ODM_Partner__c WHERE VASP_Partner__c = :sc.Account__c AND ODM_Partner__r.ODM_Code__c = :v];
                if (ops.size() > 0) sc.ODM_Partner__c = ops[0].Id;
            }
        }
        sc.ValidSerialNumber__c = true;
    }
 
    public void clearVal() {
        sc.ODM_Partner__c = NULL;
        sc.Customer_Address__c=NULL;
        sc.Customer_City__c=NULL;
        sc.Customer_Country__c=NULL;
        sc.Customer_First_Name__c=NULL;
        sc.Customer_Last_Name__c=NULL;
        sc.Customer_State__c=NULL;
        sc.Customer_Postal_Code__c=NULL;
        sc.Customer_Phone__c=NULL;
        sc.Customer_Email__c=NULL;
        sc.Ship_Date__c=NULL;
        sc.Purchased_Date__c=NULL;
        sc.Sold_To__c=NULL;
        sc.Sales_Order__c=NULL;
        sc.PO_Number__c=NULL;
        sc.Unit_Price__c=NULL;
        sc.Model_No__c=NULL;
        sc.ValidSerialNumber__c = false;
    }
    
    
    public boolean validateFields() {
    
        result = true;
        
        if (sc.Account__c == NULL) {
            sc.Account__c.addError('An Account must be selected.');
            result = false;
        }
        if (sc.Contact__c == NULL) {
            sc.Contact__c.addError('A Contact must be selected.');
            result = false;
        }
        if (sc.StoreNumber__c == NULL) {
            sc.StoreNumber__c.addError('A Store Number/Service Center must be selected.');
            result = false;
        }
        if (sc.Serial_No__c == NULL) {
            sc.Serial_No__c.addError('A Serial # is required.');
            result = false;
        }
        if (sc.ODM_Partner__c == NULL && !userProfile.contains('Community')) {
            sc.ODM_Partner__c.addError('An ODM Partner is required.');
            result = false;
        }
        if (sc.Model_No__c == NULL && !userProfile.contains('Community')) {
            sc.Model_No__c.addError('A Model # is required.');
            result = false;
        }
        if (sc.Lease_Date__c == NULL) {
            sc.Lease_Date__c.addError('An Original Lease/Purchase Date is required.');
            result = false;
        }

        //* RMA specific validations
        if (sc.recordType.DeveloperName == 'RMA' || sc.recordTypeId == rmaRecType) {
            if (sc.Problem_Type__c == NULL) {
                sc.Problem_Type__c.addError('A Problem Type must be selected.');
                result = false;
            }
            if (sc.Problem_Description__c == NULL) {
                sc.Problem_Description__c.addError('A Problem Description must be selected.');
                result = false;
            } 
        }

        //* Warranty Claim specific validations
        if (sc.recordType.DeveloperName == 'Warranty_Claim' || sc.recordTypeId == wcRecType) {
            if (sc.Service_In_Date__c == NULL) {
                sc.Service_In_Date__c.addError('A Service In Date is required.');
                result = false;
            }
            if (sc.Service_Completed__c == NULL) {
                sc.Service_Completed__c.addError('A Service Completed date is required.');
                result = false;
            }
            if (sc.Defect_Type__c == NULL) {
                sc.Defect_Type__c.addError('A Defect Type must be selected.');
                result = false;
            }         
            if (sc.Defect_Code__c == NULL) {
                sc.Defect_Code__c.addError('A Defect Code must be selected.');
                result = false;
            }
            if (sc.Resolution_Code__c == NULL) {
                sc.Resolution_Code__c.addError('A Resolution Code must be selected.');
                result = false;
            }
            if (sc.Customer_First_Name__c == NULL) {
                sc.Customer_First_Name__c.addError('A Customer First Name must be entered.');
                result = false;
            }
            if (sc.Customer_Last_Name__c == NULL) {
                sc.Customer_Last_Name__c.addError('A Customer Last Name must be entered.');
                result = false;
            }
            if (sc.Customer_Address__c == NULL) {
                sc.Customer_Address__c.addError('A Customer Address must be entered.');
                result = false;
            }
            if (sc.Customer_City__c == NULL) {
                sc.Customer_City__c.addError('A Customer City must be entered.');
                result = false;
            }
            if (sc.Customer_State__c == NULL) {
                sc.Customer_State__c.addError('A Customer State must be entered.');
                result = false;
            }
            if (sc.Customer_Country__c == NULL) {
                sc.Customer_Country__c.addError('A Customer Country must be entered.');
                result = false;
            }
            if (sc.Customer_Postal_Code__c == NULL) {
                sc.Customer_Postal_Code__c.addError('A Customer Postal Code must be entered.');
                result = false;
            }
            if (sc.Customer_Phone__c == NULL) {
                sc.Customer_Phone__c.addError('A Customer Phone must be entered.');
                result = false;
            }
            if (sc.Customer_Email__c == NULL) {
                sc.Customer_Email__c.addError('A Customer Email must be entered.');
                result = false;
            }
        }
                
        return result;
    }

    public boolean checkSerial(Id recId, String serialNo) {

        boolean allowSave = true;
        
        //Map<String, Service_Claim_Custom_Setting__c> sbMap = Sandbox_Flag__c.getAll();
        //Sandbox_Flag__c sbFlag = sbMap.get('Is_Sandbox__c');
        
        Sandbox_Flag__c sbFlag = Sandbox_Flag__c.getInstance();
        string sb = '';
        if(sbFlag.Is_Sandbox__c == true) sb = 'partner/';
        
        
        //String sb = if(sbFlag == true){'partner/', '');

        List<Service_Claim__c> snl = new List<Service_Claim__c>([SELECT Id, Serial_No__c, Record_Id_Text__c, Status__c from Service_Claim__c WHERE Serial_No__c = :serialNo AND Id != :recId ORDER BY Status__c, CreatedDate DESC]);
        if(snl.size() > 0) {

            for(Service_Claim__c i : snl) {
                if(i.Status__c == 'Draft') {
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'A Pending Claim for this serial number was saved as a draft previously under <a href="/' +sb+ i.Id + '" style="font-size:100%;margin:0;" title="Click to go to Claim record.">' + i.Record_Id_Text__c + '</a>. This claim cannot be saved or submitted. Please modify previous claim and submit for approval.'));
                    allowSave = false;
                    return allowSave;
                }
                else if(i.Status__c == 'Pending Review') {
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'A Pending Claim for this serial number was submitted for <a href="/' +sb+ i.Id + '" style="font-size:100%;margin:0;" target="_blank" title="Click to open Claim in new window.">' + i.Record_Id_Text__c + '</a>. Claim cannot be saved or submitted to VIZIO for approval at this time.'));
                    allowSave = false;
                    return allowSave;
                }
                else if(i.Status__c == 'Approved') {
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.WARNING, 'A Claim was previously approved for this serial number on <a href="/' +sb+ i.Id + '" style="font-size:100%;margin:0;" target="_blank" title="Click to open Claim in new window.">' + i.Record_Id_Text__c + '</a>. Please verify this is a valid claim before saving and/or submitting.'));
                    allowSave = true;
                    return allowSave;
                }
                else if(i.Status__c == 'Rejected') {
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.WARNING, 'A Claim was previously submitted for this serial number on <a href="/' +sb+ i.Id + '" style="font-size:100%;margin:0;" target="_blank" title="Click to open Claim in new window.">' + i.Record_Id_Text__c + '</a>. Please verify this is a valid claim before saving and/or submitting.'));
                    allowSave = true;
                    return allowSave;
                }
            }
        }

        return allowSave;
    }
}