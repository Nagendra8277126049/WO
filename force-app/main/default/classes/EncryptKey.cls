public with sharing class EncryptKey {
    
    @AuraEnabled   
    public static List<String> getEncryptedValue(String pKey ) {
    String errMsg='Error in key Generation';
    List<String> retList=new List<String>();
    
    if (pKey!=null && pKey!='') {
    
        Blob cryptoKey = Crypto.generateAesKey(256); 
        retList.add(EncodingUtil.base64Encode(cryptoKey));  
        // Generate the data to be encrypted.
        
        Blob data = Blob.valueOf(pKey);
           
         
        
        // Encrypt the data and have Salesforce.com generate the initialization vector
        
        Blob encryptedData = Crypto.encryptWithManagedIV('AES256', cryptoKey, data);
        String b64DataEncryptKey = EncodingUtil.base64Encode(encryptedData);
        retList.add(b64DataEncryptKey);
         
        
        /*// Decrypt the data - the first 16 bytes contain the initialization vector
        
        Blob decryptedData = Crypto.decryptWithManagedIV('AES256', cryptoKey, encryptedData);
        
         
        
        // Decode the decrypted data for subsequent use
        
        String decryptedDataString = decryptedData.toString();
        
        System.debug(b64DataEncryptKey);
        
        system.debug(decryptedDataString);
        
        System.debug(EncodingUtil.base64Encode(cryptoKey));
        
         
        
        //Blob data = EncodingUtil.base64Decode(pitemName);
        
        //Blob newEncrypteddata = EncodingUtil.base64Decode(b64Data);
        
        Blob newEncrypteddata = EncodingUtil.base64Decode('NTBtsDUzLpPj4UPhtxoSNuoos3iJSYqE9mxbI23qYYKtMMpbH5uh1J/CBeTN6eqr');
        
        Blob newCryptoKey=EncodingUtil.base64Decode('88pb0dxR7IE7dKp+AncMBXRxNE7za5h6trr8mv34YlQ=');
        
        Blob newdecryptedData = Crypto.decryptWithManagedIV('AES256', newCryptoKey, newEncrypteddata);*/
        
        //system.debug(newdecryptedData.toString());
        //return b64DataEncryptKey ;
        //return retList;
       
    } else {
        retList.add(errMsg);
        
    }
    return retList;
}
}