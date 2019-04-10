@isTest
private class ObjectSharingUtilTest
{

	@testSetup
	static void generateCustomSettings(){
		MockupFactory.generateAcceleratorSetting();
	}

	@isTest
	static void insertTagSharing()
	{
		// Given
		List<Cluster__c> clusterRootList = MockupFactory.createCluster('ClusterRootTest', null, 1, 'ClusterRoot', 'CRT');
		List<Cluster__c> clusterList = [SELECT Id, Name FROM Cluster__c WHERE Name LIKE 'ClusterRootTest%' LIMIT 1 ];
		System.debug('ClusterTriggersTest method clusterList: '+clusterList);

		List<Tag__c> tagList = MockupFactory.createTag('TagTest1', 'Test Tag', 1, clusterList[0].Id);

		System.debug('ClusterTriggersTest method tagList: '+tagList);
		// When
		//Test.startTest();//(List<SObject> records, String lookupField, String nameObjectShare, String sharingReason, Boolean isCluster){
			//'Cluster__c', 'Tag__Share', 'Clustering__c', false
		ObjectSharingUtil.SharingWrapper sharingWrapper = ObjectSharingUtil.generateSharingForRecordsOnCluster(tagList, 'Cluster__c', 'Tag__Share', 'Clustering__c', false);
		//Test.stopTest();
		System.assertEquals(0, sharingWrapper.objectIdToMessageErrosMap.size());
		System.assertEquals(3, sharingWrapper.listOfSharesToInsert.size());

	}

	@isTest
	static void insertClusterSharing()
	{
		// Given
		

		// When
		List<Cluster__c> clusterRootList = MockupFactory.createCluster('ClusterRootTest', null, 1, 'ClusterRoot', 'CRT');

		ObjectSharingUtil.SharingWrapper sharingWrapper = ObjectSharingUtil.generateSharingForCluster(clusterRootList, 'Cluster__c', 'Cluster__Share', 'Clustering__c', false);

		//Then
		System.assertEquals(0, sharingWrapper.objectIdToMessageErrosMap.size());
		System.assertEquals(3, sharingWrapper.listOfSharesToInsert.size());


		//Test.startTest();//(List<SObject> records, String lookupField, String nameObjectShare, String sharingReason, Boolean isCluster){
			//'Cluster__c', 'Tag__Share', 'Clustering__c', false
		
		//Test.stopTest();


	}

}