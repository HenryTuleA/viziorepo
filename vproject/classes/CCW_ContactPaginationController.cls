public with sharing class CCW_ContactPaginationController {
 
    /*
    *   item in context from the page
    */
    public String contextItem{get;set;}
 
    /*
    *   set controller
    */
    private ApexPages.StandardSetController setCon;
 
    /*
    *   the contact ids selected by the user
    */
    private Set<Id> selectedContactIds;
    
    public List<Case> CaseList {get;set;}
    
    public Case Individual{get;set;}
    
    public  List<Case> statusSearch {get;set;}
    
    public Case aCase {get;set;}
    
    public Case dummy {get;set;}
    
    public string statusf {get;set;}
    
    private String currentStep;
    private final PageReference fromPage;
    
    public Date startDate {get;set;}
    public Date endDate {get;set;}
    
  
    /*
    *   constructor
    */
    public CCW_ContactPaginationController (ApexPages.StandardSetController controller) {
        //init variable
        this.selectedContactIds= new Set<Id>();
 		CaseList = new List<Case>();
 		statusSearch =new List<Case>();
 		aCase = new Case(); 	
 		dummy = new Case();	
 		statusf=''; 
        //gather data set
        this.setCon= new ApexPages.StandardSetController( [SELECT Id, Status, Ownerid  FROM Case] );
        this.setCon.setpageNumber(1);
        this.setCon.setPageSize(10);
      //  startDate=null;
        //endDate = null;
         currentStep = '0';
       fromPage = setCon.cancel();
 		startDate = date.today();
    }
    
    public String getStep() {
		return currentStep;
	}
	
	public PageReference cancel() {
        return fromPage;
    }
    
    //for current page
     public PageReference step0() {
     	currentStep ='0';
     	return ApexPages.currentPage();
     
     }
     
     //searched page
     public PageReference step11() {
     	currentStep ='11';
     	//statusf = Apexpages.currentPage().getParameters().get('statusField');
     	statusf = aCase.status;
     	System.debug(statusf);
     	//createfield =aCase.CreatedDate; 
     	return ApexPages.currentPage();
     
     }
     
   

    public PageReference step1() { 
    	currentStep='1';   	     
        return ApexPages.currentPage();
    }
    
    public PageReference step2() {
     //   if(getRecordSize()<1) return fromPage;      
    	currentStep='2';   	     
        return ApexPages.currentPage();
    }
    
    public PageReference step3() {
        //currentMsg = new ApexPages.Message(ApexPages.severity.INFO, getFieldInfoToDisplay());
       // ApexPages.addMessage(currentMsg);
        currentStep='3';   	     
        return ApexPages.currentPage();
    } 
  
  /**
    public PageReference step4() {
   //     convertedFieldData = convertUserInputToFieldData();
        
         data type validation
        if (currentMsg!=null) {
            ApexPages.Message msg = new ApexPages.Message(ApexPages.severity.INFO, getFieldInfoToDisplay());
            ApexPages.addMessage(msg);
            ApexPages.addMessage(currentMsg);
            return ApexPages.currentPage();
        }
        
        String msg = 'Please review your selections before confirm: <br></br>'; 
        msg = msg + '<br><b>Records Selected:</b>    ' + getRecordSize() +'</br>';
        msg = msg + '<br><b>Field To Be Updated:</b> ' + fieldName + '</br>';
        msg = msg + '<br><b>New Value:</b>           ' + convertedFieldData + '</br>';
        currentMsg = new ApexPages.Message(ApexPages.severity.INFO, msg);
        ApexPages.addMessage(currentMsg);
        currentStep='4';   	     
        return ApexPages.currentPage();
    } 
      
    public PageReference step5() {
        currentMsg = (new MassUpdater(objs, field, convertedFieldData)).massUpdate();
        ApexPages.addMessage(currentMsg); 
        currentStep='5';   	     
        return ApexPages.currentPage();
    }
 **/
    /*
    *   handle item selected
    */
    public void doSelectItem(){
 
        this.selectedContactIds.add(this.contextItem);
        
    }
 
    /*
    *   handle item deselected
    */
    public void doDeselectItem(){
 
        this.selectedContactIds.remove(this.contextItem);
    }
 
    /*
    *   return count of selected items
    */
    public Integer getSelectedCount(){
 
        return this.selectedContactIds.size();
 
    }
    
    
    //now selecting everything... run this method only after confirm
    public List<Case> getAddedCount(){
    	
    	
    	CaseList = [Select Id, Status From Case where Id in:selectedContactIds];
    	
    	
    	return CaseList;
    }
 
    /*
    *   advance to next page
    */
    public void doNext(){
 
        if(this.setCon.getHasNext())
            this.setCon.next();
 
    }
 
    /*
    *   advance to previous page
    */
    public void doPrevious(){
 
        if(this.setCon.getHasPrevious())
            this.setCon.previous();
 
    }
    
    
    
    
    public List<Case> getrunSearch(){
    	
    	 //string statusSearch1 =  '[SELECT Id, Status, Ownerid  FROM Case where Status ='+ statusf+']';
    	//statusSearch = database.query(statusSearch1);
    	statusSearch= [SELECT Id, Status, Ownerid  FROM Case where Status=:statusf] ;
    	return statusSearch;
    }
 
    /*
    *   return current page of groups
    */
    public List<CCWRowItem> getCaselets(){
 
        List<CCWRowItem> rows = new List<CCWRowItem>();
 
        for(sObject r : this.setCon.getRecords()){
            Case c = (Case)r;
 
            CCWRowItem row = new CCWRowItem(c,false);
            if(this.selectedContactIds.contains(c.Id)){
                row.IsSelected=true;
            }
            else{
                row.IsSelected=false;
            }
            rows.add(row);
        }
 
        return rows;
 
    }
 
 
   public List<CCWRowItem> getSearchCases(){
 
        List<CCWRowItem> rows = new List<CCWRowItem>();
 
        for(sObject r : this.getrunSearch()){
            Case c = (Case)r;
 
            CCWRowItem row = new CCWRowItem(c,false);
            if(this.selectedContactIds.contains(c.Id)){
                row.IsSelected=true;
            }
            else{
                row.IsSelected=false;
            }
            rows.add(row);
        }
 
        return rows;
 
    }
 
    
 
    /*
    *   return whether previous page exists
    */
    public Boolean getHasPrevious(){
 
        return this.setCon.getHasPrevious();
 
    }
 
    /*
    *   return whether next page exists
    */
    public Boolean getHasNext(){
 
        return this.setCon.getHasNext();
 
    }
 
    /*
    *   return page number
    */
    public Integer getPageNumber(){
 
        return this.setCon.getPageNumber();
 
    }
 
    /*
    *    return total pages
    */
    Public Integer getTotalPages(){
 
        Decimal totalSize = this.setCon.getResultSize();
        Decimal pageSize = this.setCon.getPageSize();
 
        Decimal pages = totalSize/pageSize;
 
        return (Integer)pages.round(System.RoundingMode.CEILING);
    }
 
    /*
    *   helper class that represents a row
    */
    public with sharing class CCWRowItem{
 
        public Case tContact{get;set;}
        public Boolean IsSelected{get;set;}
       
 
        public CCWRowItem(Case c, Boolean s){
            this.tContact=c;
            this.IsSelected=s;
        }
 
    }
}