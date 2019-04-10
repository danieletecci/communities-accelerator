@isTest(seeAllData = false)
public class MenuAssignmentTriggersTest {
	
	@isTest 
	static void insertMenuAssignmentTest(){
		/* Comment: Comprueba que al crear un MenuAssignment__c se inserta
			con el correspondiente ExternalId__c */

		//Given
		MockupFactory.generateAcceleratorSetting();
        Cluster__c cluster = MockupFactory.createCluster('Argentina', null, 1, 'ClusterRoot', 'CRT')[0];
		MockupFactory.createComponent('Banner', 1);
		Menu__c menuTest = new Menu__c(Name='Test');
		insert menuTest;

		Component__c compTest = [select id, Name, ExternalId__c from Component__c limit 1];			

		MenuAssignment__c menuAssigmentTest = new MenuAssignment__c(Component__c = compTest.id, Menu__c=menuTest.id, Order__c = 1);

		//When
		Test.startTest();
			insert(menuAssigmentTest);
		Test.stopTest();

		//Then
		MenuAssignment__c menuAssigmentTestResult =[select id, ExternalId__c from MenuAssignment__c where id =: menuAssigmentTest.id];
		System.assertNotEquals(menuAssigmentTestResult.ExternalId__c, null);

	}

	@isTest
	static void updateMenuAssignment(){
		/*Comment: Comprueba que al actualizar un MenuAssignment__c se actualiza
		con correspondiente ExternalId__c */

		//Given
		MockupFactory.generateAcceleratorSetting();
        Cluster__c cluster = MockupFactory.createCluster('Argentina', null, 1, 'ClusterRoot', 'CRT')[0];
		MockupFactory.createComponent('Banner', 1);
        Component__c compTest = [select id, Name, ExternalId__c from Component__c limit 1];
		Menu__c menuTest = new Menu__c(Name='Test');
		insert menuTest;
		MenuAssignment__c menuAssigmentTest = new MenuAssignment__c(Component__c = compTest.id, Menu__c=menuTest.id, Order__c = 1);
		insert menuAssigmentTest;
		menuAssigmenttest.ExternalId__c = null;


		//When
		Test.startTest();
		update(menuAssigmenttest);
		Test.stopTest();

		//Then
		MenuAssignment__c menuAssigmentTestResult =[select id, ExternalId__c from MenuAssignment__c where id =: menuAssigmentTest.id];
		System.assertNotEquals(menuAssigmentTestResult.ExternalId__c, null);

	}
}