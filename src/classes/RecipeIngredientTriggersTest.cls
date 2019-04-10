@isTest
private class RecipeIngredientTriggersTest {

@testSetup
    static void setupTest(){
    	MockupFactory.generateAcceleratorSetting();
    	String name = 'Argentina';
    	List<Cluster__c> clusterRootList = MockupFactory.createCluster(name, null, 1, 'ClusterRoot', 'CRT');
    	List<Content__c> contentList = MockupFactory.createContent('Recipe', clusterRootList[0], 1);
    	List<Recipe__c> recipesList = MockupFactory.createRecipes('RecipeTest',1, contentList[0].id, clusterRootList[0].id); 
    }

	@isTest 
	static void ExternalIdTest() {
		//When
//		RecipeIngredient__c recipeIng = new RecipeIngredient__c(name='TestIngredient');
		List<Recipe__c> recipesList = [SELECT id from Recipe__c];
		//Given
		Test.startTest();
		List<RecipeIngredient__c> ingredientList = MockupFactory.createRecipeIngredientWithoutBrand('TestIngredient', 1, recipesList[0].id);
		Test.stopTest();

		//Then
		RecipeIngredient__c recipeIngTest = [SELECT id, ExternalID__c from RecipeIngredient__c where id =: ingredientList[0].Id Limit 1];
		System.assertNotEquals(recipeIngTest.ExternalID__c, null);
	}

	@isTest 
	static void ExternalIdUpdateTest() {
		//When
		List<Recipe__c> recipesList = [SELECT id from Recipe__c];
		List<RecipeIngredient__c> ingredientList = MockupFactory.createRecipeIngredientWithoutBrand('TestIngredient', 1, recipesList[0].id);

		RecipeIngredient__c recipeIng = [SELECT id, Name, ExternalID__c from RecipeIngredient__c where id =: ingredientList[0].Id Limit 1];
		recipeIng.ExternalID__c='';
		//Given
		Test.startTest();
		update recipeIng;
		Test.stopTest();

		//Then
		RecipeIngredient__c recipeIngTest = [SELECT id, Name, ExternalID__c from RecipeIngredient__c where id =: recipeIng.Id Limit 1];
		System.assertEquals(recipeIngTest.ExternalID__c, recipeIngTest.Name);
	}
}