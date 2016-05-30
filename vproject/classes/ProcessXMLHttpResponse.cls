@isTest(SeeAllData=true)
global class ProcessXMLHttpResponse implements HttpCallOutMock{
    global HTTPResponse respond (HTTPRequest request){
       
        string resbody = '<?xml version="1.0" encoding="UTF-8"?><ListBucketResult xmlns="http://s3.amazonaws.com/doc/2006-03-01/"><Name>forceunleashed</Name><Prefix>VHUB/INBOX/</Prefix><Marker></Marker><MaxKeys>1000</MaxKeys><Delimiter>/</Delimiter><IsTruncated>false</IsTruncated><Contents><Key>VHUB/INBOX/</Key><LastModified>2016-03-28T17:46:48.000Z</LastModified><ETag>&quot;d41d8cd98f00b204e9800998ecf8427e&quot;</ETag><Size>0</Size><Owner><ID>01c5085f8ba076c62fd879040d9e90632e3685effb1dd8bd8bf55427c5c1a0de</ID><DisplayName>aws-it</DisplayName></Owner><StorageClass>STANDARD</StorageClass></Contents><Contents><Key>VHUB/INBOX/HLPBACC1609241-20151215-0135.xml</Key><LastModified>2016-03-29T23:33:41.000Z</LastModified><ETag>&quot;6bc7895a26fbcc1ee8ceeb1f98b42680&quot;</ETag><Size>1463</Size><Owner><ID>01c5085f8ba076c62fd879040d9e90632e3685effb1dd8bd8bf55427c5c1a0de</ID><DisplayName>aws-it</DisplayName></Owner><StorageClass>STANDARD</StorageClass></Contents><Contents><Key>VHUB/INBOX/HLPBSR1608602-20151215-013.xml</Key><LastModified>2016-03-29T23:33:41.000Z</LastModified><ETag>&quot;1514f3fe9bbf98cc189b2d7029332ced&quot;</ETag><Size>1013</Size><Owner><ID>01c5085f8ba076c62fd879040d9e90632e3685effb1dd8bd8bf55427c5c1a0de</ID><DisplayName>aws-it</DisplayName></Owner><StorageClass>STANDARD</StorageClass></Contents></ListBucketResult>';
        //System.assertEquals('GET', request.getMethod());
        HttpResponse response = new HttpResponse();
        response.setHeader('Content-Type', '');
        response.setStatusCode(200);
        response.setBody(resbody);
        return response;
    }
}