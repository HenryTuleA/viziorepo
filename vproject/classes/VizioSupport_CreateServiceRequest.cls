/**
 * VizioSupport_CreateServiceRequest. Create Service Request.
 *
 * @author              Stela Zhang
 * @version             1.0
 * @since               1.0
 */ 
 
 
 /*
 
Error Code: Use Product- SKU DESC field value do query from error code object, select error code category field(will get 1 or more). Show the picklist for the available error code.

SR Type: 
	Step 1. Use Product SKU value (already create a formula field on Case object named from SKU__c, just use this field) do 
		query from Authorized_SRType_for_SKU__c, select the SR type (will get 1 or more). Show the picklist for the available SR type.

Svc Provider: 
	Step 1. Use Product SKU (already create a formula field on Case object named from SKU__c, just use this field) and 
		selected SR type (See the SR Type logic above) do query from Authorized_SP_for_SRtypenSKU__c, select the ServiceProviderId or 
		ServiceProviderName. (will get 1 or more)

    Step 2. Compare the ServiceProvider (Contact)'s country and State with Customer?s country and State, 
    	show the picklist for the match list (at least one match)
    	

Service Request Information: Use lookup field ProductId__c =: relatedProduct[0].Id AND Country__c =: relatedContact[0].MailingCountryCode to filter.
*/

public without sharing class VizioSupport_CreateServiceRequest{
    
    public Service_Request__c newSR {get;set;}   
    public List<Case> relatedCase{get;set;}
    public List<Asset> relatedAsset {get;set;}
    public List<Product2> relatedProduct {get;set;}
    public List<Contact> relatedContact {get;set;}
    public Line_Items__c theFirstLineItem {get;set;} 
    
    
    // Line item
    public List<lineItem> lineItemList {get;set;}
    public List<Line_Items__c> insertlineItemList {get;set;}
    
    // When select different SR type or click Override
    public List <Line_Items__c> getPrepopulateLineItem {get;set;}
    
    // Get Service Request Information list 
    public List <Service_Request_Information__c> srInfo{get;set;}
    
    // Get Error Code
    private List<Error_Code__c> listErrorCode {get;set;}
    
    // These values populate the picklists from SRType and SVC Provider
    private List<Authorized_SRtype_for_SKU__c> authSRTypeList;
    private List<Authorized_SP_for_SRtypenSKU__c> authSPforSRList;
    
    
    // These are the selected (saved) values from the picklists!
    public String selectedSRType {get;set;}
    public String selectedSVCProvider {get;set;}
    public String selectedErrorCode {get;set;}
    
    // SelectOptionList
    public List<SelectOption> errorCodeSelectList {get;set;}
    public List<SelectOption> provList  {get;set;}
    public List<SelectOption> TypeList  {get;set;}
     
    // Value from URL
    public String CaseId {get;set;}
    
    public Boolean showPageBlock {get;set;}
    public Boolean showSRinformation{get;set;}
    
    // No. of rows add in the Line Item
    public Integer countItem = 1;
    public Integer selectRowIndex{get;set;}
    
    // Maps for storing the Id and selected string
    public  Map<String, Id> srTypetoId {get;set;} 
    public  Map<String, Id> errorCodetoId {get;set;}
    public  Map<String, Id> svcProvidertoId {get;set;}
    
    // Use for override button
    public String srNum {get;set;}
    public Boolean clickOverride {get;set;}
    public List<Service_Request__c> overRideSR {get;set;}
    
    // For Credit card
    public Boolean needCreditCard {get;set;}
    public Double totalAmount {get;set;}
    public String firstName {get;set;}
    public String lastName {get;set;}
    public String ccType {get;set;}
    public String ccNumber {get;set;}
    public String expMonth {get;set;}
    public String expYear {get;set;}
    public String cvvNumber {get;set;}
    public Boolean sameAsCustomer {get;set;}
    public String address {get;set;}
    public String city {get;set;}
    public String state {get;set;}
    public String zipCode {get;set;}
    public Integer countClickTime {get;set;}
    
    // For Model Substitute check box
    public Boolean showModelSub {get;set;}
    
    // For select SP then show the SP's address
    public Boolean showSPaddress {get;set;}
    public List<Authorized_SP_for_SRtypenSKU__c> spShowAddress {get;set;}
    public Boolean showMessage {get;set;}
    
    // For select different SR type for 
    public Boolean isAR {get;set;}
    public Boolean isRNR {get;set;}
    public Boolean isOther {get;set;} // ACC OSS AR SR
    
    // For Cast information
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
    public VizioSupport_CreateServiceRequest() {
        CaseId = ApexPages.currentPage().getParameters().get('CaseId');
        newSR = new Service_Request__c();
        theFirstLineItem = new Line_Items__c();
        relatedCase = new List<Case>();
        relatedAsset = new List<Asset>();
        relatedProduct = new List<Product2>();
        listErrorCode = new List<Error_Code__c>();
        relatedContact = new List<Contact>(); 
        srInfo = new List<Service_Request_Information__c>();  
        lineItemList = new List<lineItem>();
        insertlineItemList = new List<Line_Items__c>();
        getPrepopulateLineItem = new List<Line_Items__c>();
        showPageBlock = true;
        showSRinformation = false;
        selectRowIndex = 0;
        srTypetoId = new Map<String, Id>();
        errorCodetoId = new Map<String, Id>();
        svcProvidertoId = new Map<String, Id>();     
        srNum = '';
        clickOverride = false;
        overRideSR = new List<Service_Request__c>();
        errorCodeSelectList = new List<SelectOption>();
        provList = new List<SelectOption>();
    	TypeList = new List<SelectOption>();
    	needCreditCard = false;
    	totalAmount = 0;
    	sameAsCustomer = false ;
    	countClickTime = 0;
    	showModelSub = true;   	
    	isAR = false;
        isRNR = false;
        isOther = true;
        showMessage = false;
        showSPaddress = false;
    	spShowAddress = new List<Authorized_SP_for_SRtypenSKU__c>();
    	currentCast = new List<Cast__c>();
     	hasCast = false;
    	getInformation();
    }
    
    /**
     * The GetInformation function, get the basic related objects information
     *
     * @param                   None
     * @return       PageReference           None
     * @since                   1.0
     */ 
    public PageReference getInformation() {
        
        // Get the service Request's related Case
        relatedCase = [Select Id, AssetId, ContactId, Product_SKU__c From Case Where Id=:CaseId];
        if (relatedCase.isEmpty()) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Case does not exist.'));
            showPageBlock = false;
            return null;
        }
        
        // Get the case's related Customer
        relatedContact = [Select Id, OtherPhone, Extension__c, MailingPostalCode,MailingStreet, Phone, MailingStateCode, MailingCountryCode, MailingCity, MailingAddress, LastName, FirstName, Fax, Email
                          From Contact 
                          Where Id=: relatedCase[0].ContactId];
        if (relatedContact.isEmpty()) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Customer does not exist.'));
            showPageBlock = false;
            return null;            
        }
        
        // Get the case's related Asset
        relatedAsset = [Select Id, Product2Id, Product2.Cast_Tablet_SKU__c, PurchaseDate, SerialNumber, Purchase_Location__c, DOA_Date__c From Asset Where Id=: relatedCase[0].AssetId];
        if (relatedAsset.isEmpty()) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Asset does not exist.'));
            showPageBlock = false;
            return null;
        }
        
        // Get the Asset's related Product
        relatedProduct = [Select Id, Description, Model__c, SKU__c, SKUDesc__c, isPart__c  From Product2 Where Id=: relatedAsset[0].Product2Id];
        if (relatedProduct.isEmpty()) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Product does not exist.'));
            showPageBlock = false;
            return null;
        }
        
        // Get the SR Information
        srInfo = [Select isActive__c, SubModelOutDOA__c, SubModelOutDOASKU__c, SubModelDOA__c, SubModelDOASKU__c,
        				 SpecialInstructions__c, SR__c, RepairableBacklight__c, RepairableBacklightModels__c, RR__c, RNR__c, RC__c, 
        				 ProductId__c, OSS__c, OSR__c, Country__c, ODM__c, ContactODM__r.LastName, AR__c, ACC__c 
        		  From Service_Request_Information__c
        		  Where ProductId__c =: relatedProduct[0].Id AND Country__c =: relatedContact[0].MailingCountryCode];
        if (srInfo.isEmpty()) {
        	showSRinformation = false; 
        	showModelSub = false;     	
        } else {
        	showSRinformation = true;
        	if (srInfo[0].SubModelDOA__c  != null && srInfo[0].SubModelOutDOA__c != null) {
    			showModelSub = true;
    		} else {
    			showModelSub = false;
    		}
        }
        
        //  Check Case info
	    if (relatedAsset[0].SerialNumber != null && relatedAsset[0].Product2Id != null && relatedAsset[0].Product2.Cast_Tablet_SKU__c != null) {
	   		currentCast = [Select TabletSerialNo__c, TVserialNo__c From Cast__c Where TVserialNo__c = : relatedAsset[0].SerialNumber];
	       		
	        if (!currentCast.isEmpty()) {
	       		hasCast = true;
	       	}
	       		
	    } 
        
    	system.debug('showModelSub' + showModelSub);
        return null; 
    }
    
    
    /**
     * Create a none sobject type class to save the line item, create line item on the VF page
     *
     * @param                   None
     * @return        List<SelectOption>           
     * @since                   1.0
     */ 
    public class lineItem {
    	public Line_Items__c addLineItem{get;set;}
    	public Integer recCount{get;set;}
    	public lineItem(Integer intCount){
    		addLineItem = new Line_Items__c();
    		recCount = intCount;
    	}
    }
    
    /**
     * Add button, add new line item 
     *
     * @param                   None
     * @return                  None        
     * @since                   1.0
     */ 
    public void addButton() {
    	countItem ++;
    	lineItem newLineItem = new lineItem(countItem);
    	lineItemList.add(newLineItem);
    }
    
    /**
     * Del button, delete the selected lineitem
     *
     * @param                   None
     * @return                  None        
     * @since                   1.0
     */ 
    public void deleteButton() {
        lineItemList.remove(selectRowIndex);
        countItem = countItem - 1;

    }
    
    /**
     * Create a none sobject type class to save the service requst information, show the information on the VF page
     *
     * @param                   None
     * @return        List<SelectOption>           
     * @since                   1.0
     */ 
    public class ServiceRequestInformation {
    	public Service_Request_Information__c showSRinfo{get;set;}
    	public ServiceRequestInformation(Service_Request_Information__c srInfolist){
    		showSRinfo = srInfolist;
    	}
    }
    /**
     * The getSRInformation function, return the ServiceRequestInformation list 
     *
     * @param                   None
     * @return        List<SelectOption>           
     * @since                   1.0
     */ 
    public List<ServiceRequestInformation> getSRInformation() {
        
        // Get the Service Request Information
        if (!srInfo.isEmpty()) {
        	List<ServiceRequestInformation> srInfolist = new List<ServiceRequestInformation>();
        	for (Service_Request_Information__c sr : srInfo) {
				srInfolist.add(new ServiceRequestInformation(sr));  
			}
        	return srInfolist;
        }
        return null;     	
    }
    
    
    /**
     * The getErrorCodeList function, return the ErrorCode selectOption List show up on VF page
     *
     * @param                   None
     * @return        List<SelectOption>           
     * @since                   1.0
     */ 
    public List<SelectOption> getErrorCodeList() {
  
        errorCodeSelectList = new List<SelectOption>();
  		errorCodeSelectList.add(new SelectOption(' ',' '));
        errorCodetoId = new Map<String, Id>();
  		
  		// If click override will show the original value inside salesforce but also editable, user can select all the error code
  		if (clickOverride == true) {
  			listErrorCode = [Select Id, Name, Description__c
        				     From   Error_Code__c];
  			
  			// If entered a reference SR# prepopulate the existing data for the reference service request
  			if (!overRideSR.isEmpty()) {
  				selectedErrorCode = overRideSR[0]. Error_Code__r.Name + '-' + overRideSR[0].Error_Code__r.Description__c;
  				errorCodeSelectList.add(new SelectOption(overRideSR[0]. Error_Code__r.Name + '-' + overRideSR[0].Error_Code__r.Description__c,overRideSR[0]. Error_Code__r.Name + '-' + overRideSR[0].Error_Code__r.Description__c));
    			errorCodetoId.put(overRideSR[0]. Error_Code__r.Name + '-' + overRideSR[0].Error_Code__r.Description__c, overRideSR[0].Error_Code__c);
  			    
  			}
  			if (!listErrorCode.isEmpty()) {  		
	  			for (Error_Code__c errorCode : listErrorCode)
	  			{		  				
	  				errorCodeSelectList.add(new SelectOption(errorCode.Name + '-' + errorCode.Description__c, errorCode.Name + '-' + errorCode.Description__c));
	  				errorCodetoId.put(errorCode.Name + '-' + errorCode.Description__c, errorCode.Id);
	  			}
	  		}  			
  		} else { 
  			
  			// Before click override only show the get the error code based on the SKUDesc__c field on Product object
  			listErrorCode = [Select Id, Name, Description__c
        				 From   Error_Code__c
        				 Where  Error_Category__c includes (:relatedProduct[0].SKUDesc__c)];
	  		if (!listErrorCode.isEmpty()) {  			
	  			for (Error_Code__c errorCode : listErrorCode)
	  			{	  				 
	  				errorCodeSelectList.add(new SelectOption(errorCode.Name + '-' + errorCode.Description__c, errorCode.Name + '-' + errorCode.Description__c));
	  				errorCodetoId.put(errorCode.Name + '-' + errorCode.Description__c, errorCode.Id);
	  			}	  			
	  		} 
  		} 		
  		return errorCodeSelectList;
    }
    
    /**
     * The getsrTypeList function, return the SR Type selectOption List show up on VF page
     *
     * @param                   None
     * @return        List<SelectOption>           
     * @since                   1.0
     */ 
    public List<SelectOption> getsrTypeList() {
    	   	
    	TypeList = new List<SelectOption>();
    	TypeList.add(new SelectOption(' ',' '));
        srTypetoId = new Map<String, Id>();
        
        // If click override will show the original value inside salesforce but also editable, user can select all the SR Type
  		if (clickOverride == true) {
  			authSRTypeList = [ Select	ID, SRType__c
    		                   From 	Authorized_SRtype_for_SKU__c
    		                   Where    Override__c =: true];
    		// If entered a reference SR# prepopulate the existing data for the reference service request                   
  			if (!overRideSR.isEmpty()) {

  				selectedSRType = overRideSR[0].AuthSRtype__r.SRType__c;		  				
  				TypeList.add(new SelectOption(overRideSR[0].AuthSRtype__r.SRType__c,overRideSR[0].AuthSRtype__r.SRType__c));
    			srTypetoId.put(overRideSR[0].AuthSRtype__r.SRType__c, overRideSR[0].AuthSRtype__c);
  			}
  			if (!authSRTypeList.isEmpty()) {
		  		for (Authorized_SRtype_for_SKU__c authSR : authSRTypeList)
		  		{
		  			TypeList.add(new SelectOption(authSR.SRType__c,authSR.SRType__c));
		  			srTypetoId.put(authSR.SRType__c, authSR.Id);
		  		}
	  	    } 
  	    } else { 
  	    	
  	    	// Before click override only show the get the SR Type based on the Product_SKU__c field on Case object
  	        authSRTypeList = [ Select	ID, SRType__c
    		                   From 	Authorized_SRtype_for_SKU__c
    		                   Where	SKU__c =: relatedCase[0].Product_SKU__c];
	  	    if (!authSRTypeList.isEmpty()) {
		  		for (Authorized_SRtype_for_SKU__c authSR : authSRTypeList)
		  		{
		  			TypeList.add(new SelectOption(authSR.SRType__c,authSR.SRType__c));
		  			srTypetoId.put(authSR.SRType__c, authSR.Id);
		  		}
	  	    } 
  		}  		
  		if (selectedSRType == 'RNR') {
  			isRNR = true;
  		} else if (selectedSRType == 'AR'){
  			isAR = true;		
  		}
  		if (selectedSRType != 'OSS' && selectedSRType != 'AR' && selectedSRType != 'SR' && selectedSRType != 'ACC') {
  			isOther = true;
  		} else {
  			isOther = false;
  		}
    	return TypeList;
    }
    
    
    /*TODO*/
    /**
     * The getsvcProviderList function, return the Svc Provider selectOption List show up on VF page
     *
     * @param                   None
     * @return        List<SelectOption>           
     * @since                   1.0
     */ 
    public List<SelectOption> getsvcProviderList() {
    	provList = new List<SelectOption>();
    	provList.add(new SelectOption(' ',' '));
        svcProvidertoId = new Map<String, Id>();
        
        
        // If click override will show the original value inside salesforce but also editable
        if (clickOverride == true) {
        	authSPforSRList = [
	    			Select ServiceProviderID__c, ServiceProviderID__r.SP_for_Country__c, ServiceProviderID__r.SP_for_State__c, ServiceProviderName__c,
	    				   ServiceProviderID__r.MailingStreet, ServiceProviderID__r.MailingStateCode, ServiceProviderID__r.MailingCountryCode,
	    			       ServiceProviderID__r.MailingPostalCode, ServiceProviderID__r.MailingCity
					From Authorized_SP_for_SRtypenSKU__c
					Where  Override__c =: true];
        	
        	// If entered a reference SR# prepopulate the existing data for the reference service request   
        	if (!overRideSR.isEmpty()) {
        		selectedSVCProvider = overRideSR[0].Service_Provider__r.ServiceProviderName__c;
  				provList.add(new SelectOption(overRideSR[0].Service_Provider__r.ServiceProviderName__c,overRideSR[0].Service_Provider__r.ServiceProviderName__c));
    			svcProvidertoId.put(overRideSR[0].Service_Provider__r.ServiceProviderName__c, overRideSR[0].Service_Provider__c);
    			
    			
    	 		spShowAddress = [
	    			Select ServiceProviderID__c, ServiceProviderID__r.SP_for_Country__c, ServiceProviderID__r.SP_for_State__c, ServiceProviderName__c,
	    				   ServiceProviderID__r.MailingStreet, ServiceProviderID__r.MailingStateCode, ServiceProviderID__r.MailingCountryCode,
	    			       ServiceProviderID__r.MailingPostalCode, ServiceProviderID__r.MailingCity
					From Authorized_SP_for_SRtypenSKU__c
					Where  Id =:overRideSR[0].Service_Provider__c];
        	}
        	if (!authSPforSRList.isEmpty()) {
		  		for (Authorized_SP_for_SRtypenSKU__c authSP : authSPforSRList)
		  		{
		  			provList.add(new SelectOption(authSP.ServiceProviderName__c,authSP.ServiceProviderName__c));
		  			svcProvidertoId.put(authSP.ServiceProviderName__c, authSP.id);
		  		}
	  	    }  
  	    }  else { 
  	    	
  	    	// Before click override only show the get the SR Type based on the selectedSRType on the vf page and Product_SKU__c field on Case object And customer's country and state
	    	if (selectedSRType != null)
	    	{   
	    		authSPforSRList = [
	    			Select ServiceProviderID__c, ServiceProviderID__r.SP_for_Country__c, ServiceProviderID__r.SP_for_State__c, ServiceProviderName__c,
	    			       ServiceProviderID__r.MailingStreet, ServiceProviderID__r.MailingStateCode, ServiceProviderID__r.MailingCountryCode,
	    			       ServiceProviderID__r.MailingPostalCode, ServiceProviderID__r.MailingCity
					From Authorized_SP_for_SRtypenSKU__c
					Where SRType__c =: selectedSRType AND SKU__c =: relatedCase[0].Product_SKU__c];
	    		
	    		if (!authSPforSRList.isEmpty()) {		
		    		for (Authorized_SP_for_SRtypenSKU__c authSP : authSPforSRList)
		  			{
		  				
		  				// If the Country is ALL then we just add the option to the list and the continue to the next iteration
		  				if (authSP.ServiceProviderID__r.SP_for_Country__c == 'ALL')
		  				{
		  					provList.add(new SelectOption(authSP.ServiceProviderName__c,authSP.ServiceProviderName__c));
		  					svcProvidertoId.put(authSP.ServiceProviderName__c, authSP.id);
		  					
		  					continue;
		  				} 				
		  				
		  				// If the country matches and the State is ALL then we added it to the list and continue to the next iteration
		  				String[] tmpString = authSP.ServiceProviderID__r.SP_for_Country__c.split(';');
		  				
		  				for (String s : tmpString)
		  				{
							system.debug(s);
							
							if (relatedContact[0].MailingCountryCode == s)
							{
								if (authSP.ServiceProviderID__r.SP_for_State__c == 'ALL' )
								{
									provList.add(new SelectOption(authSP.ServiceProviderName__c,authSP.ServiceProviderName__c));
		  					        svcProvidertoId.put(authSP.ServiceProviderName__c, authSP.id);
		  							continue;
								}
								
								
								// We check the multipicklist of states to see if there is any matches if they match then we add it to the picklist
								String[] tmpString2 = authSP.ServiceProviderID__r.SP_for_State__c.split(';');
								
								for (String s1 : tmpString2)
								{
									if (relatedContact[0].MailingStateCode == s1)
									{
										provList.add(new SelectOption(authSP.ServiceProviderName__c,authSP.ServiceProviderName__c));
		  					            svcProvidertoId.put(authSP.ServiceProviderName__c, authSP.id);
		  								continue;		
									}
								}
								
							}
		  				}
		  					   
		  			}
		    		
		    	} 
		    } 
        }
        
    	return provList;
    }
	
	/**
     * The Override button, enter the SR request number, if the SR inside salesforce prepopulate the SR's information with line items 
     * And Assign current SR's RelationSRNo__c to this SR.
     *
     * @param                   None
     * @return        PageReference          
     * @since                   1.0
     */ 
    public void overrideSR() {
    	getPrepopulateLineItem = new List<Line_Items__c>();
    	//spShowAddress = new List<Authorized_SP_for_SRtypenSKU__c>();
    	//showSPaddress = false;
    	
    	clickOverride = true;
    	needCreditCard = false;
        if (srNum != null) {
        	
        	overRideSR = [Select Id, Name, Shipping_Notes__c, Internal_Notes__c, Box__c, isWallMount__c, isWhiteGlove__c, isSubstitution__c, Label__c,
        	                     Error_Code__c, AuthSRtype__c, Service_Provider__c, Service_Provider__r.ServiceProviderName__c,
        	                     Error_Code__r.Name, Error_Code__r.Description__c, AuthSRtype__r.SRType__c
        	              From Service_Request__c
        	              Where Name =: srNum];
        	
        	// If the SR inside salesforce, prepopulate some values and update the new SR's value
        	if (!overRideSR.isEmpty()) {
        		showSPaddress = true;
				//clickOverride = true;
        		newSR.Shipping_Notes__c = overRideSR[0].Shipping_Notes__c;
        		newSR.Internal_Notes__c = overRideSR[0].Internal_Notes__c;
        		newSR.Box__c = overRideSR[0].Box__c;
        		newSR.isWallMount__c = overRideSR[0].isWallMount__c;
        		newSR.isWhiteGlove__c = overRideSR[0].isWhiteGlove__c;
        		newSR.isSubstitution__c = overRideSR[0].isSubstitution__c;
        		newSR.Label__c = overRideSR[0].Label__c;
        		newSR.RelatedSRNo__c = overRideSR[0].Id;
        		getPrepopulateLineItem = [Select Id, PartType__c, Service_Request__c, SKU__c, Quantity__c, Grade__c, Core__c, Serial_No__c, Price__c, Restocking_Fee__c, Sales_Order_No__c, Notes__c
        							   From Line_Items__c
        							   Where Service_Request__c =: overRideSR[0].Id];
        		
        		// Get the related line items
        		lineItemList = new List<lineItem>();
        		if (!getPrepopulateLineItem.isEmpty()) {
        			for (Line_Items__c line_Item : getPrepopulateLineItem) { 
        				countItem ++;
    					lineItem newLineItem = new lineItem(countItem);
    					newLineItem.addLineItem = line_Item;
    					lineItemList.add(newLineItem);
        			} 
        		}
       		
        	}
        }
    }
    
    /**
     * The editAsset button, return to the editAsset VF page
     *
     * @param                   None
     * @return        PageReference          
     * @since                   1.0
     */ 
    public PageReference editAsset() {
    	PageReference page ;
        page = new PageReference('/apex/VizioSupport_EditAsset?CaseID='+ CaseId+'&Open=CreateSR');
        page.setRedirect(true);        
        return page;     	
    }
    
    /**
     * The editCustomer button, return to the editCustomer VF page
     *
     * @param                   None
     * @return        PageReference          
     * @since                   1.0
     */ 
    public PageReference editCustomer() {
    	PageReference page ;
        page = new PageReference('/apex/VizioSupport_USPSEditCustomer?id='+ relatedContact[0].Id+'&CaseID='+ CaseId + '&Open=CreateSR');
        page.setRedirect(true);          
        return page;    
    }

    /**
     * The modelComparison button, return to the modelComparison VF page
     *
     * @param                   None
     * @return        PageReference          
     * @since                   1.0
     */ 
    public PageReference modelComparison() {
    	PageReference page ;
    	if (!relatedProduct.isEmpty() && !srInfo.isEmpty()) {
        	page = new PageReference('/apex/VizioSupport_ModelComparison?CaseID='+ CaseId+'&model1=' + relatedProduct[0].Model__c + '&model2=' + srInfo[0].SubModelDOA__c + '&model3=' + srInfo[0].SubModelOutDOA__c);
    	} else {
    		return null;
    	}
        page.setRedirect(true);        
        return page;     	
    }
    
    /**
     * The Save button, Save the service request and line item
     *
     * @param                   None
     * @return        PageReference          
     * @since                   1.0
     */ 
    public PageReference saveSR() {
    	PageReference page ;
  		
  		// Get SRtypeId, errorCodeId, providerId from the maps
  		String SRtypeId = srTypetoId.get(selectedSRType);
  		String errorCodeId = errorCodetoId.get(selectedErrorCode);
  		String providerId = svcProvidertoId.get(selectedSVCProvider);	
  		
  		// SRtypeId and errorCodeId are required. 
  		if (SRtypeId == null) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'SR type is required.'));   
            return null;
        }
        if (errorCodeId == null) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Error Code is required.'));   
            return null;
        }
        if (providerId == null && selectedSRType != 'RC') {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Service Provider is required.'));   
            return null;
        }
        if (selectedSRType == 'ACC' && relatedProduct[0].isPart__c == false) {
        	ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Sorry, you can\'t create ACC service request.'));   
            return null;
        }
  		system.debug('Id '+ SRtypeId+' '+errorCodeId+' '+providerId); 
  		
        // Create a new Service Request
    	newSR.Case__c = CaseId; 
    	newSR.Error_Code__c = errorCodeId;
    	newSR.AuthSRtype__c = SRtypeId;
    	newSR.Service_Provider__c = providerId;
    	    	
    	// Create line items
    	if (theFirstLineItem.SKU__c != null && theFirstLineItem.Quantity__c != 0 && theFirstLineItem.Grade__c != null && theFirstLineItem.SKU__c.length()==11) {   		
    		insertlineItemList.add(theFirstLineItem);
    	} else {
    		if (theFirstLineItem.PartType__c != null || theFirstLineItem.Core__c!= null ||  theFirstLineItem.Serial_No__c != null ||
    		    theFirstLineItem.Price__c  != null || theFirstLineItem.Restocking_Fee__c != null ||
    		    theFirstLineItem.Sales_Order_No__c != null || theFirstLineItem.Notes__c != null) {
    			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Please enter SKU, Quantity and Grade'));   
            	return null;
    		}
    	}
    	for (lineItem item:lineItemList) {
    		if (item.addLineItem.SKU__c != null && item.addLineItem.Quantity__c != 0 && item.addLineItem.Grade__c != null && item.addLineItem.SKU__c.length()==11) {    			
    			insertlineItemList.add(item.addLineItem);
    		} else {
    			 ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Please enter Quantity, Grade and 11 digits SKU, '));   
                 return null;
    		}
    	}
    
    	// After no error message create service request 
    	insert newSR;
    	
    	if (!insertlineItemList.isEmpty()) {
    		
    		// update the Line_Items__c's Service_Request__c lookup field to the new service request Id
    		for (Line_Items__c i : insertlineItemList) {
    			i.Service_Request__c = newSR.Id;
    		}
    		insert insertlineItemList;
    	} 
    	
    	page = new PageReference('/'+newSR.Id);
        page.setRedirect(true);        
        return page;    	
    }
    
    
  
    /**
     * The Cancle button, return the case detail page
     *
     * @param                   None
     * @return        PageReference          
     * @since                   1.0
     */ 
    public PageReference cancelSR() {
    	PageReference page ;
        page = new PageReference('/'+CaseId);
        page.setRedirect(true);        
        return page;   
    }
    
    /**
     * The SR Type picklist, select different will prepopulate some values
     * CRC, RC, MRC have some functionality, create receive line item
     * RR create send and receive as grade new, auto check label
     * AR, SR, OSS create send (Grade based on DOA date) and receive as grade new
     * AR has credit card section
     * SR auto check the label, if there's sub model auto check model substituion 
     * OSS check wall mount, white glove 
     * OOW, SBS nothing
     * SCR, VCR, OSR wall mount auto check
     * ACC only create line item when ispart = 1 (field from product object)
     * Model Substition alert functionality for all types
     * @param                   None
     * @return        PageReference          
     * @since                   1.0
     */
    public Pagereference autoPopulate() {
    	overRideSR = new List<Service_Request__c>();	
    	showMessage = false;
    	
    	// Check the SR type for different functionalities
    	if (selectedSRType == 'RNR') {
  			isRNR = true;
  		} else if (selectedSRType == 'AR'){
  			isAR = true;		
  		}
    	if (selectedSRType != 'OSS' && selectedSRType != 'AR' && selectedSRType != 'SR' && selectedSRType != 'ACC') {
  			isOther = true;
  		} else {
  			isOther = false;
  		}
  		
    	// Set defaul value for all
    	needCreditCard = false;
    	lineItemList = new List<lineItem>();
    	countItem = 1;
    	newSR.isWallMount__c = false;
    	newSR.isWhiteGlove__c = false;
    	newSR.label__c = false;
    	newSR.box__c = false;
    	newSR.internal_Notes__c = '';	
        
        if (selectedSRType != 'SR' && selectedSRType != 'AR' && selectedSRType != 'OSS') {
        	newSR.isSubstitution__c = false;
        }
    	if (selectedSRType == 'ACC'){
    		
    	     // Create send line item when product ispart is 1 
    		autoCreateDOASend();
    	} else if (selectedSRType == 'CRC') {
    		
    		// line item based on Serial No and SKU, grade New; receive   	
	    	autoCreateReceive();
	    	
    	} else if (selectedSRType == 'AR') {
    		
    		// send and receive   		
	    	autoCreateDOASend();  		
	    	
    		// credit card 
    	} else if (selectedSRType == 'MRC') {
    		
    		// Create one line item based on Serial No and SKU , grade New; receive	 
    		autoCreateReceive();
    		
    	} else if (selectedSRType == 'RC') {
    		
    		// Create one line item based on Serial No and SKU , grade New; receive	    	
    		autoCreateReceive();
    		
    	} else if (selectedSRType == 'RNR') {
    		
    		//SelectSRType = RNR will never use box and lable and no line item
    		
    	} else if (selectedSRType == 'RR') {
    		
    		// Label always selected;  Auto create Label line item           
            newSR.Label__c = true;  
            checkboxLabel();
   		
    		// Auto filled in with the information pulled biased off the SN and defaults to new for the send and receive.
    		autoCreateSend();
    		autoCreateReceive(); 
    		  		
    	} else if (selectedSRType == 'SR') {
    		     	    		
    		// If there?s sub model check model comparison 
    		if (showModelSub == true) {
    			newSR.isSubstitution__c = true;
    		}
    		// Check label; create lable line item; create send and receive
            autoCreateDOASend();
    		
    	} else if (selectedSRType == 'OOW') {
    		// Nothing, no line item
    	} else if (selectedSRType == 'SCR') {
    		
    		// Wall mount auto check; no line item
    		newSR.isWallMount__c = true;
    		
    	} else if (selectedSRType == 'VCR') {
    		
    		// Wall mount auto check; no line item
    		newSR.isWallMount__c = true;
    		
    	} else if (selectedSRType == 'SBS') {
    		// Nothing, no line item
    	} else if (selectedSRType == 'OSS') {    		
    		
    		// Wall mount auto check; White glove auto check;    		
    		newSR.isWallMount__c = true;
    		newSR.isWhiteGlove__c = true;
    		
    		// Line item create, send and receive
    		autoCreateDOASend();		
    		
    	} else if (selectedSRType == 'OSR') {
    		
    		// Wall mount auto check; no line item
    		newSR.isWallMount__c = true;   
    		 
    	} else if (selectedSRType == 'RO') { 
    		
    		// line item based on Serial No and SKU, grade New; receive   	
	    	// autoCreateReceive();
    	}
    	
    	return null;
    }
    
    /**
     * autoCreateSend, Auto create send line time after select SRType
     *
     * @param                   None
     * @return        PageReference          
     * @since                   1.0
     */
     public PageReference autoCreateDOASend () {
     	 
     	
     	// Set isSubstitution__c
    	newSR.isSubstitution__c = newSR.isSubstitution__c;	
       
    	// If SRType = SR auto check label and create a label lineitem, create receive line item
    	
    	if (selectedSRType == 'ACC') {
    		lineItemList = new List<lineItem>();
    		if (relatedProduct[0].isPart__c != true) {
    			return null;
    		}		   		
    	} else if (selectedSRType == 'SR') {
    		lineItemList = new List<lineItem>();
    		newSR.Label__c = true;  
    		checkboxLabel();
    		autoCreateReceive();
    	} else if (selectedSRType == 'AR' ) {
    		
    		// If SRType = AR OR OSS create receive line item
    		lineItemList = new List<lineItem>();
    		autoCreateReceive();
    	} else if (selectedSRType == 'OSS') {
    		
    		// If SRType = OSS create receive line item
    		lineItemList = new List<lineItem>();
    		autoCreateReceive();
    		
    		// If hasCast = true create a revice and send
    		if (hasCast == true) {
    			autoCreateCastSend();
    			autoCreateCastReceive();
    		}
    	}
    	
    	// If the box checkbox checked create a box line item
    	if (newSR.box__c == true) {
    		checkboxBox();
    	}
    	
    	// If SR is OSS and customer's in Canada
    	if (selectedSRType == 'OSS' && relatedContact[0].MailingCountryCode == 'CA') {
	    	
	    	selectedSVCProvider = 'Edtech Technology Inc.';
  			provList.add(new SelectOption('Edtech Technology Inc.','Edtech Technology Inc.'));
    		
	    	spShowAddress = [
	    			Select ServiceProviderID__c, ServiceProviderID__r.SP_for_Country__c, ServiceProviderID__r.SP_for_State__c, ServiceProviderName__c,
	    				   ServiceProviderID__r.MailingStreet, ServiceProviderID__r.MailingStateCode, ServiceProviderID__r.MailingCountryCode,
	    			       ServiceProviderID__r.MailingPostalCode, ServiceProviderID__r.MailingCity
					From Authorized_SP_for_SRtypenSKU__c
					Where  ServiceProviderName__c =:'Edtech Technology Inc.'];
			svcProvidertoId.put(spShowAddress[0].ServiceProviderName__c, spShowAddress[0].Id);
			showSPaddress = true;
			showMessage = true;
	    }
	    
    	// Create a send line item based on DOA [AR OSS SR]
    	Line_Items__c newLine_Item = new Line_Items__c();
	    newLine_Item.PartType__c = 'Send';
	    newLine_Item.Quantity__c = 1;
	    newLine_Item.Core__c = 'No';
	    newLine_Item.Price__c = 0.00;
	    newLine_Item.Restocking_Fee__c = 0.00;
	    
	    if (relatedAsset[0].DOA_Date__c != null) {	
	    	if (date.Today().daysBetween(relatedAsset[0].DOA_Date__c) >= 0 && newSR.isSubstitution__c == false) {
	    			
	    		// In DOA and without Sub model
	    		newSR.internal_Notes__c = 'EU IN DOA NEW GRADE.';   			
		    	newLine_Item.SKU__c = relatedProduct[0].SKU__c;
		    	newLine_Item.Notes__c = '';
		    	newLine_Item.Grade__c = 'New';
		    	
	    	} else if (date.Today().daysBetween(relatedAsset[0].DOA_Date__c) < 0 && newSR.isSubstitution__c == false) {
	    			
	    		// Out DOA and without Sub model
	    		newSR.internal_Notes__c = 'OUT OF DOA EU ACCEPTS RECERT.';
	    		newLine_Item.SKU__c = relatedProduct[0].SKU__c;
		    	newLine_Item.Notes__c = 'EU ACCEPTS RECERT';
		    	newLine_Item.Grade__c = 'B';
		    		
	    	} else if (date.Today().daysBetween(relatedAsset[0].DOA_Date__c) >= 0 && newSR.isSubstitution__c == true) {
	    			
	    		// In DOA and without Sub model
	    		newSR.internal_Notes__c = 'IN DOA EU NEW GRADE EU ACCEPTS SUB MODEL.';
	    		if (!srInfo.isEmpty()) {
	    			if (srInfo[0].SubModelDOA__c  != null && srInfo[0].SubModelOutDOA__c != null) {
	    				newLine_Item.SKU__c = srInfo[0].SubModelDOASKU__c;
	    			}
	    		}			
		    	newLine_Item.Notes__c = 'EU ACCEPTS SUB';
		    	newLine_Item.Grade__c = 'New';
	    			
	    	} else if (date.Today().daysBetween(relatedAsset[0].DOA_Date__c) < 0 && newSR.isSubstitution__c == true) {
	    			
	    		// In DOA and without Sub model
	    		newSR.internal_Notes__c = 'OUT OF DOA EU ACCEPTS B GRADE AND SUB MODEL.';
	    			
	    		if (!srInfo.isEmpty()) {
	    			if (srInfo[0].SubModelDOA__c  != null && srInfo[0].SubModelOutDOA__c != null) {
	    				newLine_Item.SKU__c = srInfo[0].SubModelOutDOASKU__c;
	    			}
	    		}
		    	newLine_Item.Notes__c = 'ACCEPTS SUB AND RECERT';
		    	newLine_Item.Grade__c = 'B';
	    	}
	    } else {
	    	    newSR.internal_Notes__c = 'NEW GRADE.';   			
		    	newLine_Item.SKU__c = relatedProduct[0].SKU__c;
		    	newLine_Item.Notes__c = '';
		    	newLine_Item.Grade__c = 'New';

	    }
    	countItem ++;
	    lineItem newLineItem = new lineItem(countItem);
	    newLineItem.addLineItem = newLine_Item;
	    lineItemList.add(newLineItem);
	    	
	    return null;
     }
    
    /**
     * autoCreateSend, Auto create send line time after select SRType
     *
     * @param                   None
     * @return        PageReference          
     * @since                   1.0
     */
     public void autoCreateSend () {
    	
    	Line_Items__c newLine_Item = new Line_Items__c();
	   	newLine_Item.PartType__c = 'Send';
	   	newLine_Item.SKU__c = relatedProduct[0].SKU__c;
	    newLine_Item.Quantity__c = 1;
	    newLine_Item.Grade__c = 'New';
	    newLine_Item.Core__c = 'No';
	    newLine_Item.Price__c = 0.00;
	    newLine_Item.Restocking_Fee__c = 0.00;
	    newLine_Item.Serial_No__c = relatedAsset[0].SerialNumber;
	    countItem ++;
	    lineItem newLineItem = new lineItem(countItem);
	    newLineItem.addLineItem = newLine_Item;
	    lineItemList.add(newLineItem);
    }
    
    /**
     * autoCreateCastSend, Auto create cast send line time if any
     *
     * @param                   None
     * @return        PageReference          
     * @since                   1.0
     */
     public void autoCreateCastSend () {
    	
    	Line_Items__c newLine_Item = new Line_Items__c();
	   	newLine_Item.PartType__c = 'Send';
	   	newLine_Item.SKU__c = relatedAsset[0].Product2.Cast_Tablet_SKU__c;
	    newLine_Item.Quantity__c = 1;
	    newLine_Item.Grade__c = 'New';
	    newLine_Item.Core__c = 'No';
	    newLine_Item.Price__c = 0.00;
	    newLine_Item.Restocking_Fee__c = 0.00;
	    newLine_Item.Notes__c = 'Tablet';
	    newLine_Item.Serial_No__c = currentCast[0].TabletSerialNo__c;
	    countItem ++;
	    lineItem newLineItem = new lineItem(countItem);
	    newLineItem.addLineItem = newLine_Item;
	    lineItemList.add(newLineItem);
    }
    
    /**
     * autoCreateReceive, Auto create receive line time after select SRType
     *
     * @param                   None
     * @return        PageReference          
     * @since                   1.0
     */
     public void autoCreateReceive () {
    	
	    Line_Items__c newLine_Item = new Line_Items__c();
	    newLine_Item.PartType__c = 'Receive';
	    newLine_Item.SKU__c = relatedProduct[0].SKU__c;
	    newLine_Item.Quantity__c = 1;
	    newLine_Item.Grade__c = 'New';
	    newLine_Item.Core__c = 'No';
	    newLine_Item.Price__c = 0.00;
	    newLine_Item.Restocking_Fee__c = 0.00;	    
	    newLine_Item.Serial_No__c = relatedAsset[0].SerialNumber;
	    countItem ++;
	    lineItem newLineItem = new lineItem(countItem);
	    newLineItem.addLineItem = newLine_Item;
	    lineItemList.add(newLineItem);      
    }
    
    /**
     * autoCreateCastReceive, Auto create cast receive line time if any
     *
     * @param                   None
     * @return        PageReference          
     * @since                   1.0
     */
     public void autoCreateCastReceive () {
    	
	    Line_Items__c newLine_Item = new Line_Items__c();
	    newLine_Item.PartType__c = 'Receive';
	    newLine_Item.SKU__c = relatedAsset[0].Product2.Cast_Tablet_SKU__c;
	    newLine_Item.Quantity__c = 1;
	    newLine_Item.Grade__c = 'New';
	    newLine_Item.Core__c = 'No';
	    newLine_Item.Price__c = 0.00;
	    newLine_Item.Restocking_Fee__c = 0.00;	   
	    newLine_Item.Notes__c = 'Tablet';
	    newLine_Item.Serial_No__c = currentCast[0].TabletSerialNo__c;
	    countItem ++;
	    lineItem newLineItem = new lineItem(countItem);
	    newLineItem.addLineItem = newLine_Item;
	    lineItemList.add(newLineItem);      
    }
    
    /**
     * checkboxBox, if check the Box checkbox add one box line item, if uncheck delete the box line item
     *
     * @param                   None
     * @return        PageReference          
     * @since                   1.0
     */
    public void checkboxBox () {
    	Integer boxPosition = 0;
    	// set newSR.Label__c
    	newSR.Box__c = newSR.Box__c;
    	
    	if (newSR.Box__c == true ) {
	    	Line_Items__c newLine_Item = new Line_Items__c();
	    	newLine_Item.PartType__c = 'Send';
	    	newLine_Item.SKU__c = '00000000010';
	    	newLine_Item.Quantity__c = 1;
	    	newLine_Item.Grade__c = 'Not Available';
	    	newLine_Item.Core__c = 'No';
	    	newLine_Item.Price__c = 0.00;
	    	newLine_Item.Restocking_Fee__c = 0.00;
	    	newLine_Item.Notes__c = 'BOX';
	    	countItem ++;
	    	lineItem newLineItem = new lineItem(countItem);
	    	newLineItem.addLineItem = newLine_Item;
	    	lineItemList.add(newLineItem);
        } else {
        	for (lineItem i : lineItemList) {
        		boxPosition ++;
        		if (i.addLineItem.Notes__c == 'BOX' && i.addLineItem.SKU__c == '00000000010') {
        			lineItemList.remove(boxPosition-1);
        		    break;
        		}
        	}
            countItem = countItem - 1;
        }
    }
    
    /**
     * checkboxLabel, if check the Label checkbox add one label line item, if uncheck delete the label line item
     *
     * @param                   None
     * @return        PageReference          
     * @since                   1.0
     */
    public void checkboxLabel () {
    	
    	Integer labelPosition = 0;
    	// set newSR.Label__c
    	newSR.Label__c = newSR.Label__c;
  	
    	if (newSR.Label__c == true ) {
	    	Line_Items__c newLine_Item = new Line_Items__c();
	    	newLine_Item.PartType__c = 'Send';
	    	newLine_Item.SKU__c = '00000000015';
	    	newLine_Item.Quantity__c = 1;
	    	newLine_Item.Grade__c = 'Not Available';
	    	newLine_Item.Core__c = 'No';
	    	newLine_Item.Price__c = 0.00;
	    	newLine_Item.Restocking_Fee__c = 0.00;
	    	newLine_Item.Notes__c = 'LABEL';
	    	countItem ++;
	    	lineItem newLineItem = new lineItem(countItem);
	    	newLineItem.addLineItem = newLine_Item;
	    	lineItemList.add(newLineItem);
        } else {
        	for (lineItem i : lineItemList) {
        		labelPosition ++;
        		if (i.addLineItem.Notes__c == 'LABEL' && i.addLineItem.SKU__c == '00000000015') {
        			lineItemList.remove(labelPosition-1); 
        		   	break;	
        		}
        	}
            countItem = countItem - 1;
        }
    }
    
    /**
     * The getYearList function, return the year selectOption List show up on VF page, for the exp year
     *
     * @param                   None
     * @return        List<SelectOption>           
     * @since                   1.0
     */ 
    public List<SelectOption> getYearList() {
    	Integer currentYear = System.Today().year();
    	List<SelectOption> yearSelectList = new List<SelectOption>();
    	yearSelectList.add(new SelectOption(' ','Select'));
    	Integer i;
    	for (i = currentYear; i < currentYear + 20; i++) {
    		yearSelectList.add(new SelectOption(string.valueof(i), string.valueof(i)));
    	}
    	return yearSelectList;
    }
    
    /**
     * checkCreditCard, if SRType =  AR, and the price is greater than 0
     *
     * @param                   None
     * @return        PageReference          
     * @since                   1.0
     */
    public void checkCreditCard () {
    	totalAmount = 0;
    	for (lineItem i : lineItemList) {
    		if (i.addLineItem.Price__c > 0) {
    			needCreditCard = true;
    			firstName = relatedContact[0].FirstName;
    			lastName = relatedContact[0].LastName;
    			totalAmount = totalAmount + i.addLineItem.Price__c;
    		}
    	}  	
    }
    
    /**
     * if check same as customer checkbox, use the customer's address on top (relatedContact[0])
     *
     * @param                   None
     * @return        PageReference          
     * @since                   1.0
     */
    public void uesSameAddress () {
    	countClickTime ++;
    	if (math.mod(countClickTime,2) == 1 ) {
    		sameAsCustomer = true;	
    		address = relatedContact[0].MailingStreet;
    		city = relatedContact[0].MailingCity;
    		zipCode = relatedContact[0].MailingPostalCode;
    		state = relatedContact[0].MailingStateCode;
    	} else {
    		sameAsCustomer = false;
    		address = null;
    		city = null;
    		zipCode = null;
    		state = 'Select';
    	}
    	
    }
    
    /**
     * Show Service Provider Address
     *
     * @param                   None
     * @return        PageReference          
     * @since                   1.0
     */
    public void spAddress () {
    	 showMessage = false;
    	 overRideSR = new List<Service_Request__c>();
    	 showSPaddress = true;
    	 
    	 if (selectedSRType == 'OSS' && relatedContact[0].MailingCountryCode == 'CA' && selectedSVCProvider == 'Edtech Technology Inc.') {
			showMessage = true;
	    }
    	 
    	 String providerId = svcProvidertoId.get(selectedSVCProvider);
    	 spShowAddress = [
	    			Select ServiceProviderID__c, ServiceProviderID__r.SP_for_Country__c, ServiceProviderID__r.SP_for_State__c, ServiceProviderName__c,
	    				   ServiceProviderID__r.MailingStreet, ServiceProviderID__r.MailingStateCode, ServiceProviderID__r.MailingCountryCode,
	    			       ServiceProviderID__r.MailingPostalCode, ServiceProviderID__r.MailingCity
					From Authorized_SP_for_SRtypenSKU__c
					Where  Id =:providerId];
						 
    }
   
    /**
     * verifyCreditCard, call out to verify 
     *
     * @param                   None
     * @return        PageReference          
     * @since                   1.0
     */
    public void verifyCreditCard () {
    	
    }
}