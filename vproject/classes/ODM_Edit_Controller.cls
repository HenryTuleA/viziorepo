public class ODM_Edit_Controller {

    public ODM_Partner__c odm {get; set;}
    public String oId = ApexPages.currentpage().getParameters().get('id');
    public String vId = ApexPages.currentpage().getParameters().get('retURL');

    public ODM_Edit_Controller(ApexPages.StandardController stdCtrl) {
        this.odm = (ODM_Partner__c)stdCtrl.getRecord();
    }

    public PageReference save() {
        if (odm.Mark_Up_Percentage__c != NULL && odm.Margin_Percentage__c != NULL) {
            ApexPages.Message msg = new Apexpages.Message(ApexPages.Severity.Error,'An ODM Partner is not allowed to have both "Mark Up %" and "Margin %" entries. Please correct your entry.');
            ApexPages.addMessage(msg);
            return null;
        }
        else if (odm.Mark_Up_Percentage__c == NULL && odm.Margin_Percentage__c == NULL) {
            ApexPages.Message msg = new Apexpages.Message(ApexPages.Severity.Error,'Either "Mark Up %" or "Margin %" must be completed to save this ODM Partner.');
            ApexPages.addMessage(msg);
            return null;
        }
        upsert this.odm;
        return new PageReference('/' + vId);
    }
}