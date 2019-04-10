@isTest(seeAllData = false)
public with sharing class CategoryTriggersTest {
	@isTest 
	static void insertCategoryTest(){
		/* Comment: Comprueba que al crear un Category__c se inserta
			con el correspondiente ExternalId__c */

		//Given
		MockupFactory.generateAcceleratorSetting();

		Category__c categoryTest = new Category__c(Name='Category Test 01');
		String name = 'Argentina';
        String nameGroup = 'Buenos Aires';
        List<Cluster__c> clusterRootList = MockupFactory.createCluster(name, null, 1, 'ClusterRoot', 'CRT');
        Cluster__c cg = clusterRootList[0];
        List<Cluster__c> clusterList = MockupFactory.createCluster(nameGroup, cg.Id, 1, 'ClusterGroup', 'CGT');
        Cluster__c cgGr = clusterList[0];
        categoryTest.Cluster__c=cgGr.Id;
		//When
		Test.startTest();
			insert(categoryTest);
		Test.stopTest();

		//Then
		Category__c catTestResult =[select id, ExternalId__c from Category__c where id =: categoryTest.id];
		System.assertNotEquals(catTestResult.ExternalId__c, null);
	}	

	@isTest 
	static void updateCategoryTest(){
		/* Comment: Comprueba que al crear un Category__c se inserta
			con el correspondiente ExternalId__c */

		//Given
		MockupFactory.generateAcceleratorSetting();

		Category__c categoryTest = new Category__c(Name='Category Test 01');
		String name = 'Argentina';
        String nameGroup = 'Buenos Aires';
        List<Cluster__c> clusterRootList = MockupFactory.createCluster(name, null, 1, 'ClusterRoot', 'CRT');
        Cluster__c cg = clusterRootList[0];
        List<Cluster__c> clusterList = MockupFactory.createCluster(nameGroup, cg.Id, 1, 'ClusterGroup', 'CGT');
        Cluster__c cgGr = clusterList[0];
        categoryTest.Cluster__c=cgGr.Id;

		insert(categoryTest);
		categoryTest.ExternalId__c = null;
		categoryTest.Name = 'Category Test 02';
		//When
		Test.startTest();
			update(categoryTest);
		Test.stopTest();

		//Then
		Category__c catTestResult2 =[select id, ExternalId__c from Category__c where id =: categoryTest.id];
		System.assertNotEquals(catTestResult2.ExternalId__c, null);
	}

	@isTest
	static void insertCatSharing()
	{
		/*
		Valida la creacion de las Manual Sharing al moemnto de crear un Tag*/

		// Given
		MockupFactory.generateAcceleratorSetting();
		List<Cluster__c> clusterRootList = MockupFactory.createCluster('ClusterRootTest', null, 1, 'ClusterRoot', 'CRT');
		List<Cluster__c> clusterList = [SELECT Id, Name FROM Cluster__c WHERE Name LIKE 'ClusterRootTest%' LIMIT 1 ];
		//System.debug('ClusterTriggersTest method clusterList: '+clusterList);
		
		// When
		Test.startTest();
		List<Category__c> catList = MockupFactory.createCategory('TagTest1', 1,clusterList[0].Id);
		Test.stopTest();

		// Then
		List<Category__Share> shareList = [SELECT Id, ParentId FROM Category__Share WHERE ParentId = :catList[0].Id AND RowCause = 'Clustering__c'];

		System.assertEquals(3, shareList.size());

	}

	@isTest
	static void updateCatSharing(){
		// Given
		MockupFactory.generateAcceleratorSetting();
		List<Cluster__c> clusterRootList = MockupFactory.createCluster('ClusterRootTest', null, 2, 'ClusterRoot', 'CRT');
		List<Cluster__c> getClusterList = [SELECT Id, Name FROM Cluster__c WHERE Name LIKE 'ClusterRootTest%' LIMIT 2 ];
		System.debug('ClusterTriggersTest method getClusterList: '+getClusterList);
		
		List<Category__c> tagsList = MockupFactory.createCategory('CatTest1', 1,getClusterList[0].Id);
		List<Category__c> getCatList = [SELECT Id, Name FROM Category__c WHERE Name LIKE 'CatTest1%'];
		System.debug('ClusterTriggersTest method getCatList: '+getCatList);

		Category__c getCatsToUpdate = getCatList[0];
		getCatsToUpdate.Cluster__c = getClusterList[1].Id;
		List<Category__c> catToUpdateList = new List<Category__c>{getCatsToUpdate};
		System.debug('ClusterTriggersTest method catToUpdateList: '+catToUpdateList);
		// When
		Test.startTest();
		update catToUpdateList;
		Test.stopTest();


		System.debug('ClusterTriggersTest method catToUpdateList: '+catToUpdateList);

		// Then
		List<Category__Share> shareList = [SELECT Id, ParentId FROM Category__Share WHERE ParentId = :catToUpdateList[0].Id AND RowCause = 'Clustering__c'];
		System.debug('ClusterTriggersTest method shareList: '+shareList);

		System.assertEquals(6, shareList.size());
	}
	
	@isTest 
	static void insertAnotherCategoryTest(){
		/* Comment: Comprueba que al crear un Category__c se inserta existiendo otro Category__c
			para el mismo Cluster__c */

		//Given
		MockupFactory.generateAcceleratorSetting();

		Category__c categoryTest = new Category__c(Name='Category Test 01');
		String name = 'Argentina';
        String nameGroup = 'Buenos Aires';
        List<Cluster__c> clusterRootList = MockupFactory.createCluster(name, null, 1, 'ClusterRoot', 'CRT');
        Cluster__c cg = clusterRootList[0];
        List<Cluster__c> clusterList = MockupFactory.createCluster(nameGroup, cg.Id, 1, 'ClusterGroup', 'CGT');
        Cluster__c cgGr = clusterList[0];
        categoryTest.Cluster__c=cgGr.Id;
        
		insert(categoryTest);
		Category__c categoryTest2 = new Category__c(Name='Category Test 02');
		categoryTest2.Cluster__c=cgGr.Id;
		//When
		Test.startTest();
		insert(categoryTest2);
		Test.stopTest();

		//Then
		Category__c catTestResult2 =[select id, ExternalId__c from Category__c where id =: categoryTest.id];
		System.assertNotEquals(catTestResult2.ExternalId__c, null);

	}
	
}