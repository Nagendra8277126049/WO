public class ARRCreateInvoiceController {
    @AuraEnabled
    public static String GetSettlementRecoveryBalance(String valueRecoveryBalanceID){
        ValueRecoveryBalance__x balance = new ValueRecoveryBalance__x();
        if(!Test.isRunningTest()){
        	balance = [select v.Id from ValueRecoveryBalance__x v where v.ValueRecoveryBalanceID__c = :valueRecoveryBalanceID LIMIT 1];
        }
        else{
            balance = CreateBalanceMock();
        }
        return balance.Id;
    }
    
    private static ValueRecoveryBalance__x CreateBalanceMock(){
        ValueRecoveryBalance__x balanceMock = new ValueRecoveryBalance__x();
        balanceMock.ValueRecoveryBalanceID__c = '620c1a93-0b40-426b-2245-08d634f76640';
        return balanceMock;
    }
}