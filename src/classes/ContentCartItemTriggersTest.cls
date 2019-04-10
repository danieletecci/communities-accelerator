@isTest
private class ContentCartItemTriggersTest {
	@testSetup
    static void setupTest(){
    	String nameRecordType = 'Banner';
    	Integer quantity = 3;
    	MockupFactory.generateAcceleratorSetting();
        
        String name = 'Argentina';
        List<Cluster__c> clusterRootList = MockupFactory.createCluster(name, null, 1, 'ClusterRoot', 'CRT');
        Cluster__c cg = clusterRootList[0];
        List<Cluster__c> clusterList = MockupFactory.createCluster('Buenos Aires', cg.Id, 1, 'ClusterGroup', 'CGT');
    	List<Content__c> contentList = MockupFactory.createContent(nameRecordType, clusterList[0], quantity);
       
    }

	@isTest 
	static void ExternalIdTest() {
		//When
		

		Content__c content = [SELECT id from Content__c Limit 1];

		ContentCartItem__c item = new ContentCartItem__c(Content__c = content.Id, User__c = UserInfo.getUserId(), Name='Test');

		//Given
		Test.startTest();
		insert item;
		Test.stopTest();

		//Then
		ContentCartItem__c itemTest = [SELECT id, ExternalID__c from ContentCartItem__c Limit 1];
		System.assertNotEquals(itemTest.ExternalID__c, null);
	}

	@isTest 
	static void ExternalIdUpdateTest() {
		//When
		

		Content__c content = [SELECT id from Content__c Limit 1];

		ContentCartItem__c item = new ContentCartItem__c(Content__c = content.Id, User__c = UserInfo.getUserId(), Name='Test');
		insert item;
		item = [SELECT id, ExternalID__c, Name from ContentCartItem__c where Content__c =: content.Id and User__c =: UserInfo.getUserId()  Limit 1];
		item.Name = 'TestUpdate';
		item.ExternalID__c = '';
		//Given
		Test.startTest();
		update item;
		Test.stopTest();

		//Then
		ContentCartItem__c itemTest = [SELECT id, ExternalID__c from ContentCartItem__c where Content__c =: content.Id and User__c =: UserInfo.getUserId()  Limit 1];
		System.assertEquals(itemTest.ExternalID__c, 'TestUpdate');
	}
}