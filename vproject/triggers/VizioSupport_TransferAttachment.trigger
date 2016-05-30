/* Move Attachment from Email attachment to Case attachment
 * 
 * @author      Stela Zhang
 * @version     1.0
 * @since       1.0
 */


trigger VizioSupport_TransferAttachment on Attachment (after insert) {
    
    // Email Message list with HasAttachment = true
     List<EmailMessage> insertEmailList = new List<EmailMessage>();
     
     List<Attachment> emailAttachmentList = new List<Attachment>();
     
     Attachment caseAttachment = new Attachment();
     List<Attachment> caseAttachementList = new List<Attachment>();
     
     CaseComment createCaseComment = new CaseComment ();
     List<CaseComment > caseCommentList = new List<CaseComment>();
     
     Set<Id> attachParentId = new Set<Id>();
    
     for (Attachment theAttach : trigger.new) {

        attachParentId.add(theAttach.ParentId);
        emailAttachmentList.add(theAttach);
     }
     
     insertEmailList = [Select Id, ParentId, FromName , FromAddress , ToAddress , CcAddress , TextBody, HtmlBody From EmailMessage Where Id IN: attachParentId AND HasAttachment =: true ];  
     
     for (EmailMessage theEmail : insertEmailList) {
         for (Attachment theAttach : emailAttachmentList){
             // theAttachment's parent Id is the same as the email Id
             if (theAttach.ParentId == theEmail.Id) {
                               
                 // Create a new attachment which parentId = email's parentId (Case Id)
                 caseAttachment = new Attachment();
                 caseAttachment.ParentId = theEmail.ParentId;
                 caseAttachment.Name = theAttach.Name;
                 caseAttachment.ContentType = theAttach.ContentType;
                 caseAttachment.Body = theAttach.Body;
                 caseAttachment.IsPrivate = theAttach.IsPrivate;
                 caseAttachment.Description = theAttach.Description;
                 caseAttachementList.add(caseAttachment);
             }   
         } 
         // Create new CaseComment which parentId = email's parentId and commentBody = email content
         createCaseComment = new CaseComment();
         createCaseComment .IsPublished = true;
                   
         String header = 'From: ' + theEmail.FromName +  ' <' + theEmail.FromAddress + '>\n';
         header += 'To: '+ theEmail.ToAddress + '\n';
         header += theEmail.CcAddress!=null?'CC: '+ theEmail.CcAddress + '\n\n':'\n';
                  
         createCaseComment.ParentId = theEmail.ParentId;
         if (theEmail.TextBody!=null) {
              createCaseComment .CommentBody = header + theEmail.TextBody;
         } else if (theEmail.HtmlBody!=null) {
              createCaseComment .CommentBody = header + theEmail.HtmlBody.replaceAll('\\<.*?>','');
         }
         caseCommentList.add(createCaseComment); 
            
     }
     
     // Create attachments   
     insert caseAttachementList;    
     
     // Create caseCmment
     insert caseCommentList;   
     

}