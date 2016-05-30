trigger CaseSR_approval on Service_Claim__c (after update) {



    for(Service_Claim__c UpdatedSC : Trigger.New){
    	
    	//if approved
    
        Asset AssetNew = new Asset();
        AssetNew.Name= UpdatedSC.Serial_No__c; 
        AssetNew.Product2Id = UpdatedSC.Model_No__c; 
        AssetNew.SerialNumber = UpdatedSC.Serial_No__c;
        AssetNew.ContactId=UpdatedSC.Contact__c; 
        AssetNew.PurchaseDate= UpdatedSC.Purchased_Date__c;
        //AssetNew. = UpdatedSC.Sold_To__c;					/*Purchase location is picklist and sold to is text*/
    	insert(AssetNew);
    	
        /* New Case*/
        Case caseNew = new Case();
        caseNew.Origin = 'Web';
        caseNew.Status ='New';								//Should be new or closed?
        caseNew.Priority ='Medium';
        caseNew.ContactId = UpdatedSC.Contact__c;
        caseNew.RecordTypeId = '0121a0000001qp9'; 			//Change it to going live
        caseNew.AssetId = AssetNew.Id;		
        caseNew.Notes__c =  UpdatedSC.Problem_Type__c + UpdatedSC.Problem_Description__c;
        insert(caseNew); 
        
        //caseNew.
        
        
        /*New SR*/
        Service_Request__c SRNew = new Service_Request__c();
        SRNew.Case__c = caseNew.Id;
        SRNew.AuthSRtype__c = 'a0v170000016WlH';		//hardcoding because no particular data to input yet
        SRNew.Error_Code__c = 'a0N170000038YwO';			//hardcoding dummy EC because no particular data to input yet
        SRNew.Internal_Notes__c = UpdatedSC.Problem_Type__c + UpdatedSC.Problem_Description__c;		//Temp Error Codes and problem type notes
        SRNew.Service_Provider__c = UpdatedSC.Account__c;
        insert(SRnew);
        
        System.debug('AssetNew ' + AssetNew);
        System.debug('Case ' + caseNew);
        
    }
    
    
    
   
    
}