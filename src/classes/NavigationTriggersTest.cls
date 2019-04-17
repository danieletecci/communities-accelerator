@isTest
private class NavigationTriggersTest
{

	@testSetup
	static void generateCustomSettings(){
		MockupFactory.generateAcceleratorSetting();
	}
	
	@isTest
	static void insertNavigationSharing()
	{
		

		// Given
		//List<String> clustersList = new List<String>();
		List<Cluster__c> clusterRootList = MockupFactory.createCluster('ClusterRootTest', null, 1, 'ClusterRoot', 'CRT');
		List<Cluster__c> clusterList = [SELECT Id, Name FROM Cluster__c WHERE Name LIKE 'ClusterRootTest%' LIMIT 1 ];
		
		// When
		Test.startTest();
		List<Navigation__c> tagList = MockupFactory.createNavigation('navTest1', 'Url.com', 1,clusterList[0].Id);
		
		Test.stopTest();
		
		// Then
		List<Navigation__Share> shareList = [SELECT Id, ParentId FROM Navigation__Share WHERE ParentId = :tagList[0].Id AND RowCause =: GeneralUtils.prefix('[CMS]Clustering__c')];
		
		System.assertEquals(3, shareList.size());

	}

	@isTest
	static void insertNavigationSharingWithoutClusterId()
	{
		

		// Given
		//List<String> clustersList = new List<String>();
		List<Cluster__c> clusterRootList = MockupFactory.createCluster('ClusterRootTest', null, 1, 'ClusterRoot', 'CRT');
		List<Cluster__c> clusterList = [SELECT Id, Name FROM Cluster__c WHERE Name LIKE 'ClusterRootTest%' LIMIT 1 ];
		
		// When
		Test.startTest();
		List<Navigation__c> tagList = MockupFactory.createNavigation('navTest1', 'Url.com', 1,null);
		
		Test.stopTest();
		
		// Then
		List<Navigation__Share> shareList = [SELECT Id, ParentId FROM Navigation__Share WHERE ParentId = :tagList[0].Id AND RowCause =: GeneralUtils.prefix('[CMS]Clustering__c')];
		
		System.assertEquals(0, shareList.size());

	}

	@isTest
	static void updateNavigationSharing()
	{
		

		// Given
		//List<String> clustersList = new List<String>();
		List<Cluster__c> clusterRootList = MockupFactory.createCluster('ClusterRootTest', null, 2, 'ClusterRoot', 'CRT');
		List<Cluster__c> getClusterList = [SELECT Id, Name FROM Cluster__c WHERE Name LIKE 'ClusterRootTest%' LIMIT 2 ];
		
		List<Navigation__c> navList = MockupFactory.createNavigation('navTest1', 'Url.com', 1,getClusterList[0].Id);
		List<Navigation__c> getNavList = [SELECT Id, Name FROM Navigation__c WHERE Name LIKE 'navTest1%'];
		
		Navigation__c getNavToUpdate = getNavList[0];
		getNavToUpdate.Cluster__c = getClusterList[1].Id;
		List<Navigation__c> navigationToInsert = new List<Navigation__c>{getNavToUpdate};
		// When
		Test.startTest();
		update navigationToInsert;
		Test.stopTest();

		// Then
		List<Navigation__Share> shareList = [SELECT Id, ParentId FROM Navigation__Share WHERE ParentId = :navigationToInsert[0].Id AND RowCause =: GeneralUtils.prefix('[CMS]Clustering__c')];
		
		System.assertEquals(6, shareList.size());

	}

	@isTest
	static void updateNavigationSharingWithoutClusterId()
	{
		

		// Given
		//List<String> clustersList = new List<String>();
		List<Cluster__c> clusterRootList = MockupFactory.createCluster('ClusterRootTest', null, 2, 'ClusterRoot', 'CRT');
		List<Cluster__c> getClusterList = [SELECT Id, Name FROM Cluster__c WHERE Name LIKE 'ClusterRootTest%' LIMIT 2 ];
		
		List<Navigation__c> navList = MockupFactory.createNavigation('navTest1', 'Url.com', 1,getClusterList[0].Id);
		List<Navigation__c> getNavList = [SELECT Id, Name FROM Navigation__c WHERE Name LIKE 'navTest1%'];
		
		Navigation__c getNavToUpdate = getNavList[0];
		getNavToUpdate.Cluster__c = getClusterList[0].Id;
		List<Navigation__c> navigationToInsert = new List<Navigation__c>{getNavToUpdate};
		// When
		Test.startTest();
		update navigationToInsert;
		Test.stopTest();

		// Then
		List<Navigation__Share> shareList = [SELECT Id, ParentId FROM Navigation__Share WHERE ParentId = :navigationToInsert[0].Id AND RowCause =: GeneralUtils.prefix('[CMS]Clustering__c')];
		
		System.assertEquals(3, shareList.size());

	}

}