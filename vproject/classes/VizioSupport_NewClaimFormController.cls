public with sharing class VizioSupport_NewClaimFormController 
{
    
    public Contact contact1 { get; set; }
    public Asset asset1 { get; set; }
    public VASP_Claims__c vclaim1 { get; set; }
    
    public VizioSupport_NewClaimFormController()
    {
    	contact1 = new Contact();
    	asset1 = new Asset();
    	vclaim1 = new VASP_Claims__c();
    	
    }
    
}