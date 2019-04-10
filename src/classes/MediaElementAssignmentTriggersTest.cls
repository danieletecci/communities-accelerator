@isTest(seeAllData = false)
public class MediaElementAssignmentTriggersTest {
	
	@isTest 
	static void insertMediaElementAssignmentTest(){
		/* Comment: Comprueba que al crear un MediaElementAssignment__c se inserta
			con el correspondiente ExternalId__c */

		//Given
		MockupFactory.generateAcceleratorSetting();
		List<Cluster__c> clusterRootList = MockupFactory.createCluster('ClusterRootTest', null, 1, 'ClusterRoot', 'CRT');
		List<Content__c> listContent= MockupFactory.createContent('Banner', clusterRootList[0], 1);

		MediaElement__c mediaElementTest = new MediaElement__c(Name='Test');
		insert mediaElementTest;						

		MediaElementAssignment__c MediaElementAssigmentTest = new MediaElementAssignment__c(Content__c=listContent[0].id, MediaElement__c = mediaElementTest.Id);

		//When
		Test.startTest();
			insert(mediaElementAssigmentTest);
		Test.stopTest();

		//Then
		MediaElementAssignment__c mediaElementAssigmentTestResult =[select id, ExternalId__c from MediaElementAssignment__c where id =: mediaElementAssigmentTest.id];
		System.assertNotEquals(mediaElementAssigmentTestResult.ExternalId__c, null);

	}

	@isTest
	static void updateMediaElementAssignment(){
		/*Comment: Comprueba que al actualizar un MediaElementAssignment__c se actualiza
		con correspondiente ExternalId__c */

		//Given
		MockupFactory.generateAcceleratorSetting();
		List<Cluster__c> clusterRootList = MockupFactory.createCluster('ClusterRootTest', null, 1, 'ClusterRoot', 'CRT');
		List<Content__c> listContent= MockupFactory.createContent('Banner', clusterRootList[0], 1);
		
		MediaElement__c mediaElementTest = new MediaElement__c(Name='Test');
		insert mediaElementTest;
		
		MediaElementAssignment__c mediaElementAssigmentTest = new MediaElementAssignment__c(Content__c=listContent[0].id, MediaElement__c = mediaElementTest.Id);
		insert mediaElementAssigmentTest;
		mediaElementAssigmenttest.ExternalId__c = null;


		//When
		Test.startTest();
		update(mediaElementAssigmenttest);
		Test.stopTest();

		//Then
		MediaElementAssignment__c mediaElementAssigmentTestResult =[select id, ExternalId__c from MediaElementAssignment__c where id =: MediaElementAssigmentTest.id];
		System.assertNotEquals(mediaElementAssigmentTestResult.ExternalId__c, null);

	}
	
}