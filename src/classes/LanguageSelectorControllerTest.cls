@isTest(seeAllData = false)
public with sharing class LanguageSelectorControllerTest {

	@testSetup
	static void generateCustomSettings(){
		MockupFactory.generateAcceleratorSetting();
	}

	@isTest 
	static void insertCategoryTest(){
		/* Comment: Comprueba que dado un Cluster__c retorna un wrapper con los idiomas 
			correspondientes*/

		//Given
		List<Cluster__c> clusterRootList = MockupFactory.createCluster('ClusterRootTest', null, 1, 'ClusterRoot', 'CRT');
		List<Cluster__c> clusterList = [SELECT Id, Name FROM Cluster__c WHERE Name LIKE 'ClusterRootTest%' LIMIT 1 ];
		Cluster__c cluster = clusterList[0];
		cluster.DefaultLanguage__c='es';
		cluster.OtherLanguages__c='en_US';
		update cluster;

		//When
		Test.startTest();

		LanguageSelectorController.MenuWrapper wrap = LanguageSelectorController.getLanguageMenu(cluster.Id);
		
		Test.stopTest();
		//Then
		System.assertNotEquals(wrap, null);
	}

		@isTest 
	static void setLanguageTest(){
		/* Comment: Comprueba que seleccionado un lenguaje se setea en el usuario*/

		//Given

		//When
		Test.startTest();

		LanguageSelectorController.setLanguage('es');
		
		Test.stopTest();
		//Then
		User u = [SELECT id ,LanguageLocaleKey FROM User WHERE id =: UserInfo.getUserId()];
		System.assertEquals(u.LanguageLocaleKey, 'es');
	}
}