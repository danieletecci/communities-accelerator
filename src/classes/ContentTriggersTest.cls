@isTest(seeAllData = false)
public with sharing class ContentTriggersTest {

    @testSetup
	static void generateData(){
		MockupFactory.generateAcceleratorSetting();
		List<Cluster__c> clusterRoot = MockupFactory.createCluster('Cluster Root', '', 1, 'ClusterRoot', 'CRT');
        MockupFactory.createComponent('Banner', 1, clusterRoot.get(0));
	}

	@isTest 
	static void insertContentTest(){
		/* Comment: Comprueba que al crear un Content__c se inserta
		con el correspondiente ExternalId__c */

		//Given
		List<Cluster__c> clusterArg = MockupFactory.createCluster('Global', null, 1, 'ClusterRoot', 'ARG');

		//When
		Test.startTest();
		List<Content__c> contentTest = MockupFactory.createContent('Banner', clusterArg[0], 1);
		Test.stopTest();

		//Then
		Content__c contentTestResult =[SELECT ExternalId__c FROM Content__c WHERE Id =: contentTest[0].Id];
		System.assertNotEquals(contentTestResult.ExternalId__c, null);
	}

	@isTest
	static void updateContentTest(){
		/* Comment: Comprueba que al actualizar un Content__c se actualiza
		con el correspondiente ExternalId__c */

		//Given
		List<Cluster__c> clusterArg = MockupFactory.createCluster('Global', null, 1, 'ClusterRoot', 'ARG');
		List<Content__c> contentTest = MockupFactory.createContent('Banner', clusterArg[0], 1);
		contentTest[0].ExternalId__c = null;
		contentTest[0].Name = 'Content Test 02';

		//When
		Test.startTest();
		update(contentTest);
		Test.stopTest();

		//Then
		Content__c contentTestResult2 =[SELECT ExternalId__c FROM Content__c WHERE Id =: contentTest[0].Id];
		System.assertNotEquals(contentTestResult2.ExternalId__c, null);
	}

	@isTest
	static void insertComponentSharing()
	{
		/*
		Valida la creacion de las Manual Sharing al moemnto de crear un Tag*/

		// Given
		List<Cluster__c> clusterRootList = MockupFactory.createCluster('ClusterRootTest', null, 1, 'ClusterRoot', 'ARG');
		List<Cluster__c> getClusterList = [SELECT Id, Name FROM Cluster__c WHERE Name LIKE 'ClusterRootTest%' LIMIT 1 ];
		//System.debug('ClusterTriggersTest method clusterList: '+clusterList);
		
		// When
		Test.startTest();
		List<Content__c> contentList = MockupFactory.createContent('Banner', getClusterList[0], 1);
		Test.stopTest();

		// Then
		List<Content__Share> shareList = [SELECT Id, ParentId FROM Content__Share WHERE ParentId = :contentList[0].Id AND RowCause = 'Clustering__c'];

		System.assertEquals(3, shareList.size());

	}


	@isTest
	static void updateNavigationSharing(){
		// Given
		List<Cluster__c> clusterRootList = MockupFactory.createCluster('ClusterRootTest', null, 2, 'ClusterRoot', 'ARG');
		List<Cluster__c> getClusterList = [SELECT Id, Name FROM Cluster__c WHERE Name LIKE 'ClusterRootTest%' LIMIT 2 ];
		System.debug('ClusterTriggersTest method getClusterList: '+getClusterList);
		
		List<Content__c> contentList = MockupFactory.createContent('Banner', getClusterList[0], 1);
		List<Content__c> getContentList = [SELECT Id, Name FROM Content__c ];
		System.debug('ClusterTriggersTest method getContentList: '+getContentList);

		Content__c getContenToUpdate = getContentList[0];
		getContenToUpdate.Cluster__c = getClusterList[1].Id;
		List<Content__c> contenToUpdateList = new List<Content__c>{getContenToUpdate};
		System.debug('ClusterTriggersTest method contenToUpdateList: '+contenToUpdateList);
		// When
		Test.startTest();
		update contenToUpdateList;
		Test.stopTest();


		System.debug('ClusterTriggersTest method contenToUpdateList: '+contenToUpdateList);

		// Then
		List<Content__Share> shareList = [SELECT Id, ParentId FROM Content__Share WHERE ParentId = :contenToUpdateList[0].Id AND RowCause = 'Clustering__c'];
		System.debug('ClusterTriggersTest method shareList: '+shareList);

		System.assertEquals(6, shareList.size());

	}

	@isTest 
	static void deleteBeforeContentTest(){
		/* Comment: Comprueba que al eliminar un Content__c se eliminan
		los assigment correspondientes */

		//Given
		List<Cluster__c> clusterArg = MockupFactory.createCluster('Global', null, 1, 'ClusterRoot', 'ARG');
		List<Content__c> contentTest = MockupFactory.createContent('Banner', clusterArg[0], 1);
		
		List<MediaElement__c> mediaElementList = MockupFactory.createMediaElement(1);
		List<MediaElementAssignment__c> mediaElementAssigList = MockupFactory.createMediaElementAssignment(contentTest, mediaElementList);

		Component__c component = [SELECT Id FROM Component__c LIMIT 1];

		List<Tag__c> tagList = MockupFactory.createTag('TestTag', 'description', 1, clusterArg[0].id);
		List<TagAssignment__c> tagAssigList =  MockupFactory.createTagAssignment(tagList, new List<Component__c>{component}, contentTest);
		//When
		Test.startTest();
		delete contentTest;
		Test.stopTest();

		//Then

		List<MediaElementAssignment__c> mediaElementAssignResultList = [SELECT ID FROM MediaElementAssignment__c WHERE id = : mediaElementAssigList[0].id];
        List<TagAssignment__c> tagAssignResultList = [SELECT ID FROM TagAssignment__c WHERE id = : tagAssigList[0].id];

		System.Assert(mediaElementAssignResultList.isEmpty());
		System.Assert(tagAssignResultList.isEmpty());
	}

//	@isTest 
//	static void AdvanceContentTest(){
		/* Comment: Comprueba que al crear un Content__c se inserta
		con el correspondiente ExternalId__c */

/*		//Given
		MockupFactory.generateAcceleratorSetting();
		List<Cluster__c> clusterArg = MockupFactory.createCluster('Global', null, 1, 'ClusterRoot');
		List<Content__c> contentList = MockupFactory.createContent('Advance Content', clusterArg[0], 1);

		Content__c contentTest = [SELECT Id, Name, ExternalId__c, HTMLContent__c FROM Content__c WHERE Id =: contentList[0].Id];
		contentTest.HTMLContent__c ='<h1>[!Cluster__c.Name]</h1>';

		//When
		Test.startTest();
			update contentTest;		
		Test.stopTest();

		//Then
		Content__c contentTestResult =[SELECT ExternalId__c FROM Content__c WHERE Id =: contentTest.Id];
		System.assertNotEquals(contentTestResult.ExternalId__c, null);
	}
*/

	@isTest 
	static void insertContentAssignment(){

		//Given
        Component__c component = [SELECT Id FROM Component__c LIMIT 1];
        component.Datasource__c = 'ManualAssignment';
        update component;
        List<Cluster__c> clusterArg = MockupFactory.createCluster('Global', null, 1, 'ClusterRoot', 'ARG');

		//When
		Test.startTest();
		Content__c contentTest = MockupFactory.createBannerContentRelatedToComponent(clusterArg[0], component);
		contentTest.HTMLContent__c = '<h1>WELCOME [!user.name]</h1>';
		update contentTest;
		Test.stopTest();

		//Then
		List<ContentAssignment__c> contAssigment = [SELECT Id FROM ContentAssignment__c WHERE Component__c =: component.Id AND Content__c =: contentTest.Id];
		System.Assert(!contAssigment.isEmpty());
	}

}