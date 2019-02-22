@isTest
private class Service1CommonAPIUlitity_Test {
    static testMethod void Service1CommonAPIUlitity(){    
       
            Service1CommonAPIUlitity scu = new Service1CommonAPIUlitity();
            
            Test.setMock(HttpCalloutMock.class, new Service1CommonAPIUlitityMock());
          
            JSONGenerator gen = JSON.createGenerator(true);  
            // Write data to the JSON string.
            gen.writeStartObject();
            gen.writeStringField('ServiceTag', 'MyAsset');
            
            // will construct standard request header details
            CommonRequestHeader MessageHeader = new CommonRequestHeader();
            gen.writeFieldName('MessageHeader');
            gen.writeObject(MessageHeader);
            gen.writeEndObject();
            String pretty = gen.getAsString();
            scu.sendAPIRequest('callout:AssetContactUpdate',pretty,'POST',assetContactDetailsJSON.class);
            System.AssertEquals(200,scu.statusCode);  
       
    }
    
    public class Service1CommonAPIUlitityMock implements HttpCalloutMock{
        
        Public HttpResponse respond(HttpRequest req){
            System.assertEquals('callout:AssetContactUpdate', req.getEndpoint());
            System.assertEquals('POST', req.getMethod());
            
            // Create a fake response
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json;charset=UTF-8');
            string res2='{"serviceTag":"MyAsset","firstName":"John","lastName":"Smith","email":"John@sm.com","areaCode":"CA","countryCode":"12234","extension":"9089898765","phoneNumber":"9090909090","addressType":"CA","secondaryFirstName":"Micheal","secondaryLastName":"Steve","secondaryEmail":"Steve@oc.com","secondaryAreaCode":"CAS","secondaryCountryCode":"DAD","secondaryExtension":"123456789","secondaryPhoneNumber":"9898989898","secondaryAddressType":"Current","tertiaryFirstName":"Bob","tertiaryLastName":"Steve","tertiaryEmail":"bob@re.com","tertiaryAreaCode":"78788","tertiaryCountryCode":"87877","tertiaryExtension":"8989898989","tertiaryPhoneNumber":"7898990871","tertiaryAddressType":"Current"}';
            res.setBody(res2);
            res.setStatusCode(200);
            
            return res;
        } 
    }
    
    //exception block covering.
    static testMethod void Service1CommonAPIUlitityException(){    
        
            Service1CommonAPIUlitity scu = new Service1CommonAPIUlitity();
            
            //Test.setMock(HttpCalloutMock.class, new Service1CommonAPIUlitityNegativeMock());
           
            JSONGenerator gen = JSON.createGenerator(true);  
            // Write data to the JSON string.
            gen.writeStartObject();
            gen.writeStringField('ServiceTag', 'MyAsset');
            
            // will construct standard request header details
            CommonRequestHeader MessageHeader = new CommonRequestHeader();
            gen.writeFieldName('MessageHeader');
            gen.writeObject(MessageHeader);
            gen.writeEndObject();
            String pretty = gen.getAsString();
            scu.sendAPIRequest('callout:AssetContactUpdate',pretty,'POST',assetContactDetailsJSON.class);
            System.AssertEquals(null,scu.statusCode);  
       
    }
    
    //negative testing.
    static testMethod void Service1CommonAPIUlitityNegative(){    
        
            Service1CommonAPIUlitity scu = new Service1CommonAPIUlitity();
            
            Test.setMock(HttpCalloutMock.class, new Service1CommonAPIUlitityNegativeMock());
           
            JSONGenerator gen = JSON.createGenerator(true);  
            // Write data to the JSON string.
            gen.writeStartObject();
            gen.writeStringField('ServiceTag', 'MyAsset');
            
            // will construct standard request header details
            CommonRequestHeader MessageHeader = new CommonRequestHeader();
            gen.writeFieldName('MessageHeader');
            gen.writeObject(MessageHeader);
            gen.writeEndObject();
            String pretty = gen.getAsString();
            scu.sendAPIRequest('callout:AssetContactUpdate',pretty,'POST',assetContactDetailsJSON.class);
            System.AssertEquals(400,scu.statusCode);  
       
    }
    
    public class Service1CommonAPIUlitityNegativeMock implements HttpCalloutMock{
        
        Public HttpResponse respond(HttpRequest req){
            System.assertEquals('callout:AssetContactUpdate', req.getEndpoint());
            System.assertEquals('POST', req.getMethod());
            
            // Create a fake response
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json;charset=UTF-8');
            string res2='{"serviceTag":"MyAsset","firstName":"John","lastName":"Smith","email":"John@sm.com","areaCode":"CA","countryCode":"12234","extension":"9089898765","phoneNumber":"9090909090","addressType":"CA","secondaryFirstName":"Micheal","secondaryLastName":"Steve","secondaryEmail":"Steve@oc.com","secondaryAreaCode":"CAS","secondaryCountryCode":"DAD","secondaryExtension":"123456789","secondaryPhoneNumber":"9898989898","secondaryAddressType":"Current","tertiaryFirstName":"Bob","tertiaryLastName":"Steve","tertiaryEmail":"bob@re.com","tertiaryAreaCode":"78788","tertiaryCountryCode":"87877","tertiaryExtension":"8989898989","tertiaryPhoneNumber":"7898990871","tertiaryAddressType":"Current"}';
            res.setBody(res2);
            res.setStatusCode(400);
            
            return res;
        } 
    }
}