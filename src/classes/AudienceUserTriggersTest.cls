@isTest
private class AudienceUserTriggersTest {
    @testSetup
    static void generateAcceleratorSetting(){
        MockupFactory.generateAcceleratorSetting();
        
    }
@isTest
	static void insertAudienceUserTest(){
		/* Comment: Comprueba que al crear un AudienceUser__c se inserta
		con el correspondiente ExternalId__c */
		
		//When
		Test.startTest();
		List<Cluster__c> clusterList = MockupFactory.createCluster('ClusterRootTest', null, 1, 'ClusterRoot', 'CRT');
		User us = MockupFactory.createUser('userTest@cg.com','test@testinguser.com');
		AudienceUser__c AU = MockupFactory.createAudienceUser('AudienceUser1',clusterList[0].Id,'Active',us.Id);
		Test.stopTest();

		//Then
		AudienceUser__c audienceUserTestResult =[SELECT Id, ExternalId__c FROM AudienceUser__c WHERE Id =: AU.Id];
		System.assertNotEquals(audienceUserTestResult.ExternalId__c, null);
	}

	@isTest
	static void updateAudienceUserTest(){
		/* Comment: Comprueba que al actualizar un AudienceUser__c se actualiza
		con el correspondiente ExternalId__c */

		//Given
	    List<Cluster__c> clusterList = MockupFactory.createCluster('ClusterRootTest', null, 1, 'ClusterRoot', 'CRT');
		User us = MockupFactory.createUser('userTest@cg.com','test@testinguser.com');
		AudienceUser__c AU = MockupFactory.createAudienceUser('AudienceUser1',clusterList[0].Id,'Active',us.Id);
		AU.ExternalId__c = '';
		

		
		//When
		Test.startTest();
		update(AU);
		Test.stopTest();

		//Then
		AudienceUser__c audienceUserTest2 =[SELECT Id, ExternalId__c FROM AudienceUser__c WHERE Id =: AU.Id];
		System.assertNotEquals(audienceUserTest2.ExternalId__c, null);
	}

}