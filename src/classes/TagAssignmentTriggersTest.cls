@isTest(seeAllData = false)
public class TagAssignmentTriggersTest {
	
	@isTest 
	static void insertTagAssignmentTest(){
		/* Comment: Comprueba que al crear un TagAssignment__c se inserta
			con el correspondiente ExternalId__c */

		//Given
		//MockupFactory.createRecords();
		Tag__c tagTest = new Tag__c(Name='Test');
		insert tagTest;

		Component__c compTest = [select id, Name, ExternalId__c from Component__c limit 1];
		Content__c contTest = [select id, Name, ExternalId__c from Content__c limit 1];								

		TagAssignment__c tagAssigmentTest = new TagAssignment__c(Component__c = compTest.id, Content__c=contTest.id );

		//When
		Test.startTest();
			insert(tagAssigmentTest);
		Test.stopTest();

		//Then
		TagAssignment__c tagAssigmentTestResult =[select id, ExternalId__c from TagAssignment__c where id =: tagAssigmentTest.id];
		System.assertNotEquals(tagAssigmentTestResult.ExternalId__c, null);

	}

	@isTest
	static void updateTagAssignment(){
		/*Comment: Comprueba que al actualizar un TagAssignment__c se actualiza
		con correspondiente ExternalId__c */

		//Given
		//MockupFactory.createRecords();
		Component__c compTest = [select id, Name, ExternalId__c from Component__c limit 1];
		Content__c contTest = [select id, Name, ExternalId__c from Content__c limit 1];	
		TagAssignment__c tagAssigmentTest = new TagAssignment__c(Component__c = compTest.id, Content__c=contTest.id );
		insert tagAssigmentTest;
		tagAssigmenttest.ExternalId__c = null;


		//When
		Test.startTest();
		update(tagAssigmenttest);
		Test.stopTest();

		//Then
		TagAssignment__c tagAssigmentTestResult =[select id, ExternalId__c from TagAssignment__c where id =: tagAssigmentTest.id];
		System.assertNotEquals(tagAssigmentTestResult.ExternalId__c, null);

	}
}