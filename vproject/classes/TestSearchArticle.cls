/**
 * Test class to test the class named vfKeywordSearchController.cls
 *
 * @author		Xin Zhang
 * @version		1.0
 * @since		1.0
 */
 
@isTest (SeeAllData=false)
private class TestSearchArticle {
	
	/**
     * method to test the vfKeywordSearchController
     *
     * @param			None	  
     * @return			None
     * @since			1.0
     */
	static testMethod void myTestSearch() { 
	    
	    PageReference testSearchPage = Page.SearchArticle;
	    
	    Test.setCurrentPage(testSearchPage);
	    vfKeywordSearchController testSearch = new vfKeywordSearchController();
	    testSearch.searchArticle();
    	testSearch.getCurrentPageNumber();
        testSearch.getNextRequired();
        testSearch.getPrevRequired();
        testSearch.next();
        testSearch.previous();
    	
    	Test.setCurrentPage(testSearchPage);
    	ApexPages.currentPage().getParameters().put('language','en_CA'); 
    	vfKeywordSearchController testen_CA = new vfKeywordSearchController();
    	Test.setCurrentPage(testSearchPage);
    	ApexPages.currentPage().getParameters().put('language','en_ca'); 
    	vfKeywordSearchController testen_ca1 = new vfKeywordSearchController();
    	Test.setCurrentPage(testSearchPage);
    	ApexPages.currentPage().getParameters().put('language','fr_ca'); 
    	vfKeywordSearchController testfr_ca = new vfKeywordSearchController();
        Test.setCurrentPage(testSearchPage); 
    	ApexPages.currentPage().getParameters().put('language','fr_CA'); 
    	vfKeywordSearchController testfr_CA1 = new vfKeywordSearchController();
    	Test.setCurrentPage(testSearchPage);
    	ApexPages.currentPage().getParameters().put('language','es_MX'); 
    	vfKeywordSearchController testes_MX = new vfKeywordSearchController();
    	Test.setCurrentPage(testSearchPage);
    	ApexPages.currentPage().getParameters().put('language','es_mx'); 
    	vfKeywordSearchController testes_mx1 = new vfKeywordSearchController();
    	Test.setCurrentPage(testSearchPage);
    	ApexPages.currentPage().getParameters().put('language','en_us'); 
    	vfKeywordSearchController testen_us = new vfKeywordSearchController();
    	Test.setCurrentPage(testSearchPage);
    	ApexPages.currentPage().getParameters().put('language','en_US'); 
    	vfKeywordSearchController testen_US1 = new vfKeywordSearchController();
    	
	    
		
    	
	}
}