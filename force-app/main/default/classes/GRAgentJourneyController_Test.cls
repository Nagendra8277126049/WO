@isTest
public class GRAgentJourneyController_Test {
    private static integer flag=0;
    public class GRAgentHttpCalloutMock implements HttpCalloutMock {
   		// Implement this interface method
    	public HTTPResponse respond(HTTPRequest request) {
                
        // Create a fake response
        HttpResponse response = new HttpResponse();
        response.setHeader('Content-Type', 'application/json;charset=UTF-8');
            if(flag==1){
                response.setBody('{"serviceTag":"C19TR72","model":"Latitude E5470","biosVersion":"1.18.6","hardDrives":{"Hard Drive 1":{"Model":"SAMSUNG SSD PM871 M.2 2280 256GB","Disk ePPID":"CN00T52D7845261K03ZL"}},"videoCard":{"Video Controller":"Intel(R) HD Graphics 520","Video RAM Bytes":"1073741824"},"os":"Microsoft Windows 10 Enterprise[64-bit OS][System Locale en-US]","deviceType":"Client","driverDetails":[{"driverName":"ACPI Fixed Feature Button","driverVersion":"10.0.15063.966"},{"driverName":"ACPI Lid","driverVersion":"10.0.15063.966"},{"driverName":"ACPI Power Button","driverVersion":"10.0.15063.966"},{"driverName":"ACPI Sleep Button","driverVersion":"10.0.15063.966"},{"driverName":"ACPI Thermal Zone","driverVersion":"10.0.15063.966"},{"driverName":"ACPI x64-based PC","driverVersion":"10.0.15063.0"},{"driverName":"Airplane Mode Switch","driverVersion":"1.4.2.0"},{"driverName":"Airplane Mode Switch Collection","driverVersion":"1.4.2.0"},{"driverName":"Audio Endpoint","driverVersion":"10.0.15063.502"},{"driverName":"Bluetooth Device (Personal Area Network)","driverVersion":"10.0.15063.608"},{"driverName":"Bluetooth Device (RFCOMM Protocol TDI)","driverVersion":"10.0.15063.540"},{"driverName":"Charge Arbitration Driver","driverVersion":"10.0.15063.0"},{"driverName":"Composite Bus Enumerator","driverVersion":"10.0.15063.0"},{"driverName":"Dell ControlVault w/o Fingerprint Sensor","driverVersion":"4.6.25.41"},{"driverName":"Dell Data Vault Control Device","driverVersion":"2.0.1.0"},{"driverName":"Dell Radio Control Device","driverVersion":"1.0.0.4"},{"driverName":"Dell Touchpad","driverVersion":"10.1207.101.103"},{"driverName":"Dell VPN Adapter","driverVersion":"11.3.0.336"},{"driverName":"Disk drive","driverVersion":"10.0.15063.850"},{"driverName":"ECP Printer Port","driverVersion":"10.0.15063.0"},{"driverName":"Generic PnP Monitor","driverVersion":"10.0.15063.0"},{"driverName":"Generic software device","driverVersion":"10.0.15063.0"},{"driverName":"Generic volume shadow copy","driverVersion":"10.0.15063.0"},{"driverName":"HID-compliant mouse","driverVersion":"10.0.15063.0"},{"driverName":"HUAWEI Mobile Connect - Bus Enumerate Device","driverVersion":"2.6.2.3155"},{"driverName":"High Definition Audio Controller","driverVersion":"10.0.15063.502"},{"driverName":"High precision event timer","driverVersion":"10.0.15063.966"},{"driverName":"Intel Processor","driverVersion":"10.0.15063.1155"},{"driverName":"Intel(R) 100 Series Chipset Family LPC Controller/eSPI Controller - 9D48","driverVersion":"10.1.1.9"},{"driverName":"Intel(R) 100 Series Chipset Family PCI Express Root Port #11 - 9D1A","driverVersion":"10.1.1.9"},{"driverName":"Intel(R) 100 Series Chipset Family PCI Express Root Port #5 - 9D14","driverVersion":"10.1.1.9"},{"driverName":"Intel(R) 100 Series Chipset Family PMC - 9D21","driverVersion":"10.1.1.9"},{"driverName":"Intel(R) 100 Series Chipset Family SMBUS - 9D23","driverVersion":"10.1.1.9"},{"driverName":"Intel(R) 100 Series Chipset Family Thermal subsystem - 9D31","driverVersion":"10.1.1.9"},{"driverName":"Intel(R) 6th Generation Core Processor Family Platform I/O SATA AHCI Controller","driverVersion":"15.7.5.1025"},{"driverName":"Intel(R) Display Audio","driverVersion":"10.24.0.3"},{"driverName":"Intel(R) Dual Band Wireless-AC 8260","driverVersion":"19.2.0.1"},{"driverName":"Intel(R) Dynamic Platform and Thermal Framework Generic Participant","driverVersion":"8.2.10900.330"},{"driverName":"Intel(R) Dynamic Platform and Thermal Framework Manager","driverVersion":"8.2.10900.330"},{"driverName":"Intel(R) Dynamic Platform and Thermal Framework Processor Participant","driverVersion":"8.2.10900.330"},{"driverName":"Intel(R) Ethernet Connection I219-LM","driverVersion":"12.15.25.6"},{"driverName":"Intel(R) HD Graphics 520","driverVersion":"23.20.16.4973"},{"driverName":"Intel(R) Management Engine Interface","driverVersion":"11.5.0.1019"},{"driverName":"Intel(R) Power Engine Plug-in","driverVersion":"10.0.15063.1182"},{"driverName":"Intel(R) Wireless Bluetooth(R)","driverVersion":"18.1.1546.2762"},{"driverName":"Legacy device","driverVersion":"10.0.15063.966"},{"driverName":"Local Print Queue","driverVersion":"10.0.15063.0"},{"driverName":"Microsoft AC Adapter","driverVersion":"10.0.15063.0"},{"driverName":"Microsoft ACPI-Compliant Control Method Battery","driverVersion":"10.0.15063.0"},{"driverName":"Microsoft ACPI-Compliant Embedded Controller","driverVersion":"10.0.15063.966"},{"driverName":"Microsoft ACPI-Compliant System","driverVersion":"10.0.15063.966"},{"driverName":"Microsoft Basic Display Driver","driverVersion":"10.0.15063.0"},{"driverName":"Microsoft Basic Render Driver","driverVersion":"10.0.15063.966"},{"driverName":"Microsoft Bluetooth Enumerator","driverVersion":"10.0.15063.1058"},{"driverName":"Microsoft Bluetooth LE Enumerator","driverVersion":"10.0.15063.1112"},{"driverName":"Microsoft Hyper-V PCI Server","driverVersion":"10.0.15063.1324"},{"driverName":"Microsoft Hyper-V Virtual Disk Server","driverVersion":"10.0.15063.1155"},{"driverName":"Microsoft Hyper-V Virtual Machine Bus Provider","driverVersion":"10.0.15063.1324"},{"driverName":"Microsoft Hyper-V Virtualization Infrastructure Driver","driverVersion":"10.0.15063.1266"},{"driverName":"Microsoft Kernel Debug Network Adapter","driverVersion":"10.0.15063.0"},{"driverName":"Microsoft RemoteFX Synth3D VSP Driver","driverVersion":"10.0.15063.850"},{"driverName":"Microsoft Storage Spaces Controller","driverVersion":"10.0.15063.850"},{"driverName":"Microsoft System Management BIOS Driver","driverVersion":"10.0.15063.0"},{"driverName":"Microsoft Teredo Tunneling Adapter","driverVersion":"10.0.15063.0"},{"driverName":"Microsoft Usbccid Smartcard Reader (WUDF)","driverVersion":"10.0.15063.0"},{"driverName":"Microsoft Virtual Drive Enumerator","driverVersion":"10.0.15063.850"},{"driverName":"Microsoft Visual Studio Location Simulator Sensor","driverVersion":"11.0.0.0"},{"driverName":"Microsoft Wi-Fi Direct Virtual Adapter","driverVersion":"10.0.15063.0"},{"driverName":"Microsoft Windows Management Interface for ACPI","driverVersion":"10.0.15063.0"},{"driverName":"Motherboard resources","driverVersion":"10.0.15063.966"},{"driverName":"NDIS Virtual Network Adapter Enumerator","driverVersion":"10.0.15063.0"},{"driverName":"PCI Express Root Complex","driverVersion":"10.0.15063.0"},{"driverName":"PCI standard host CPU bridge","driverVersion":"10.0.15063.966"},{"driverName":"Plug and Play Software Device Enumerator","driverVersion":"10.0.15063.0"},{"driverName":"Printer Port Logical Interface","driverVersion":"10.0.15063.966"},{"driverName":"Programmable interrupt controller","driverVersion":"10.0.15063.966"},{"driverName":"Realtek Audio","driverVersion":"6.0.1.6105"},{"driverName":"Realtek PCIE CardReader","driverVersion":"10.0.14393.21292"},{"driverName":"Remote Desktop Device Redirector Bus","driverVersion":"10.0.15063.850"},{"driverName":"Remote Desktop USB Hub","driverVersion":"10.0.15063.0"},{"driverName":"STMicroelectronics 3-Axis Digital Accelerometer","driverVersion":"2.2.3.8"},{"driverName":"Smart card filter driver","driverVersion":"10.0.15063.0"},{"driverName":"Standard PS/2 Keyboard","driverVersion":"10.0.15063.0"},{"driverName":"System CMOS/real time clock","driverVersion":"10.0.15063.966"},{"driverName":"System timer","driverVersion":"10.0.15063.966"},{"driverName":"Trusted Platform Module 2.0","driverVersion":"10.0.15063.413"},{"driverName":"UMBus Enumerator","driverVersion":"10.0.15063.0"},{"driverName":"UMBus Root Bus Enumerator","driverVersion":"10.0.15063.0"},{"driverName":"USB Composite Device","driverVersion":"10.0.15063.674"},{"driverName":"USB Input Device","driverVersion":"10.0.15063.1155"},{"driverName":"USB Root Hub (USB 3.0)","driverVersion":"10.0.15063.632"},{"driverName":"USB Video Device","driverVersion":"10.0.15063.447"},{"driverName":"USB xHCI Compliant Host Controller","driverVersion":"10.0.15063.877"},{"driverName":"Volume","driverVersion":"10.0.15063.0"},{"driverName":"Volume Manager","driverVersion":"10.0.15063.1112"},{"driverName":"WAN Miniport (IKEv2)","driverVersion":"10.0.15063.0"},{"driverName":"WAN Miniport (IP)","driverVersion":"10.0.15063.0"},{"driverName":"WAN Miniport (IPv6)","driverVersion":"10.0.15063.0"},{"driverName":"WAN Miniport (L2TP)","driverVersion":"10.0.15063.0"},{"driverName":"WAN Miniport (Network Monitor)","driverVersion":"10.0.15063.0"},{"driverName":"WAN Miniport (PPPOE)","driverVersion":"10.0.15063.0"},{"driverName":"WAN Miniport (PPTP)","driverVersion":"10.0.15063.0"},{"driverName":"WAN Miniport (SSTP)","driverVersion":"10.0.15063.0"}]}');
            }
            else if (flag==2){
                response.setBody('{"serviceTag":"A19TR72","model":"Latitude E5470","biosVersion":"","os":"Microsoft"}');
            }
            else if (flag==3){
                response.setBody('{"serviceTag":"B19TR72","model":"Latitude E5470","biosVersion":"1.18.6","os":""}');
            }
            else if(flag==4){
                response.setBody('{"serviceTag":"B19TR72","model":"Latitude E5470","os":null}');
            }
        response.setStatusCode(200);
        return response;
    	}
	}
    @isTest static  void testRestGetCallout() {
        flag=1;
        Test.setMock(HttpCalloutMock.class, new GRAgentHttpCalloutMock());
        
        List<String> ServiceTag = new List<String>{'C19TR72'};
        List<String> result1 = GRAgentJourneyController.GetAttributesFromSupportAssist(ServiceTag);
        System.debug(result1);
        List<String> actualresult = new List<String>{'1.18.6;Windows 10'};
        System.assertEquals(actualresult,result1,'The actual result and expected result dont match.');
            
        // Call method to test
        //HttpResponse result = AnimalsCallouts.makeGetCallout();
        
        // Verify mock response is not null
        System.assertNotEquals(null , result1, 'The callout returned a null response.');
        // Verify status code
        //System.assertEquals(200,result1.getStatusCode(),'The status code is not 200.');
        // Verify content type   
        //System.assertEquals('application/json;charset=UTF-8', result.getHeader('Content-Type'), 'The content type value is not expected.'); 
        
        // Verify the array contains 3 items     
        //Map<String, Object> results = (Map<String, Object>) JSON.deserializeUntyped(result.getBody());
        //List<Object> animals = (List<Object>) results.get('animals');
        //System.assertEquals(3, animals.size(), 'The array should only contain 3 items.');
    }
    @isTest static void testBiosNA(){
        flag=2;
        Test.setMock(HttpCalloutMock.class, new GRAgentHttpCalloutMock());
        
        List<String> ServiceTag = new List<String>{'A19TR72'};
        List<String> result1 = GRAgentJourneyController.GetAttributesFromSupportAssist(ServiceTag);
        System.debug(result1);
        List<String> actualresult = new List<String>{'NA;Microsoft'};
        System.assertEquals(actualresult,result1,'Wrong Result. The actual result and expected result dont match.');
    }
    @isTest static void testOSNA(){
        flag=3;
        Test.setMock(HttpCalloutMock.class, new GRAgentHttpCalloutMock());
        
        List<String> ServiceTag = new List<String>{'B19TR72'};
        List<String> result1 = GRAgentJourneyController.GetAttributesFromSupportAssist(ServiceTag);
        System.debug(result1);
        List<String> actualresult = new List<String>{'1.18.6;NA'};
        System.assertEquals(actualresult,result1,'Wrong Result. The actual result and expected result dont match.');
    }
    @isTest static void testException(){
        try{
             flag=4;
        Test.setMock(HttpCalloutMock.class, new GRAgentHttpCalloutMock());
        
        List<String> ServiceTag = new List<String>{'B19TR72'};
        List<String> result1 = GRAgentJourneyController.GetAttributesFromSupportAssist(ServiceTag);
        System.debug(result1);
        List<String> actualresult = new List<String>{};
        System.assertEquals(actualresult,result1,'Wrong Result. The actual result and expected result dont match.');
        }
        catch(exception e){
            
        }
    } 
}