/**
 * VizioSupport_CaseDetail. CaseDetail information page.
 *
 * @author              Stela Zhang
 * @version             1.0
 * @since               1.0
 */ 
 
public without sharing class VizioSupport_CaseAssetInformation{
    //private ApexPages.StandardController standardController;
    
   // public Case getCaseId{get;set;}
    public String caseId {get;set;}
    
    // Related objects
  	public List<Case> currentCase{get;set;}
  	public List<Asset> currentAsset{get;set;}
  	public List<Product2> currentProduct{get;set;}
  	public List<Authorized_Retailer_for_SKU__c> getLastReturnDate {get;set;}
 	public List<Product_Warranty__c> getRetailId {get;set;}
  	public List<Product_Warranty__c> getWarrantyLength {get;set;}
  	public Boolean showPageBlock {get;set;} // show pageblock or error message
  	public Boolean showAsset {get;set;} // asset exist or not, show different fields
  	public Boolean showProduct {get;set;} // product exist or not, show different fields
  	public Boolean isPOPVerified {get;set;} // Show different message
  	public Boolean hasPurchaseDate {get;set;} // show different message
  	public Boolean findLastReturnDate {get;set;}
  	public Boolean findOOWDate {get;set;}
  	public Integer DOAremindDay {get;set;}
  	public String DOADate {get;set;}
  	public Integer OOWremindDay {get;set;}
  	public String OOWDate {get;set;}
  	public Date getOOWdata{get;set;}
  	
  	public List<Cast__c> currentCast {get;set;}
  	public Boolean hasCast {get;set;}
  
    /**
     * Definition of the constructor. 
     * Initial all variables.
     *
     * @param      None
     * @return     None
     * @since      1.0
     */ 
    public VizioSupport_CaseAssetInformation(ApexPages.StandardController standardController ){
        
        caseId = ApexPages.currentPage().getParameters().get('id');
        currentCase = new List<Case>();
      	currentAsset = new List<Asset>();
     	currentProduct = new List<Product2>();
      	getLastReturnDate = new List<Authorized_Retailer_for_SKU__c>();
        getRetailId = new List<Product_Warranty__c>();
     	getWarrantyLength = new List<Product_Warranty__c>();
     	showPageBlock = true;
     	showAsset = true;
     	showProduct = true;
     	isPOPVerified = false;
     	hasPurchaseDate = false;
     	findLastReturnDate = false;
     	findOOWDate = false;
     	
     	currentCast = new List<Cast__c>();
     	hasCast = false;
     	GetInformation();
    } 
   
   /**
     * The GetInformation function, get the basic related objects information
     *
     * @param                   None
     * @return       PageReference           None
     * @since                   1.0
     */ 
      public PageReference GetInformation() {
        
        // Get Current case, if case does not exist show error message
        currentCase = [Select Id, AssetId From Case Where Id=:caseId];
        if (currentCase.isEmpty()) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Case does not exist.'));
            showPageBlock = false;
            return null;
        }
       
       // Get current asset, if asset does not exist show blank asset and product fields else check pop value and get product value
        currentAsset = [Select Id, Product2Id, Product2.Cast_Tablet_SKU__c, PurchaseDate, SerialNumber, Purchase_Location__c, Purchase_Price__c, Asset_Notes__c, isPOPVerify__c, Last_Return_Date__c,DOA_Date__c,OOW_Date__c 
        				From Asset 
        				Where Id=: currentCase[0].AssetId];  
        
        if (currentAsset.isEmpty()) {
            showAsset = false;
            showProduct = false;
            system.debug('testing');
        } else {
        	showAsset = true;
	
        	// Get current product, if product does not exist show blank product fields, else count last return date
        	currentProduct = [Select Id, Description, Model__c, SKU__c From Product2 Where Id=: currentAsset[0].Product2Id];
        	
        	if (currentProduct.isEmpty()) {           
            	showProduct = false; 
        	} else {
        		showProduct = true;
        		
        		if (currentAsset[0].Purchase_Location__c != null) {
        			countLastReturnDate();
        		}
        	}
        	
        	// Check pop verify or not
	        if (currentAsset[0].isPOPVerify__c == true) {
	       		isPOPVerified = true;
	       	}  else {
	       		isPOPVerified = false;
	       	}
	       	
	       	// Check Purchase date
	        if (currentAsset[0].PurchaseDate == null) {
	       		hasPurchaseDate = false;
	       	}  else {
	       		hasPurchaseDate = true;
	       		countDOA();
        		countOOW(); 
	       	}
	       	
	       	//  Check Case info, find asset serial number in cast object, and the product's cast tablet sku has data
	       	if (currentAsset[0].SerialNumber != null && currentAsset[0].Product2Id != null && currentAsset[0].Product2.Cast_Tablet_SKU__c != null) {
	       		currentCast = [Select TabletSerialNo__c, TVserialNo__c From Cast__c Where TVserialNo__c = : currentAsset[0].SerialNumber];
	       		
	       		if (!currentCast.isEmpty()) {
	       			hasCast = true;
	       		}
	       		
	       	} 
	       	
        }			
        return null; 
    }
    
    
    /**
     * Calculate LastReturnDate   
     * Use Purchase Location and Porduct Id, do query from ARforSKU get Last Return Date
     *
     * @param                                      None   
     * @return                          		   None
     * @since                                      1.0
     */  
    public void countLastReturnDate() {  
    	
       	getLastReturnDate = [Select Id, Last_Return_Date__c,ProductId__r.Name,RetailerId_del__c 
       	                     From Authorized_Retailer_for_SKU__c
       	                     Where ProductId__c =: currentProduct[0].Id 
       	                     And Retailer_Name__c =: currentAsset[0].Purchase_Location__c]; 
       	    
       	if (getLastReturnDate.isEmpty()) {           
           	findLastReturnDate = false; 
        } else {
        	findLastReturnDate = true; 
        		     		
        }                     
    }
  	 
  	 /**
     * Calculate DOA date
     * DOA = purchase date + 90 days and display 
     * Get the reminder date remaining (DOA date ? Today)
     *
     * @param                                      None   
     * @return                          		   None
     * @since                                      1.0
     */ 
  	 public void countDOA() {    	
       		DOADate = string.valueof(currentAsset[0].DOA_Date__c);
       		
       		//  DOA Date - Today 
       		DOAremindDay = date.Today().daysBetween(currentAsset[0].DOA_Date__c);     
    }
    
    /**
     * Calculate OOW date  ************todo
  	 * Use AssetId and purchase location from Asset and query in Product Warranty object
	 *   If a match found get warranty length
     *      If warranty length = 30 then warranty for 30 days
     *      Else warranty length in years
     *   If match not found, just use purchase location (retailer name in product warranty object) from Asset and query in Product Warranty object
     *      Do the same things for warranty length
     *   If match not found, go to product object , query by SKU and get warranty length
	 *      Do the same things warranty length
     * Get the reminder date remaining (OOW date ? Today)
     *
     * @param                                      None   
     * @return                          		   None
     * @since                                      1.0
     */ 
  	public void countOOW() {
		
  		// Use AssetId and purchase location from Asset and query in product Warranty object 
  		getWarrantyLength = [Select Id, Retailer__c, WarrantyLength__c 
        					 From Product_Warranty__c
        					 Where AssetId__c =: currentAsset[0].Id
        					 And Retailer__c =: currentAsset[0].Purchase_Location__c];
  		
  		if (!getWarrantyLength.isEmpty()) {
  			findOOWDate = true;
  		} else {
  		 	getWarrantyLength = new List<Product_Warranty__c>();
  		 	
  		 	// Only use purchase location from Asset query in product Warranty object	
       		getWarrantyLength =  [Select Id, Retailer__c, WarrantyLength__c 
        					 	  From Product_Warranty__c
        					      Where Retailer__c =: currentAsset[0].Purchase_Location__c];
        	if (!getWarrantyLength.isEmpty()) {
        		findOOWDate = true;
        	} else {
        		
        		getWarrantyLength = new List<Product_Warranty__c>();
        		
        		// Use SKU from product query in product Warranty object
        		if (!currentProduct.isEmpty()) {
        			getWarrantyLength =  [Select Id, Retailer__c, WarrantyLength__c 
        					 	          From Product_Warranty__c
        					              Where SKU__c =: currentProduct[0].SKU__c];
        		    if (!getWarrantyLength.isEmpty()) {
        				findOOWDate = true;
        			} else {
        				findOOWDate = false;
        		    }
        		} else {
        			findOOWDate = false;
        		}	
        	}      	   
  		} 

  		if (findOOWDate == true) {
  			if(getWarrantyLength[0].WarrantyLength__c >= 30){
  				getOOWdata = currentAsset[0].PurchaseDate.addDays(Integer.valueof(getWarrantyLength[0].WarrantyLength__c));
  			} else {
  				getOOWdata = currentAsset[0].PurchaseDate.addYears(Integer.valueof(getWarrantyLength[0].WarrantyLength__c));
  			}
  			OOWDate = string.valueof(getOOWdata); 			

  			//OOWDate - Today 
  			OOWremindDay = date.Today().daysBetween(getOOWdata);
  		}            		
  	}
  	
  	/**
     * getNOCInfo
     * Get NOC information for the asset or tablet
     * 
     *
     * @param                                      None   
     * @return                          		   None
     * @since                                      1.0
     */ 
     
     public pageReference getNOCInfo() {
     	connectULI();
     	return null;
     }
     
     public void connectULI() {
        string uname = 'cody.olson';
        string token = 'datamine4Cody';
        string url = 'https://nrws.support.updatelogic.com:8443/2010/04/UliWebService.svc';
        string serialNo = currentAsset[0].SerialNumber;
        Http h = new Http();
       
      //  HttpRequest req = new HttpRequest();
        
        
        HttpResponse res= CallWebService(url,serialNo, uname, token);
            String resp = res.getBody();
            system.debug(resp);
        // set the endPoint
        
      //  req.setEndpoint(endPointValue);
        
        // set the header
      ////  Blob authorizationValue = Blob.valueOf(CONSUMER_KEY + ':' + CONSUMER_SECRET);
      //  String authorizationHeader = 'BASIC ' + EncodingUtil.base64Encode(authorizationValue);
      //  req.setHeader('Authorization', authorizationHeader);       
       
     /*  String body =
            '<soap:Envelope xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\" xmlns:xsd=\"http://www.w3.org/2001/XMLSchema\" xmlns:soap=\"http://schemas.xmlsoap.org/soap/envelope/\">' +
                '<soap:Body>' +
                    '<Echo1 xmlns=\"http://uws.updatelogic.com/\">' +
                        '<input>Connection established</input>' +
                    '</Echo1>' +
                '</soap:Body>' +
            '</soap:Envelope>';
       
        // set the body
        req.setBody(body); 
        
        // set the method          
        req.setMethod('POST');
        HttpResponse res = h.send(req);
        
        
      //  statusCode = res.getStatusCode(); 
        system.debug(res.getBody());
        // JSON Parser
     /*   JSONParser parser = JSON.createParser(res.getBody());
		
		if (statusCode == 200) {
			while (parser.nextToken()!= null) {
		        if ((parser.getCurrentToken() == JSONToken.FIELD_NAME)) {
			        String fieldName = parser.getText();
			        parser.nextToken();
			        if (fieldName == 'access_token') {
				        accessToken = parser.getText();
	   		        }
	           }
	        }
		} else if (statusCode == 400) {
			errorMessage = 'CST connection error.';
        }*/       
    }
    
    /**
     * This method performs the Web Service Call
     *
     * @param       url, serial number, the username and the token to connect with the server
     * @return      HttpResponse from the server           
     * @since       1.0                                                                          
     */
    public static HttpResponse CallWebService(String url, String serialNo, String uname, String token)
    {    
        System.debug(serialNo);
        String data='{"serialNo":"'+serialNo+'"}';
        HttpRequest request= new HttpRequest();
        request.setBody(data);
        request.setMethod('POST');
        request.setEndpoint(url);
        
        Blob headerValue = Blob.valueOf(uname + ':' + token);
        String authorizationHeader = 'BASIC ' + EncodingUtil.base64Encode(headerValue);
        request.setHeader('Authorization', authorizationHeader);
        request.setHeader('Content-Type','application/json');
        request.setTimeout(60000);
        Http h = new Http();
        HttpResponse res = h.send(request);
        
        return res;

    }
    
 	
}