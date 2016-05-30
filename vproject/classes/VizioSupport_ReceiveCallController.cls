public with sharing class VizioSupport_ReceiveCallController 
{
	
	
	
	public case case1 { get; set; }  
	public asset asset1 { get; set; }
	public contact contact1 { get; set; }
	
	private ID caseID;

	
	public VizioSupport_ReceiveCallController()
	{
		caseID = apexpages.currentpage().getparameters().get('cID');
		
		case1 = 
		[
			SELECT 	ID, Status, Serial_No__c, Product_Model_Number__c, contactID, assetID, Origin, 
					Problem_Detail__c, Resolution__c, Product_Category__c, Problem_Code_1__c, Problem_Code_2__c, Problem_Code_3__c
			FROM 	Case
			WHERE 	ID =: caseID
		];
		
		
		contact1 = 
		[
			SELECT ID, FirstName, LastName, Email, Phone 
			FROM contact
			WHERE ID =: case1.contactID
		];
		
		asset1 =
		[
			SELECT ID, Asset_Notes__c
			FROM asset
			WHERE ID =: case1.assetID
		];

		case1.Status = 'Closed';
		
	}
	
	
	public PageReference save()
    {
    	update case1;
    	update asset1;
    	
    	PageReference pageRef = new PageReference('/' + caseID);
        return pageRef;    
    }
	
}