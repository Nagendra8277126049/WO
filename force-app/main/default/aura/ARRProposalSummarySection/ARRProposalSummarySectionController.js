({
    initHandler : function(cmp) {
       var summary;
       summary = cmp.get("v.summary");     
       var total = 0;
       if(summary && summary!="Map")
       {
           for(var i = 0 ; i < summary.fees.length; i++){
               total+=summary.fees[i].totalValue; 
           }
       	}
       	cmp.set("v.feesSummantion", total);
    }

})