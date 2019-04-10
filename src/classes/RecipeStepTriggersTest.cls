@isTest
private class RecipeStepTriggersTest {

@testSetup
    static void setupTest(){
    	MockupFactory.generateAcceleratorSetting();
    	String name = 'Argentina';
    	List<Cluster__c> clusterRootList = MockupFactory.createCluster(name, null, 1, 'ClusterRoot', 'CRT');
    	List<Content__c> contentList = MockupFactory.createContent('Recipe', clusterRootList[0], 1);    	
    	List<Recipe__c> recipesList = MockupFactory.createRecipes('RecipeTest',1, contentList[0].id,clusterRootList[0].id); 
    }

	@isTest 
	static void ExternalIdTest() {
		//When
		List<Recipe__c> recipesList = [SELECT id from Recipe__c];
		//Given
		Test.startTest();
		List<RecipeStep__c> stepList = MockupFactory.createRecipeStep('TestStep', 1, recipesList[0].id);
		Test.stopTest();

		//Then
		RecipeStep__c recipeStepTest = [SELECT id, ExternalID__c from RecipeStep__c where id =: stepList[0].Id Limit 1];
		System.assertNotEquals(recipeStepTest.ExternalID__c, null);
	}

	@isTest 
	static void ExternalIdUpdateTest() {
		//When
		List<Recipe__c> recipesList = [SELECT id from Recipe__c];
		List<RecipeStep__c> stepsList = MockupFactory.createRecipeStep('TestStep', 1, recipesList[0].id);

		RecipeStep__c recipeStep = [SELECT id, Name, ExternalID__c from RecipeStep__c where id =: stepsList[0].Id Limit 1];
		recipeStep.ExternalID__c='';
		//Given
		Test.startTest();
		update recipeStep;
		Test.stopTest();

		//Then
		RecipeStep__c recipeStepTest = [SELECT id, Name, ExternalID__c from RecipeStep__c where id =: recipeStep.Id Limit 1];
		System.assertEquals(recipeStepTest.ExternalID__c, recipeStepTest.Name);
	}
}