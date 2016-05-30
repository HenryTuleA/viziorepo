/*
 *
 *  When an attachment is created and the parentID is a case then a trigger fires and calls this class with its methods 
 *	it moves the attachment to AWS S3 and then cretes  Document__c record with the link to the attachment anf finally 
 *	updates the flag isPopVerify__c from the asset associated with the case 
 *  Note: in order for the Document__d.Document_URL__c to work we need to make sure that the folder in AWS /500 is public 
 *	
 */


global class VizioSupport_AWSAttachment {



	
	// This method gets called from a trigger in order to move an attachment to Amazon - AWS S3 
	// parameter attID is the ID from the attachment and caseID is the parentID that we will use to name the folder  
	
	@future(Callout=true)
	public static void uploadAttachment(ID attID, String caseNumber)
	{	
		AWS_Keys__c awsKeySet;
    	String bucketName;
    	String attachmentString;
    	String method;
    	String filePathName;
    	String attachmentName;
    	String formattedDateString;
    	HttpRequest req;


    	bucketName = 'forceunleashed'; //'cris-bucket';
		method = 'PUT';
		//formattedDateString = DateTime.now().formatGMT('EEE, dd MMM yyyy HH:mm:ss z');
		formattedDateString = Datetime.now().format('EEE, dd MMM yyyy HH:mm:ss z','America/Los_Angeles');
		req = new HttpRequest();


		awsKeySet= AWS_Keys__c.getInstance(bucketName);

		String endpoint   = awsKeySet.AWS_Endpoint_URL__c; 
		String region     = awsKeySet.AWS_Region__c;
		String key        = awsKeySet.AWS_AccessKey_Id__c;
        String secret     = awsKeySet.AWS_Secret_Key__c ;

        System.debug( endpoint + ' ' + region + ' ' + key + ' ' + secret );

        //Query for the attachment and setup the path in which the file will be saved
        Attachment a = getAttachment(attID);
        attachmentName = a.Name.replace(' ', '+');
        filePathName = '500/'+ caseNumber + '/' + attachmentName;
        String binaryString=String.ValueOf(a.body);


        System.debug('Attachment Name = ' + a.Name + ' attachmentName: ' + attachmentName + ' filePathName: ' + filePathName);


        req.setHeader('Content-Type', '');
        req.setMethod(method);
        req.setHeader('Content-Disposition', 'attachment');
        
        

        //NOTICE THAT IN THE CUSTOM SETTING YOU NEED EXACTLY THIS STRING FOR REGION: 's3-us-west-2.amazonaws.com'
        //req.setHeader('Host', 's3-us-west-2.amazonaws.com'); 
        req.setHeader('Host', region);  


        //end point must look like: ----> https://s3-us-west-2.amazonaws.com/bucketname/filepathName
        req.setEndpoint(endpoint + bucketname +'/'+ filePathname);
        req.setHeader('Content-Type', '');
        req.setMethod(method);
        req.setHeader('Date', formattedDateString);
        req.setHeader('Authorization', createAuthHeader(method, filePathName, formattedDateString, bucketname, key, secret));


        req.setBodyAsBlob(a.body);
        req.setHeader('Content-Length', string.valueOf(binaryString.length()));   



        
        if(binaryString != null && binaryString != '')
        {
	        req.setBodyAsBlob(a.body);
	        String status;
	        Integer code;
	        Http http = new Http();


	         try
	         {
	          	//Execute web service call
				HTTPResponse res = http.send(req);

	            System.debug('RESPONSE STRING: ' + res.toString());
	            System.debug('RESPONSE STATUS: ' +res.getStatus());
	            System.debug('STATUS_CODE: ' +res.getStatusCode());
	            System.debug(' GET_BODY: ' +res.getBody());

	            status = res.getStatus();
	            code = res.getStatusCode();
	 
	        } catch(System.CalloutException e) {
	            system.debug('AWS Service Callout Exception: ' + e.getMessage());
	        }

	    	if( status == 'OK' && code == 200 )
	    	{
	    		delete a;
	    		System.debug('Attachment has been deleted from Case and moved to AWS');

	    		createLinkAndDocument(a.Name , filePathName, a.ParentID, endpoint, bucketName);
	    		System.debug('A document with the link has been created');

	    		updatePOPFlag(a.parentID);
	    	}

	    }

	}



	//Create AturhorizationHeader for AWS S3 REST API
	public static string createAuthHeader(String method, String filename, String formattedDateString, String bucket, String key, String secret)
	{
        string auth;
        
        String stringToSign = method + '\n\n\n' + formattedDateString + '\n/' + bucket + '/' + filename;
        Blob mac = Crypto.generateMac('HMACSHA1', blob.valueof(stringToSign), blob.valueof(secret));
        String sig = EncodingUtil.base64Encode(mac);
        auth = 'AWS' + ' ' + key + ':' + sig;
        
        return auth;
    }


	private static Attachment getAttachment(ID attID)
	{
		Attachment a =
		[	
			SELECT ID, Name, Body, ParentID
			FROM Attachment
			Where ID =: attID
		];

		return a;
	}



	private static void createLinkAndDocument(String fileName, String path, ID caseID, String endpoint, String bucketName)
	{
		//https://s3-us-west-2.amazonaws.com/forceunleashed/500/50017000003k1nJ/User+Story+Amazon+AWS.png

		Document__c doc = new Document__c();

		doc.Name = fileName;
		doc.Document_Name__c = fileName.replace(' ','+');
		doc.Document_FilePath__c = path;
		doc.Case__c = caseID;
		doc.Document_URL__c = endpoint + bucketname +'/'+ path; //endpoint alredy contains a /
		doc.Status__c ='Uploaded';

		insert doc;

	}



	private static void updatePOPFlag(ID caseID)
	{
		//Query for the case so that we can later get the asset
		Case case1 = 
		[
			SELECT ID, Asset.ID
			FROM Case
			Where ID =: caseID
		]; 

		//Query for the asset in order to update the flag
		Asset asset1;
		try {
			
			asset1 = 
			[
				SELECT ID, isPopVerify__c
				FROM Asset
				Where ID =: case1.Asset.ID
			];
		} catch (Exception e){

			System.debug('Error when querying for an asset. The case does not have an Asset associated ' + e);
		}



		if (asset1 != null)
		{
			asset1.isPopVerify__c = true;

			update asset1;
		}
		

	}


}