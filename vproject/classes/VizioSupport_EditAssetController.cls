public with sharing class VizioSupport_EditAssetController 
{
    /*TODO create a new asset if the serial number doesn't have one asset already */
    public case case1 { get; set; }
    public asset asset1 { get; set; }
    public SerialFormat__c snFormat { get; set;} 
    
    
    public String serialNo { get; set; }
    public String description { get; set; }
    public String SKU { get; set; }
    
    
    //typeahead
    public String modelList { get; set; }
    public String modelName { get; set; }
    
    
    //Contact ID from the URL
    private ID caseID;
    //Get this value from the URL in order to know what page to go back to 
    private String returnURL;
    //to add to the asset in case we change the serial number
    private Product2 prod1;

    
    
    public VizioSupport_EditAssetController()
    {
        System.debug('Constructor '); 
        serialNo = '';
        description = '';
        caseID = apexpages.currentpage().getparameters().get('caseID');
        
        case1 = 
        [
            SELECT ID, assetID, Product_Model_Number__c , contactID
            FROM case 
            WHERE ID =: caseID 
        ];
        
        asset1 = 
        [
            SELECT ID, Purchase_Location__c, Other_Location__c, PurchaseDate, Purchase_Price__c, isPOPVerify__c, Asset_Notes__c, SerialNumber,
                Product2.Description, Product2.SKU__c
            FROM asset
            WHERE ID =: case1.assetID
        ];
        
        
        //populates all the strings from the existing values 
        serialNo = asset1.SerialNumber;
        modelName = case1.Product_Model_Number__c;
        description = asset1.Product2.Description;
        SKU = asset1.Product2.SKU__c; 
        
    }
    


    //Button Verify SN has been clicked 
    public pageReference querySerialNumbers()
    {
        String ending;
        String prefix;
    
    
        //We validate that the serial number is longer than 14 characters
        if(serialNo.length() < 14)
        {
            ApexPages.Message myMsg; 
            myMsg = new ApexPages.Message(ApexPages.Severity.FATAL, 
                        'Serial No. ' + serialNo + ' is too short. Please inspect your Serial number ' );
            ApexPages.addMessage(myMsg);
            
            return null;
        }
        
        //First we need to ignore the last 6 characters from the string to verify
        ending = serialNo.right(6);
        prefix = serialNo.removeEnd(ending);
        
        System.debug('The serial number typed is: ' + serialNo);
        System.debug('The Last 6 digits are: ' + ending);
        System.debug('The Prefix we will query is: ' + prefix);
        
        
        //We use the new string to find the elements on the SerialFormat__c table
        list<SerialFormat__c> snFormatList;
        try {
                snFormatList = 
                [
                    SELECT Name, PID__c, PID__r.SKU__c, PID__r.Description, PID__r.Model__c
                    FROM SerialFormat__c
                    WHERE Name = :prefix
                ];
            } catch (Exception E) {
                System.Debug('The query did not return results ' + E);
            }
        
        
        //serialFormats were found
        if (snFormatList.size() > 0)
        {
            //if there are repeated serialFormats then we look for the one that is active
            if (snFormatList.size() > 1)
            {
                for (SerialFormat__c s: snFormatList)
                {
                    if(s.Active__c = true)
                    {
                        snFormat = s;
                    }
                }
            } else {
                
                snFormat = snFormatList[0];
                
            }
        
            System.debug('SerialFormat Found: ' + snFormat.Name);
            
            SKU = snFormat.PID__r.SKU__c;
            description = snFormat.PID__r.Description; 
            modelName = snFormat.PID__r.Model__c;
            
            
            //Query for the product with that model 
            try{
                prod1 = 
                [
                    SELECT  ID, SKU__c, Description
                    FROM    Product2
                    WHERE   Model__c =: modelName
                ];
            } catch (Exception E) {
                System.Debug('The query did not return results ' + E);
            }
            
            
        } else {
            
            // If no match is found in SerialFormat then we split the prefix
            System.debug('SerialFormat not found ');
            
            String firstTwo;
            String TVPrefix;
            
            firstTwo = prefix.left(2);
            TVPrefix = prefix.substringAfter(firstTwo);
            
            System.debug('Prefix ' + prefix);
            System.debug('First two characters ' + firstTwo);
            System.debug('TV Prefix ' + TVPrefix);
            
            
            SNDecrypt__c snDecrypt;
            
            try {
                    snDecrypt = 
                    [
                        SELECT Model__c
                        FROM SNDecrypt__c
                        WHERE TVPrefix__c =: TVPrefix 
                    ];
                } catch (Exception E) {
                    System.Debug('The query did not return results ' + E);
                }
        
        
            //The TVPrefix exists so we are going to update the information on description and SKU__c
            If (snDecrypt != null)
            {
                
                
                //The user didn't populate the Model Field
                modelName = snDecrypt.Model__c;
                    
                //Query for the product with that model 
                   
                try{
                    prod1 = 
                    [
                        SELECT  ID, SKU__c, Description
                        FROM    Product2
                        WHERE   Model__c =: modelName
                    ];
                } catch (Exception E) {
                    System.Debug('The query did not return results ' + E);
                }
                   
                SKU = prod1.SKU__c;
                description = prod1.Description;    
            
            } else {
                //This means that the Serial Number could not be found in the Decrypt Table
                    
                ApexPages.Message myMsg; 
                myMsg = new ApexPages.Message(ApexPages.Severity.FATAL, 
                        'Serial Format for Serial # ' + serialNo + ' cannot be found. Please inspect your Serial number ' );
                ApexPages.addMessage(myMsg);
            }
               
        }       
        
        
        
        
        
         //We are going to check if the Asset already exists if it does it will only be an update otherwise we create a new Asset
        asset asset2;
        
        //clear current asset
        asset1 = null;
        asset1 = new asset();
        
        try
        {
            asset2 = 
            [
                SELECT  ID, contactID, Name, product2ID, SerialNumber, Purchase_Location__c, Other_Location__c, PurchaseDate,
                        Purchase_Price__c, isPOPVerify__c, Asset_Notes__c
                FROM    Asset
                WHERE   SerialNumber =: serialNo
            ];
            
        } catch (Exception E) {
            System.Debug('The query did not return results ' + E);
        }
        
        if(asset2 != null)
        {
            asset1 = asset2;
        }
        
        
        return null;    
    }   
    
    
    
    //typeahead
    public void findModels()
    {
        modelList = null;
        
        string mod = '%' + modelName + '%';
        for(Product2 snf : [select Model__c from Product2 where Model__c LIKE : mod ]){
            if (modelList == '')
                modelList = snf.Model__c;
            else
                modelList = modelList + ',' + snf.Model__c;
        }
    }  
    
    
    public PageReference save()
    {
        
        
        /*
        serialNo = asset1.SerialNumber;
        description = asset1.Product2.Description;
        SKU = asset1.Product2.SKU__c; 
        
        modelName = case1.Product_Model_Number__c;
        */
           /*
           asset1.contactID = currentContact.ID;
            asset1.Name = serialNo;
            asset1.product2ID = prod1.ID;
            asset1.SerialNumber = serialNo;
           */
        //asset1.contactID = contactID;
        
        //check if serial already has an asset then we just update
       
        asset asset2;
        
        
        try
        {
            asset2 = 
            [
                SELECT  ID, contactID, Name, product2ID, SerialNumber, Purchase_Location__c, Other_Location__c, PurchaseDate,
                        Purchase_Price__c, isPOPVerify__c, Asset_Notes__c
                FROM    Asset
                WHERE   SerialNumber =: serialNo
            ];
            
        } catch (Exception E) {
            System.Debug('The query did not return results ' + E);
        }
        
        //if the asset already exists we only update
        if(asset2 != null)
        {
            update asset1;
            
        } else {
            
            // if the asset doesn't exist then we create a new one
            
            try{
                    prod1 = 
                    [
                        SELECT  ID, SKU__c, Description
                        FROM    Product2
                        WHERE   Model__c =: modelName
                    ];
                } catch (Exception E) {
                    System.Debug('The query did not return results ' + E);
          	}
            
            
            asset1.contactID = case1.contactID;
            asset1.Name = serialNo;
            asset1.product2ID = prod1.ID;
            asset1.SerialNumber = serialNo;
        
            insert asset1;
        }
        
        
            
       
        
        //creates the new case and a lookup to both the Asset we just created and to the Contact
        case1.AssetID = asset1.ID;
        //case1.Status = 'New';
        //case1.Origin = 'Call';
        case1.Product_Model_Number__c = modelName;    
        update case1; 
            
        //caseID = case1.ID;
        
        
        PageReference pageRef = new PageReference('/' + caseID);
        return pageRef;     
        
    }
    
    
    //returns to the case
    public PageReference cancel()
    {
        //parameter open will be either caseDetail createSR we use it to know what page to redirect the user to
        returnURL = apexpages.currentpage().getparameters().get('open');
        
        if (returnURL == 'caseDetail')
        {
            //PageReference pageRef = new PageReference('/' + caseID);
            
            /*Xin edit here*/
            PageReference pageRef = new PageReference('/apex/VizioSupport_CaseAssetInformation?id='+ caseID);
            return pageRef;
        }
        
        if (returnURL == 'createSR')
        {
            //PageReference pageRef = new PageReference('/apex/VizioSupport_CreateServiceRequest?CaseId' + caseID);
            
            /*Xin edit here*/
            PageReference pageRef = new PageReference('/apex/VizioSupport_CreateServiceRequest?CaseId=' + caseID);
            return pageRef;
        }
        if (returnURL == 'CaseDetailAdmin')
        {
            //PageReference pageRef = new PageReference('/' + caseID);
            
            /*Xin edit here 02/26/2016*/
            PageReference pageRef = new PageReference('/apex/VizioSupport_CaseAssetInformationAdmin?id='+ caseID);
            return pageRef;
        }
        
        
        return null;
    }
    
    
    
    
}