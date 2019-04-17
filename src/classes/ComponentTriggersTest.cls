@isTest(seeAllData = false)
public with sharing class ComponentTriggersTest {

@isTest 
	static void insertComponentTest(){
		/* Comment: Comprueba que al crear un Component__c se inserta
		con el correspondiente ExternalId__c */
		
		//When
		Test.startTest();
		List<Component__c> componentTest = MockupFactory.createComponent('Banner', 1);
		Test.stopTest();

		//Then
		Component__c componentTestResult =[SELECT Id, ExternalId__c FROM Component__c WHERE Id =: componentTest];
		System.assertNotEquals(componentTestResult.ExternalId__c, null);
	}

	@isTest
	static void updateComponentTest(){
		/* Comment: Comprueba que al actualizar un Component__c se actualiza
		con el correspondiente ExternalId__c */

		//Given
		List<Component__c> componentTest = MockupFactory.createComponent('Banner', 1);
		componentTest[0].OrderBy__c = 'Custom Sorting';
		componentTest[0].OrderByAdvance__c = 'CreatedDate';
		update(componentTest);
		componentTest[0].ExternalId__c = null;
		componentTest[0].Name = 'Component Test 02';
		
		//When
		Test.startTest();
		update(componentTest);
		Test.stopTest();

		//Then
		Component__c componentTestResult2 =[SELECT Id, ExternalId__c FROM Component__c WHERE Id =: componentTest];
		System.assertNotEquals(componentTestResult2.ExternalId__c, null);
	}


@isTest
	static void checkIfClusterWasChangedInComponent(){
		//PA-206 Governance de Componentes(Reparenting)
		/*Comment: Comprueba que al modificar el Cluster, el componente no tenga 
		Contenidos, Tags o Categorias relacionadas con el Componente*/

		//Given
		MockupFactory.generateAcceleratorSetting();
		List<Cluster__c> clusterTest1 = MockupFactory.createCluster('CR1 Test', null, 1, 'ClusterRoot', 'CR1');
		List<Cluster__c> clusterTest2 = MockupFactory.createCluster('CR2 Test', null, 1, 'ClusterRoot', 'CR2');
		List<Component__c> componentListTest = MockupFactory.createComponent('Banner', 1);
		List<Content__c> contentListTest = MockupFactory.createContent('Banner', clusterTest1[0], 1);
		List<ContentAssignment__c> contentAssignmentListTest = MockupFactory.createContentAssignment(contentListTest, componentListTest);
		update componentListTest;
		List<Component__c> componentTest = [SELECT Id, Cluster__c FROM Component__c WHERE Id =: componentListTest];
		DmlException expectedException;

		//When
		Test.startTest();
		try{
			if(!componentTest.isEmpty()){
				componentTest[0].Cluster__c = clusterTest2[0].Id;  
			}
			update componentTest;
		}catch(DmlException expected){
			expectedException = expected;
		}
		Test.stopTest();

		//Then
		Component__c componentTestResult3 = [SELECT Id, Cluster__c FROM Component__c WHERE Id =: componentListTest]; 
		System.assertNotEquals(null,expectedException,Label.CannotReassignComponent);
	}


	@isTest
	static void insertComponentSharing()
	{
		// Given
		MockupFactory.generateAcceleratorSetting();
		List<Cluster__c> clusterRootList = MockupFactory.createCluster('ClusterRootTest', null, 1, 'ClusterRoot', 'CRT');
		List<Cluster__c> clusterList = [SELECT Id, Name FROM Cluster__c WHERE Name LIKE 'ClusterRootTest%' LIMIT 1 ];
		System.debug('ClusterTriggersTest method clusterList: '+clusterList);
		String nameRecordType = 'Banner';
		
		// When
		Test.startTest();
		List<Component__c> contentListTest = MockupFactory.createComponent(nameRecordType,  1, clusterList[0]);
		Test.stopTest();
		System.debug('ClusterTriggersTest method contentListTest: '+contentListTest);

		// Then
		List<Component__Share> shareList = [SELECT Id, ParentId FROM Component__Share WHERE ParentId = :contentListTest[0].Id AND RowCause = '[CMS]Clustering__c'];
		System.debug('ClusterTriggersTest method shareList: '+shareList);

		System.assertEquals(3, shareList.size());
	}

	@isTest
	static void updateComponentSharing(){
		// Given
		MockupFactory.generateAcceleratorSetting();
		List<Cluster__c> clusterRootList = MockupFactory.createCluster('ClusterRootTest', null, 2, 'ClusterRoot', 'CRT');
		List<Cluster__c> getClusterList = [SELECT Id, Name FROM Cluster__c WHERE Name LIKE 'ClusterRootTest%' LIMIT 2 ];
		System.debug('ClusterTriggersTest method getClusterList: '+getClusterList);
		
		List<Component__c> contentList = MockupFactory.createComponent('Banner', 1,getClusterList[0]);
		List<Component__c> getComponentList = [SELECT Id, Name FROM Component__c WHERE Name LIKE 'Banner%'];
		



		System.debug('ClusterTriggersTest method getComponentList: '+getComponentList);

		Component__c getComponentToUpdate = getComponentList[0];
		getComponentToUpdate.Cluster__c = getClusterList[1].Id;
		List<Component__c> componentToUpdateList = new List<Component__c>{getComponentToUpdate};
		System.debug('ClusterTriggersTest method componentToUpdateList: '+componentToUpdateList);
		// When
		Test.startTest();
		update componentToUpdateList;
		Test.stopTest();


		System.debug('ClusterTriggersTest method componentToUpdateList: '+componentToUpdateList);

		// Then
		List<Component__Share> shareList = [SELECT Id, ParentId FROM Component__Share WHERE ParentId = :componentToUpdateList[0].Id AND RowCause = '[CMS]Clustering__c'];
		System.debug('ClusterTriggersTest method shareList: '+shareList);

		System.assertEquals(6, shareList.size());

	}

	@isTest 
	static void deleteBeforeComponentTest(){
		/* Comment: Comprueba que al eliminar un Content__c se eliminan
		los assigment correspondientes */

		//Given
		MockupFactory.generateAcceleratorSetting();
		List<Cluster__c> clusterArg = MockupFactory.createCluster('Global', null, 1, 'ClusterRoot', 'CRT');
		List<Component__c> componentList = MockupFactory.createComponent('Banner', 1, clusterArg[0]);
		
		List<Content__c> contentList = MockupFactory.createContent('Banner', clusterArg[0], 1);
		List<ContentAssignment__c> contentAssigList = MockupFactory.createContentAssignment(contentList, componentList);
		
		List<Menu__c> menuList = MockupFactory.createMenu('menuName', 1, clusterArg[0].id);
		List<MenuAssignment__c> menuAssigList = MockupFactory.createMenuAssignment(menuList, componentList);

		List<Tag__c> tagList = MockupFactory.createTag('TestTag', 'description', 1, clusterArg[0].id);
		List<TagAssignment__c> tagAssigList =  MockupFactory.createTagAssignment(tagList, componentList, contentList);

		List<Category__c> categoryList = MockupFactory.createCategory('catName', 1, clusterArg[0].id);
		List<CategoryAssignment__c> categoryAssigList = MockupFactory.createCategoryAssignment(categoryList, componentList);

		//When
		Test.startTest();
		delete componentList;
		Test.stopTest();

		//Then
        List<ContentAssignment__c> contentAssignResultList = [SELECT ID FROM ContentAssignment__c WHERE id = : contentAssigList[0].id];
        List<MenuAssignment__c> menuAssignResultList = [SELECT ID FROM MenuAssignment__c WHERE id = :  menuAssigList[0].id];  
        List<TagAssignment__c> tagAssignResultList = [SELECT ID FROM TagAssignment__c WHERE id = : tagAssigList[0].id];
		List<CategoryAssignment__c> categoryAssignResultList = [SELECT ID FROM CategoryAssignment__c WHERE id = : categoryAssigList[0].id];

		System.Assert(contentAssignResultList.isEmpty());
		System.Assert(menuAssignResultList.isEmpty());
		System.Assert(tagAssignResultList.isEmpty());
		System.Assert(categoryAssignResultList.isEmpty());
	}

}