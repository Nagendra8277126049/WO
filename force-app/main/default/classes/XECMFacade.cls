/**
 * This class is an entry point xecm Managed Package
 *
 */
public class XECMFacade {
    
    /* This method is entry point for XECM Managed Package */
    public static void raiseStandardEvent(List<ID> recordIDs, List<String> eventParameters) {
        if (!Test.isRunningTest()) {
            if( isValidLicense() ) {
                xecm.IBusinessEventService svc = xecm.ServiceFactory.getInstance().getBusinessEventService();
                svc.raiseStandardEvent(recordIDs, eventParameters);
            } else {
                System.debug('License for OpenText Extended ECM is Expired');
            }
        } else {
            new zzMockBusinessEventService().raiseStandardEvent(recordIDs, eventParameters);
        }
    }

    public static void processContents(List<sObject> sObjects) {
        if (!Test.isRunningTest()) {
            if( isValidLicense() ) {
                xecm.ServiceFactory.getInstance2().getBusinessEventService2().processContents(sObjects);
            } else {
                System.debug('License for OpenText Extended ECM is Expired');
            }
        } else {
            new zzMockBusinessEventService().processContents(sObjects);
        }
    }
    
    /* This method checks if license is valid or not */
    private static boolean isValidLicense() {
        return UserInfo.isCurrentUserLicensed('xecm');
    }
}