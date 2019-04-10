@isTest
public with sharing class CG_SocialNetworkControllerTest {
	
	@isTest
	public static void setNetworkData(){
		//Given
		MockupFactory.generateAcceleratorSetting();
		List<Cluster__c> cluster = MockupFactory.createCluster('ClusterTest', null, 1, 'ClusterRoot', 'CRT');
		List<Navigation__c> navigation = MockupFactory.createNavigation('TestNav', 'http://www.google.com/', 1 , cluster[0].Id);
		List<Brand__c> brand = MockupFactory.createBrand('BrandTest', 1, cluster[0].Id);
		List<SocialNetwork__c> socialNetwork = MockupFactory.createSocialNetworks('Test','test',brand[0].Id,navigation[0].Id,'Twitter');
		
		//Then
		Test.startTest();
		CG_SocialNetworkController.NetworkWrapper socialNetworkToBrand = CG_SocialNetworkController.getSocialNetworks(brand[0].Id);
		Test.stopTest();
	}
}