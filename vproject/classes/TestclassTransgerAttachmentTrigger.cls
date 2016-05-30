/**
 * Test class to test the VizioSupport_TransferAttachment 
 * @author		Stela Zhang
 * @version		1.0
 * @since		1.0
 */
 
@isTest (SeeAllData=false)
private class TestclassTransgerAttachmentTrigger {

	static testMethod void testAttachment() {
		
		AWS_Keys__c awsKey = new AWS_Keys__c(Name = 'forceunleashed	', AWS_Endpoint_URL__c = 'https://s3-us-west-2.amazonaws.com/', AWS_Region__c = 'http://s3-us-west-2.amazonaws.com',AWS_AccessKey_Id__c= 'AKIAIHM22JTMD7JVKTGQ',  AWS_Secret_Key__c = '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');
		insert awsKey;
		
		Id contactRecotType = [Select Id From RecordType Where Name = 'Support' AND SobjectType = 'Contact'].get(0).Id;        
        Contact customer = new Contact(LastName = 'Customer', RecordTypeId = contactRecotType);
        insert customer;
        
        Case newCase = new Case(ContactId = customer.Id); 
        insert newCase;
		
		EmailMessage newEmail = new EmailMessage(ParentId = newCase.Id, TextBody = 'testing', FromName = 'test zhang', FromAddress = 'test@123.com', ToAddress = 'test@321.com');
		insert newEmail;
				
		Blob bodyBlob=Blob.valueOf('Unit Test Attachment Body');		
		Attachment newAttachment = new Attachment(Name = 'test.pdf', Body = bodyBlob, ParentId = newEmail.Id);
	    insert newAttachment;
	}

}