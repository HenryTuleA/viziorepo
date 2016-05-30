@isTest(SeeAllData=true)
public class Test_VizioSupport_ProcessXML{
    
    @isTest 
    static void testProcessXMLT(){
        List <VizioSupport_ProcessXML.FileObject> bucketObjList;
        List<VizioSupport_ProcessXML.FileObject> fObj = new  List<VizioSupport_ProcessXML.FileObject>();
        VizioSupport_ProcessXML pxml = new VizioSupport_ProcessXML();
        VizioSupport_ProcessXML.FileObject fOb  = new VizioSupport_ProcessXML.FileObject();
        
        string xmlstr = '<?xml version="1.0" encoding="utf-8"?> <ServiceRequest xmlns:msxsl="urn:schemas-microsoft-com:xslt" xmlns:vbs="urn:schemas-sqlxml-org:vbs"> <Header> <ServiceRequestInformation> <Action>Test22161010</Action> <CreateDate>22161010</CreateDate> <ServiceRequestNumber>0000603</ServiceRequestNumber> <ServiceRequestType>SR</ServiceRequestType> <ServiceProviderID>PRB</ServiceProviderID> </ServiceRequestInformation> </Header> <LineItems> <LineItem> <SKU>15151515151</SKU> <SerialNumber></SerialNumber> <Qty>3</Qty> <LineItemType>Send</LineItemType> <Grade></Grade> <TrackingNumber>1ZA8468801Y8909034</TrackingNumber> <ErrorCode></ErrorCode> <Carrier>FEDEX</Carrier> <Method>FEDEX Ground</Method> <Status>Cancel</Status> <Note></Note> <TransactionDate>2015-12-15</TransactionDate> </LineItem> </LineItems> <Footer> <Status /> </Footer> </ServiceRequest>';
        XmlStreamReader xsr = new XmlStreamReader(xmlstr);
        string xmlmsg = '<?xml version="1.0" encoding="UTF-8"?><ListBucketResult xmlns="http://s3.amazonaws.com/doc/2006-03-01/"><Name>forceunleashed</Name><Prefix>VHUB/INBOX/</Prefix><Marker></Marker><MaxKeys>1000</MaxKeys><Delimiter>/</Delimiter><IsTruncated>false</IsTruncated><Contents><Key>VHUB/INBOX/</Key><LastModified>2016-03-28T17:46:48.000Z</LastModified><ETag>&quot;d41d8cd98f00b204e9800998ecf8427e&quot;</ETag><Size>0</Size><Owner><ID>01c5085f8ba076c62fd879040d9e90632e3685effb1dd8bd8bf55427c5c1a0de</ID><DisplayName>aws-it</DisplayName></Owner><StorageClass>STANDARD</StorageClass></Contents><Contents><Key>VHUB/INBOX/HLPBACC1609241-20151215-0135.xml</Key><LastModified>2016-03-29T23:33:41.000Z</LastModified><ETag>&quot;6bc7895a26fbcc1ee8ceeb1f98b42680&quot;</ETag><Size>1463</Size><Owner><ID>01c5085f8ba076c62fd879040d9e90632e3685effb1dd8bd8bf55427c5c1a0de</ID><DisplayName>aws-it</DisplayName></Owner><StorageClass>STANDARD</StorageClass></Contents><Contents><Key>VHUB/INBOX/HLPBSR1608602-20151215-013.xml</Key><LastModified>2016-03-29T23:33:41.000Z</LastModified><ETag>&quot;1514f3fe9bbf98cc189b2d7029332ced&quot;</ETag><Size>1013</Size><Owner><ID>01c5085f8ba076c62fd879040d9e90632e3685effb1dd8bd8bf55427c5c1a0de</ID><DisplayName>aws-it</DisplayName></Owner><StorageClass>STANDARD</StorageClass></Contents></ListBucketResult>';        
        XmlStreamReader xmsg = new XmlStreamReader(xmlmsg);
        
        Test.setMock(HttpCalloutMock.class, new ProcessXMLHttpResponse());
        
        fOb.key  = 'HEXIL';
        fOb.size = 2000;
        fOb.xmlfile = xmlstr;
        fOb.delStatus = 200;
        fObj.add(fOb);
        
        bucketObjList = pxml.parseFiles(xmsg);
        
        bucketObjList = pxml.readXMLFile(fObj); 
        pxml.createSRLineItemRecords(bucketObjList);
        pxml.updateTransLog(bucketObjList); 
       
       
    }
}