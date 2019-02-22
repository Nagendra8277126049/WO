public class BRERequest{
	public cls_customParameters customParameters;
    public String to {get; set;}
	public String interactionId {get; set;}
	public String fromNum {get; set;}
	public String channel {get; set;}
	public cls_segAttributes segAttributes;
	public String decisionFunctionName {get; set;}
    public String decisionFunctionVersion = '4.0';
	public class cls_customParameters {
		public String Interaction_Type {get; set;}
		public String Client_IP {get; set;}
		public String Client_App {get; set;}
		public String Interaction_ID {get; set;}
		public String Language {get; set;}
		public String Request_Type {get; set;}
	}
	public class cls_segAttributes {
		public String DNIS_Country_Code {get; set;}
		public String Customer_Type_Group {get; set;}
		public String ServiceTag_Entitlement_Type_Group {get; set;}
		public String Customer_Entitlement_Type_Group {get; set;}
		public String Product_Line_Group {get; set;}
		public String Product_Item_Class {get; set;}
		public String Product_Shipped_Date {get; set;}
		public String SDS_Transfer_Reason_Group {get; set;}
		public String Transfer_Count {get; set;}
	}
	/*public static BRERequest parse(String json){
		return (BRERequest) System.JSON.deserialize(json, BRERequest.class);
    }*/
    public BRERequest()
    {
        customParameters = new cls_customParameters();
        segAttributes = new cls_segAttributes();
    }
}