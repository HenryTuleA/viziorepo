public with sharing class POSController {
	
	public List<POS__c> posList {get;set;}
	//public String sortExpression {get;set;}
	//public String sortDirection {get;set;}
	
	public String sortDirection {get;set;}
    public String sortExp {get;set;} 
    public Integer showSize {get;set;}
	public Integer noOfRecords {get; set;}
	public List<POS__c> newPosList {get;set;}
	
    private ApexPages.StandardSetController setCon{get;set;}
	
	//private ApexPages.StandardController stdController;
	private Id recordId {get;set;}
	
	public POSController(ApexPages.StandardController controller) {
		posList = new List<POS__c>();
		newPosList = new List<POS__c>();
		showSize = 10;
		//recordId = ApexPages.currentPage().getParameters().get('id');
		recordId = controller.getRecord().Id;
        setCon = new ApexPages.StandardSetController(posList);
        setCon.setPageSize(showSize);
	    noOfRecords = setCon.getResultSize();
        //getPos();
	}
	
    public POSController(ApexPages.StandardSetController controller) {
    	
    }
    
    public String sortExpression {
        get {
                return sortExp;
        }
        set {
                //if the column is clicked on then switch between Ascending and Descending modes
                if (value == sortExp)
                        sortDirection = (sortDirection == 'ASC')? 'DESC' : 'ASC';
                else
                        sortDirection = 'ASC';
                sortExp = value;
        }
        
    }
    
    /*get the Direction for sort*/
    public String getSortDirection() {
        //if not column is selected 
        if ((sortExpression == null) 
                 || (sortExpression == '')) {
                    return 'ASC';
        }
        return sortDirection;
    }
    
    /*set the Direction for sort*/
    public void setSortDirection(String value) {  
       sortDirection = value;
    }
    
    //public PageReference getPos() {   
    public List<POS__c> getPos() {
    	//Date myDate = Date.newinstance(1960, 2, 17);
    	posList = new List<POS__c>();
    	try {
	    	List<Account> distributorAcc;
	        
	        Claim__c claim = [SELECT Id, Account__c, Claim_End_Date__c, Claim_Start_Date__c FROM Claim__c WHERE Id=: recordId];
	    	Account acc = [SELECT Id, Channel_Id__c FROM Account WHERE Id =: claim.Account__c];
	        List<Claim_Item__c> claimitem = [SELECT Id, Control_Number__c, Claim__c FROM Claim_Item__c WHERE Claim__c =: claim.Id];
	        Set<Id> IdSet = new Set<Id>();
	        
	        for (Claim_Item__c ci: claimitem) {
	        	IdSet.add(ci.Control_Number__c);
	        }
	        
	        List<Control_Number__c> cnList = [SELECT Id, Account__c, SKU__c FROM Control_Number__c WHERE Id IN: IdSet];
	        Set<Id> accIdSet = new Set<Id>();
	        
	        for (Control_Number__c cn: cnList) {
	        	accIdSet.add(cn.Account__c);
	        }
	        //accIdSet.remove(claim.Account__c);
	        distributorAcc = [SELECT Id, Channel_Id__c FROM Account WHERE Id IN: accIdSet];
	        
	        Http h = new Http();
			HttpRequest req = new HttpRequest();
			
			Map<String, POS_Custom_Setting__c> posMap = POS_Custom_Setting__c.getAll();
			POS_Custom_Setting__c posReq = posMap.get('Request');
			req.setEndpoint(posReq.URL__c);
			req.setMethod('POST');
			req.setHeader('Content-Type', 'application/json');
			
			String uname = posReq.Username__c;
			String token = posReq.Password__c;
			
			Blob headerValue = Blob.valueOf(uname + ':' + token); 
			//Password Auth 
			String authorizationHeader = 'BASIC ' + EncodingUtil.base64Encode(headerValue);
			
			req.setHeader('Authorization', authorizationHeader);
			
			fromJSON reqBody = new fromJSON();
			
			Datetime startdt = datetime.newInstance(claim.Claim_Start_Date__c.year(), claim.Claim_Start_Date__c.month(),claim.Claim_Start_Date__c.day());
			Datetime enddt = datetime.newInstance(claim.Claim_End_Date__c.year(), claim.Claim_End_Date__c.month(),claim.Claim_End_Date__c.day());
			
			reqBody.startDate = '/Date(' + String.ValueOf(startdt.getTime()) + ')/';
			reqBody.endDate = '/Date(' + String.ValueOf(enddt.getTime()) + ')/';
			
			if (distributorAcc.size() == 1) {
				reqBody.channelId = distributorAcc[0].Channel_Id__c;
				if (distributorAcc[0].Id == acc.Id) {
					reqBody.retailerId = null;
				} else {
					reqBody.retailerId = acc.Channel_Id__c;
				}
			}
			reqBody.sku = new List<String>();
			 
			for (Control_Number__c cn: cnList) {
				reqBody.sku.add(cn.SKU__c);
			}
			
			String requestBody = JSON.serialize(reqBody);
			
			System.debug('**** body = ' + requestBody); 
			
			
			req.setBody(requestBody); 
			
			//HttpResponse res;
			if (Test.isRunningTest()) {
				Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
			}
						
			
			HttpResponse res = h.send(req);
			System.debug('response = ' + res.getStatus() + '  ' + res.getBody());
			
			JSONParser parser = JSON.createParser(res.getBody());
			
			POSresponseList posDataList = (POSresponseList)parser.readValueAs(POSresponseList.class);
			
			System.debug('**** posDataList = ' + posDataList);
			
			for (POSobject cur : posDataList.GetWeeklyPosDataByChannelResult) {
				POS__c posnode = new POS__c();
				posnode.Channel_Id__c = cur.ChannelId;
				posnode.Current_Store_Count__c = cur.CurrentStoreCount;
				String newEnd = cur.EndDate.substring(cur.EndDate.indexOf('(', 0), cur.EndDate.indexOf('-', 0));
				DateTime edt = datetime.newInstance(Long.ValueOf(newEnd.substring(1)));
				posnode.End_Date__c = date.newinstance(edt.year(), edt.month(), edt.day());
				posnode.Item__c = cur.Item;
				posnode.Model__c = cur.Model;
				posnode.On_Hand_Quantity__c = cur.OnHandQty;
				posnode.Retailer_Id__c = cur.RetailerId;
				posnode.Return_Quantity__c = cur.ReturnQty;
				posnode.SKU__c = cur.SKU;
				posnode.Sell_Through__c = cur.SellThruQty;
				String newStart = cur.StartDate.substring(cur.StartDate.indexOf('(', 0), cur.StartDate.indexOf('-', 0));
				
				DateTime sdt = datetime.newInstance(Long.ValueOf(newStart.substring(1)));
				posnode.Start_Date__c = date.newinstance(sdt.year(), sdt.month(), sdt.day());
				posnode.Traited_Store__c = cur.TraitedStoreCount;
				posnode.Week__c = cur.Week;
				posnode.Year__c = String.ValueOf(cur.Year);
				posList.add(posnode);
			}
			if (posList.isEmpty()) {
				ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.CONFIRM, 'No POS for this Claim record.'));
			}
			return posList;
    	} catch (Exception e) {
    		ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.WARNING, 'The system took too long to respond. Please try again.'));
    		return posList;
    	}
    }
    
    public PageReference getSetCon() {
    	newPosList = getPos().deepclone(true,true,true);
    	setCon = new ApexPages.StandardSetController(newPosList);
		setCon.setPageSize(showSize);
        setCon.setpageNumber(setCon.getResultSize());
    	return null;
    }
    
    public List<POS__c> getShowList() {
    	List<POS__c> showPosList = new List<POS__c>();
    	
    	for (sObject s: setCon.getRecords()) {
            POS__c p = (POS__c)s;
    		showPosList.add(p);
    	}
    	return showPosList;
    }
    
    /**
     * The link for go next page
     *
     * @param       None
     * @return      True or False for VF has next page 
     * @since       1.0
     */ 
    public Boolean hasNext {
        get {
            return setCon.getHasNext();
        }
        set;
    }
    
    /**
     * The link for go previous page
     *
     * @param       None
     * @return      True or False for VF has previous page 
     * @since       1.0
     */ 
    public Boolean hasPrevious {
        get {
            return setCon.getHasPrevious();
        }
        set;
    }
    
    /**
     * The page number
     *
     * @param       None
     * @return      True or False for VF show the page number tag
     * @since       1.0
     */ 
    public Boolean hasPage {
        get {
            if (getTotalPages() == 0) {
                return false;
            }
            else {
                return true;
            }
        }
        set;
    }
    
    /**
     * The current page number
     *
     * @param       None
     * @return      Current page number
     * @since       1.0
     */ 
    public Integer pageNumber {
        get {
            return setCon.getPageNumber();
        }
        set;
    }
    /**
     * The link for go previous page
     *
     * @param       None
     * @return      None
     * @since       1.0
     */ 
    public void previous() {
        if (setCon.getHasPrevious())
            setCon.previous();
    }
  
    /**
     * The link for go next page
     *
     * @param       None
     * @return      None
     * @since       1.0
     */ 
    public void next() {
        if (setCon.getHasNext())
            setCon.next();
    }
    
    /**
     * Show the all page number
     *
     * @param       None
     * @return      Total page number
     * @since       1.0
     */ 
    public Integer getTotalPages(){
 
        Decimal totalSize = setCon.getResultSize();
        Decimal pageSize = setCon.getPageSize();
 
        Decimal pages = totalSize/pageSize;
        return (Integer)pages.round(System.RoundingMode.CEILING);
    }
    
    public void clickLink() {
    	QuickSort(newPosList, 0, posList.size()-1, sortExpression, sortDirection);
    	setCon = new ApexPages.StandardSetController(newPosList);
		setCon.setPageSize(showSize);
        setCon.setpageNumber(setCon.getResultSize());
    }
    
    private integer Partition(List<POS__c> pList, integer left, integer right, String type, String Dir) {
        integer i = left;
        integer j = right;
        POS__c tmp;
        POS__c pivot = pList[(left+right)/2];
        
        while (i<=j) {
            if (type == 'Model') {
                if (Dir == 'ASC') {
                    while (pList[i].Model__c < pivot.Model__c) {
                        i++;
                    }
                    while (pList[j].Model__c > pivot.Model__c) {
                        j--;
                    }
                } else {
                    while (pList[i].Model__c > pivot.Model__c) {
                        i++;
                    }
                    while (pList[j].Model__c < pivot.Model__c) {
                        j--;
                    }
                }
            } else if (type == 'Start Date') {
                if (Dir == 'ASC') {
                    while (pList[i].Start_Date__c < pivot.Start_Date__c) {
                        i++;
                    }
                    while (pList[j].Start_Date__c > pivot.Start_Date__c) {
                        j--;
                    } 
                } else {
                    while (pList[i].Start_Date__c > pivot.Start_Date__c) {
                        i++;
                    }
                    while (pList[j].Start_Date__c < pivot.Start_Date__c) {
                        j--;
                    }
                }
            } else if (type == 'End Date') {
                if (Dir == 'ASC') {
                    while (pList[i].End_Date__c < pivot.End_Date__c) {
                        i++;
                    }
                    while (pList[j].End_Date__c > pivot.End_Date__c) {
                        j--;
                    } 
                } else {
                    while (pList[i].End_Date__c > pivot.End_Date__c) {
                        i++;
                    }
                    while (pList[j].End_Date__c < pivot.End_Date__c) {
                        j--;
                    }
                }
            } else if (type == 'Sell Through') {
                if (Dir == 'ASC') {
                    while (pList[i].Sell_Through__c < pivot.Sell_Through__c) {
                        i++;
                    }
                    while (pList[j].Sell_Through__c > pivot.Sell_Through__c) {
                        j--;
                    } 
                } else {
                    while (pList[i].Sell_Through__c > pivot.Sell_Through__c) {
                        i++;
                    }
                    while (pList[j].Sell_Through__c < pivot.Sell_Through__c) {
                        j--;
                    }
                }
            } else if (type == 'On Hand Quantity') {
                if (Dir == 'ASC') {
                    while (pList[i].On_Hand_Quantity__c < pivot.On_Hand_Quantity__c) {
                        i++;
                    }
                    while (pList[j].On_Hand_Quantity__c > pivot.On_Hand_Quantity__c) {
                        j--;
                    } 
                } else {
                    while (pList[i].On_Hand_Quantity__c > pivot.On_Hand_Quantity__c) {
                        i++;
                    }
                    while (pList[j].On_Hand_Quantity__c < pivot.On_Hand_Quantity__c) {
                        j--;
                    }
                }
            } 
            
            if (i <= j) {
                tmp = pList[i];
                pList[i] = pList[j];
                pList[j] = tmp;
                i++;
                j--;
            }
        }
        return i; 
    }
    /*quick sort function*/
    private void QuickSort(List<POS__c> pList, integer left, integer right, String type, String Dir) {
        integer index = Partition(pList, left, right, type, Dir);
        if (left < index-1) {
            quickSort(pList, left, index-1, type, Dir);
        }
        if (index < right) {
            quickSort(pList,index, right, type, Dir);
        }
    }
}