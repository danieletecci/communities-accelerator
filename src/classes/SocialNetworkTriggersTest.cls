@isTest(seeAllData = false)
public with sharing class SocialNetworkTriggersTest {
	
	@testSetup
	static void generateCustomSettings(){
		MockupFactory.generateAcceleratorSetting();
	}

	@isTest
	public static void insertExternalId(){
		//Given
		List<Cluster__c> cluster = MockupFactory.createCluster('ClusterTest', null, 1, 'ClusterRoot', 'CRT');
		List<Navigation__c> navigation = MockupFactory.createNavigation('TestNav', 'http://www.google.com/', 1 , cluster[0].Id);
		List<Brand__c> brand = MockupFactory.createBrand('BrandTest', 1, cluster[0].Id);
		
		//When
		Test.startTest();
		List<SocialNetwork__c> socialNetwork = MockupFactory.createSocialNetworks('Test','test',brand[0].Id,navigation[0].Id, 'Twitter');
		Test.stopTest();

		//Then
		SocialNetwork__c socialNetworkResult = [SELECT Id, ExternalId__c FROM SocialNetwork__c WHERE Id =: socialNetwork[0].Id];
		System.assertNotEquals(socialNetworkResult.ExternalId__c, null);
	}

	@isTest
	public static void updateExternalId(){
		//Given
		List<Cluster__c> cluster = MockupFactory.createCluster('ClusterTest', null, 1, 'ClusterRoot', 'CRT');
		List<Navigation__c> navigation = MockupFactory.createNavigation('TestNav', 'http://www.google.com/', 1 , cluster[0].Id);
		List<Brand__c> brand = MockupFactory.createBrand('BrandTest', 1, cluster[0].Id);
		
		//When
		Test.startTest();
		List<SocialNetwork__c> socialNetwork = MockupFactory.createSocialNetworks('Test','test',brand[0].Id,navigation[0].Id, 'Twitter');
		socialNetwork[0].ExternalId__c = 'Test2';
		update socialNetwork[0];
		Test.stopTest();

		//Then
		SocialNetwork__c socialNetworkResult = [SELECT Id, ExternalId__c FROM SocialNetwork__c WHERE Id =: socialNetwork[0].Id];
		System.assertNotEquals(socialNetworkResult.ExternalId__c, null);	
	}
}