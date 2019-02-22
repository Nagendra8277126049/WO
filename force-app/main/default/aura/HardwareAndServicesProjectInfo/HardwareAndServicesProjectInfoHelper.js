({
	convertArrayOfObjectsToCSV : function(component,objectRecords) {       
        // check if "objectRecords" parameter is null, then return from function
        if (objectRecords == null || !objectRecords.length) {
            return null;
         }
        // store ,[comma] in columnDivider variabel for sparate CSV values and 
        // for start next line use '\n' [new line] in lineDivider varaible  
        var columnDivider = ',';
        var lineDivider =  '\n';
 
        // in the keys valirable store fields API Names as a key 
        // this labels use in CSV file header 
        var headers = ['Order #','Tie #','SKU #','SKU Description','Quantity', 'Item Class / LOB Description']; 
        var keys = ['orderNumber','Tie_Number__c','SKU_Number__c','SKU_Description__c','Quantity', 'classLobDescription'];
        
        var csvStringResult = '';
        csvStringResult += headers.join(columnDivider);
        csvStringResult += lineDivider;
 
        for(var i=0; i < objectRecords.length; i++){   
            var counter = 0;
           
             for(var sTempkey in keys) {
                var skey = keys[sTempkey] ;  
 
              // add , [comma] after every String value,. [except first]
                  if(counter > 0){ 
                      csvStringResult += columnDivider; 
                   }   
               
                 csvStringResult += objectRecords[i][skey] != undefined ? '"'+ objectRecords[i][skey]+'"' : ''; 
               
               counter++;
 
            } // inner for loop close 
             csvStringResult += lineDivider;
          }// outer main for loop close 
       
       // return the CSV formate String 
        return csvStringResult;        
    }
})