/**
 * Test class to test the class named searchKnowledgeArticle.cls
 *
 * @author		Xin Zhang
 * @version		1.0
 * @since		1.0
 */
 
@isTest (SeeAllData=true)
private class TestClassSearchKnowledgeArticle {
	
	/**
     * method to test the searchKnowledgeArticle seachString = null 
     *
     * @param			None	  
     * @return			None
     * @since			1.0
     */
	static testMethod void myTestSearch() { 
	    
		searchKnowledgeArticle testSearchArticle = new searchKnowledgeArticle();
    	PageReference testSearch = Page.searchKnowledgeArticle;
    	  	
    	Test.setCurrentPage(testSearch);
    	testSearchArticle.searchArticle();
    	testSearchArticle.getArticles();
    	testSearchArticle.first();
    	testSearchArticle.last();
    	testSearchArticle.next();
    	Integer pageNumber = testSearchArticle.pageNumber;
    	Boolean hasNext = testSearchArticle.hasNext;
    	Boolean hasPrevious = testSearchArticle.hasPrevious;  	
    	testSearchArticle.previous();
    	testSearchArticle.clickPage = '1';
    	testSearchArticle.clickPageNum();
    	
    	
	}
	
	/**
     * method to test the searchKnowledgeArticle seachString != null
     *
     * @param			None	  
     * @return			None
     * @since			1.0
     */
	static testMethod void myTestSearchWithString() { 
	    
		searchKnowledgeArticle testSearchArticle = new searchKnowledgeArticle();
    	PageReference testSearch = Page.searchKnowledgeArticle;
    	  	
    	Test.setCurrentPage(testSearch);
    	testSearchArticle.searchstring = 'how';
    	testSearchArticle.searchArticle();
    	testSearchArticle.getArticles();
    	testSearchArticle.first();
    	testSearchArticle.last();
    	testSearchArticle.next();
    	Integer pageNumber = testSearchArticle.pageNumber;
    	Boolean hasNext = testSearchArticle.hasNext;
    	Boolean hasPrevious = testSearchArticle.hasPrevious;    	
    	testSearchArticle.previous();
    	testSearchArticle.clickPage = '1';
    	testSearchArticle.clickPageNum();  	
	}		
}