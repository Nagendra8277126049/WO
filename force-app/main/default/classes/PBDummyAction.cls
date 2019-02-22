public class PBDummyAction {
  @InvocableMethod(label='Dummy Ids' description='Dummy method to be used in Process Builder')
  public static List<Id> getIds(List<ID> inputIDs) {
    return inputIDs;
  }
}