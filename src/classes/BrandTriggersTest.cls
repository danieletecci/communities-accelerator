@isTest
private class BrandTriggersTest
{

	@testSetup
	static void generateCustomSettings(){
		MockupFactory.generateAcceleratorSetting();
	}
	
	@isTest
	static void insertBrandSharing()
	{
		

		// Given
		//List<String> clustersList = new List<String>();
		List<Cluster__c> clusterRootList = MockupFactory.createCluster('ClusterRootTest', null, 1, 'ClusterRoot', 'CRT');
		List<Cluster__c> clusterList = [SELECT Id, Name FROM Cluster__c WHERE Name LIKE 'ClusterRootTest%' LIMIT 1 ];
		System.debug('ClusterTriggersTest method clusterList: '+clusterList);

		// When
		Test.startTest();
		List<Brand__c> tagList = MockupFactory.createBrand('brandTest1', 1,clusterList[0].Id);
		
		Test.stopTest();
		System.debug('ClusterTriggersTest method tagList: '+tagList);

		// Then
		List<Brand__Share> shareList = [SELECT Id, ParentId FROM Brand__Share WHERE ParentId = :tagList[0].Id AND RowCause = 'Clustering__c'];
		System.debug('ClusterTriggersTest method shareList: '+shareList);

		System.assertEquals(3, shareList.size());

	}

	@isTest
	static void insertBrandSharingWithoutClusterId()
	{
		

		// Given
		//List<String> clustersList = new List<String>();
		List<Cluster__c> clusterRootList = MockupFactory.createCluster('ClusterRootTest', null, 1, 'ClusterRoot', 'CRT');
		List<Cluster__c> clusterList = [SELECT Id, Name FROM Cluster__c WHERE Name LIKE 'ClusterRootTest%' LIMIT 1 ];
		System.debug('ClusterTriggersTest method clusterList: '+clusterList);

		// When
		Test.startTest();
		List<Brand__c> tagList = MockupFactory.createBrand('brandTest1', 1,null);
		
		Test.stopTest();
		System.debug('ClusterTriggersTest method tagList: '+tagList);

		// Then
		List<Brand__Share> shareList = [SELECT Id, ParentId FROM Brand__Share WHERE ParentId = :tagList[0].Id AND RowCause = 'Clustering__c'];
		System.debug('ClusterTriggersTest method shareList: '+shareList);

		System.assertEquals(0, shareList.size());

	}

	@isTest
	static void updateBrandSharing()
	{
		

		// Given
		//List<String> clustersList = new List<String>();
		List<Cluster__c> clusterRootList = MockupFactory.createCluster('ClusterRootTest', null, 2, 'ClusterRoot', 'CRT');
		List<Cluster__c> getClusterList = [SELECT Id, Name FROM Cluster__c WHERE Name LIKE 'ClusterRootTest%' LIMIT 2 ];
		System.debug('ClusterTriggersTest method getClusterList: '+getClusterList);
		
		List<Brand__c> brandList = MockupFactory.createBrand('brandTest1', 1,getClusterList[0].Id);
		List<Brand__c> getBrandList = [SELECT Id, Name FROM Brand__c WHERE Name LIKE 'brandTest1%'];
		System.debug('ClusterTriggersTest method getBrandList: '+getBrandList);

		Brand__c getBrandToUpdate = getBrandList[0];
		getBrandToUpdate.Cluster__c = getClusterList[1].Id;
		List<Brand__c> brandToInsert = new List<Brand__c>{getBrandToUpdate};
		System.debug('ClusterTriggersTest method brandToInsert: '+brandToInsert);
		// When
		Test.startTest();
		update brandToInsert;
		Test.stopTest();


		System.debug('ClusterTriggersTest method brandToInsert: '+brandToInsert);

		// Then
		List<Brand__Share> shareList = [SELECT Id, ParentId FROM Brand__Share WHERE ParentId = :brandToInsert[0].Id AND RowCause = 'Clustering__c'];
		System.debug('ClusterTriggersTest method shareList: '+shareList);

		System.assertEquals(6, shareList.size());

	}

	@isTest
	static void updateBrandSharingWithoutClusterId()
	{
		

		// Given
		//List<String> clustersList = new List<String>();
		List<Cluster__c> clusterRootList = MockupFactory.createCluster('ClusterRootTest', null, 2, 'ClusterRoot', 'CRT');
		List<Cluster__c> getClusterList = [SELECT Id, Name FROM Cluster__c WHERE Name LIKE 'ClusterRootTest%' LIMIT 2 ];
		System.debug('ClusterTriggersTest method getClusterList: '+getClusterList);
		
		List<Brand__c> brandList = MockupFactory.createBrand('brandTest1', 1,getClusterList[0].Id);
		List<Brand__c> getBrandList = [SELECT Id, Name FROM Brand__c WHERE Name LIKE 'brandTest1%'];
		System.debug('ClusterTriggersTest method getBrandList: '+getBrandList);

		Brand__c getBrandToUpdate = getBrandList[0];
		getBrandToUpdate.Cluster__c = getClusterList[0].Id;
		List<Brand__c> brandToInsert = new List<Brand__c>{getBrandToUpdate};
		System.debug('ClusterTriggersTest method brandToInsert: '+brandToInsert);
		// When
		Test.startTest();
		update brandToInsert;
		Test.stopTest();


		System.debug('ClusterTriggersTest method brandToInsert: '+brandToInsert);

		// Then
		List<Brand__Share> shareList = [SELECT Id, ParentId FROM Brand__Share WHERE ParentId = :brandToInsert[0].Id AND RowCause = 'Clustering__c'];
		System.debug('ClusterTriggersTest method shareList: '+shareList);

		System.assertEquals(3, shareList.size());

	}

}