/**
 *  This class is the controller used by the page VizioSupport_AgentConsole 
 *  it handles all the queries, pagination and searches by data range 
 *
 * @author              Cristian Torres
 * @version             1.0
 * @since               1.0
 */ 
public with sharing class VizioSupport_AgentConsoleController 
{
    
    public string test { get; set; }
    public case case1 { get; set; } 
    public case case2 { get; set; }
    public case case3 { get; set; }
    public Service_Request__c sr1 { get; set; }
    public Service_Request__c sr2 { get; set; }
    public contact contact1 { get; set; }
    public contact contact2 { get; set; }
    public list<case> caseList { get; set; } 
    public list<contact> contactList { get; set; }
    public list<service_request__c> srList1 { get; set; }
    public list<service_request__c> srList2 { get; set; } 
    public Phone_Call__c call1 { get; set; }
    public Authorized_SRtype_for_SKU__c srType1 { get; set; }
    
    
    public String contactStoreName { get; set; }
    public string caseIDsearch { get; set; }
    public string caseContactFirstName { get; set; }
    public string caseContactLastName { get; set; }
    public string caseContactphone { get; set; }
    public string agentIDsearch { get; set; }
    public String srIDsearch { get; set; }
    public String srErrorCodeSearch { get; set; }
    public String srCreatedByNameSearch { get; set; }
    public String srSerialNoSearch { get; set; }
    public String srStoreSearch { get; set; }
    public String srFirstNameSearch { get; set; }
    public String srLastNameSearch { get; set; }
    public String srPhoneSearch { get; set; }
    public String sr2IDsearch { get; set; }
    public String sr2CreatedBySearch { get; set; }
    public String sr2ServiceProvSearch { get; set; }
    
    
    private String userID;
    
    public boolean firstTimeContact { get; set; }
    public boolean firstTimeCase { get; set; }
    public boolean firstTimeSR { get; set; }
    
    
    //Pagination
    public boolean prevCont { get; set; }
    public boolean nextCont { get; set; }
    public boolean prevCase { get; set; }
    public boolean nextCase { get; set; }
    public boolean prevSR   { get; set; }
    public boolean nextSR   { get; set; }
    public boolean prevSR2  { get; set; }
    public boolean nextSR2  { get; set; }
    
    private integer totalRecsCont = 0;
    private integer OffsetSizeCont = 0;
    private integer totalRecsCase = 0;
    private integer OffsetSizeCase = 0; 
    private integer totalRecsSR = 0;
    private integer OffsetSizeSR = 0;
    private integer totalRecsSR2 = 0;
    private integer OffsetSizeSR2 = 0;  
    private final integer LIMIT_SIZE = 10;
    
    
    
    /**
     * Constructor
     *
     * @param        
     * @return                
     * @since   1.0                                                                       
     */ 
    public VizioSupport_AgentConsoleController() 
    { 
        //gets name of the current user
        userID = UserInfo.getUserId(); 
        contact1 = new contact();
        contact2 = new contact();
        case1 = new case();
        case2 = new case();
        case3 = new case();
        sr1 = new Service_Request__c();
        sr2 = new Service_Request__c(); //this one we use to get the date input field in the SR by Date Range
        srType1 = new Authorized_SRtype_for_SKU__c();
        case1.status = '';  //for some reason if we don't initialize to null the default is New
        case2.status = '';  //we use this to query for the status field in the SR section
        case3.status = '';
        
        
       
        firstTimeContact = true;
        firstTimeCase = true;
        firstTimeSR = true;
        
        queryCustomers();
        queryCases();
        querySR();
        togglePaginationButtons();
        
        
    }

    
    /**
     *  Query Customers will get all the information from the Contact object
     *  The first time only shows the contacts created by the current agent and then once the search button is clicked 
     *  then we query by the criteria used by the agent
     *
     * @param        
     * @return                
     * @since   1.0                                                                       
     */ 
    public void queryCustomers()
    {
        String flag = apexpages.currentpage().getparameters().get('firstTimeFlag');
        system.debug('CONTACT PARAMETERS Value of flag: ' + flag);
        
        //If this is called from the search button then we are going to filter
        if (flag != null && Boolean.valueOf(flag) == false)
        {
            firstTimeContact = false;
            OffsetSizeCont = 0;
        }
        
        
        //If there are no filters then we will get the contacts created by the agent instead
        //This also avoids having too many rows retrieved when there is no filters
        if(         (flag != null && Boolean.valueOf(flag) == false)
                &&  (contactStoreName == null  ||  contactStoreName == '' )
                &&  (contact1.FirstName == null || contact1.FirstName == '' )
                &&  (contact1.LastName == '' || contact1.LastName == null )
                &&  (contact1.mailingPostalCode == '' || contact1.mailingPostalCode == null)
                &&  ( contact1.phone == '' || contact1.phone == null )
                &&  (contact1.email == '' || contact1.email == null)  )
        {

            firstTimeContact = true;
            OffsetSizeCont = 0;
        }

        
        
        if(firstTimeContact)
        {
            //Pagination on the first table?
            //Gets the total size of the query, used for pagination purposes
            totalRecsCont = [ SELECT count() FROM contact WHERE createdByID =: userID  ];
            
            //LIMIT :LIMIT_SIZE OFFSET :OffsetSizeCont
            
            contactList = [ 
                SELECT ID, Voogle_Cust_ID__c, FirstName, LastName, phone, email, mailingPostalCode, Store_Name__c, Store_Number__c,
                       otherPhone, CreatedBy.FirstName, CreatedBy.LastName, MobilePhone, CreatedDate
                FROM contact
                WHERE createdByID =: userID 
                LIMIT :LIMIT_SIZE OFFSET :OffsetSizeCont
                
            ];

            //This will prevent for users to be able to go to pages that don't exist (less than 0 or greater that the total records)
            togglePaginationButtons(); 
            
        } else if (!firstTimeContact) {
            
            //We start building the query for contact
            String query = 'SELECT ID, CreatedDate, FirstName, LastName, phone, email, mailingPostalCode, ' + 
                    'Store_Name__c, Store_Number__c, '  + 
                    'otherPhone, CreatedBy.FirstName, CreatedBy.LastName, MobilePhone ';
                    
            query += 'FROM contact ';
            

            //using this variable because the code will not pick up 
            String whereClause = '';
            //sortDir = sortDir.equals('asc') ? 'desc' : 'asc';
            
            
            //Query CONTACT by: STORE NAME
            String aux = '%' + contactStoreName + '%';
            System.debug( 'Store Name ' + aux );
            if (contactStoreName != null && contactStoreName != '' )
            {
                whereClause += ' Store_Name__c LIKE :aux ';
            }
            
            //Query CONTACT by: FIRST NAME
            String aux2 = '%' + contact1.FirstName + '%';
            System.debug( 'First Name ' + aux2 );
            if (contact1.FirstName != null && contact1.FirstName != '' )
            {
                if (whereClause.length() >0) whereClause += ' AND ';
                whereClause += ' FirstName LIKE :aux2 ';
            }
            
            //Query CONTACT by: LAST NAME
            String aux3 = '%' + contact1.LastName + '%';
            System.debug( 'Last Name ' + aux3 );
            if (contact1.LastName != '' && contact1.LastName != null )
            {
                if (whereClause.length() >0) whereClause += ' AND ';
                whereClause += ' LastName like :aux3 ';
            }
            
            //Query CONTACT by: ZIP CODE
            String aux4 =  contact1.mailingPostalCode;
            System.debug( 'Zip Code ' + aux4 );
            if (contact1.mailingPostalCode != '' && contact1.mailingPostalCode != null)
            {
                if (whereClause.length() >0) whereClause += ' AND ';
                whereClause += ' mailingPostalCode like :aux4 ';
            }
            
            
            //Query CONTACT by: PHONE NUMBER
            String aux5 = phoneFormatSF(contact1.phone) + '%';
            System.debug('phone ' + aux5 );
            if ( contact1.phone != '' && contact1.phone != null )
            {
                if (whereClause.length() >0) whereClause += ' AND ';
                whereClause += ' (Phone like :aux5 OR MobilePhone like :aux5) ';
            }
            
            
            //Query CONTACT by: EMAIL
            String aux6 =  contact1.email + '%';
            System.debug('email ' + aux6 );
            if (contact1.email != '' && contact1.email != null)
            {
                if (whereClause.length() >0) whereClause += ' AND ';
                whereClause += ' email like :aux6 ';
            }
            
            
            //if there are any WHERE statements then we add the word WHERE and the statements
            if ( whereClause.length() > 0)
            {
                query += ' WHERE ' + whereClause;
            }
            
            
            //Gets the total size of the query, used for pagination purposes 
            //If the clause length is less than 0 then we avoid the exception
            if (whereClause.length() > 0)
            {   
                totalRecsCont = (Database.query('SELECT ID FROM Contact WHERE ' + whereClause)).Size();
            } else { totalRecsCont = (Database.query('SELECT ID FROM Contact')).Size(); }
            
            System.debug('CONTACT The Total Size of the Contacts is: ' + totalRecsCont);
            System.debug('CONTACT The Offset value is OffsetSizeCont: ' + OffsetSizeCont);
            
            query += ' LIMIT :LIMIT_SIZE OFFSET :OffsetSizeCont';

            //This will prevent for users to be able to go to pages that don't exist (less than 0 or greater that the total records)
            togglePaginationButtons(); 
            
            System.debug(query);
            contactList = Database.query(query);
            
        }
        
        
    }
    
    
    
    
    /**
     *  Query CASES will get all the information from the Case object
     *  The first time only shows the cases owned by the current agent and then once the search button is clicked 
     *  then we query by the criteria used by the agent
     *
     * @param        
     * @return                
     * @since   1.0                                                                       
     */ 
    public void queryCases()
    {
        String flag = apexpages.currentpage().getparameters().get('firstTimeFlag');
        system.debug('value of flag ' + flag);
        
        //If this is called from the search button then we are going to filter
        if (flag != null && Boolean.valueOf(flag) == false)
        {
            firstTimeCase = false;
            OffsetSizeCase = 0;
        }
        



        //If there are no filters then we will get the cases owned by the agent instead
        //This also avoids having too many rows retrieved when there is no filters
        if(        (flag != null && Boolean.valueOf(flag) == false)
                && (caseIDsearch == null || caseIDsearch == '' )
                && (case1.Status == '' || case1.Status == null)
                && (agentIDsearch == '' || agentIDsearch == null)
                && (case1.Serial_No__c == '' || case1.Serial_No__c == null)
                && (caseContactFirstName == '' || caseContactFirstName == null)
                && (caseContactLastName == '' || caseContactLastName == null)
                && (caseContactPhone == '' || caseContactPhone == null) )
        {
            firstTimeCase = true;
            OffsetSizeCase = 0;
        }
            

        
        
        
        if(firstTimeCase)
        {
            //Pagination on the first table?
            //Gets the total size of the query, used for pagination purposes
            totalRecsCase = [ SELECT count() FROM case WHERE ownerID =: userID  ];
            
            
            caseList = [ 
            SELECT ID, CaseNumber, Serial_No__c, ContactID, Owner.Name, OwnerID, Status, Service_Request_Count__c, CreatedDate, Contact.FirstName, 
                Contact.LastName, Contact.Phone             
            FROM case
            WHERE ownerID =: userID 
            LIMIT :LIMIT_SIZE OFFSET :OffsetSizeCase
            ];

            //This will prevent for users to be able to go to pages that don't exist (less than 0 or greater that the total records)
            togglePaginationButtons(); 
            
        
        } else if (!firstTimeCase) { 
            
            String query = 'SELECT ID, CaseNumber, Serial_No__c, ContactID, Owner.Name, OwnerID, Status, Service_Request_Count__c, CreatedDate, ' + 
                    'Contact.FirstName, Contact.LastName, Contact.Phone ';

                    
                    
            query += 'FROM case ';    
            
            
            //This is were we are going to put the where part of the Query
            String whereClause = '';

            
            //Query CASE by: ID
            String aux =  caseIDsearch;
            System.debug(' ' + aux);
            if (caseIDsearch != null && caseIDsearch != '' )
            {
                whereClause += ' CaseNumber =: aux ';
            }
            
            //Query CASE by: STATUS
            String aux1 =  case1.Status;
            System.debug(' ' + aux1);
            if (case1.Status != '' && case1.Status != null)
            {
                //If there are any other previous where statements add the word AND to separate them
                if (whereClause.length() >0) whereClause += ' AND ';
                whereClause += ' Status like :aux1 ';
            }
            
            
            
            //Query CASE by: AGENT ID
            String aux2 =  agentIDsearch;
            System.debug(' ' + aux2);
            if (agentIDsearch != '' && agentIDsearch != null)
            {
                //If there are any other previous where statements add the word AND to separate them
                if (whereClause.length() >0) whereClause += ' AND ';
                whereClause += ' Owner.ID =: aux2 ';
            }
            
            
            
            //Query CASE by: SERIAL NUMBER (formula field: Asset.SerialNumber)
            String aux3 =  case1.Serial_No__c;
            if (case1.Serial_No__c != '' && case1.Serial_No__c != null)
            {
                //If there are any other previous where statements add the word AND to separate them
                if (whereClause.length() >0) whereClause += ' AND ';
               whereClause += ' Serial_No__c like :aux3 ';
            }
            
            
            //Query CASE by: Contact.FirstName
            String aux4 = '%' + caseContactFirstName + '%';
            System.debug('First NAme ' + caseContactFirstName);
            if (caseContactFirstName != '' && caseContactFirstName != null)
            {
                //If there are any other previous where statements add the word AND to separate them
                if (whereClause.length() >0) whereClause += ' AND ';
                whereClause += ' Contact.FirstName like :aux4 ';
            }
            
            
            //Query CASE by: Contact.LastName
            String aux5 =  '%' + caseContactLastName + '%';
            System.debug('LAst NAme ' + caseContactLastName);
            if (caseContactLastName != '' && caseContactLastName != null)
            {
                //If there are any other previous where statements add the word AND to separate them
                if (whereClause.length() >0) whereClause += ' AND ';
                whereClause += ' Contact.LastName like :aux5 ';
            }
            
            
            //Query CASE by : Phone Number
            String aux6 =  phoneFormatSF(caseContactPhone) + '%';
            System.debug('Phone ' + aux6);
            if (caseContactPhone != '' && caseContactPhone != null)
            {
                //If there are any other previous where statements add the word AND to separate them
                if (whereClause.length() >0) whereClause += ' AND ';
                whereClause += ' Contact.Phone like :aux6 ';
            }
            
            
            //if there are any WHERE statements then we add the word WHERE and the statements
            if ( whereClause.length() > 0)
            {
                query += ' WHERE ' + whereClause;
            }

            
            
            //Gets the total size of the query, used for pagination purposes
            //If the clause length is less than 0 then we avoid the exception
            if (whereClause.length() > 0)
            {   
                totalRecsCase = (Database.query('SELECT ID FROM Case WHERE ' + whereClause)).Size();
            } else { totalRecsCase = (Database.query('SELECT ID FROM Case')).Size(); }
            System.debug('CASE The Total Size of the Case is: ' + totalRecsCase);
            System.debug('CASE The Offset value is OffsetSizeCase: ' + OffsetSizeCase);
            
            
            query += ' LIMIT :LIMIT_SIZE OFFSET :OffsetSizeCase';  
            
            //This will prevent for users to be able to go to pages that don't exist (less than 0 or greater that the total records)
            togglePaginationButtons(); 
                     
            System.debug(query);
            caseList = Database.query(query);
            
        }

        
    }
    
    
    
    
     
    /**
     *  Query SR will get all the information from the Service_Request__c object
     *  The first time only shows the SR  by the current agent and then once the search button is clicked 
     *  then we query by the criteria used by the agent
     *
     * @param         
     * @return                
     * @since   1.0                                                                       
     */ 
    public void querySR()
    {
        String flag = apexpages.currentpage().getparameters().get('firstTimeFlag');
        system.debug('value of flag ' + flag);
        
        //If this is called from the search button then we are going to filter
        if (flag != null && Boolean.valueOf(flag) == false)
        {
            firstTimeSR = false;
            OffsetSizeSR = 0;
        }
        
        


        

        //If there are no filters then we will get the cases owned by the agent instead
        //This also avoids having too many rows retrieved when there is no filters
        if(        (flag != null && Boolean.valueOf(flag) == false)
                && (srIDsearch == null || srIDsearch == '' )
                && (case2.Status == '' || case2.Status == null)
                && (srErrorCodeSearch == '' || srErrorCodeSearch == null)
                && (srCreatedByNameSearch == '' || srCreatedByNameSearch == null)
                && (srSerialNoSearch == '' || srSerialNoSearch == null)
                && (srStoreSearch == null || srStoreSearch == '' )
                && (srFirstNameSearch == null || srFirstNameSearch == '' )
                && (srLastNameSearch == '' || srLastNameSearch == null )
                && (srPhoneSearch == '' || srPhoneSearch == null) )
        {
            firstTimeSR = true;
            OffsetSizeSR = 0;
        }
           

        
        if(firstTimeSR)
        {
            
            //Pagination on the first table?
            //Gets the total size of the query, used for pagination purposes
            totalRecsSR = [ SELECT count() FROM Service_Request__c WHERE CreatedByID =: userID  ];
            
            
            srList1 = [
                SELECT ID, Voogle_SRID__c, Name, SerialNumber__c, CreatedDate, Voogle_ApproveDate__c, case__r.CaseNumber, case__r.ID, case__r.status, 
                    case__r.Product_Model_Number__c, case__r.Contact.Name
                FROM Service_Request__c
                WHERE CreatedByID =: userID 
                LIMIT :LIMIT_SIZE OFFSET :OffsetSizeSR
            ];

            //This will prevent for users to be able to go to pages that don't exist (less than 0 or greater that the total records)
            togglePaginationButtons(); 
            
        
        } else if (!firstTimeSR) { 
            
            String query = 'SELECT ID, Voogle_SRID__c, Name, SerialNumber__c, CreatedDate, Voogle_ApproveDate__c, case__r.CaseNumber, case__r.ID, case__r.status, ' + 
                    'case__r.Product_Model_Number__c, case__r.Contact.Name ';
                    
            query += 'FROM Service_Request__c ';
            
            
            
            
            //This is were we are going to put the where part of the Query
            String whereClause = '';

            
            //Query SR by: ID    
            String aux =  srIDsearch;
            System.debug(' ' + aux);
            if (srIDsearch != null && srIDsearch != '' )
            {
                whereClause += ' Voogle_SRID__c =: aux ';
            }
            
            
            //Query SR by: STATUS
            String aux1 =  case2.Status;
            System.debug(' ' + aux1);
            if (case2.Status != '' && case2.Status != null)
            {
                //If there are any other previous where statements add the word AND to separate them
                if (whereClause.length() >0) whereClause += ' AND ';
                whereClause += ' Case__r.Status like :aux1 ';
            }
            
            
            
            
            //Query SR by: ERROR CODE
            String aux2 =  srErrorCodeSearch;
            System.debug(' ' + aux2);
            if (srErrorCodeSearch != '' && srErrorCodeSearch != null)
            {
                //If there are any other previous where statements add the word AND to separate them
                if (whereClause.length() >0) whereClause += ' AND ';
                whereClause += ' Error_Code__r.Name =: aux2 ';
            }
            
            
            
            //Query SR by: CreatedBy
            String aux3 =  '%' + srCreatedByNameSearch + '%';
            if (srCreatedByNameSearch != '' && srCreatedByNameSearch != null)
            {
                //If there are any other previous where statements add the word AND to separate them
                if (whereClause.length() >0) whereClause += ' AND ';
               whereClause += ' CreatedBy.Name like :aux3 ';
            }
            
            
            //Query SR by: Serial Number
            String aux4 = srSerialNoSearch;
            System.debug('Serial No ' + aux4);
            if (srSerialNoSearch != '' && srSerialNoSearch != null)
            {
                //If there are any other previous where statements add the word AND to separate them
                if (whereClause.length() >0) whereClause += ' AND ';
                whereClause += ' SerialNumber__c like :aux4 ';
            }
            
            
            
            //Query SR by: STORE NAME
            String aux5 = '%' + srStoreSearch + '%';
            System.debug( 'Store Name ' + aux5 );
            if (srStoreSearch != null && srStoreSearch != '' )
            {
                whereClause += ' Case__r.Contact.Store_Name__c LIKE :aux5 ';
            }
            
            
            //Query SR by: FIRST NAME
            String aux6 = '%' + srFirstNameSearch + '%';
            System.debug( 'First Name ' + aux6 );
            if (srFirstNameSearch != null && srFirstNameSearch != '' )
            {
                if (whereClause.length() >0) whereClause += ' AND ';
                whereClause += ' First_Name__c LIKE :aux6 ';
            }
            
            //Query SR by: LAST NAME
            String aux7 = '%' + srLastNameSearch + '%';
            System.debug( 'Last Name ' + aux7 );
            if (srLastNameSearch != '' && srLastNameSearch != null )
            {
                if (whereClause.length() >0) whereClause += ' AND ';
                whereClause += ' Last_Name__c like :aux7 ';
            }
            
            
            //Query SR by : Phone Number
            String aux8 =  phoneFormatSF(srPhoneSearch) + '%';
            System.debug('Phone ' + aux8);
            if (srPhoneSearch != '' && srPhoneSearch != null)
            {
                //If there are any other previous where statements add the word AND to separate them
                if (whereClause.length() >0) whereClause += ' AND ';
                whereClause += ' Primary_Number__c like :aux8 ';
            }
            
            
            
            
             //if there are any WHERE statements then we add the word WHERE and the statements
            if ( whereClause.length() > 0)
            {
                query += ' WHERE ' + whereClause;
            }
            
            
            
            //Gets the total size of the query, used for pagination purposes
            //If the clause length is less than 0 then we avoid the exception
            if (whereClause.length() > 0)
            {   
                totalRecsSR = (Database.query('SELECT ID FROM Service_Request__c WHERE ' + whereClause)).Size();
            } else { totalRecsSR = (Database.query('SELECT ID FROM Service_Request__c')).Size(); }
            System.debug('SERVICE REQUEST: The Total Size of the SR is: ' + totalRecsSR);
            System.debug('SERVICE REQUEST: The Offset value is OffsetSizeSR: ' + OffsetSizeSR);
            
            
            query += ' LIMIT :LIMIT_SIZE OFFSET :OffsetSizeSR';  
            //This will prevent for users to be able to go to pages that don't exist (less than 0 or greater that the total records)
            togglePaginationButtons(); 
            
            System.debug(query);
            srList1 = Database.query(query);
            
        }
        
        
        
    }
    
    

    /**
     *  Query SR will get all the information from the Service_Request__c object
     *  the agent can chose to get a date and then if he choses only a starting date it will search for everything after that date
     *  ending date only will result on a search on every SR created before that date
     *  if we get both a starting and ending date then we will then search for that specific range 
     *
     * @param   standard controller       
     * @return                
     * @since   1.0                                                                       
     */ 
    public void querySRDateRange()
    {
        
        String flag = apexpages.currentpage().getparameters().get('firstTimeFlag');
        system.debug('value of flag ' + flag);
        
        //If this is called from the search button then we are going to reset to page 1
        if (flag != null && Boolean.valueOf(flag) == false)
        {
            OffsetSizeSR2 = 0;
        }
        
        
        String query = 'SELECT ID, Voogle_SRID__c, SRType__c, Name, SerialNumber__c, CreatedDate, Voogle_ApproveDate__c, CreatedBy.Name, ' +  
                        'case__r.CaseNumber, case__r.ID, case__r.status, case__r.Product_Model_Number__c, ' + 
                        'case__r.Contact.Name, Case__r.Voogle_CaseID__c, case__r.Contact.Customer_Type__c, Service_Provider__r.ServiceProviderName__c ';
                    
        query += 'FROM Service_Request__c ';
        

            //This is were we are going to put the where part of the Query
            String whereClause = '';

        
            //Query SR DATE RANGE by: ID    
            String aux =  sr2IDsearch;
            System.debug(' ' + aux);
            if (sr2IDsearch != null && sr2IDsearch != '' )
            {
                whereClause += ' Voogle_SRID__c =: aux ';
            }
            
            
            //Query SR DATE RANGE by: SR TYPE
            String aux1 =  srType1.SRType__c;
            System.debug('SR DATE RANGE SR Type ' + srType1.SRType__c);
            if (srType1.SRType__c != '' && srType1.SRType__c != null)
            {
                //If there are any other previous where statements add the word AND to separate them
                if (whereClause.length() >0) whereClause += ' AND ';
                whereClause += ' SRType__c like :aux1 ';
            }
            
            
            //Query SR DATE RANGE by: STATUS
            String aux2 =  case3.Status;
            System.debug('SR DATE RANGE Status ' + aux2);
            if (case3.Status != '' && case3.Status != null)
            {
                //If there are any other previous where statements add the word AND to separate them
                if (whereClause.length() >0) whereClause += ' AND ';
                whereClause += ' Case__r.Status like :aux2 ';
            }
            
            
     
            //Query SR by: Service Provider Name
            String aux3 =  '%' + sr2ServiceProvSearch + '%';
            if (sr2ServiceProvSearch != '' && sr2ServiceProvSearch != null)
            {
                //If there are any other previous where statements add the word AND to separate them
                if (whereClause.length() >0) whereClause += ' AND ';
               whereClause += ' Service_Provider__r.ServiceProviderName__c like :aux3 ';
            }
            
            
            //SR by: Start Date 
            //String aux4 = sr2.Voogle_ApproveDate__c;
            //System.debug('SR DATE RANGE Start Date ' + aux4);
            //DateTime date1 = sr2.Voogle_ApproveDate__c;
            DateTime dt1 = sr2.Voogle_ApproveDate__c;
            if (dt1 != null)
                Date date1 = date.newinstance(dt1.year(), dt1.month(), dt1.day());
            if (sr2.Voogle_ApproveDate__c != null)// && sr2.Voogle_ApproveDate__c != null)
            {
                //If there are any other previous where statements add the word AND to separate them
                if (whereClause.length() >0) whereClause += ' AND ';
                whereClause += ' CreatedDate > :date1 ';
            }
            
            
            
            //DateTime date2 = sr2.Voogle_CloseDate__c;
            DateTime dt2 = sr2.Voogle_CloseDate__c;
            if (dt2 != null)
                Date date2 = date.newinstance(dt2.year(), dt2.month(), dt2.day());
            if (sr2.Voogle_CloseDate__c != null)// && sr2.Voogle_ApproveDate__c != null)
            {
                //If there are any other previous where statements add the word AND to separate them
                if (whereClause.length() >0) whereClause += ' AND ';
                whereClause += ' CreatedDate < :date2 ';
            }
            
            
            //Query SR by: CreatedBy
            String aux5 =  '%' + sr2CreatedBySearch + '%';
            if (sr2CreatedBySearch != '' && sr2CreatedBySearch != null)
            {
                //If there are any other previous where statements add the word AND to separate them
                if (whereClause.length() >0) whereClause += ' AND ';
               whereClause += ' CreatedBy.Name like :aux5 ';
            }
            
          
            //Query SR DATE RANGE by: CUSTOMER TYPE
            String aux6 = '%' + contact2.Customer_Type__c + '%';
            System.debug( 'Customer Type ' + aux6 );
            if (contact2.Customer_Type__c != null && contact2.Customer_Type__c != '' )
            {
                if (whereClause.length() >0) whereClause += ' AND ';
                whereClause += ' Case__r.Contact.Customer_Type__c LIKE :aux6 ';
            }
            

            
             //if there are any WHERE statements then we add the word WHERE and the statements
            if ( whereClause.length() > 0)
            {
                query += ' WHERE ' + whereClause;
            }
            
            
            
            //Gets the total size of the query, used for pagination purposes
            //If the clause length is less than 0 then we avoid the exception
            if (whereClause.length() > 0)
            {   
                totalRecsSR2 = (Database.query('SELECT ID FROM Service_Request__c WHERE ' + whereClause)).Size();
            } else { totalRecsSR2 = (Database.query('SELECT ID FROM Service_Request__c')).Size(); }
            
            System.debug('SERVICE REQUEST RANGE DATE: The Total Size of the SR is: ' + totalRecsSR2);
            System.debug('SERVICE REQUEST RANGE DATE: The Offset value is OffsetSizeSR: ' + OffsetSizeSR2);
            
           
            
            query += ' LIMIT :LIMIT_SIZE OFFSET :OffsetSizeSR2';  
            //This will prevent for users to be able to go to pages that don't exist (less than 0 or greater that the total records)
            togglePaginationButtons(); 
            
            System.debug(query);
            srList2 = Database.query(query);
            
            
    }
    
    
    

 
    /**
     *  This method receives a phone number in any format and returns it in the Salesforce format
     *  (xxx) yyy-zzzz
     *
     * @param   Phone in any format  
     * @return                
     * @since   1.0                                                                       
     */ 
    private String phoneFormatSF(String phone)
    {
        String phoneReady = '';
        String aux;
        String leftString;
    
        //replace non-numeric values in the String called phone leaving it in xxxyyyzzzz format
        aux = phone.replaceAll('[^0-9]','');
    
        if (aux.Length() <= 10 || aux.Length() == 0)
        {

            //We are going to split the String and convert it to the format (xxx) yyy-zzzz
 
            leftString = aux.left(3);
            phoneReady = '(' + leftString;
            aux = aux.removeStart(leftString);
    
            if (aux.length() > 0)
            { 
                leftString =  aux.left(3);
                aux = aux.removeStart(leftString);
                phoneReady += ') ' + leftString;
            }
        
            if (aux.length() > 0)
            { 
                leftString=aux.left(4);
                phoneReady += '-' + leftString;
            }

    
        } else {
            System.debug('METHOD: VizioSupport_AgentConsoleController.phoneFormatSF Number length is greater than 10');
            return phone;
        }
        
        System.debug('The original Phone Number ' + phone); 
        System.debug('The new phone Number with SF format is ' + phoneReady);
        System.debug('The length of this the phone number with SF format is: ' + phoneReady.length());
        
        return phoneReady;
    }
    
    


    //***********
    //PAGINATION
    //***********

    /*
     *  when the button previous is clicked then we will call this method and it will basically requery for the previous page by
     *  decreasing the Offset and moving the query to the particular set of records that we are looking for
     */

    public void previous()
    {
        
        //we use this flag to know what is the section that is calling this method 
        String listType = apexpages.currentpage().getparameters().get('listType');
        system.debug('Previous Button value of listType ' + listType);
        
        if (listType == 'contact')
        {
            OffsetSizeCont = OffsetSizeCont - LIMIT_SIZE;
            queryCustomers();
        } 
        
        if (listType == 'case')
        {
            OffsetSizeCase = OffsetSizeCase - LIMIT_SIZE;
            queryCases();
        } 
        
        if (listType == 'sr')
        {
            OffsetSizeSR = OffsetSizeSR - LIMIT_SIZE;
            querySR();
        } 
        
        if (listType == 'sr2')
        {
            OffsetSizeSR2 = OffsetSizeSR2 - LIMIT_SIZE;
            querySRDateRange();
        } 
        
        //This will prevent for users to be able to go to pages that don't exist (less than 0 or greater that the total records)
        togglePaginationButtons();
    }
    


    /*
     *  when the button previous is clicked then we will call this method and it will basically requery for the next page by
     *  increasing the Offset and moving the query to the particular set of records that we are looking for
     */

    public PageReference next()
    {
        
        //we use this flag to know what is the section that is calling this method 
        String listType = apexpages.currentpage().getparameters().get('listType');
        system.debug('value of listType ' + listType);
        
        if (listType == 'contact')
        {
            OffsetSizeCont = OffsetSizeCont + LIMIT_SIZE;
            queryCustomers();
        }
        
        if (listType == 'case')
        {
            OffsetSizeCase = OffsetSizeCase + LIMIT_SIZE;
            queryCases();
        }
        
        
        if (listType == 'sr')
        {
            OffsetSizeSR = OffsetSizeSR + LIMIT_SIZE;
            querySR();
        }
        
        
        if (listType == 'sr2')
        {
            OffsetSizeSR2 = OffsetSizeSR2 + LIMIT_SIZE;
            querySRDateRange();
        }
        
        //This will prevent for users to be able to go to pages that don't exist (less than 0 or greater that the total records)
        togglePaginationButtons();
        
        return null;
    }
    
    
    
    /*
     *  We have different flags for all the buttons so that we can control when the buttons to change page will be available and when they won't be available
     *  this way we won't try to go to a page that doesn't exist
     */
    
    public void togglePaginationButtons()
    {
        //Customer
        if (OffsetSizeCont == 0)
        { 
            prevCont = true;  
        } else {
            prevCont = false;
        }
        
        if ((OffsetSizeCont + LIMIT_SIZE) > totalRecsCont)
        {
            nextCont = true;
        } else {
            nextCont = false;
        }
        
        
        //Case
        if (OffsetSizeCase == 0) prevCase = true; 
        else prevCase = false;
        
        if ((OffsetSizeCase + LIMIT_SIZE) > totalRecsCase) nextCase = true;
        else nextCase = false;
        
        
        //Service Request
        if (OffsetSizeSR == 0) prevSR = true; 
        else prevSR = false;
        
        if ((OffsetSizeSR + LIMIT_SIZE) > totalRecsSR) nextSR = true;
        else nextSR = false;
        
        
        //Service Request by Date Range
        if (OffsetSizeSR2 == 0) prevSR2 = true; 
        else prevSR2 = false;
        
        if ((OffsetSizeSR2 + LIMIT_SIZE) > totalRecsSR2) nextSR2 = true;
        else nextSR2 = false;
        
        System.debug('Finished execution');
    }

}