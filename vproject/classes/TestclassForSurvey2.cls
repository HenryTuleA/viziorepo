/**
 * Test class to test the class named Survey 
 *
 * @author		Hay Mun Win
 * @version		1.0
 * @since		1.0
 */
 @isTest 
public with sharing class TestclassForSurvey2 {
	
 /**
     * method to test the Survey2
     *
     * @param			None	  
     * @return			None
     * @since			1.0
     */
     
     static testMethod void myTestClassforSurvey2(){     	
     	 
     	  	
     	
     	
     	Contact contact1 =new Contact(LastName='Solo',FirstName='Han',Email='win.haymun@gmail.com', RecordTypeId ='012170000004b5h');
     	insert contact1;
     	
     	Case case1 = new Case(Contactid = contact1.Id, RecordTypeId='0121a0000001qp9',Origin='Web', Status='New');
     	insert case1; 
     	
     	/*System.debug('case id ' + case1.id);
     	System.debug('contact id '+contact1.id);*/    	
     	
     	
     	PageReference testsurvey = Page.Survey2;
     	Test.setCurrentPage(testsurvey);
     	ApexPages.currentPage().getParameters().put('caseid',case1.id); 
     	Survey2 survey1 = new Survey2();    
     	survey1.getStep();

     	survey1.submit();
     	     	
     }
}