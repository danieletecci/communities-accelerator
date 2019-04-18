@isTest
private class MenuTriggersTest{

	@testSetup
	static void generateCustomSettings(){
		MockupFactory.generateAcceleratorSetting();
	}
	
	@isTest
	static void insertMenuSharing(){
		// Given
		//List<String> clustersList = new List<String>();
		List<Cluster__c> clusterRootList = MockupFactory.createCluster('ClusterRootTest', null, 1, 'ClusterRoot', 'CRT');
		List<Cluster__c> clusterList = [SELECT Id, Name FROM Cluster__c WHERE Name LIKE 'ClusterRootTest%' LIMIT 1 ];

		// When
		Test.startTest();
		List<Menu__c> tagList = MockupFactory.createMenu('menuTest1', 1,clusterList[0].Id);		
		Test.stopTest();

		// Then
		List<Menu__Share> shareList = [SELECT Id, ParentId FROM Menu__Share WHERE ParentId = :tagList[0].Id AND RowCause =: GeneralUtils.prefix('[CMS]Clustering__c')];

		System.assertEquals(3, shareList.size());
	}

	@isTest
	static void insertMenuSharingWithoutClusterId(){
		// Given
		//List<String> clustersList = new List<String>();
		List<Cluster__c> clusterRootList = MockupFactory.createCluster('ClusterRootTest', null, 1, 'ClusterRoot', 'CRT');
		List<Cluster__c> clusterList = [SELECT Id, Name FROM Cluster__c WHERE Name LIKE 'ClusterRootTest%' LIMIT 1 ];
		
		// When
		Test.startTest();
		List<Menu__c> tagList = MockupFactory.createMenu('menuTest1', 1,null);
		Test.stopTest();
		
		// Then
		List<Menu__Share> shareList = [SELECT Id, ParentId FROM Menu__Share WHERE ParentId = :tagList[0].Id AND RowCause =: GeneralUtils.prefix('[CMS]Clustering__c')];
		
		System.assertEquals(0, shareList.size());
	}

	@isTest
	static void updateMenuSharing(){
		// Given
		//List<String> clustersList = new List<String>();
		List<Cluster__c> clusterRootList = MockupFactory.createCluster('ClusterRootTest', null, 2, 'ClusterRoot', 'CRT');
		List<Cluster__c> getClusterList = [SELECT Id, Name FROM Cluster__c WHERE Name LIKE 'ClusterRootTest%' LIMIT 2 ];
		
		List<Menu__c> menuList = MockupFactory.createMenu('menuTest1', 1,getClusterList[0].Id);
		List<Menu__c> getMenuList = [SELECT Id, Name FROM Menu__c WHERE Name LIKE 'menuTest1%'];
		
		Menu__c getMenuToUpdate = getMenuList[0];
		getMenuToUpdate.Cluster__c = getClusterList[1].Id;
		List<Menu__c> menuToInsert = new List<Menu__c>{getMenuToUpdate};
		// When
		Test.startTest();
		update menuToInsert;
		Test.stopTest();

		// Then
		List<Menu__Share> shareList = [SELECT Id, ParentId FROM Menu__Share WHERE ParentId = :menuToInsert[0].Id AND RowCause =: GeneralUtils.prefix('[CMS]Clustering__c')];
		
		System.assertEquals(6, shareList.size());
	}

	@isTest
	static void updateMenuSharingWithoutClusterId(){
		// Given
		//List<String> clustersList = new List<String>();
		List<Cluster__c> clusterRootList = MockupFactory.createCluster('ClusterRootTest', null, 2, 'ClusterRoot', 'CRT');
		List<Cluster__c> getClusterList = [SELECT Id, Name FROM Cluster__c WHERE Name LIKE 'ClusterRootTest%' LIMIT 2 ];
		
		List<Menu__c> menuList = MockupFactory.createMenu('menuTest1', 1,getClusterList[0].Id);
		List<Menu__c> getMenuList = [SELECT Id, Name FROM Menu__c WHERE Name LIKE 'menuTest1%'];

		Menu__c getMenuToUpdate = getMenuList[0];
		getMenuToUpdate.Cluster__c = getClusterList[0].Id;
		List<Menu__c> menuToInsert = new List<Menu__c>{getMenuToUpdate};

		// When
		Test.startTest();
		update menuToInsert;
		Test.stopTest();

		// Then
		List<Menu__Share> shareList = [SELECT Id, ParentId FROM Menu__Share WHERE ParentId = :menuToInsert[0].Id AND RowCause =: GeneralUtils.prefix('[CMS]Clustering__c')];
		
		System.assertEquals(3, shareList.size());
	}

}