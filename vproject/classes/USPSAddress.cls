public class USPSAddress {
        
        // in the USPS world, address 1 contains address 2 data (i.e. UNIT 101 or APT A)
        // So you will need to put the actual street address in address2 for proper parsing
        public string Address1 {get; set;}
        public string Address2 {get; set;}
        public string City {get; set;}
        public string State {get; set;}
        public string Zip5 {get; set;}
        public string Zip4 {get; set;}
        
        public boolean USPS_Returned_Error {get; set;}
        public string USPS_ERROR_CODE {get; set;}
        public string USPS_ERROR_DESC {get; set;}
        public string USPS_ERROR_SOURCE {get; set;}
        
        public USPSAddress() {
            Address1='';
            Address2='';
            City='';
            State='';
            Zip5='';
            Zip4='';
            
            USPS_Returned_Error = false;
            USPS_ERROR_CODE = '';
            USPS_ERROR_DESC = '';
            USPS_ERROR_SOURCE = '';         
        } // constructor
        
        public string getZip() {
            string ReturnValue = Zip5;
            
            if (Zip4 != null && Zip4 != '') {
                ReturnValue += '-' + Zip4;
            }
            
            return ReturnValue;
        }// getZip
        
        public boolean CanCheckAddress() {
            // this method is used to determine when the component can
            // make a valid call to the USPS validation service.
            
            // since some data is required, there is no need to send
            // the request until we have the min data required
                        
            boolean ReturnValue = false;
                        
            if (Address2 != '' && Address2 != null) {
                
                if (Zip5 != '') {
                    ReturnValue = true;
                } else if ((City != '') && (State != '')) {
                    ReturnValue = true;
                } // have city and state OR Zip
                
            } // Address2 != ''
            
            system.debug('>>>>>> CanCheckAddress: Returning: ' + ReturnValue);
            return ReturnValue;
        } // Can Check Address
        
        public boolean HasData() {
            // this will return false if everything was defaulted.
            boolean ReturnValue = false;
            
            if (Address1 !='') {
                ReturnValue = true;
            } else if (Address2 !='') {
                ReturnValue = true;
            } else if (City !='') {
                ReturnValue = true;
            } else if (State !='') {
                ReturnValue = true;
            } else if (Zip5 !='') {
                ReturnValue = true;
            } else if (Zip4 !='') {
                ReturnValue = true;
            } else if (USPS_Returned_Error !=false) {
                ReturnValue = true;
            } else if (USPS_ERROR_CODE !='') {
                ReturnValue = true;
            } else if (USPS_ERROR_DESC !='') {
                ReturnValue = true;
            } else if (USPS_ERROR_SOURCE !='') {
                ReturnValue = true;
            }

            return ReturnValue;
        } // HasData
        
   }