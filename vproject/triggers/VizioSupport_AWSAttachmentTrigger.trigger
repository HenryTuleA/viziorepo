/*
 *	This trigger will fire on the creation of an attachment, first it makes sure that the parent is a Case 
 *	if it is an attachment to the case then it calls a future method that moves the attachment to AWS S3
 */
 
trigger VizioSupport_AWSAttachmentTrigger on Attachment (after insert) 
{
	//List caseList = new List()
	Set<ID> caseIDs = new Set<ID>();
	List<Case> caseList;
	//Map<String,Attachment> mapParentidAtt = new Map<String,Attachment>(); //<parentID, attachment>
	Map<String,List<Attachment>> mapParentidAtt = new Map<String,List<Attachment>>(); 
	

	for (Attachment att: trigger.new)
	{
		System.debug('Trigger Attachment ID: ' + att.ID + ' parentID ' + att.parentID );
		//Check if the attachment is realted to a Case
		caseIDs.add(att.parentID);

		if (mapParentidAtt.containsKey(att.parentID))
		{
			System.debug('Inside IF 1 ' + mapParentidAtt.containsKey(att.parentID));
			mapParentidAtt.get(att.parentID).add(att);
		} 
		else 
		{
			System.debug('Inside ELSE 2 ' + mapParentidAtt.containsKey(att.parentID));
			mapParentidAtt.put(att.parentID, new List<Attachment>());
			mapParentidAtt.get(att.parentID).add(att);
		}
		//mapParentidAtt.put(att.parentID, att);
	}

	caseList = 
	[
		SELECT 	ID
		FROM	Case
		WHERE 	ID IN: caseIDs
	];
  

	for (Case c: caseList) 
	{
		//get the attachment for the set of attachments from the map created earlier
		for(Attachment a: mapParentidAtt.get(c.ID))
		{
			System.debug('Calling Web Service for attachment with ID: ' + a.ID + ' with parent Case ID: ' + c.ID);

			// We only take the first 15 characters from the ID in order to make this compatible with the 
			// VizioSupport_AWS_DocumentUploadPage.page
			// because the folders it creates in AWS are named with the shorter version of the ID
			String caseShortID = c.ID; 
			caseShortID = caseShortID.substring(0,15);

			VizioSupport_AWSAttachment.uploadAttachment(a.ID, caseShortID);
		}
		/*
		//get the attachment from the map created earlier
		Attachment a = mapParentidAtt.get(c.ID);

		System.debug('Calling Web Service for attachment with ID: ' + a.ID + ' with parent Case ID: ' + c.ID);

		// We only take the first 15 characters from the ID in order to make this compatible with the VizioSupport_AWS_DocumentUploadPage.page
		//because the folders it creates in AWS are named with the shorter version of the ID

		String caseShortID = c.ID; 
		caseShortID = caseShortID.substring(0,15);

		VizioSupport_AWSAttachment.uploadAttachment(a.ID, caseShortID);
		*/
	}

}