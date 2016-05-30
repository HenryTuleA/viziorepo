public class CaseReopen{

/***StandardController****/
  private ApexPages.StandardController standardController;
  public Case c{get;set;}
  public String Case_Status{get;set;} 
  
  
  /****************Constructor with Standard controller extensions*****************/
  public CaseReopen(ApexPages.StandardController standardController ){
  this.standardController = standardController;
      c = new Case();  
  }
  
  

/*********************Method for Save button***********************/  
/*****************Update the status and go back to detail page**********************/

  public PageReference UpdateStatus(){
  Id recordId = standardController.getId();
  Case record = (Case) standardController.getRecord();
  system.debug(record );
  record.status = 'Work in Progress';
  update record ;
  
  /** this section will redirect to the detail page after saving**/
  /*****
  ****
  *****/
   PageReference casePage = new ApexPages.StandardController(record ).view();
       casePage.setRedirect(true);
  return casePage ;
  }
  
}