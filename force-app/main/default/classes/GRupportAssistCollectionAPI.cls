public with sharing class GRupportAssistCollectionAPI {
        /*******************************************************************************************************
Name: GRupportAssistCollectionAPI.apxc
Description: Controller for agent journey, getting Support Assist Data using CollectionAPI for Flows
Story 5768144: KMT GR Agent Journey - Integration for getting Support Assist Data
*******************************************************************************************************
Date         Version            Author                Summary of Changes 
*******************************************************************************************************
02/01/2019     1.0       	Lovedeep Singh               Initial draft  
******************************************************************************************************/
    @InvocableMethod
    public static List<String> InvokeSupportAssistCollectionAPI(List<String> ServiceTag){
        list<String> SAattributes = new list<String>();
        String SMARTStatusTest='NA', SMARTThresholdsTest ='NA', RandomSeekTest ='NA', LinearReadTest='NA', HardDriveTest='NA';
        String BitLowTest = 'NA',BitHighTest = 'NA',NibbleMoveTest = 'NA',CheckerboardTest = 'NA',WalkingOnesLeftTest = 'NA',WalkingOnesRightTest = 'NA',AuxiliaryPatternTest = 'NA',AddressTest = 'NA',MovingInversionTest = 'NA',Modulo20Test = 'NA',WindowsMemoryTest = 'NA',MemoryTest='NA';
        String MotherBoardTest='NA', RTCAccuracyTest = 'NA', sAtt;        
        try{
            if(ServiceTag != null){
                system.debug('GRupportAssistCollectionAPI class, InvokeSupportAssistCollectionAPI method has started, Service tag is ' + ServiceTag);
                
                //for fetching collectionIDs using ServiceTag
                //String APIURL_SA = 'https://sit.apidp.dell.com/supportassist/asset/sit/'+ ServiceTag[0] + '/collection?apikey=d489e485-7384-4911-a94c-99511202d585'; 							                
                String APIURL_SA = Label.GR_DPCollectionIdURL + ServiceTag[0] + Label.GR_DPCollectionIdKEY;
                system.debug(APIURL_SA);
                HttpRequest req = new HttpRequest();
                req.setMethod('GET');
                req.setHeader('Token', Label.GR_DPCollectionIdTOKEN);
                req.setEndpoint(APIURL_SA);
                Http http = new Http();
                HttpResponse res = http.send(req);
                Integer statusCode = res.getStatusCode();
                system.debug('statusCode is ' + statusCode);
                if(statusCode == 200){
                    //system.debug(res.getBody());
                    map<String, object> m = (map<String, object>) JSON.deserializeUntyped(res.getBody());
                    List<Object> m1 = (List<Object>)m.get('dataFiles');
                    Map<String, Object> m2 = (Map<String, Object>)m1[0];
                    //for(Object dataFile: m1){
                    //Map<String, Object> m2 = (Map<String, Object>)dataFile;
                    //}
                    string CollectionId = (string)m2.get('fileToken');
                    system.debug(CollectionId);
                    
                    //for fetching jsonresponse using collectionID
                    //String APIURL = 'https://sit.apidp.dell.com/supportassist/sit/v1/clientCollection/'+ CollectionId +'/tree?apikey=c0831095-5908-4a10-b2c7-4bba099d6c9d'; 							                
                    String APIURL = Label.GR_DPCollectionIdDetailsURL + CollectionId + Label.GR_DPCollectionIdDetailsKEY;
                    system.debug(APIURL);
                    HttpRequest request = new HttpRequest();
                    request.setMethod('GET');
                    //request.setHeader('Token', '1df7616d-1e13-4edd-9a51-eef7b361aff8');
                    request.setHeader('Token', Label.GR_DPCollectionIdDetailsTOKEN);
                    request.setEndpoint(APIURL);
                    Http http1 = new Http();
                    HttpResponse response = http.send(request);
                    Integer statusCode1 = response.getStatusCode();
                    system.debug('CollectionID request statusCode is ' + statusCode1);
                    if(statusCode1 == 200){
                        //system.debug(response.getBody());
                        try{
                            List<Object> results = (List<Object>) JSON.deserializeUntyped(response.getBody());
                            for(Object result: results) {
                                Map<String,Object> a1=(Map<String,Object>)result;
                                
                                string objectClass = (string)a1.get('objectClass');
                                //System.debug(objectClass);
                                
                                if(objectClass == 'PCDrDiagnostic') {
                                    system.debug('FOUND OBJECT PCR');
                                    
                                    List<Object> a2 = (List<Object>)a1.get('relations');
                                    for(Object relations: a2){
                                        //system.debug(relations);
                                        Map<String, Object> a3 = (Map<String, Object>)relations;
                                        Map<string,object> a4 = (Map<string,object>)a3.get('fields');
                                        //System.debug('fields : '+a4);
                                        Set<string> fieldKeys = a4.keySet();
                                        
                                        for(string field: fieldKeys) {
                                            
                                            //System.debug('field number : '+field);
                                            
                                            Map<string, object> testResults = (Map<string, object>)a4.get(field);
                                            
                                            string testName = (string)testResults.get('Test GUID');
                                            string testResult = (string)testResults.get('Test Result');
                                            //System.debug('Test Name:'+testName);
                                            //System.debug('Test Result:'+testResult);
                                            
                                            //--HardDrive--//
                                            if(testName=='pcdrsmart2_SMARTStatusTest'){
                                                System.debug('Test Name:'+testName + '----- Test Result: ' + testResult);
                                                SMARTStatusTest = testResult;
                                                system.debug('SMARTStatusTest: '+ SMARTStatusTest);
                                            }
                                            if(testName=='pcdrsmart2_SMARTThresholdsTest'){
                                                System.debug('Test Name:'+testName + '----- Test Result: ' + testResult);
                                                SMARTThresholdsTest = testResult;
                                                system.debug('SMARTThresholdsTest: '+ SMARTThresholdsTest);
                                            }
                                            if(testName=='pcdrssd_RandomSeekTest'){
                                                System.debug('Test Name:'+testName + '----- Test Result: ' + testResult);
                                                RandomSeekTest = testResult;
                                                system.debug('RandomSeekTest: '+ RandomSeekTest);
                                            }
                                            if(testName=='pcdrssd_LinearReadTest'){
                                                System.debug('Test Name:'+testName + '----- Test Result: ' + testResult);
                                                LinearReadTest = testResult;
                                                system.debug('LinearReadTest: '+ LinearReadTest);
                                            }
                                            if(SMARTStatusTest.equalsIgnoreCase('Failed')||SMARTThresholdsTest.equalsIgnoreCase('Failed')||RandomSeekTest.equalsIgnoreCase('Failed')||LinearReadTest.equalsIgnoreCase('Failed')){
                                                HardDriveTest = 'Failed';
                                            }
                                            else if(SMARTStatusTest.equalsIgnoreCase('NA') && SMARTThresholdsTest.equalsIgnoreCase('NA') && RandomSeekTest.equalsIgnoreCase('NA') && LinearReadTest.equalsIgnoreCase('NA')){
                                                HardDriveTest = 'NA';
                                            }else{
                                                HardDriveTest = 'Passed';
                                            }
                                            
                                            //--MotherBoard--//
                                            if(testName=='pcdrmemory2_BitLowTest'){
                                                System.debug('Test Name:'+testName + '----- Test Result: ' + testResult);
                                                BitLowTest = testResult;
                                                system.debug('BitLowTest: '+ BitLowTest);
                                            }
                                            if(testName=='pcdrmemory2_BitHighTest'){
                                                System.debug('Test Name:'+testName + '----- Test Result: ' + testResult);
                                                BitHighTest = testResult;
                                                system.debug('BitHighTest: '+ BitHighTest);
                                            }
                                            if(testName=='pcdrmemory2_NibbleMoveTest'){
                                                System.debug('Test Name:'+testName + '----- Test Result: ' + testResult);
                                                NibbleMoveTest = testResult;
                                                system.debug('NibbleMoveTest: '+ NibbleMoveTest);
                                            }
                                            if(testName=='pcdrmemory2_CheckerboardTest'){
                                                System.debug('Test Name:'+testName + '----- Test Result: ' + testResult);
                                                CheckerboardTest = testResult;
                                                system.debug('CheckerboardTest: '+ CheckerboardTest);
                                            }
                                            if(testName=='pcdrmemory2_WalkingOnesLeftTest'){
                                                System.debug('Test Name:'+testName + '----- Test Result: ' + testResult);
                                                WalkingOnesLeftTest = testResult;
                                                system.debug('WalkingOnesLeftTest: '+ WalkingOnesLeftTest);
                                            }
                                            if(testName=='pcdrmemory2_WalkingOnesRightTest'){
                                                System.debug('Test Name:'+testName + '----- Test Result: ' + testResult);
                                                WalkingOnesRightTest = testResult;
                                                system.debug('WalkingOnesRightTest: '+ WalkingOnesRightTest);
                                            }
                                            if(testName=='pcdrmemory2_AuxiliaryPatternTest'){
                                                System.debug('Test Name:'+testName + '----- Test Result: ' + testResult);
                                                AuxiliaryPatternTest = testResult;
                                                system.debug('AuxiliaryPatternTest: '+ AuxiliaryPatternTest);
                                            }
                                            if(testName=='pcdrmemory2_AddressTest'){
                                                System.debug('Test Name:'+testName + '----- Test Result: ' + testResult);
                                                AddressTest = testResult;
                                                system.debug('AddressTest: '+ AddressTest);
                                            }
                                            if(testName=='pcdrmemory2_MovingInversionTest'){
                                                System.debug('Test Name:'+testName + '----- Test Result: ' + testResult);
                                                MovingInversionTest = testResult;
                                                system.debug('MovingInversionTest: '+ MovingInversionTest);
                                            }
                                            if(testName=='pcdrmemory2_Modulo20Test'){
                                                System.debug('Test Name:'+testName + '----- Test Result: ' + testResult);
                                                Modulo20Test = testResult;
                                                system.debug('Modulo20Test: '+ Modulo20Test);
                                            }
                                            if(testName=='pcdrmemory2_WindowsMemoryTest'){
                                                System.debug('Test Name:'+testName + '----- Test Result: ' + testResult);
                                                WindowsMemoryTest = testResult;
                                                system.debug('WindowsMemoryTest: '+ WindowsMemoryTest);
                                            }
                                            if(BitLowTest.equalsIgnoreCase('Failed')||BitHighTest.equalsIgnoreCase('Failed')||NibbleMoveTest.equalsIgnoreCase('Failed')||CheckerboardTest.equalsIgnoreCase('Failed')
                                               ||WalkingOnesLeftTest.equalsIgnoreCase('Failed')||WalkingOnesRightTest.equalsIgnoreCase('Failed')||AuxiliaryPatternTest.equalsIgnoreCase('Failed')||AddressTest.equalsIgnoreCase('Failed')
                                               ||MovingInversionTest.equalsIgnoreCase('Failed')||Modulo20Test.equalsIgnoreCase('Failed')||WindowsMemoryTest.equalsIgnoreCase('Failed')){
                                                   MemoryTest = 'Failed';
                                               }else if(BitLowTest.equalsIgnoreCase('NA') && BitHighTest.equalsIgnoreCase('NA') && NibbleMoveTest.equalsIgnoreCase('NA') && CheckerboardTest.equalsIgnoreCase('NA')
                                                        && WalkingOnesLeftTest.equalsIgnoreCase('NA') && WalkingOnesRightTest.equalsIgnoreCase('NA') && AuxiliaryPatternTest.equalsIgnoreCase('NA') && AddressTest.equalsIgnoreCase('NA')
                                                        && MovingInversionTest.equalsIgnoreCase('NA') && Modulo20Test.equalsIgnoreCase('NA') && WindowsMemoryTest.equalsIgnoreCase('NA')){
                                                            MemoryTest = 'NA';
                                                        }else{
                                                            MemoryTest = 'Passed';
                                                        }
                                            
                                            //--MotherBoard--//
                                            if(testName=='pcdrsystemboard_RTCAccuracyTest'){
                                                System.debug('Test Name:'+testName + '----- Test Result: ' + testResult);
                                                RTCAccuracyTest = testResult;
                                                system.debug('RTCAccuracyTest: '+ RTCAccuracyTest);
                                            }
                                            if(RTCAccuracyTest.equalsIgnoreCase('Failed')){
                                                MotherBoardTest = 'Failed';
                                            }
                                            else if(RTCAccuracyTest.equalsIgnoreCase('NA')){
                                                MotherBoardTest = 'NA';
                                            }else{
                                                MotherBoardTest = 'Passed';
                                            }
                                            //--sAtt--//
                                        }
                                    }
                                }
                            }
                        }
                        catch(Exception e){
                            system.debug(e);
                            ExceptionHandler.logHandledExceptions(e,'GRupportAssistCollectionAPI','InvokeSupportAssistCollectionAPI','KMT');
                        }
                        
                        //--//
                    }
                }
            }
            //
        }
        catch(exception e){
            //Handling exception
            ExceptionHandler.logHandledExceptions(e,'GRupportAssistCollectionAPI','InvokeSupportAssistCollectionAPI','KMT');
        }
        sAtt = HardDriveTest + ';' + MemoryTest + ';' + MotherBoardTest;
        system.debug('HardDriveTest: '+HardDriveTest);
        system.debug('MemoryTest: '+MemoryTest);
        system.debug('MotherBoardTest: '+MotherBoardTest);
        system.debug('sAtt: '+sAtt);
        SAattributes.add(sAtt);
        system.debug('return list is' + SAattributes);
        return SAattributes;
    }
}