/**
 * Class to control trigger functionality.
 *
 * Note: this class should become unnecessary if we separate SA from Core and
 * test core functionality before the SA is loaded.
 */
public without sharing class TriggerController {
    
    /** controls operation of the Project trigger  */
    public static Boolean projectTriggerEnabled = true;
}