/**
 * Test class to test the class named GetQuickText.cls
 *
 * @author		Xin Zhang
 * @version		1.0
 * @since		1.0
 */
 
@isTest (SeeAllData=false)
private class TestclassGetQuickText {
	
	/**
     * method to test the GetQuickText 
     *
     * @param			None	  
     * @return			None
     * @since			1.0
     */
	static testMethod void myTestSearch() { 
	    
	    QuickText newQuickText = new QuickText(Name = 'Add', Message = 'Address is here');
	    insert newQuickText;
	    
		GetQuickText testQuickText = new GetQuickText();
    	PageReference testPageQuickText = Page.GetQuickText;
    	  	
    	Test.setCurrentPage(testPageQuickText);
    	testQuickText.getQuickText();
    	testQuickText.sortExpression = null;
    	testQuickText.getSortDirection();
        testQuickText.sortExpression ='Name';
        testQuickText.setSortDirection('DESC');
    	
    	testQuickText.getSortDirection();
    	testQuickText.sortExpression ='Name';
    	testQuickText.setSortDirection('ASC');
    	testQuickText.getSortDirection();
    	testQuickText.goSearch();
    	testQuickText.clearSearch();
    	testQuickText.keyword = 'add';
    	testQuickText.goSearch();
    	testQuickText.first();
    	testQuickText.last();
    	Integer pageNumber = testQuickText.pageNumber;
    	Integer totalNumber = testQuickText.totalNumber;
    	Boolean hasNext = testQuickText.hasNext;
    	Boolean hasPrevious = testQuickText.hasPrevious;  	
    	testQuickText.next();
    	testQuickText.previous();
    	testQuickText.clickToSort();

    	
	}
}