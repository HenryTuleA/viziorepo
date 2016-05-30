/***************************************************************************
Created By : Henry Akpala
Created Date : 02/14/2016
    
    Class to call the AWS S3 and get, delete or send request. 
    Input:     
            docName => Name of document to delete
            folderName => Url of folder
    Output:
            
   
***************************************************************************/
  
  
  public class VizioSupport_AWSIntegration{
    public VizioSupport_ErrorObj vErrObj ;
    public Integer statusCode = 400;
    public AWS_Keys__c awsKeySet;

    public String key; 
    public String region; 
    public String endpoint; 
    public String secret; 
    public String prefix;
    public String bucketname; 
    public String xmlMessage = null; 
    
    
    public String bucket = 'forceunleashed';
    
   /**
     * Constructor to get variable from AWS_Keys__c object
    **/
    public VizioSupport_AWSIntegration(){
        
        awsKeySet= AWS_Keys__c.getInstance(bucket);      
        key        = awsKeySet.AWS_AccessKey_Id__c;
        region     = awsKeySet.AWS_Region__c;
        endpoint   = awsKeySet.AWS_Endpoint_URL__c;  
        secret     = awsKeySet.AWS_Secret_Key__c ;
        prefix     = awsKeySet.AWS_Prefix_Path__c;
        bucketname = awsKeySet.Name;
    
    }
       
    /**
     * Method is used to create authorization header for Amazon S3 REST API
     *
     * @param         string
     * @return        string       
     * @since         1.0
    **/ 
    public string createAuthHeader(String method,String filename,String formattedDateString,String bucket,String key,String secret){
        string auth;
        String stringToSign = method+'\n\n\n'+formattedDateString+'\n/'+bucket +'/'+filename;
        Blob mac = Crypto.generateMac('HMACSHA1', blob.valueof(stringToSign),blob.valueof(secret));
        String sig = EncodingUtil.base64Encode(mac);
        auth = 'AWS' + ' ' + key + ':' + sig;
        return auth;
    }
 
    /**
     * Method used to delete files from the amazon s3 location  
     *
     * @param         string[documentName and FolderName]
     * @return        Integer[StatusCode] 
     * @since         1.0
    **/
    public Integer deleteFromS3(String docName, String folderName){         
        
        String formattedDateString = Datetime.now().format('EEE, dd MMM yyyy HH:mm:ss z','America/Los_Angeles');    //this is needed for the PUT operation and the generation of the signature.  I use my local time zone.        
        String method     = 'DELETE';
        String filename   = folderName;
        
        HttpRequest req = new HttpRequest();
        Http http = new Http();
        
        req.setHeader('Content-Type', '');
        req.setMethod(method);
        
        req.setHeader('Host', region);  
        req.setEndpoint(endpoint+ bucketname + '/'+ filename);
        
        req.setHeader('Content-Disposition', 'attachment');
        req.setHeader('Content-Type', '');
        req.setMethod(method);
        req.setHeader('Date', formattedDateString);
        req.setHeader('Authorization',createAuthHeader(method,filename,formattedDateString,bucketname,key,secret));
        
        //Execute web service call
        try {
            HTTPResponse res = http.send(req);
            statusCode = res.getStatusCode();
            return statusCode;
        } catch(System.CalloutException e) {
            system.debug('MYDEBUG: AWS Service Callout Exception on ' + docName + 'ERROR: ' + e.getMessage());
            return statusCode;
        }
        
    }
    
     
    /**
     * Method used to GET the xml files from the amazon s3 location  
     *     Called from VizioSupport_ProcessXML.readGetFileAmazonS3()
     * @param         string[documentName]
     * @return        String       
     * @since         1.0
    **/
    public String saveGetFileFromVirtualS3(String filename){                   
        
        //setup variables
        String formattedDateString = Datetime.now().format('EEE, dd MMM yyyy HH:mm:ss z','America/Los_Angeles');    //this is needed for the PUT operation and the generation of the signature.  I use my local time zone.        
        String method = 'GET';
        HttpRequest req = new HttpRequest();
        Http http = new Http();
          
        req.setHeader('Content-Type', '');
        req.setMethod(method);
       
        req.setHeader('Host', region);  
        req.setEndpoint(endpoint+ bucketname + '/'+ filename);
        
        req.setHeader('Content-Type', '');
        req.setMethod(method);
        req.setHeader('Date', formattedDateString);
        req.setHeader('Authorization',createAuthHeader(method,filename,formattedDateString,bucketname,key,secret));
         try {
                HTTPResponse res = http.send(req);
                //System.debug('MYDEBUG: '  + ' GET_BODY:'+res.getBody());
                xmlMessage = res.getBody();
            } catch(System.CalloutException e) {
                //system.debug('MYDEBUG: AWS Service Callout Exception on ' + 'ERROR: ' + e.getMessage());
            }           
            return xmlMessage;
    }
           
    /**
     * Method is used to write xml file to AmazonS3.
     *     Called from VizioSupport_XMLGenerator.GetInformation()
     * @param         String [DocumentName, XMLFile and Path]
     * @return        XmlStreamReader data       
     * @since         1.0
    **/      
    public VizioSupport_ErrorObj saveXMLToVirtualS3(String docName, String XMLFile, String SRProvider){   
            vErrObj = new VizioSupport_ErrorObj();
            
            Integer statusCode = 400;
            
            //this is needed for the PUT operation and the generation of the signature.  I use my local time zone.        
            String formattedDateString = Datetime.now().format('EEE, dd MMM yyyy HH:mm:ss z','America/Los_Angeles');    
            String method = 'PUT';
            
            HttpRequest req = new HttpRequest();
            Http http = new Http();
           
            String filename = SRProvider+docName;
            filename = filename.substring(1);
            
            req.setHeader('Content-Disposition', 'attachment');
            req.setHeader('Content-Type', '');
            req.setMethod(method);
            req.setHeader('ACL','public-read');
            
            req.setHeader('Host', region);  
            req.setEndpoint(endpoint + bucketname + '/' +  filename);  
            
            req.setHeader('Date', formattedDateString);
            req.setHeader('Authorization',createAuthHeader(method,filename,formattedDateString,bucketname,key,secret));
        
            String binaryString=String.ValueOf(XMLFile);
        
            if(binaryString != null && binaryString != ''){
                req.setBody(XMLFile);
            
                req.setHeader('Content-Length', string.valueOf(binaryString.length()));           
                //Execute web service call
                try {
                    HTTPResponse res = http.send(req);
                    vErrObj.ErrCode     = res.getStatusCode();
                    vErrObj.ErrStatus   = res.getStatus();
                    vErrObj.ErrBody     = res.getBody();
                    vErrObj.ErrFolder   = filename;
                    return vErrObj;
                    
                } catch(System.CalloutException e) {
                    //system.debug('MYDEBUG: AWS Service Callout Exception on ' + docName + 'ERROR: ' + e.getMessage());
                    vErrObj.ErrCode = StatusCode;
                    vErrObj.ErrMsg  = e.getMessage();
                    vErrObj.ErrFolder   = filename;
                    return vErrObj;
                }
            }
            return vErrObj;

    }
   
    /**
     * Method is used to retreive file list from AmazonS3. 
     *     Called from VizioSupport_ProcessXML.readGetFromVirtualS3()
     * @param         none
     * @return        XmlStreamReader data       
     * @since         1.0
    **/    
    public XmlStreamReader readGetFilesFromAmazonS3(){   
        String formattedDateString = Datetime.now().format('EEE, dd MMM yyyy HH:mm:ss z','America/Los_Angeles');    
        String method = 'GET';
        String filename = ''; 
        
        HttpRequest req = new HttpRequest();
        Http http = new Http();
        req.setHeader('Content-Type', '');
        req.setMethod(method);
        
        //use set to store params and encoding  prefix value = 'Vhub/inbox/'
        
        Set<String> getParams = new Set<String> {
            'prefix=' + EncodingUtil.urlEncode(prefix,'UTF-8'),
            'delimiter=' + EncodingUtil.urlEncode('/', 'UTF-8')           
        };
        
        List<String> paramList = new List<String>(getParams);    
        String params = String.join(paramList, '&');
        String endpointBase = endpoint+ bucketname + '/'+ filename;
        
        req.setEndpoint(endpointBase + '?' + params);
        req.setHeader('Content-Type', ''); 
        req.setMethod(method);
        req.setHeader('Date', formattedDateString);
        req.setHeader('Authorization',createAuthHeader(method,filename,formattedDateString,bucketname,key,secret));
        HTTPResponse res;
        XmlStreamReader reader;
        //Execute web service call
        try {
            res = http.send(req);
            reader = res.getXmlStreamReader();    
           // system.debug('MY =>: ' +  res.getBody());            
        } catch(System.CalloutException e) {
            system.debug('MYDEBUG: AWS Service Callout Exception on ' + 'ERROR: ' + e.getMessage());            
        }
        return reader;
    }
    
    
}