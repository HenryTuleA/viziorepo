public with sharing class NewCase{

/***StandardController****/
  private ApexPages.StandardController standardController;
  public case c{get;set;}
  public String Case_Status{get;set;} 
  
  
  /****************Constructor with Standard controller extensions*****************/
  public NewCase(ApexPages.StandardController standardController ){
  this.standardController = standardController;
      c = new case();  
  }
  
  
  public List<SelectOption> getStatus() {
        List<SelectOption> options = new List<SelectOption>();
        options.add(new SelectOption('Closed','Closed'));
        options.add(new SelectOption('New','New'));
        return options;
    }   
  
   public void Submit() {  
   
       c.Status = 'New'; 
       c.Reason =ApexPages.currentPage().getParameters().get('Case Reason');  
       c.Origin =ApexPages.currentPage().getParameters().get('Case Origin');
       insert c;  
       
     System.debug ('c.Status');
    }
    
    
  
 }
  
  
  


/*********************Method for Save button***********************/  
/*****************Update the status and go back to detail page**********************/
/*****
  public PageReference UpdateStatus(){
  Id recordId = standardController.getId();
  Case record = (Case) standardController.getRecord();
  system.debug(record );
  record.status = 'Work in Progress';
  update record ;
  
  // this section will redirect to the detail page after saving
  
   PageReference casePage = new ApexPages.StandardController(record ).view();
       casePage.setRedirect(true);
  return casePage ;
  }
  
}**/