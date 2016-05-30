/**
 *
 * This class is a batch job that creates parent accounts for those contacts that have a Record Type of Support, Customer Type of End User 
 * and do not have a parent account. 
 *
 * @author              Cristian Torres
 * @version             1.0
 * @since               1.0
 */ 
global class VizioSupport_LinkContactToAccountBatch implements Database.Batchable<sObject> {

	
	public String query;
	private RecordType recordType1;
	
	
	// We use this wrapper class in order to preserve the relationsip of the contact and account before we insert them 
	class ContactAccountWrapper {
		public contact cont;
		public account acc;
		
		contactAccountWrapper(contact contact1, account account1)
		{
			cont = contact1;
			acc = account1;
		}
	}
	

    /**
     * Definition of the constructor.
     * Initial all variables.
     *
     * @param                None
     * @return               None
     * @since                 1.0
     */ 
    global VizioSupport_LinkContactToAccountBatch()
    {   
        //query = q;
        
        recordType1 = [
        	SELECT ID, Name
        	FROM RecordType
        	WHERE SObjectType = 'Account' AND Name = 'Vizio Support' LIMIT 1
        ];        
    }


    /**
     * Required method
     * 
     *
     * @param                Required argument
     * @return               None
     * @since                 1.0
     */ 
    global Database.QueryLocator start(Database.BatchableContext BC)
    {   
        String query = 	'SELECT ID, MailingStreet, MailingCity, MailingStateCode, MailingCountry, MailingCountryCode, MailingPostalCode, LastName, OwnerID, phone ' +
   				'FROM Contact WHERE RecordType.Name = \'Support\' AND AccountID = NULL AND Customer_Type__c = \'End User\' ';
		/*
			VizioSupport_LinkContactToAccountBatch obj;
			obj = new VizioSupport_LinkContactToAccountBatch();
			database.executeBatch(obj, 5000);

 		*/
        
        
        return Database.getQueryLocator(query);        
    }


    /**
     * Required method includes all the logic to create parent accounts for orphan accounts 
     * 
     *
     * @param                Required argument
     * @return               None
     * @since                 1.0
     */ 
    global void execute(Database.BatchableContext BC, list<sObject> scope)
    {
    	list<contact> contactsToUpdate = new list<contact>();
    	list<account> accountsToCreate = new list<account>();
    	list<String> addressList = new list<String>();
    	list<contact> contactsNullAddress = new list<contact>();
    	set<String> contactAdressUpdated = new set<String>();
    	map<String,Contact> contactAddressMap = new map<String,Contact>();
    	
    	
    	//Using this list to preserve the relationship between the contact and the account
    	list<ContactAccountWrapper> contAccWrapList = new list<ContactAccountWrapper>();
    	
    	
    	
    	//get list of ID's and map the Contacts using their Street Address as the key  
        for (sobject sobj : scope)       
        {
        	contact cont = (contact) sobj;
        	System.debug('Contact ' + cont.LastName + ' ' + cont.MailingStreet);
        	
        	//The ones that have a mailing address wil be used to try to find accounts with the same address so they can be tied together
        	if(cont.MailingStreet != null)
        	{
        		contactAddressMap.put(cont.MailingStreet, cont);
        	} else {
        		//If there is a null address then we will put it in a different list so that an account can be created for them and we don't query 
        		//for accounts with null addresses 
        		
        		contactsNullAddress.add(cont);
        	}
        }
        
        //here we are going to add all the Accounts that match the address of any of the contacts we are working with
        list<account> accountsMatchingAddress = 
        [
        	SELECT ID, Name, BillingStreet, BillingCity, BillingStateCode, BillingCountry, BillingPostalCode,
        		ShippingStreet, ShippingCity, ShippingStateCode, ShippingCountry, ShippingPostalCode
        	FROM Account 
        	WHERE BillingStreet IN: contactAddressMap.keySet() OR ShippingStreet IN: contactAddressMap.keySet() 
        ];	
        
        //loop throught the accounts to check if their shipping or billing address matches exactly to any of the accounts
        for (account acc: accountsMatchingAddress)
        {
        	System.debug('Currect Account ' + acc.Name + ' With Address: ' + acc.BillingStreet + ' and ' + acc.ShippingStreet );
        	
        	
        	//check to see what street address from a contact matched to this account   
        	contact auxContact = contactAddressMap.get(acc.BillingStreet); 
        	
        	
        	// if an auxContact was found that means that there Street matches we will check for the other 
        	// fields and if they all match then we will relate the contact to the account
        	if (auxContact != null)
        	{
        		System.debug('This contact address matches the Billing Street address ' + auxContact.MailingStreet);
        		
        		//check first for the billing address
        		if(acc.BillingCity == auxContact.MailingCity && acc.BillingStateCode == auxContact.MailingStateCode && 
        			acc.BillingCountry == auxContact.MailingCountry && acc.BillingPostalCode == auxContact.MailingPostalCode) 
        		{
        			//If we got here that means that the address matched 
        			System.debug('Contact with ID ' + auxContact.ID + ' and Account with ID ' + acc.ID + ' - Address matched');
        			
        			auxContact.accountID = acc.ID;
        			contactAdressUpdated.add(auxContact.MailingStreet);
        			contactsToUpdate.add(auxContact);
        			
        		}
        		
        	} else { 
        		//If we are here it is because there was not a match found for the Billing address so now we are going to try the Shipping
        		
        		
        		//check to see what street address from a contact matched to this account   
        		auxContact = contactAddressMap.get(acc.ShippingStreet); 
        	
        	
        		// if an auxContact was found that means that there Street matches we will check for the other 
        		// fields and if they all match then we will relate the contact to the account
        		if (auxContact != null)
        		{
        			System.debug('This contact addresss matches the Shipping Street address ' + auxContact.MailingStreet);
        			
        			//check for the entire shipping address
        			if(acc.ShippingCity == auxContact.MailingCity && acc.ShippingStateCode == auxContact.MailingStateCode && 
        				acc.ShippingCountry == auxContact.MailingCountry && acc.ShippingPostalCode == auxContact.MailingPostalCode) 
        			{
        				//If we got here that means that the address matched 
        				System.debug('Contact with ID ' + auxContact.ID + ' and Account with ID ' + acc.ID + ' - Address matched');
        			
        				auxContact.accountID = acc.ID;
        				contactAdressUpdated.add(auxContact.MailingStreet);
        				contactsToUpdate.add(auxContact);
        			}
        		}
        		
        	} 	
        }
        
        
        
        
        
        
        //now we will loop through the contacts and if they haven't been found yet (using contactAdressUpdated) then we will create a new account for them
		//contactAddressMap.put(cont.MailingStreet, cont);        
        for(String addressContact: contactAddressMap.keySet())
        {
        	if (contactAdressUpdated.contains(addressContact))
        	{
        		System.debug('The address: ' + addressContact + ' has already been associated with an Account');
        		continue;
        	}
        	
        	System.debug('Creating a new account for: ' + contactAddressMap.get(addressContact).LastName + ' Address ' + addressContact );
        	account tempAccount = new account();
        	
        	//Populating fields on the new account based on the information for the contacts
        	tempAccount.Name = contactAddressMap.get(addressContact).LastName + ' ' + contactAddressMap.get(addressContact).MailingCity + ' ' + 
        			contactAddressMap.get(addressContact).MailingStateCode + ' ' + contactAddressMap.get(addressContact).MailingCountry + ' Household';
        	
        	tempAccount.BillingStreet = contactAddressMap.get(addressContact).MailingStreet;
        	tempAccount.BillingCity = contactAddressMap.get(addressContact).MailingCity;
        	tempAccount.BillingStateCode = contactAddressMap.get(addressContact).MailingStateCode;
        	tempAccount.BillingCountry = contactAddressMap.get(addressContact).MailingCountry;
            tempAccount.BillingCountryCode = contactAddressMap.get(addressContact).MailingCountryCode;
        	tempAccount.BillingPostalCode = contactAddressMap.get(addressContact).MailingPostalCode;
        	
        	tempAccount.ShippingStreet = contactAddressMap.get(addressContact).MailingStreet;
        	tempAccount.ShippingCity = contactAddressMap.get(addressContact).MailingCity;
        	tempAccount.ShippingStateCode = contactAddressMap.get(addressContact).MailingStateCode;
        	tempAccount.ShippingCountry = contactAddressMap.get(addressContact).MailingCountry;
            tempAccount.ShippingCountryCode = contactAddressMap.get(addressContact).MailingCountryCode;
        	tempAccount.ShippingPostalCode = contactAddressMap.get(addressContact).MailingPostalCode;
        	
        	tempAccount.OwnerID = contactAddressMap.get(addressContact).OwnerID;
        	tempAccount.Phone = contactAddressMap.get(addressContact).Phone;
        	tempAccount.Fax = contactAddressMap.get(addressContact).Phone;
        	tempAccount.Cust_Type__c = 'End User';
        	tempAccount.RecordTypeID = recordType1.ID;
        	
        	System.debug(tempAccount);
        	
        	//helps us map the contact and its newly created acocunt
        	contAccWrapList.add(new ContactAccountWrapper(contactAddressMap.get(addressContact), tempAccount));
        	accountsToCreate.add(tempAccount);
        }
        
        
        //now we are going to create the accounts for the contacts with the null address
        for(contact c1: contactsNullAddress)
        {
        	System.debug('Creating a new account for: ' + c1.LastName + ' Address ' + c1.MailingStreet );
        	account tempAccount = new account();
        	
        	//Populating fields on the new account based on the information for the contacts
        	tempAccount.Name = c1.LastName + ' ' + c1.MailingCity + ' ' + c1.MailingStateCode + ' ' + c1.MailingCountry + ' Household';
        	
        	tempAccount.BillingStreet = c1.MailingStreet;
        	tempAccount.BillingCity = c1.MailingCity;
        	tempAccount.BillingStateCode = c1.MailingStateCode;
        	tempAccount.BillingCountry = c1.MailingCountry;
            tempAccount.BillingCountryCode = c1.MailingCountryCode;
        	tempAccount.BillingPostalCode = c1.MailingPostalCode;

        	
        	tempAccount.ShippingStreet = c1.MailingStreet;
        	tempAccount.ShippingCity = c1.MailingCity;
        	tempAccount.ShippingStateCode = c1.MailingStateCode;
        	tempAccount.ShippingCountry = c1.MailingCountry;
            tempAccount.ShippingCountryCode = c1.MailingCountryCode;
        	tempAccount.ShippingPostalCode = c1.MailingPostalCode;
        	
        	tempAccount.OwnerID = c1.OwnerID;
        	tempAccount.Phone = c1.Phone;
        	tempAccount.Fax = c1.Phone;
        	tempAccount.Cust_Type__c = 'End User';
        	tempAccount.RecordTypeID = recordType1.ID;
        	
        	System.debug(tempAccount);	
        	
        	
        	//helps us map the contact and its newly created acocunt
        	contAccWrapList.add(new ContactAccountWrapper(c1, tempAccount));
 			
        	accountsToCreate.add(tempAccount);
        }



		
		//we finally get ready to insert and update accounts and contacts first accounts and then the contacts with the lookup to the
		//accounts that were just created
		System.debug('This is the list that contains all the new accounts that will be created along with their contacts ' + contAccWrapList);        
        
        insert accountsToCreate;
        
        
        for (ContactAccountWrapper caw: contAccWrapList)
        {
        	caw.cont.AccountID = caw.acc.ID;
        	contactsToUpdate.add(caw.cont);
        }
        
        
        update contactsToUpdate;
    }
    
    global void finish(Database.BatchableContext BC){
        //Finished BATCH JOB
    } 
    
}