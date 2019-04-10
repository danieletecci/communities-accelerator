@isTest 
public with sharing class JunctionObjectManagerControllerTest {

	@isTest 
	static void findContent(){
		//Comment: Desde un componente Banner busco todos los registros de contenido, sin condiciones

		//Given
		MockupFactory.generateAcceleratorSetting();
		List<Cluster__c> cluster = MockupFactory.createCluster('Global',null, 1,'ClusterRoot', 'CRT');
		List<Component__c> comp = MockupFactory.createComponent('Banner', 1);
		List<Content__c> cont = MockupFactory.createContent('Banner',cluster[0],1);
		List<ContentAssignment__c> contAssign = MockupFactory.createContentAssignment(cont,comp);

		//When 
		Test.startTest();
		JunctionObjectManagerController.RecordsWrapper rw = JunctionObjectManagerController.getRecords(comp[0].Id, 'ContentAssignment__c',  'Component__c', 'Content__c', null, 'Name');
		Test.stopTest();

		//Then
		List<Content__c> contentResult = [SELECT Id FROM Content__c WHERE Id = :rw.recordsSelected[0].idRecord]; 
		System.assertEquals(1, contentResult.size());
	}

	@isTest 
	static void findContentWithCriteria(){
		// Comment: Desde un componente Banner busco todos los registros de contenido, con condiciones

		// Given
		MockupFactory.generateAcceleratorSetting();
		List<Cluster__c> cluster = MockupFactory.createCluster('Global',null, 1,'ClusterRoot', 'CRT');
		List<Component__c> comp = MockupFactory.createComponent('Banner', 1);
		List<Content__c> cont = MockupFactory.createContent('Banner',cluster[0],1);
		List<ContentAssignment__c> contAssign = MockupFactory.createContentAssignment(cont,comp);
	
		// When 
		Test.startTest();
		JunctionObjectManagerController.RecordsWrapper rw = JunctionObjectManagerController.getRecords(comp[0].id, 'ContentAssignment__c',  'Component__c', 'Content__c', 'WHERE ExternalId__c = \''+ comp[0].ExternalId__c + '\'', 'Name');
		Test.stopTest();
   
		// Then 
		Content__c var = [SELECT Id, ExternalId__c FROM Content__c WHERE Id = :rw.recordsSelected[0].idRecord];
		System.assertNotEquals(var, null);
	}

	@isTest 
	static void menuRelatedToComponent() {
		// Comment: Desde un componente Banner le relaciono dos registros de contenido.

		// Given
		MockupFactory.generateAcceleratorSetting();
		List<Cluster__c> cluster = MockupFactory.createCluster('Global', null, 1, 'ClusterRoot', 'CRT');
		List<Component__c> comp = MockupFactory.createComponent('Banner', 1);
		List<Menu__c> menu = MockupFactory.createMenu('testMenu', 2, cluster[0].id);
		List<MenuAssignment__c> menuAssign = MockupFactory.createMenuAssignment(menu,comp);

		List<String> listSelectedIds = new List<String>(); 
		listSelectedIds.add(menu[0].Id);
		listSelectedIds.add(menu[1].Id);

		// When 
		Test.startTest();
		String response = JunctionObjectManagerController.saveRelationships(comp[0].Id, 'MenuAssignment__c', 'Component__c', 'Menu__c', listSelectedIds, 'order__c', 'false');
		Test.stopTest();

		// Then
		System.assertEquals('OK', response);
	}


	@isTest 
	static void saveRelationshipsTest() {
		// Comment: Desde un componente Banner le relaciono dos registros de contenido.

		// Given
		MockupFactory.generateAcceleratorSetting();
		List<Cluster__c> cluster = MockupFactory.createCluster('Global', null, 1, 'ClusterRoot', 'CRT');
		List<Component__c> comp = MockupFactory.createComponent('Banner', 1);
		List<Menu__c> menu = MockupFactory.createMenu('testMenu', 2, cluster[0].id);
		List<MenuAssignment__c> menuAssign = MockupFactory.createMenuAssignment(menu,comp);

		List<String> listSelectedIds = new List<String>(); 
		listSelectedIds.add(menuAssign[0].Id);
//		listSelectedIds.add(menuAssign[1].Id);

		// When 
		Test.startTest();
		String response = JunctionObjectManagerController.saveRelationships(comp[0].Id, 'MenuAssignment__c', 'Component__c', 'Menu__c', listSelectedIds, 'order__c', 'true');
		Test.stopTest();

		// Then
		System.assertEquals('OK', response);
	}

}