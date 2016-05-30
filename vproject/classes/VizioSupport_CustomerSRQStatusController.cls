/**
 * Controller for the VF page VizioSupport_CustomerSQRStatus
 *
 * @author              Cristian Torres
 * @version             1.0
 * @since               1.0
 */ 

public with sharing class VizioSupport_CustomerSRQStatusController 
{

	public List<Service_Request__c> sr1 { get; set; }
	public List<Line_Items__c> li1 { get; set; }
	public boolean srFound { get; set; }			// to show fiels on the VF
	public boolean liFound { get; set; }			// to show the table on the VF
	public boolean show48Message { get; set; }		// shows a message when there are no Line Items
	public String zipCode { get; set; }
	public String srNumber { get; set; }
	public String last4Phone { get; set; }


	public VizioSupport_CustomerSRQStatusController() 
	{
		srFound = false;
		liFound = false;
		show48Message = false;

		li1 = new List<Line_Items__c>();
	}

	public pageReference search()
	{
		reset(); 		//resets all the values to hide messages

		if(srNumber == '' && last4Phone == '') 
		{
			ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR, 
					'Please enter a value for the SR# OR Last 4 Digits of the Phone'));
    		return null;
		}

		if( zipCode == '' )
		{
			ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR, 
					'Please enter a value for the Zip Code'));
    		return null;
		}

		
		 String query = 'SELECT ID, Voogle_SRID__c, Case__r.CaseNumber ' +
			' FROM Service_Request__c WHERE ';



        // Service Request Number was input by the user 
		if (srNumber != '')
		{
		 	query += ' Voogle_SRID__c LIKE :srNumber ';

		} else {
			// That means that the user input the last 4 numbers of the phone number
			// Primary_Number__c = 
			String temp =  '%' + last4Phone;
			query += ' Case__r.Contact.Phone LIKE :temp ';
			
		}

		//we add now the Zip Code part 
		query += ' AND Case__r.Contact.MailingPostalCode =: zipCode AND Case__r.Status != \'CLOSED\' AND Case__r.Status != \'Cancelled\' ';

		System.debug(query);
        

		// We get the values of the 	
		try {
			sr1 = Database.query(query);	
		
		} catch (Exception e) {
			System.debug('ERROR ' + e);
		}
        

		//As long as there is a service request we try to search for the Line Items
		if (sr1.size() > 0)
		{
			//this will show the fields that have information respecting the Service Request and the Serial Number
			srFound = true;

			//we query for the line items
			List<Line_Items__c> lineItems = [
				SELECT ID, Product__r.SKUDesc__c, Transaction_Date__c, Tracking__c, Carrier_Name__c, LastModifiedDate, PartType__c, Notes__c,
						Ship_Date__c, Receive_Date__c
				FROM Line_Items__c
				WHERE Service_Request__c =: sr1[0].ID
				ORDER BY LastModifiedDate DESC
			];

			
			// IF there is only one Line item then we show it
			if (lineItems.size() == 1)
			{
				li1 = lineItems;

			} else {	
				// if there is more than one then we only return the most recent on for a Type Receive 
				// and one for the Send Type 
				li1 = recentSendReceiveItems(lineItems);
			}


	
		
		}

		System.debug('Line Items ' + li1);

		// If there are any line times then show the table in the VF page
		if ( li1.size()  > 0 )
		{
			liFound = true;

		} else {

			show48Message = true;
		}

		return null;
	}


	/**
     * This method resets the values so that the search can be executed again
     *
     * @param            
     * @return                
     * @since                                                                            
     */ 
	private void reset()
	{
		//we do not want to display any of these fields by default
		srFound = false;
		liFound = false;
		show48Message = false;		

		//restarting the lists of line ITems and service requests
		li1 = new List<Line_Items__c>();
		sr1 = new List<Service_Request__c>();
	}


	/**
     * This method gets a list of Line items and returns at most one Receive and on Send Line item
     *
     * @param      List of line items      
     * @return     List of recent one Receive and one Send Line Items           
     * @since                                                                            
     */ 
	private List<Line_Items__c> recentSendReceiveItems(List<Line_Items__c> lineItems)
	{
		List<Line_Items__c> returningList = new List<Line_Items__c>();
		Line_Items__c sendLI;
		Line_Items__c receiveLI;
		
		for (Line_Items__c li: lineItems)
		{

			// we get only the most recent line item with the Part Type = Send
			if (sendLI == null && li.PartType__c == 'Send')
			{
				sendLI = li;

				if (sendLI.Transaction_Date__c == null && sendLI.Ship_Date__c == null)
				{
					sendLI.Notes__c = 'Item getting ready for shipment';
				}

				if (sendLI.Transaction_Date__c != null || sendLI.Ship_Date__c != null)
				{
					sendLI.Notes__c = 'Item sent by Vizio';
				}

			}

			// we get only the most recent line item with the Part Type = Receive
			if (receiveLI == null && li.PartType__c == 'Receive')
			{

				receiveLI = li;

				if (receiveLi.Transaction_Date__c == null && receiveLi.Receive_Date__c == null)
				{
					receiveLI.Notes__c = 'Waiting for the customer';
				}

				if (receiveLi.Transaction_Date__c != null || receiveLi.Receive_Date__c != null)
				{
					receiveLI.Notes__c = 'Thank you. We received your item';
				}
			}

			
		}

		returningList.add(receiveLI);
		returningList.add(sendLI);

		return returningList; 	
	}

}