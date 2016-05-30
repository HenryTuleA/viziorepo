/**
 *  This class is a controller used for both VizioSupport_ServiceRequesDetail_PDF and for the page 
 *  VizioSupport_srCreatePDF
 *
 * @author              Cristian Torres
 * @version             1.0
 * @since               1.0
 */ 
public class VizioSupport_ServiceReq_PDFController 
{
    public list<Line_Items__c> lineItemsList {get; set;} 
    public Service_Request__c sr1 {get; set;}
    public Vizio_Return_Location__c vizioInfo { get; set; }
    private final ApexPages.StandardController controller;

    
    
    /**
     * Constructor
     *
     * @param   standard controller       
     * @return                
     * @since   1.0                                                                       
     */ 
    public VizioSupport_ServiceReq_PDFController(ApexPages.StandardController controller)
    {
        this.controller = controller;
    }
    

    /**
     * Constructor
     *
     * @param            
     * @return                
     * @since    1.0                                                                          
     */ 
    public VizioSupport_ServiceReq_PDFController()
    {
        // First we query for the SR that is returned by this query, the ID is passed here by using the and argument
        //in the URL

        try
        {   
            sr1 = [ 
                SELECT ID, name, SerialNumber__c, Service_Request_ID__c, CreatedDate, Case__r.Contact.Phone,
                    Case__r.Contact.Name, Case__r.Contact.MailingStreet, Case__r.Contact.MailingCity,
                    Case__r.Contact.MailingStateCode, Case__r.Contact.MailingCountryCode, Case__r.Contact.MailingPostalCode,
                    Service_Provider__r.ServiceProviderId__r.Phone, Service_Provider__r.ServiceProviderId__r.Name, Service_Provider__r.ServiceProviderId__r.MailingStreet,
                    Service_Provider__r.ServiceProviderId__r.MailingCity, Service_Provider__r.ServiceProviderId__r.MailingStateCode, Service_Provider__r.ServiceProviderId__r.MailingPostalCode
                FROM Service_Request__c     
                WHERE id = : ApexPages.currentPage().getParameters().get('id') LIMIT 1
            ]; 
              
            System.debug('Service_Request__c -> ' + sr1); 

        } catch(Exception ex){ 
            ApexPages.addMessages(+ex); 
            System.debug('ERROR ' + ex );
        }
        
        
        // Now we get all the line items associated with the SR 
        try
        { 
             lineItemsList = [
                    SELECT ID, name, PartType__c, Notes__c, Product__c, Quantity__c, SKU__c, Product__r.Product_ID__c, Product__r.Description  
                    FROM Line_Items__c 
                    WHERE  Service_Request__c = : ApexPages.currentPage().getParameters().get('id')
             ]; 
         } catch(Exception ex){ 
            ApexPages.addMessages(+ex); 
            System.debug('ERROR ' + ex );
        }
             
         //We get this from the Custom Setting in order to get the address and the information from Vizio 
         
        try
        { 
             vizioInfo = [
                SELECT Name, Corporate_Info__c, Corporate_Info_2__c, phone__c, fax__c, address__c, zipcode__c, city__c, state__c
                FROM Vizio_Return_Location__c
                WHERE Name LIKE : 'Vizio Inc%' 
             ];
        } catch(Exception ex){ 
            ApexPages.addMessages(+ex); 
            System.debug('ERROR ' + ex );
        }

        System.debug('Debug statement this is the Vizio_Return_Location__c ' + vizioInfo.Name + ' ' + vizioInfo.Corporate_Info__c);
        
    }
    
    
      
    /**
     * This method is called by VizioSupport_srCreatePDF and basically returns the PDF
     *
     * @param            
     * @return                
     * @since   1.0                                                              
     */ 
    public PageReference createPDF()
    {
        
        PageReference pdf = Page.VizioSupport_ServiceRequestDetail_PDF;
        String contractId = ApexPages.CurrentPage().getParameters().get('id');
        pdf.getParameters().put('id', contractId); 
    
        return pdf;
    } 
        
}