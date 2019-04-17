@isTest(seeAllData = false)
public with sharing class TagTriggersTest {

	@testSetup
	static void generateCustomSettings(){
		MockupFactory.generateAcceleratorSetting();
	}


	@isTest 
	static void insertTagTest(){
		/* Comment: Comprueba que al crear un tag__c se inserta
			con el correspondiente ExternalId__c */

		//Given
		Tag__c tagTest = new Tag__c(Name='Tag Test 01');

		//When
		Test.startTest();
			insert(tagTest);
		Test.stopTest();

		//Then
		Tag__c tagTestResult =[select id, ExternalId__c from Tag__c where id =: tagTest.id];
		System.assertNotEquals(tagTestResult.ExternalId__c, null);
	}

	@isTest
	static void updatetagTest(){
		/* Comment: Comprueba que al actualizar un tag__c se actualiza
		con el correspondiente ExternalId__c */
		
		//Given
		Tag__c tagTest = new Tag__c(Name='Tag Test 01');
		insert(tagTest);
		tagTest.ExternalId__c = null;
		tagTest.Name = 'tagl Test 02';
		//When
		Test.startTest();
			update(tagTest);
		Test.stopTest();

		//Then
		Tag__c tagTestResult2 =[select id, ExternalId__c from Tag__c where id =: tagTest.id];
		System.assertNotEquals(tagTestResult2.ExternalId__c, null);
	}

	@isTest
	static void insertTagSharing()
	{
		/*
		Valida la creacion de las Manual Sharing al moemnto de crear un Tag*/

		// Given
		List<Cluster__c> clusterRootList = MockupFactory.createCluster('ClusterRootTest', null, 1, 'ClusterRoot', 'CRT');
		List<Cluster__c> clusterList = [SELECT Id, Name FROM Cluster__c WHERE Name LIKE 'ClusterRootTest%' LIMIT 1 ];
		//System.debug('ClusterTriggersTest method clusterList: '+clusterList);
		
		// When
		Test.startTest();
		List<Tag__c> tagList = MockupFactory.createTag('TagTest1', 'Test Tag', 1,clusterList[0].Id);
		Test.stopTest();

		// Then
		List<Tag__Share> shareList = [SELECT Id, ParentId FROM Tag__Share WHERE ParentId = :tagList[0].Id AND RowCause = :GeneralUtils.prefix('[CMS]Clustering__c')];

		System.assertEquals(3, shareList.size());

	}

	@isTest
	static void updateTagSharing(){
		// Given
		List<Cluster__c> clusterRootList = MockupFactory.createCluster('ClusterRootTest', null, 2, 'ClusterRoot', 'CRT');
		List<Cluster__c> getClusterList = [SELECT Id, Name FROM Cluster__c WHERE Name LIKE 'ClusterRootTest%' LIMIT 2 ];
		System.debug('ClusterTriggersTest method getClusterList: '+getClusterList);
		
		List<Tag__c> tagsList = MockupFactory.createTag('TagTest1', 'Test Tag', 1,getClusterList[0].Id);
		List<Tag__c> getTagList = [SELECT Id, Name FROM Tag__c WHERE Name LIKE 'TagTest1%'];
		System.debug('ClusterTriggersTest method getTagList: '+getTagList);

		Tag__c getTagsToUpdate = getTagList[0];
		getTagsToUpdate.Cluster__c = getClusterList[1].Id;
		List<Tag__c> tagToUpdateList = new List<Tag__c>{getTagsToUpdate};
		System.debug('ClusterTriggersTest method tagToUpdateList: '+tagToUpdateList);
		// When
		Test.startTest();
		update tagToUpdateList;
		Test.stopTest();


		System.debug('ClusterTriggersTest method tagToUpdateList: '+tagToUpdateList);

		// Then
		List<Tag__Share> shareList = [SELECT Id, ParentId FROM Tag__Share WHERE ParentId = :tagToUpdateList[0].Id AND RowCause = :GeneralUtils.prefix('[CMS]Clustering__c')];
		System.debug('ClusterTriggersTest method shareList: '+shareList);

		System.assertEquals(6, shareList.size());

	}

	@isTest 
	static void insertAnotherTagTest(){
		
		/* Comment: Comprueba que al crear un Category__c se inserta existiendo otro Category__c
			para el mismo Cluster__c */

		//Given
		Tag__c tagTest = new Tag__c(Name='Tag Test 01');
		String name = 'Argentina';
        String nameGroup = 'Buenos Aires';
        List<Cluster__c> clusterRootList = MockupFactory.createCluster(name, null, 1, 'ClusterRoot', 'CRT');
        Cluster__c cg = clusterRootList[0];
        List<Cluster__c> clusterList = MockupFactory.createCluster(nameGroup, cg.Id, 1, 'ClusterGroup', 'CGT');
        Cluster__c cgGr = clusterList[0];
        tagTest.Cluster__c=cgGr.Id;
        
		insert(tagTest);
		Tag__c tagTest2 = new Tag__c(Name='Category Test 02');
		tagTest2.Cluster__c=cgGr.Id;
		//When
		Test.startTest();
		insert(tagTest2);
		Test.stopTest();

		//Then
		Tag__c tagTestResult2 =[select id, ExternalId__c from Tag__c where id =: tagTest.id];
		System.assertNotEquals(tagTestResult2.ExternalId__c, null);
	}

}