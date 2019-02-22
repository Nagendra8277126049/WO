/* -----------------------------------------------------------------------------------------------------------------------
Name:       AddGroupMember_Test
Description:  This is Test class for the AddGroupMember #5384972
Date         Version  Author             Summary of Changes 
-----------  -------  -----------------  ------------------------------------------------------------------------------
08/07/2018     1.0     Seshank Reddy	FastTrack
-------------------------------------------------------------------------------------------------------------------------- */
@isTest
public class AddGroupMember_Test {
    @isTest
static void SearchGroupMethod()
    {
       Test.startTest();     
 
        //Create Parent Group
        Group grp = new Group();
        grp.name = 'Test Group1';
        grp.Type = 'Regular'; 
        Insert grp; 
 
        //Create Group Member
        GroupMember grpMem1 = new GroupMember();
        grpMem1.UserOrGroupId = UserInfo.getUserId();
        grpMem1.GroupId = grp.Id;
        Insert grpMem1;
 
        //Create Sub group
        Group subGrp  = new Group();
        subGrp.name = 'Test Group2';
        subGrp.Type = 'Regular'; 
        Insert subGrp; 
 
        //Assign Role To Parent Group
        GroupMember grpMem2 = new GroupMember();
        grpMem2.UserOrGroupId = subGrp.Id;
        grpMem2.GroupId = grp.Id;
        Insert grpMem2;  
 
        //Create Group Map Data
        Map<String,Id> groupNameRoleIdMap = new Map<String,Id>();
        for(Group gp: [SELECT Id, Name FROM Group WHERE Type = 'Role']){
            groupNameRoleIdMap.put('SuperAdmin', gp.Id);
        }     
 
        //Assign role to parent group
        GroupMember grpMem3 = new GroupMember();
        grpMem3.UserOrGroupId = groupNameRoleIdMap.get('SuperAdmin');
        grpMem3.GroupId = grp.Id;
        Insert grpMem3; 
 
        //Create Group And Sub Group Map Data
        Map<String,Id> groupNameRoleAndSubordinatesIdMap = new Map<String,Id>();
        for(Group gp: [SELECT Id, Name FROM Group WHERE Type = 'RoleAndSubordinates']){
            groupNameRoleAndSubordinatesIdMap.put('Admin', gp.Id);
        } 
 
        //Assign Role To Parent Group
        GroupMember grpMem4 = new GroupMember();
        grpMem4.UserOrGroupId = groupNameRoleAndSubordinatesIdMap.get('Admin');
        grpMem4.GroupId = grp.Id;
        Insert grpMem4;             
         
        //Execute your method here with Group and Group Member Test data
         
        Test.stopTest();
        AddGroupMember.getGroupmembers();
        AddGroupMember.fetchLookUpValues('test', 'User', subGrp.id, 'Add User');
        AddGroupMember.fetchLookUpValues('test', 'User', subGrp.id, 'Remove User');
        AddGroupMember.fetchGroup('test');
        Profile p = [SELECT Id FROM Profile WHERE Name='System Administrator']; 
        User u = new User(Alias = 'standt', Email='standarduser@testorg.com', 
            EmailEncodingKey='UTF-8', LastName='Kumar', LanguageLocaleKey='en_US', 
            LocaleSidKey='en_US', ProfileId = p.Id, 
            TimeZoneSidKey='America/Los_Angeles', UserName='standarduser@testorg.com');
              String s = JSON.serialize(u);
            AddGroupMember.addUsers(s ,grp.id, 'Remove User');
            try {

            AddGroupMember.addUsers(s ,grp.id, 'Add User');
                } catch (Exception e) {
			System.debug('>>> ERROR ='+e);
		} 
    }
}