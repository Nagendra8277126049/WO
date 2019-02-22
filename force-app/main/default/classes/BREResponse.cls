public class BREResponse {
	public String timestamp;	//1538157880236
	public String selectedDestId;	//1184901d-8db1-4ad2-ad60-ad457ae51d46
	public String selectedDestNativeId;	//2
	public String selectedDestType;	//AGENT_GROUP
	public String selectedDestName;	//DCEC Demo Skill 2
	public String selectedDestAddress;	//6166002
	public cls_extendedResponse extendedResponse;
	public Integer resultCode;	//10
	public String debugString;	//#requestType=NON_PROD;CFlo:S;CFlo:S;SGds:S;CFtt:S;#chkDestinationInterval=DCEC Demo Skill 2:Exception:OPEN;CFtt:S;#chkDestinationInterval=DCEC Demo Skill 2:Holiday:OPEN;CFtt:S;#chkDestinationInterval=DCEC Demo Skill
	public String interactionId;//11902246231529517256
	public boolean countDecision;
	public String locationName;	//Austin
	public String companyName;	//DELL
	public String segLabel;	//Default_Rule
	public String segTable;	//SDS_Voice_Service_Tag
	public String strategySettingsName;	//SDS_EWT_DestGrp1
	class cls_extendedResponse {
		public String nextExperience;	//InternalTransfer
	}
/*	public static BREResponse parse(String json){
		return (BREResponse) System.JSON.deserialize(json, BREResponse.class);
	}*/
}