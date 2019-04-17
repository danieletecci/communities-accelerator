@isTest
private class SharingUtilsTest{

	@testSetup
	static void generateCustomSettings(){
		MockupFactory.generateAcceleratorSetting();
	}

	@isTest
	static void insertTagSharing(){
		// Given
		List<Cluster__c> clusterRootList = MockupFactory.createCluster('ClusterRootTest', null, 1, 'ClusterRoot', 'CRT');
		List<Cluster__c> clusterList = [SELECT Id, Name FROM Cluster__c WHERE Name LIKE 'ClusterRootTest%' LIMIT 1 ];		
		List<Tag__c> tagList = MockupFactory.createTag('TagTest1', 'Test Tag', 1, clusterList[0].Id);

		// When
		SharingUtils.SharingWrapper sharingWrapper = SharingUtils.generateSharingForRecordsOnCluster(tagList, GeneralUtils.prefix('[CMS]Cluster__c'), GeneralUtils.prefix('[CMS]Tag__Share'), GeneralUtils.prefix('[CMS]Clustering__c'), false);

		System.assertEquals(0, sharingWrapper.objectIdToMessageErrosMap.size());
		System.assertEquals(3, sharingWrapper.listOfSharesToInsert.size());
	}

	@isTest
	static void insertClusterSharing(){
		// Given
		
		// When
		List<Cluster__c> clusterRootList = MockupFactory.createCluster('ClusterRootTest', null, 1, 'ClusterRoot', 'CRT');

		SharingUtils.SharingWrapper sharingWrapper = SharingUtils.generateSharingForCluster(clusterRootList, GeneralUtils.prefix('[CMS]Cluster__c'), GeneralUtils.prefix('[CMS]Cluster__Share'), GeneralUtils.prefix('[CMS]Clustering__c'), false);

		//Then
		System.assertEquals(0, sharingWrapper.objectIdToMessageErrosMap.size());
		System.assertEquals(3, sharingWrapper.listOfSharesToInsert.size());
	}

}