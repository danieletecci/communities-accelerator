@isTest
private class RecipeTriggersTest {	

@testSetup
    static void setupTest(){
    	MockupFactory.generateAcceleratorSetting();
        
        String name = 'Argentina';
        List<Cluster__c> clusterRootList = MockupFactory.createCluster(name, null, 1, 'ClusterRoot', 'CRT');
        Cluster__c cg = clusterRootList[0];
        List<Cluster__c> clusterList = MockupFactory.createCluster('BuenosAires', cg.Id, 1, 'ClusterGroup', 'CGT');
        List<Content__c> contentList = MockupFactory.createContent('Recipe', clusterList[0], 1);
       
    }

	@isTest 
	static void ExternalIdTest() {
		//When
		Cluster__c cluster = [Select id FROM Cluster__c Limit 1]; 
		Content__c cont = [SELECT id from Content__c limit 1];
		//Given
		Test.startTest();
		List<Recipe__c> recipesList = MockupFactory.createRecipes('recipe test', 1, cont.id, cluster.Id);
		Test.stopTest();

		//Then
		Recipe__c recipeTest = [SELECT id, ExternalID__c from Recipe__c where id =: recipesList[0].Id Limit 1];
		System.assertNotEquals(recipeTest.ExternalID__c, null);
	}

	@isTest 
	static void ExternalIdUpdateTest() {
		//When
		Cluster__c cluster = [Select id FROM Cluster__c Limit 1]; 
		Content__c cont = [SELECT id from Content__c limit 1]; 
		List<Recipe__c> recipesList = MockupFactory.createRecipes('recipeTestUpdate', 1, cont.id, cluster.Id);
		Recipe__c recipe = [SELECT id, ExternalID__c, Name from Recipe__c where id =: recipesList[0].Id Limit 1];
		recipe.ExternalID__c='';
		
		//Given
		Test.startTest();
		update recipe;
		Test.stopTest();

		//Then
		Recipe__c recipeTest = [SELECT id, ExternalID__c, Name from Recipe__c where Id =: recipe.Id   Limit 1];
		System.assertNotEquals(recipeTest.ExternalID__c, null);
	}
	

	@isTest 
	static void insertRecipeSharing() {
		//When
		Cluster__c cluster = [Select id FROM Cluster__c Limit 1]; 
		Content__c cont = [SELECT id from Content__c limit 1]; 
		//Given
		Test.startTest();
		List<Recipe__c> recipesList = MockupFactory.createRecipes('recipe test', 1, cont.id, cluster.Id);
		Test.stopTest();

		//Then
		List<Recipe__Share> shareList = [SELECT Id, ParentId FROM Recipe__Share WHERE ParentId = :recipesList[0].Id AND RowCause = 'Clustering__c'];
		
		System.assertEquals(3, shareList.size());
	}

	@isTest 
	static void insertSharingWithoutClusterId() {
		//When
		Content__c cont = [SELECT id from Content__c limit 1]; 
		//Given
		Test.startTest();
		List<Recipe__c> recipesList = MockupFactory.createRecipes('recipe test', 1, cont.id, null);
		Test.stopTest();

		//Then
		List<Recipe__Share> shareList = [SELECT Id, ParentId FROM Recipe__Share WHERE ParentId = :recipesList[0].Id AND RowCause = 'Clustering__c'];
		
		System.assertEquals(0, shareList.size());
	}


	@isTest
	static void updateMenuSharing(){
		// Given
		List<Cluster__c> clusterRootList = MockupFactory.createCluster('ClusterRootTest', null, 2, 'ClusterRoot', 'CR2');
		List<Cluster__c> getClusterList = [SELECT Id, Name FROM Cluster__c WHERE Name LIKE 'ClusterRootTest%' LIMIT 2 ];
		System.debug('ClusterTriggersTest method getClusterList: '+getClusterList);
		Content__c cont = [SELECT id from Content__c limit 1]; 
		List<Recipe__c> recipesList = MockupFactory.createRecipes('recipe test', 1, cont.id, getClusterList[0].Id);
		Recipe__c recipe = [SELECT id, Name, ExternalID__c, Cluster__c from Recipe__c where id =: recipesList[0].Id Limit 1];
		recipe.Cluster__c = getClusterList[1].Id;
			
		// When
		Test.startTest();
		update recipe;
		Test.stopTest();

		// Then
		List<Recipe__Share> shareList = [SELECT Id, ParentId FROM Recipe__Share WHERE ParentId = :recipe.Id AND RowCause = 'Clustering__c'];	
		System.assertEquals(6, shareList.size());
	}

	@isTest
	static void updateMenuSharingWithoutClusterId(){
		// Given
		List<Cluster__c> clusterRootList = MockupFactory.createCluster('ClusterRootTest', null, 2, 'ClusterRoot', 'CR2');
		List<Cluster__c> getClusterList = [SELECT Id, Name FROM Cluster__c WHERE Name LIKE 'ClusterRootTest%' LIMIT 2 ];	
		Content__c cont = [SELECT id from Content__c limit 1]; 
		List<Recipe__c> recipesList = MockupFactory.createRecipes('recipe test', 1, cont.id, getClusterList[0].Id);
		Recipe__c recipe = [SELECT id, Name, ExternalID__c, Cluster__c from Recipe__c where id =: recipesList[0].Id Limit 1];
		recipe.Cluster__c = getClusterList[0].Id;

		// When
		Test.startTest();
		update recipe;
		Test.stopTest();

		// Then
		List<Recipe__Share> shareList = [SELECT Id, ParentId FROM Recipe__Share WHERE ParentId = :recipe.Id AND RowCause = 'Clustering__c'];

		System.assertEquals(3, shareList.size());

	}

}