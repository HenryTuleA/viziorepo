public with sharing class ErrorPageController{

    public ErrorPageController(ApexPages.StandardController controller) {

    }

    public ErrorPageController(ApexPages.StandardController stdController, String message) {
        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, message));
    }
    
    public PageReference cancelButton() {
        Schema.DescribeSObjectResult r = Claim__c.sObjectType.getDescribe();
        String keyPrefix = r.getKeyPrefix();
        PageReference pageRef = new PageReference('/' + keyPrefix + '/o');
        return pageRef;
    }

}