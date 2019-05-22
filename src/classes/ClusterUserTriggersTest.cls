@isTest
private class ClusterUserTriggersTest{

	@testSetup
	static void setup(){
		MockupFactory.generateAcceleratorSetting();
		List<Cluster__c> clusters = MockupFactory.createCluster('Test Cluster Root', null, 1, 'ClusterRoot', 'CRT');
		
		User userToInsert = MockupFactory.createUser('userToInsert@cg.com','test@user.com');
		User userRW = MockupFactory.createUser('userRW@cg.com','test@user.com');
		User userRO = MockupFactory.createUser('userRO@cg.com','test@user.com');
		
		MockupFactory.createClusterUser(clusters.get(0).Id, userRO.Id, 1, 'Read Only');
		MockupFactory.createClusterUser(clusters.get(0).Id, userRW.Id, 1, 'Read/Write');
	}

	@isTest
	static void insertClusterUserWithAccessLevelReadWrite(){
		// Given
		Map<Id, Group> groups = new Map<Id, Group> ([SELECT Id, developerName FROM Group WHERE developerName LIKE 'CRT%']);
		Cluster__C cluster = [SELECT Id FROM Cluster__c WHERE Name = 'Test Cluster Root00' LIMIT 1];
		User testUser = [SELECT Id FROM User WHERE username = 'userToInsert@cg.com' LIMIT 1];
		ClusterUser__c clusterUser = new ClusterUser__c();
		clusterUser.Cluster__c = cluster.Id;
		clusterUser.User__c = testUser.Id;
		clusterUser.AccessLevel__c = 'Read/Write';

		// When
		Test.startTest();
		insert clusterUser;
		Test.stopTest();

		// Then
		List<GroupMember> groupMembers = [SELECT Id, GroupId, UserOrGroupId FROM GroupMember WHERE UserOrGroupId = :testUser.Id];
		for (GroupMember gm : groupMembers){
			Group g = groups.get(gm.GroupId);
			system.assert(g.developerName.contains('_RW') || g.developerName.contains('_ROViewUp'));
		}
	}

	@isTest
	static void insertClusterUserWithAccessLevelReadOnly(){
		// Given
		Map<Id, Group> groups = new Map<Id, Group> ([SELECT Id, developerName FROM Group WHERE developerName LIKE 'CRT%']);
		Cluster__C cluster = [SELECT Id FROM Cluster__c WHERE Name = 'Test Cluster Root00' LIMIT 1];
		User testUser = [SELECT Id FROM User WHERE username = 'userToInsert@cg.com' LIMIT 1];
		ClusterUser__c clusterUser = new ClusterUser__c();
		clusterUser.Cluster__c = cluster.Id;
		clusterUser.User__c = testUser.Id;
		clusterUser.AccessLevel__c = 'Read Only';

		// When
		Test.startTest();
		insert clusterUser;
		Test.stopTest();

		// Then
		List<GroupMember> groupMembers = [SELECT Id, GroupId, UserOrGroupId FROM GroupMember WHERE UserOrGroupId = :testUser.Id];
		for (GroupMember gm : groupMembers){
			Group g = groups.get(gm.GroupId);
			system.assert(g.developerName.contains('_ROViewDown') || g.developerName.contains('_ROViewUp'));
		}
	}

	@isTest
	static void updateClusterUserAccessLevelRWToRO(){
		// Given
		Map<Id, Group> groups = new Map<Id, Group> ([SELECT Id, developerName FROM Group WHERE developerName LIKE 'CRT%']);
		Cluster__C cluster = [SELECT Id FROM Cluster__c WHERE Name = 'Test Cluster Root00' LIMIT 1];
		User testUser = [SELECT Id FROM User WHERE username = 'userRW@cg.com' LIMIT 1];
		ClusterUser__c clusterUser = [SELECT Id FROM ClusterUser__c WHERE User__c = :testUser.Id LIMIT 1];

		// When
		Test.startTest();
		clusterUser.AccessLevel__c = 'Read Only';
		update clusterUser;
		Test.stopTest();

		// Then
		List<GroupMember> groupMembers = [SELECT Id, GroupId, UserOrGroupId FROM GroupMember WHERE UserOrGroupId = :testUser.Id];
		for (GroupMember gm : groupMembers){
			Group g = groups.get(gm.GroupId);
			system.assert(g.developerName.contains('_ROViewDown') || g.developerName.contains('_ROViewUp'));
		}
	}

	@isTest
	static void updateClusterUserAccessLevelROToRW(){
		// Given
		Map<Id, Group> groups = new Map<Id, Group> ([SELECT Id, developerName FROM Group WHERE developerName LIKE 'CRT%']);
		User testUser = [SELECT Id FROM User WHERE username = 'userRO@cg.com' LIMIT 1];
		ClusterUser__c clusterUser = [SELECT Id FROM ClusterUser__c WHERE User__c = :testUser.Id LIMIT 1];

		// When
		Test.startTest();
		clusterUser.AccessLevel__c = 'Read/Write';
		update clusterUser;
		Test.stopTest();

		// Then
		List<GroupMember> groupMembers = [SELECT Id, GroupId, UserOrGroupId FROM GroupMember WHERE UserOrGroupId = :testUser.Id];
		for (GroupMember gm : groupMembers){
			Group g = groups.get(gm.GroupId);
			system.assert(g.developerName.contains('_RW') || g.developerName.contains('_ROViewUp'));
		}
	}

	@isTest
	static void deleteClusterUserAccessLevelReadWrite(){
		// Given
		Map<Id, Group> groups = new Map<Id, Group> ([SELECT Id, developerName FROM Group WHERE developerName LIKE 'CRT%']);
		User testUser = [SELECT Id FROM User WHERE username = 'userRW@cg.com' LIMIT 1];
		ClusterUser__c clusterUser = [SELECT Id FROM ClusterUser__c WHERE User__c = :testUser.Id LIMIT 1];

		// When
		Test.startTest();
		delete clusterUser;
		Test.stopTest();

		// Then
		List<GroupMember> groupMembers = new List<GroupMember>();
		try{
			groupMembers = [SELECT Id, GroupId, UserOrGroupId FROM GroupMember WHERE UserOrGroupId = :testUser.Id];
		}catch(Exception e){
			system.assert(groupMembers.isEmpty());
		}
	}

	@isTest
	static void deleteClusterUserAccessLevelReadOnly(){
		// Given
		Map<Id, Group> groups = new Map<Id, Group> ([SELECT Id, developerName FROM Group WHERE developerName LIKE 'CRT%']);
		User testUser = [SELECT Id FROM User WHERE username = 'userRO@cg.com' LIMIT 1];
		ClusterUser__c clusterUser = [SELECT Id FROM ClusterUser__c WHERE User__c = :testUser.Id LIMIT 1];

		// When
		Test.startTest();
		delete clusterUser;
		Test.stopTest();

		// Then
		List<GroupMember> groupMembers = new List<GroupMember>();
		try{
			groupMembers = [SELECT Id, GroupId, UserOrGroupId FROM GroupMember WHERE UserOrGroupId = :testUser.Id];
		}catch(Exception e){
			system.assert(groupMembers.isEmpty());
		}
	}

	@isTest
	static void upsertClusterUserCMSUserSetting(){
		// Given
		Cluster__c cluster = [SELECT Id FROM Cluster__c WHERE Name = 'Test Cluster Root00' LIMIT 1];
		User testUser = [SELECT Id FROM User WHERE username = 'userToInsert@cg.com' LIMIT 1];
		ClusterUser__c clusterUser = new ClusterUser__c();
		clusterUser.Cluster__c = cluster.Id;
		clusterUser.User__c = testUser.Id;
		clusterUser.AccessLevel__c = 'Read Only';

		// When
		Test.startTest();
		insert clusterUser;
		Test.stopTest();

		// Then
		System.Assert([SELECT User__c FROM CMSUserSettings__c WHERE User__c =: clusterUser.User__c].size() == 1);		
	}
}