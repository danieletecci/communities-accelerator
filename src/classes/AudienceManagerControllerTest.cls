@isTest 
public with sharing class AudienceManagerControllerTest {

	@isTest 
	static void menuRelatedToComponent() {

		// Given
		MockupFactory.generateAcceleratorSetting();
		List<Cluster__c> clusterList = MockupFactory.createCluster('Global', null, 1, 'ClusterRoot', 'CRT');
		List<Menu__c> menuList = MockupFactory.createMenu('testMenu', 2, clusterList[0].id);
		List<Audience__c> audienceList = MockupFactory.createAudience('testAudience', 1, clusterList[0].id);

		// When 
		Test.startTest();
		AudienceManagerController.RecordsWrapper record =  AudienceManagerController.getRecords(menuList[0].id, GeneralUtils.prefix('[CMS]Menu__c'));
		
		Test.stopTest();

		System.debug('DEBUG RECORD'+record);
		List<Audience__c> audienceResultList =[SELECT id, ExternalId__c FROM Audience__c WHERE name like 'testAudience%'];

		// Then
		System.assertEquals(record.recordsToSelect[0].externalId, audienceResultList[0].ExternalId__c);
	}


	@isTest 
	static void saveRelationshipsTest() {

		// Given
		MockupFactory.generateAcceleratorSetting();
		List<Cluster__c> clusterList = MockupFactory.createCluster('Global', null, 1, 'ClusterRoot', 'CRT');
		List<Menu__c> menuList = MockupFactory.createMenu('testMenu', 2, clusterList[0].id);
		List<Audience__c> audienceList = MockupFactory.createAudience('testAudience', 1, clusterList[0].id);

		List<Audience__c> audienceResultList =[SELECT id, ExternalId__c FROM Audience__c WHERE name like 'testAudience%'];

		// When 
		Test.startTest();
		String response = AudienceManagerController.saveRelationships(menuList[0].id, GeneralUtils.prefix('[CMS]Menu__c'), new List<String>{audienceResultList[0].ExternalId__c});
		Test.stopTest();

		// Then
		System.assertEquals('OK', response);
	}
	
}