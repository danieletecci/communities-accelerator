@isTest(seeAllData = false)
public class ContentAssignmentTriggersTest {
	
	@isTest 
	static void insertContentAssignmentTest(){
		/* Comment: Comprueba que al crear un ContentAssignment__c se inserta
			con el correspondiente ExternalId__c */

		//Given

		MockupFactory.generateAcceleratorSetting();
		List<Cluster__c> clusterRootList = MockupFactory.createCluster('ClusterRootTest', null, 1, 'ClusterRoot', 'CRT');
		List<Content__c> listContent= MockupFactory.createContent('Banner', clusterRootList[0], 1);
		List<Component__c> listComponent = MockupFactory.createComponent('Banner', 1);							

		ContentAssignment__c contentAssigmentTest = new ContentAssignment__c(Component__c = listComponent[0].id, Content__c = listContent[0].id );

		//When
		Test.startTest();
			insert(contentAssigmentTest);
		Test.stopTest();

		//Then
		ContentAssignment__c contentAssigmentTestResult =[select id, ExternalId__c from ContentAssignment__c where id =: contentAssigmentTest.id];
		System.assertNotEquals(contentAssigmentTestResult.ExternalId__c, null);

	}

	@isTest
	static void updateContentAssignment(){
		/*Comment: Comprueba que al actualizar un ContentAssignment__c se actualiza
		con correspondiente ExternalId__c */

		//Given
		MockupFactory.generateAcceleratorSetting();
		List<Cluster__c> clusterRootList = MockupFactory.createCluster('ClusterRootTest', null, 1, 'ClusterRoot', 'CRT');
		List<Content__c> listContent= MockupFactory.createContent('Banner', clusterRootList[0], 1);
		List<Component__c> listComponent = MockupFactory.createComponent('Banner', 1);		
		
		ContentAssignment__c contentAssigmentTest = new ContentAssignment__c(Component__c = listComponent[0].id, Content__c=listContent[0].id );
		insert contentAssigmentTest;
		ContentAssigmenttest.ExternalId__c = null;


		//When
		Test.startTest();
		update(contentAssigmenttest);
		Test.stopTest();

		//Then
		ContentAssignment__c contentAssigmentTestResult =[select id, ExternalId__c from ContentAssignment__c where id =: contentAssigmentTest.id];
		System.assertNotEquals(contentAssigmentTestResult.ExternalId__c, null);

	}
}