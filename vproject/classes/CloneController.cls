public with sharing class CloneController {
	
	private ApexPages.StandardController stdController;
	private Claim__c newClaim = new Claim__c();
	private Claim__c currentClaim = new Claim__c();
	private string oldStatus;
	List <Claim_Item__c> claimItemList = new List<Claim_Item__c>();
	
	public CloneController (ApexPages.StandardController stdController){
		this.stdController=stdController;
	}
	
	//get claim items associated to claim. Must set currentClaim status to draft before insert to make sure user sees 'Draft' as the default status of the cloned claim.
	public PageReference claimClone(){		
		currentClaim = (Claim__c) stdController.getRecord();
		claimItemList = [SELECT Id, Quantity_Claimed__c, Control_Number__c, Claim_Item_Amount_Claimed__c, Claim_Type_del__c FROM Claim_Item__c WHERE claim__c =: currentClaim.id];
		
		//save oldStatus incase of cancel
		//oldStatus=currentClaim.status__c;
		currentClaim.status__c='Draft';

		return null;
	}	
	
	public PageReference save(){
		newClaim= new Claim__C();
		newClaim = currentClaim.clone(false,true);
		newClaim.status__c='Draft';
		insert newClaim;
		
		try{
			//Cloning claim items, setting claim__c of new claim items to cloned claim id
			Claim__c tempClaim = [SELECT Id, Name, Account__c FROM Claim__c WHERE Id =: newclaim.Id];		
			List <Claim_Item__c> clonedClaimItems = claimItemList.deepclone();		
			for (Claim_Item__c ci: clonedClaimItems){
				ci.claim__c = tempClaim.id;
				/*
				ci.Quantity_Claimed__c = ci.Quantity_Claimed__c;
				ci.Control_Number__c = ci.Control_Number__c;
				ci.Claim_Item_Amount_Claimed__c = ci.Claim_Item_Amount_Claimed__c;
				ci.Claim_Type_del__c = ci.Claim_Type_del__c;
				*/
			}
			insert clonedClaimItems;
			
			//Setting up cloned claim's name
			List<Account> accList = [SELECT channel_id__c FROM Account WHERE id=:currentClaim.account__c];
			for (Account acc: accList){
				if (acc.id==currentClaim.account__c){
					tempClaim.claim_name__c= acc.channel_id__c + '-' + tempClaim.name;
				}
			}
			update tempClaim;
			//List <Claim__c> claimList = [SELECT id FROM claim__c];
	
			return new PageReference('/'+newClaim.id);
		} catch(exception e){
			return null;
		}
		
	}
	
	public PageReference cancel(){
		//currentClaim.status__c=oldStatus;
		return new PageReference('/'+currentClaim.id);
	}
	
	/*
	public PageReference saveAndNew(){
		newClaim= new Claim__C();
		newClaim = currentClaim.clone(false,true);
		insert newClaim;
		
		//Cloning claim items, setting id's to cloned claim
		Claim__c tempClaim = [SELECT Id, Name, Account__c FROM Claim__c WHERE Id =: newclaim.Id];		
		List <Claim_Item__c> clonedCIs = new List<Claim_Item__c>();
		for (Claim_Item__c ci: ciList){
			Claim_Item__c newCi = ci.clone();
			newCi.claim__c = tempClaim.id;
			newCi.Quantity_Claimed__c = ci.Quantity_Claimed__c;
			newCi.Control_Number__c = ci.Control_Number__c;
			newCi.Claim_Item_Amount_Claimed__c = ci.Claim_Item_Amount_Claimed__c;
			newCi.Claim_Type_del__c = ci.Claim_Type_del__c;
			clonedCIs.add(newCi);
		}
		insert clonedCIs;
		
		//Setting up cloned claim's name
		Account acc = [SELECT channel_id__c FROM Account WHERE id=:currentClaim.account__c LIMIT 1];
		tempClaim.claim_name__c= acc.channel_id__c + '-' + tempClaim.name;
		update tempClaim;
		
		return new PageReference('/a01/e?retURL=%2Fpartner%2Fa01%2Fo&scontrolCaching=1');
	}
	*/
}