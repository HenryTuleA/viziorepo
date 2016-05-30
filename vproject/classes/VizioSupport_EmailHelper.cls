public class VizioSupport_EmailHelper
{
	public static void sendEmail()
 	{
	  	Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage(); 
	  	string body = 'Demo Body ';
	  	String[] toAddresses = new String[] {'ctorres@ucinnovation.com'};
	  	mail.setToAddresses(toAddresses);
	  	mail.setSubject('Test Subject'); 
	  	mail.setSaveAsActivity(false); 
  		
  		for(OrgWideEmailAddress owa : [select id, Address, DisplayName from OrgWideEmailAddress])
  		{
   			if(owa.DisplayName.contains('System Admin'))
   			{
    			mail.setOrgWideEmailAddressId(owa.id);
   			}
  		}

  		mail.setHtmlBody(body); 
  		Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
    } 
}