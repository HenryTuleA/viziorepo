public with sharing class SelectControlNumber{
    
    
    public List<conNumWrapper> wrapList {get;set;}
    public Claim__c claim {get;set;}
    public Integer index {get;set;}
    public List<Claim_Item__c> claimItemList {get;set;}
    public boolean controlNumberPage {get;set;}
    public boolean claimItemPage {get;set;}
    public boolean claimPage {get;set;}
    public boolean errorPage {get;set;}
    public boolean readOnlyClaimPage {get;set;}
    public List<Control_Number__c> selectControlNumList {get;set;}
    public List<List<SelectOption>> claimTypeList {get;set;}
    public Integer showSize {get;set;}
    public Integer noOfRecords {get; set;}
    public String keyword {get;set;}
    public Claim__c savedClaim {get;set;}
    public Boolean internalUser {get;set;}
    private String sortDirection {get;set;}
    private String sortExp {get;set;}
    private Integer size {get;set;}
    private User loginUser {get;set;}
    private Account acc {get;set;}
    private List<AccountPartner__c> partnerAccList {get;set;}
    private Set<Id> accIdSet {get;set;}
    @TestVisible private List<conNumWrapper> allWrapList {get;set;}
    @TestVisible private Claim_Item__c savedClaimItem {get;set;}
    
    
    public SelectControlNumber(ApexPages.StandardController stdController) {
        controlNumberPage = true;
        claimItemPage = false;
        claimPage = false;
        errorPage = false;
        readOnlyClaimPage = false;
        allWrapList = new List<conNumWrapper>();
        accIdSet = new Set<Id>();
        sortDirection = 'DESC';
        sortExp = 'Event_Start_Date__c';
        internalUser = false;
        
        try {
            savedClaimItem = (Claim_Item__c)stdController.getRecord();
            savedClaim = [SELECT Id, Co_Op__c, Claim_Start_Date__c, Claim_End_Date__c, Claim_Name__c, Status__c, Account__c, Claim_Type__c FROM Claim__c WHERE Id =: savedClaimItem.Claim__c];
            if (savedClaim.Status__c != 'Draft') {
                controlNumberPage = false;
                claimItemPage = false;
                claimPage = false;
                errorPage = true;
                readOnlyClaimPage = false;
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'This Claim has been locked. Please contact the System Administrator.'));
                //return null;
            }
            
        } catch (Exception e) {}
        //ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, savedClaim + ' Please ' + savedClaimItem.Claim__c));
        
        try {
            loginUser = [SELECT AccountId, Id, UserType FROM User WHERE Id =: UserInfo.getUserId()];
            if (loginUser.UserType == 'PowerPartner') {
                acc = [SELECT Id, Channel_Id__c FROM Account WHERE Id =: loginUser.AccountId];
                partnerAccList = [SELECT Id, Main_AccountId__c FROM AccountPartner__c WHERE Partner_AccountId__c =: acc.Id AND Partner_Type__c = 'VAR/Reseller'];
                accIdSet.add(acc.Id);
                for (AccountPartner__c a: partnerAccList) {
                    accIdSet.add(a.Main_AccountId__c);
                }
            } else {
                internalUser = true;
            }
        } catch (Exception e) {
            controlNumberPage = false;
            claimItemPage = false;
            claimPage = false;
            errorPage = true;
            readOnlyClaimPage = false;
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'This account is not associated to any partner Community.Please contact the System Administrator.'));
            //return null;
            //throw new CommonException('This account is not associate to any parter Community.Please contact the System Administrator.');
            //System.assert(false);
        }
    }
    
    public class CommonException extends Exception {}
    
    public ApexPages.StandardSetController setCon {
        get {
            try {
                //loginUser = [SELECT AccountId, Id FROM User WHERE Id =: UserInfo.getUserId()];
                if(setCon == null){
                    //System.debug('Search ' + accIdSet);
                    showSize = 25;
                    string sortFullExp = sortExpression  + ' ' + sortDirection;
                    //ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Please ' + sortFullExp));
                    if (keyword == null || keyword == '') {
                        string queryString;
                        if (internalUser) {
                            queryString = 'SELECT Id, Control__c, SKU__c, Price_Type__c, BSTC_Amount__c, PPSTC_Amount__c, Event_Start_Date__c, Event_End_Date__c, Account__c FROM Control_Number__c WHERE Status__c = \'Accepted by Channel\' ORDER BY ' + sortFullExp;
                        } else {
                            queryString = 'SELECT Id, Control__c, SKU__c, Price_Type__c, BSTC_Amount__c, PPSTC_Amount__c, Event_Start_Date__c, Event_End_Date__c, Account__c FROM Control_Number__c WHERE Account__c IN: accIdSet AND Status__c = \'Accepted by Channel\' ORDER BY ' + sortFullExp;
                        }
                        setCon = new ApexPages.StandardSetController(Database.getQueryLocator(queryString));
                    } else {
                        string queryString;
                        String key = '%' +keyword+ '%';
                        if (internalUser) {
                            queryString = 'SELECT Id, Control__c, SKU__c, Price_Type__c, BSTC_Amount__c, PPSTC_Amount__c, Event_Start_Date__c, Event_End_Date__c, Account__c FROM Control_Number__c WHERE (Control__c LIKE \'' + key + '\' OR SKU__c LIKE \'' + key + '\') AND Status__c = \'Accepted by Channel\' ORDER BY ' + sortFullExp;
                        } else {
                            queryString = 'SELECT Id, Control__c, SKU__c, Price_Type__c, BSTC_Amount__c, PPSTC_Amount__c, Event_Start_Date__c, Event_End_Date__c, Account__c FROM Control_Number__c WHERE Account__c IN: accIdSet AND (Control__c LIKE \'' + key + '\' OR SKU__c LIKE \'' + key + '\') AND Status__c = \'Accepted by Channel\' ORDER BY ' + sortFullExp;
                        }
                        setCon = new ApexPages.StandardSetController(Database.getQueryLocator(queryString));
                    }
                    
                    setCon.setPageSize(showSize);
                    noOfRecords = setCon.getResultSize();
                }
                return setCon;
            } catch (Exception e) {
                controlNumberPage = false;
                claimItemPage = false;
                claimPage = false;
                errorPage = true;
                readOnlyClaimPage = false;
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'This account is not associated to any partner Community.Please contact the System Administrator.'));
                //throw new CommonException('This account is not associate to any parter Community.Please contact the System Administrator.');
                //System.assert(false);
                return null;
            }
        } set;
    }
    
    public List<conNumWrapper> getWrapperList() {
        wrapList = new List<conNumWrapper>();
        
        for (Control_Number__c cn: (List<Control_Number__c>)setCon.getRecords()) {
            boolean isInclude = false;
            for (conNumWrapper wrap: allWrapList) {
                if (wrap.conNum.Id == cn.Id) {
                    isInclude = true;
                }
            }
            if (isInclude == false) {
                allWrapList.add(new conNumWrapper(cn));
                wrapList.add(new conNumWrapper(cn));
            } else {
                for (conNumWrapper wrap: allWrapList) {
                    if (wrap.conNum.Id == cn.Id) {
                        wrapList.add(wrap);
                    }
                }
            }
            
        }
        return wrapList;
    }
    
    public PageReference goSearch() {
        setcon = null;
        return null;
    }
    
    public PageReference clickLink() {
        setcon = null;
        return null;
    }
     
    public Boolean hasNext {
        get {
            return setCon.getHasNext();
        }
        set;
    }
    public Boolean hasPrevious {
        get {
            return setCon.getHasPrevious();
        }
        set;
    }
  
    public Integer pageNumber {
        get {
            return setCon.getPageNumber();
        }
        set;
    }
  
    public void first() {
        setCon.first();
    }
  
    public void last() {
        setCon.last();
    }
  
    public void previous() {
        setCon.previous();
    }
  
    public void next() {
        setCon.next();
    }
    
    /*get & set the Expression for sort*/
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
    
    public PageReference goToClaimItemPage() {
        selectControlNumList = new List<Control_Number__c>();
        claimItemList = new List<Claim_Item__c>();
        claimTypeList = new List<List<SelectOption>>();
        index = 0;
        for (conNumWrapper snw: allWrapList) {
            if (snw.isSelect == true) {
                selectControlNumList.add(snw.conNum);
            }
        }
        size = selectControlNumList.size();
        for (Control_Number__c conNum: selectControlNumList) {
            List<SelectOption> soList = new List<SelectOption>();
            Claim_Item__c claimItem = new Claim_Item__c();
            claimItem.Control_Number__c = conNum.Id;
            claimItemList.add(claimItem);
            if (conNum.Price_Type__c == 'ED' || conNum.Price_Type__c == 'LP') {
            	//Eliminating Claim Type availability if amounts are 0
                if (conNum.PPSTC_Amount__c <= 0){
                    soList.add(New SelectOption('iVMP', 'iVMP'));
                }
                else if (conNum.BSTC_Amount__c <=0){
                    soList.add(New SelectOption('PP', 'PP'));
                }
                else {
                    soList.add(New SelectOption('PP', 'PP'));
                    soList.add(New SelectOption('iVMP', 'iVMP'));
                }
            } else if (conNum.Price_Type__c == 'EDNOP') {
                soList.add(New SelectOption('iVMP', 'iVMP'));
            } else {
                soList.add(New SelectOption('STC', 'STC'));
            }
            claimTypeList.add(soList);
        }
        if (size > 0) {
            
            controlNumberPage = false;
            claimItemPage = true;
            claimPage = false;
            errorPage = false;
            readOnlyClaimPage = false;
        } else {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Please select at least one Control Number.'));
        }
        return null;
    }
    
     public class conNumWrapper {
        
        public Control_Number__c conNum {get;set;}    
        public Boolean isSelect {get;set;}                     

        public conNumWrapper(Control_Number__c cn) {
            conNum = cn;
            isSelect = false;
        }
    }
    
    public PageReference goNext() {
        if ((claimItemList[index].Claim_Type_del__c == 'PP' 
                || claimItemList[index].Claim_Type_del__c == 'STC') 
                && (selectControlNumList[index].PPSTC_Amount__c == null
                || selectControlNumList[index].PPSTC_Amount__c <=0)) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'This Claim Type is not valid for this control number. Please select another Claim Type.'));
            return null;
        } else if (claimItemList[index].Claim_Type_del__c == 'iVMP' 
                && (selectControlNumList[index].BSTC_Amount__c == null
                || selectControlNumList[index].BSTC_Amount__c <= 0)) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'This Claim Type is not valid for this control number. Please select another Claim Type.'));
            return null;
        }
        
        if (claimItemList[index].Quantity_Claimed__c < 1) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Quantity must be greater than 0. Please enter a valid Quantity.'));
            return null;
        }
        
        if (index < size-1) {
            index++;
        } else if (savedClaim != null) {
            goToReadOnlyClaimPage();
        }else {
            goToClaimPage();
        }
        return null;
    }
    
    public PageReference goBack() {
        if (index > 0) {
            /*if ((claimItemList[index].Claim_Type_del__c == 'PP' 
                || claimItemList[index].Claim_Type_del__c == 'STC') 
                && selectControlNumList[index].PPSTC_Amount__c == null) {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'For this Claim Item, the Control Number PPSTC Amount is none. Please set the PPSTC Amount first or choose the other Claim Type.'));
                return null;
            } else if (claimItemList[index].Claim_Type_del__c == 'iVMP' 
                && selectControlNumList[index].BSTC_Amount__c == null) {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'For this Claim Item, the Control Number BSTC Amount is none. Please set the BSTC Amount first or choose the other Claim Type.'));
                return null;
            }*/
            index--;
        } else {
            index = 0;
            controlNumberPage = true;
            claimItemPage = false;
            claimPage = false;
            errorPage = false;
            readOnlyClaimPage = false;
        }
        return null;
    }
    
    public void goToClaimPage() {
        claim = new Claim__c();
        if (!internalUser) {
            claim.Account__c = loginUser.AccountId;
            claim.Claim_Name__c = acc.Channel_Id__c + '-' + claim.Name;
        }
        claim.Status__c = 'Draft';
        controlNumberPage = false;
        claimItemPage = false;
        claimPage = true;
        errorPage = false;
        readOnlyClaimPage = false;
    }
    
    public void goToReadOnlyClaimPage() {
        controlNumberPage = false;
        claimItemPage = false;
        claimPage = false;
        errorPage = false;
        readOnlyClaimPage = true;
    }
    
    public PageReference save() {
        try {
            PageReference pageRef;
            //Set<Id> cnAccIdSet = new Set<Id>();
            
            //getting list of accountpartners with claim as main_accountid
            //List<AccountPartner__c> apList1 = [SELECT Id, Partner_Type__c, Partner_AccountId__c, Main_AccountId__c FROM AccountPartner__c WHERE Main_AccountId__c =: savedclaim.Account__c];
            
            if (savedClaim == null) {
                if (claim.Claim_Type__c == null) {
                    claim.Claim_Type__c = claimItemList[0].Claim_Type_del__c;
                }
                for (Claim_Item__c ci: claimItemList) {
                    if (!claim.Claim_Type__c.contains(ci.Claim_Type_del__c)) {
                        claim.Claim_Type__c = claim.Claim_Type__c + ';' + ci.Claim_Type_del__c;
                    }
                }
                if (internalUser) {
                	Set<Id> partnerIdset = new Set<Id>();
                	partnerIdset.add(claim.Account__c);
                	
			        List<AccountPartner__c> apList1 = new List<AccountPartner__c>();
			        try {
			        	apList1 = [SELECT Id, Main_AccountId__c FROM AccountPartner__c WHERE Partner_AccountId__c =: claim.Account__c AND Partner_Type__c = 'VAR/Reseller'];
			        	for (AccountPartner__c ap: apList1) {
				        	partnerIdset.add(ap.Main_AccountId__c);
				        }
			        } catch (Exception e) {}
			        for (conNumWrapper snw: allWrapList) {
                		if (snw.isSelect == true && !partnerIdset.contains(snw.conNum.Account__c)) {
			            	ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR, 'The Account of Control Number(s) does not match the Claim Account.'));
		                	return null;
                		}
			        }
                }
                insert claim;
                Claim__c tempClaim = [SELECT Id, Name, Account__c FROM Claim__c WHERE Id =: claim.Id];
                if (!internalUser) {
                    claim.Claim_Name__c = acc.Channel_Id__c + '-' + tempClaim.Name;
                } else {
                    Account tempAcc = [SELECT Id, Channel_Id__c FROM Account WHERE Id =: tempClaim.Account__c];
                    claim.Claim_Name__c = tempAcc.Channel_Id__c + '-' + tempClaim.Name;
                }
                
                update claim;
                for (Claim_Item__c ci: claimItemList) {
                    ci.Claim__c = claim.Id;
                    //ci.Claim_Type_del__c = claim.Claim_Type__c;
                }
                System.debug('search123 query ' + claimItemList);
                insert claimItemList;
                pageRef = new PageReference('/' + claim.Id);
            } else {
            	if (internalUser) {
                	Set<Id> partnerIdset = new Set<Id>();
                	partnerIdset.add(savedClaim.Account__c);
                	
			        List<AccountPartner__c> apList1 = new List<AccountPartner__c>();
			        try {
			        	apList1 = [SELECT Id, Main_AccountId__c FROM AccountPartner__c WHERE Partner_AccountId__c =: savedClaim.Account__c AND Partner_Type__c = 'VAR/Reseller'];
			        	for (AccountPartner__c ap: apList1) {
				        	partnerIdset.add(ap.Main_AccountId__c);
				        }
			        } catch (Exception e) {}
			        for (conNumWrapper snw: allWrapList) {
                		if (snw.isSelect == true && !partnerIdset.contains(snw.conNum.Account__c)) {
			            	ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR, 'The Account of Control Number(s) does not match the Claim Account.'));
		                	return null;
                		}
			        }
                }
                if (savedClaim.Claim_Type__c == null) {
                    savedClaim.Claim_Type__c = claimItemList[0].Claim_Type_del__c;
                }
                for (Claim_Item__c ci: claimItemList) {
                    ci.Claim__c = savedClaim.Id;
                    if (!savedClaim.Claim_Type__c.contains(ci.Claim_Type_del__c)) {
                        savedClaim.Claim_Type__c = savedClaim.Claim_Type__c + ';' + ci.Claim_Type_del__c;
                    }
                    //ci.Claim_Type_del__c = claim.Claim_Type__c;
                }
                System.debug('search123 query ' + claimItemList);
                update savedClaim;
                insert claimItemList;
                pageRef = new PageReference('/' + savedClaim.Id);
            }
            //ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Confirm,'All the Claims and Claim Items have been created successfully'));
            
            return pageRef;
        } catch (Exception error) {
            controlNumberPage = false;
            claimItemPage = false;
            claimPage = false;
            errorPage = true;
            readOnlyClaimPage = false;
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR, 'You cannot create this new Claim. Please contact the System Administrator.'));
        }
        return null;
    }
    
    /*public PageReference saveAndSubmit() {
        try {
            claim.Status__c = 'Submited';
            if (claim.Claim_Type__c == null) {
                claim.Claim_Type__c = claimItemList[0].Claim_Type_del__c;
            }
            for (Claim_Item__c ci: claimItemList) {
                if (!claim.Claim_Type__c.contains(ci.Claim_Type_del__c)) {
                    claim.Claim_Type__c = claim.Claim_Type__c + ';' + ci.Claim_Type_del__c;
                }
            }
            upsert claim;
            for (Claim_Item__c ci: claimItemList) {
                ci.Claim__c = claim.Id;
                //ci.Claim_Type_del__c = claim.Claim_Type__c;
            }
            upsert claimItemList;
            PageReference pageRef = new PageReference('/' + claim.Id);
            return pageRef;
        } catch (Exception error) {
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR, 'Please select a correct Claim Type'));
            return null;
        }
    }*/
    
    public PageReference cancel() {
        Schema.DescribeSObjectResult r = Claim__c.sObjectType.getDescribe();
        String keyPrefix = r.getKeyPrefix();
        PageReference pageRef = new PageReference('/' + keyPrefix + '/o');
        return pageRef;
    }
    
    
}