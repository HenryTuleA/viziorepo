/**
 *  This class is a controller used for both VizioSupport_SerialNumberValidation
 *  it is in charge of validating serial numbers and creating new assets and Quick Case Logs
 *
 * @author              Cristian Torres
 * @version             1.0
 * @since               1.0
 */ 
public with sharing class VizioSupport_SerialNoValController 
{
    
    public case case1 { get; set; }
    
    public SerialFormat__c snFormat { get; set;} 
    public String serialNo { get; set; }
    public String description { get; set; }
    public String SKU { get; set; }
    public Asset asset1 { get; set; }
    public Case_Log__c caseLog1 { get; set; }
    public List<Asset> contactAssetsList { get; set; }
    
    private CaseComment caseComment1 { get; set; }
	
	//when the value changes we also make sure to prepopulate all the fields with the existing Asset
	public String selectedAssetID { 
		get;
		set{
			selectedAssetID = value;
			System.debug('Value of SelectedAssetID ' + selectedAssetID);
			
			asset1 = 
			[
				SELECT ID, contactID, Name, product2ID, SerialNumber, Purchase_Location__c, Other_Location__c, PurchaseDate,
	        			Purchase_Price__c, isPOPVerify__c, Asset_Notes__c, Product2.SKU__c, Product2.Description, Product2.Model__c
	        	FROM Asset
	        	WHERE ID =: selectedAssetID
			];
			
			SKU = asset1.Product2.SKU__c;
            description = asset1.Product2.Description; 
            modelName = asset1.Product2.Model__c;
            serialNo = asset1.SerialNumber;
		} 
	}    
    
    
    //typeahead
    public String modelList { get; set; }
    public String modelName { get; set; }
    
    
    //Contact ID from the URL
    private ID contactID;
    //Used to add to the asset
    private Product2 prod1;
    
    public String variable {get; set; }
    
    
    /**
     * Constructor
     *
     * @param            
     * @return                
     * @since    1.0                                                                          
     */ 
    public VizioSupport_SerialNoValController()
    {
        System.debug('Constructor '); 
        serialNo = '';
        description = '';
        //selectedAssetID = '';
        
        case1 = new case();
        asset1 = new asset();
        caseLog1 = new Case_Log__c();
        caseComment1 = new caseComment();
        contactID = apexpages.currentpage().getparameters().get('cID');
        
        contactAssetsList = 
        [
        	SELECT ID, Name, PurchaseDate, Purchase_Location__c, SerialNumber, Product2.Model__c
        	FROM Asset
        	WHERE contactID =: contactID
        ];
        
    }
    

    
    /**
     * Button Verify SN has been clicked 
     *
     * @param            
     * @return      pageReference            
     * @since       1.0                                                                          
     */ 
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
                    if(s.Active__c == true)
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
       
        //clear current asset
        asset1 = null;
        asset1 = new asset();
       
        
         //We are going to check if the Asset already exists if it does it will only be an update otherwise we create a new Asset
        Asset asset2 = getAssetSerialNo(serialNo);
        
        
        if(asset2 != null)
        {
        	asset1 = asset2;
        }
        
        
        return null;    
    }   
    
    
    
    /**
     * Typeahead query
     *
     * @param            
     * @return                
     * @since    1.0                                                                          
     */ 
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
    
    
    /**
     * After clicking the Save button we create a Case and an Asset
     *
     * @param    none        
     * @return   none             
     * @since    1.0                                                                          
     */ 
    public PageReference save()
    {
    	//we will use this ID to redirect users to the next VF
    	ID caseID;
    	
    	
    	Contact currentContact = getContact(contactID);
        System.debug('The Name of the contact is: ' + currentContact.name);
        
        
        
       
        //We are going to check if the Asset already exists if it does it will only be an update otherwise we create a new Asset and Case
        Asset asset2 =  getAssetSerialNo(serialNo);
        System.debug('TEST The Name of the Asset is: ' + currentContact.name);
        
        
        //If the Asset already exists we only update it
        if(asset2 != null)
        {
        	   
	        asset1.contactID = contactID;
	        update asset1;
	    
        } else if(serialNo == '') {
        	//If there is no Serial Number then we create an asset with the name of the model instead of the Serial Number and populate the SKU and 
        	//description (there is no serial Number to query for an asset)
        	
        	//get the Product by querying using the modelName
        	prod1 = getProductModel(modelName);
        	
        	//allows the user to see the error since the model entered does not exist. 
        	if (prod1 == null) { 
                return null; 
            }
        	
        	//creates the asset and then relates it to the contact from the original request
        	asset1.contactID = currentContact.ID;
        	asset1.Name = currentContact.FirstName + ' ' + currentContact.LastName + ' ' + modelName;
        	asset1.product2ID = prod1.ID;
        	//asset1.SerialNumber = modelName; LEAVE BLANK
        
        	insert asset1;
        
        } else {

            //get the Product by querying using the modelName
            prod1 = getProductModel(modelName);
            
            //allows the user to see the error since the model entered does not exist. 
            if (prod1 == null) { 
                return null; 
            }
        	
        	//creates the asset and then relates it to the contact from the original request
        	asset1.contactID = currentContact.ID;
        	asset1.Name = serialNo;
        	asset1.product2ID = prod1.ID;
        	asset1.SerialNumber = serialNo;
        
        	insert asset1;
        		
        }
        
        
        
        //creates the new case and a lookup to both the Asset we just created and to the Contact
	        case1.contactID = currentContact.ID;
	        case1.AssetID = asset1.ID;
	        case1.Status = 'New';
	        case1.Origin = 'Call';
	        case1.Product_Model_Number__c = modelName;
	        
	        insert case1; 
	        
	        caseID = case1.ID;
		
		
		PageReference pageRef = new PageReference('/apex/VizioSupport_ReceiveCall?cID=' + caseID);
        return pageRef;     
        
    }
    
    
    
    
    /**
     * This method returns a contact the parameter is the ID of the contact to return
     *
     * @param       contactID ID of the contact that we are going to query          
     * @return      contact from the database with the ID contactID           
     * @since       1.0                                                                          
     */ 
    private contact getContact(ID contactID)
    {	
    	Contact cont;
 		
        try
        {               
	        cont = [
	            SELECT  ID, Name, FirstName, LastName 
	            FROM    Contact
	            WHERE   ID =: contactID
	        ];
	        
	    } catch (Exception E) {
        	System.Debug('The query did not return results ' + E);
        }
        
        return cont;       
    }
    
    
    
    /**
     * This method returns an asset by using the serial number to query 
     *
     * @param       serialNo serial number of the asset that we are going to query          
     * @return      asset from the database with the serial number serialNo           
     * @since       1.0                                                                          
     */
    private Asset getAssetSerialNo(String serialNo)
    {
    	Asset assetAux;
    	
    	try
        {
	        assetAux = 
	        [ 
	        	SELECT ID, contactID, Name, product2ID, SerialNumber, Purchase_Location__c, Other_Location__c, PurchaseDate,
	        			Purchase_Price__c, isPOPVerify__c, Asset_Notes__c
	        	FROM Asset
	        	WHERE SerialNumber =: serialNo
	        ];
	        
	    } catch (Exception E) {
        	System.Debug('The query did not return results ' + E);
        }
        
        return assetAux;
    }
    
    
    /**
     * This method returns a Product by using the model to query 
     *
     * @param       modelName model of the product that we are going to query          
     * @return      product from the database with the mudel modelName           
     * @since       1.0                                                                          
     */
    private Product2 getProductModel(String modelName)
    {
    	Product2 prod;
    	//Query for the product by using the modelName
        	
        try
	    {               
			prod = [
        		SELECT Model__c, ID
        		FROM Product2 
        		WHERE Model__c =: modelName
        	];
		        
		} catch (Exception E) {
	    	
	    	System.Debug('The Model you entered is invalid ' + E);
	        	
	        ApexPages.Message myMsg; 
	        myMsg = new ApexPages.Message(ApexPages.Severity.FATAL, 
	        	      'The Model you entered is invalid ' + E );
	        ApexPages.addMessage(myMsg);
	        	
	    }
    
    	return prod;
    }   
    
    

    /**
     * This method Creates a case log when we click the button quick log 
     *
     * @param       none          
     * @return      PageReference           
     * @since       1.0                                                                          
     */
    public PageReference quickLog()
    {
    	
    	//show an error if the field notes__c is empty 
    	if(caseLog1.Notes__c == null || caseLog1.Notes__c == '')
    	{
    		System.Debug('The Quick Log Notes field was not populated ');
	        	
	        ApexPages.Message myMsg; 
	        myMsg = new ApexPages.Message(ApexPages.Severity.FATAL, 
	        	      'The Quick Log Notes field is a required field when creating a quick log. Please populate the Quick Log Notes ');
	        ApexPages.addMessage(myMsg);
	        
	        return null;
    	}
    	
    	//we will use this ID to redirect users to the next VF
    	ID caseID;
    	
    	
    	Contact currentContact = getContact(contactID);
        System.debug('The Name of the contact is: ' + currentContact.name);
        
        
       
        //We are going to check if the Asset already exists if it does it will only be an update otherwise we create a new Asset and Case
        Asset asset2 =  getAssetSerialNo(serialNo);
        System.debug('TEST The Name of the Asset is: ' + currentContact.name);
        
        
        //If the Asset already exists we only update it
        if(asset2 != null)
        {
        	   
	        asset1.contactID = contactID;
	        update asset1;
	    
        }   else if(serialNo == '') {
        	//If there is no Serial Number then we create an asset with the name of the model instead of the Serial Number and populate the SKU and 
        	//description (there is no serial Number to query for an asset)
        	
        	//get the Product by querying using the modelName
        	prod1 = getProductModel(modelName);
        	
        	
        	//allows the user to see the error since the model entered does not exist. 
        	if (prod1 == null) { return null; }
        	
        	//creates the asset and then relates it to the contact from the original request
        	asset1.contactID = currentContact.ID;
        	asset1.Name = currentContact.FirstName + ' ' + currentContact.LastName + ' ' + modelName;
        	asset1.product2ID = prod1.ID;
        	//asset1.SerialNumber = modelName; LEAVE BLANK
        
        	insert asset1;
        
        } else {
        	
        	//creates the asset and then relates it to the contact from the original request
        	asset1.contactID = currentContact.ID;
        	asset1.Name = serialNo;
        	asset1.product2ID = prod1.ID;
        	asset1.SerialNumber = serialNo;
        
        	insert asset1;
        		
        }
        
        
        
        //creates the new case and a lookup to both the Asset we just created and to the Contact
	    case1.contactID = currentContact.ID;
	    case1.AssetID = asset1.ID;
	    case1.Status = 'New';
	    case1.Origin = 'Call';
	    case1.Product_Model_Number__c = modelName;
	        
		insert case1; 
	        
	        
	        
	  	//creates now the Case Log
	  	caseLog1.caseID__c = case1.ID;
	  	caseLog1.caseNumber__c = case1.CaseNumber;
	  	caseLog1.caseStatus__c = case1.Status;
	  	
	  	insert caseLog1;
	  	
	  	
	  	//creates a new CaseComment 
	  	caseComment1.ParentID = case1.ID;
	  	caseComment1.CommentBody = caseLog1.Notes__c;
	  	
	  	insert caseComment1;
	  	
	  	
	  	//Use this to redirect to the Case page
	  	caseID = case1.ID;
	  		
    	
    	PageReference pageRef = new PageReference('/' + caseID);
        return pageRef;     
        
    }
    
    
    public PageReference cancel()
    {
        PageReference pageRef = new PageReference('/' + contactID);
        return pageRef;   
    }

}