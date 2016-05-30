trigger Vizio_SRApprovalTrigger on Service_Request__c (before update, after update, before insert) {
   //if (Trigger.isUpdate ){
    if ( Trigger.isBefore)
    {
        System.debug('Trigger: isBefore');
        for (Service_Request__c sreq : Trigger.new)
        {
            if(sreq.XML_Folder__c == null || sreq.XML_Folder__c =='')
            {
                String itemnum='';
                String vsprod='';
                String srtype=''; 

                itemnum = sreq.ItemNo__c;
                vsprod  = sreq.Voogle_Service_Provider_Id__c;
                srtype  = sreq.SRType__c;
                    
                System.debug('Values vsprod ' + vsprod + ' srType ' + srType + ' itemnum ' + itemnum); 
                    
                    
                if (vsprod!= '' && srtype!= '' && itemnum !='')
                {
                    List<VoogleFileRouting__c> fPath = new List<VoogleFileRouting__c> ();

                    // Check if the values for either the srType or itemnum are all, if the values are all
                    // then we will take all the possibilities for that field in the query 
                    /*
                        fPath = 
                        [
                            SELECT XML_Folder__c 
                            FROM VoogleFileRouting__c  
                            WHERE ItemNo__c=:itemnum 
                                    AND Service_Type__c=:srtype 
                                    AND Service_Provider__c =: vsprod
                        ];
                    */

                    try {

                        fPath = 
                        [
                            SELECT XML_Folder__c, ItemNo__c, Service_Type__c
                            FROM VoogleFileRouting__c  
                            WHERE Service_Provider__c =: vsprod
                        ];    
                    } catch (Exception e) 
                    {
                        System.debug('Error in the Query for service provider: ' + vsprod );
                        System.debug(e);
                    }
                    

                    VoogleFileRouting__c fp; 
                    
                    for (VoogleFileRouting__c vfr : fPath) 
                    {

                        if  (   ( itemnum == vfr.ItemNo__c || vfr.ItemNo__c == 'ALL' ) &&
                                ( srtype == vfr.Service_Type__c || vfr.Service_Type__c == 'ALL' ) )
                        {
                            fp = vfr;
                        }
                    }
                        
                    System.debug('FILEPath =' + fPath);
                        

                    //VoogleFileRouting__c fp = (fPath != null && fPath.size()>0) ? fPath[0] : null;
                    if(fp != null)
                    {
                        sreq.XML_Folder__c = fp.XML_Folder__c;
                    }
                }
            }
        }
    }

    if (Trigger.isUpdate )
    {
        if (Trigger.isAfter)
        {
            System.debug('Trigger.isUpdate Trigger.isAfter');
               
            for (Service_Request__c sreq : Trigger.new)
            {
                System.debug('Trigger.isUpdate Trigger.isAfter');
        
                Service_Request__c sreqOld = Trigger.oldMap.get(sreq.Id);
                string oldStatus = sreqOld.Status__c;
                if(sreq.Status__c == 'APPROVED' && sreq.Status__c != sreqOld.Status__c)
                {        
               // VizioSupport_XMLGenerator vxg = new VizioSupport_XMLGenerator();
                VizioSupport_XMLGenerator.GetInformation(sreqOld.Id);
                }
            }
        }  
    }    
} //End of Trigger