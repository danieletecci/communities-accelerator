@isTest
private class CG_AssetDetailControllerTest {


	@testSetup
    static void setupTest(){
    	String nameRecordType = 'Recipe';
    	Integer quantity = 3;
    	MockupFactory.generateAcceleratorSetting();
        
        String name = 'Argentina';
        List<Cluster__c> clusterRootList = MockupFactory.createCluster(name, null, 1, 'ClusterRoot', 'CRT');
        Cluster__c cg = clusterRootList[0];
        List<Cluster__c> clusterList = MockupFactory.createCluster('BuenosAires', cg.Id, 1, 'ClusterGroup', 'CGT');

    	List<Content__c> contentList = MockupFactory.createContent(nameRecordType, clusterList[0], 1);

		List<MediaElement__c> mediaElementList= MockupFactory.createMediaElement(quantity);

		List<MediaElementAssignment__c> mediaElementAssList = new List<MediaElementAssignment__c>();
        
        for(Integer i = 0; i < mediaElementList.size(); i++){
            mediaElementAssList.add(new MediaElementAssignment__c(Content__c = contentList[0].id,
                                    MediaElement__c = mediaElementList[i].id));
        }
        insert mediaElementAssList;

        List<ContentDocumentLink> contentDocList = MockupFactory.createContentDocumentLink(mediaElementList);
	
    }
/*
	@isTest 
	static void getRecordsTest() {
		//When
		Content__c cont = [SELECT id from Content__c limit 1];

		//Given
		Test.startTest();
		CG_AssetDetailController.ContentWrapper contWr = CG_AssetDetailController.getRecord(cont.id, null);
		Test.stopTest();
		
		//Then
		System.assertNotEquals(contWr, null);
	}
*/


	@isTest 
	static void downloadAllItemsTest() {
		//When
		Content__c cont = [SELECT id from Content__c limit 1];
		CG_AssetDetailController.ContentWrapper contWr = CG_AssetDetailController.getRecord(cont.id, null);
		Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());


		//Given
		Test.startTest();
		Map <String, String> imagenMap = CG_AssetDetailController.downloadAllItems(JSON.serialize(contWr));
		Test.stopTest();
		
		//Then
		System.assertEquals(imagenMap.keySet().size(), 0);
	}


	@isTest 
	static void initDataExternalTest() {
		//When
		Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
		List<MediaElement__c> mediaElementList = [SELECT Id FROM MediaElement__c];

        for(MediaElement__c media : mediaElementList){
        	media.FileURLDesktop__c='https://www.google.com/logos/doodles/2018/gottfried-wilhelm-leibnizs-372nd-birthday-4525892901535744-2x';
        }
        update mediaElementList;

        Content__c cont = [SELECT id from Content__c limit 1];
		CG_AssetDetailController.ContentWrapper contWr = CG_AssetDetailController.getRecord(cont.id, null);
		//Given
		Test.startTest();
		Map <String, String> imagenMap = CG_AssetDetailController.downloadAllItems(JSON.serialize(contWr));
		Test.stopTest();
		
		//Then
		System.assertEquals(imagenMap.keySet().size(), 0);
	}

	@isTest
	static void getRecordsRecipeTest(){
		//When
		List<Content__c> contentList = [SELECT id FROM Content__c];
		Content__c cont = contentList[0];
		cont.URLRedirect__c='http://example.com/example/test';
		update cont;

		List<MediaElementAssignment__c> meaList = [SELECT Id, MediaElement__c, Placement__c FROM MediaElementAssignment__c];
		meaList[0].Placement__c='RecipeImageList';
		meaList[1].Placement__c='RecipeImageDetail';
		meaList[2].Placement__c='BrandImageList';
		update meaList;

		List<Brand__c> brandList = MockupFactory.createBrand('BrandTest', 1, null);
		brandList[0].BrandContent__c= cont.Id;
		update brandList;

		List<Recipe__c> recipesList = MockupFactory.createRecipes('recipeTest', 1, cont.Id, null);
		List<RecipeStep__c> stepsList = MockupFactory.createRecipeStep('stepTest', 1, recipesList[0].id);
		List<RecipeIngredient__c> ingredientsList = MockupFactory.createRecipeIngredientBrand('IngredientsList', 1, recipesList[0].id, brandList[0].Id, brandList[0].Id);
		List<RecipeIngredient__c> ingredientNotBrand = MockupFactory.createRecipeIngredientWithoutBrand('IngredientsNotBrandList', 1, recipesList[0].id);

		Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
		//Given
		Test.startTest();
		CG_AssetDetailController.ContentWrapper contWr = CG_AssetDetailController.getRecord(cont.id, null);
		Map <String, String> contZip = CG_AssetDetailController.downloadAllItems(JSON.serialize(contWr));
		Test.stopTest();
		
		//Then
		System.assertNotEquals(contWr, null);
	}

		@isTest
	static void getRecordsBrandTest(){
		//When
		 List<Cluster__c> clusterRootList = MockupFactory.createCluster('America', null, 1, 'ClusterRoot', 'Ame');
		List<Content__c> contentList = MockupFactory.createContent('Brand Detail',clusterRootList[0], 1);
		Content__c cont = contentList[0];
		cont.URLRedirect__c='http://example.com/example/test';
		update cont;

		List<MediaElementAssignment__c> meaList = [SELECT Id, MediaElement__c, Placement__c FROM MediaElementAssignment__c];
		meaList[0].Placement__c='BrandImageBanner';
		meaList[1].Placement__c='BrandImageLogo';
		meaList[2].Placement__c='BrandImageList';
		update meaList;


		Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
		//Given
		Test.startTest();
		CG_AssetDetailController.ContentWrapper contWr = CG_AssetDetailController.getRecord(cont.id, null);
		
		Test.stopTest();
		
		//Then
		System.assertNotEquals(contWr, null);
	}
	

	@isTest
	static void addToCartTest(){
		//When
		List<Content__c> contentList = [SELECT id FROM Content__c];
		//Given
		Test.startTest();
		CG_AssetDetailController.addToCart(contentList[0].id);
		Test.stopTest();
		
		//Then
		List<ContentCartItem__c> contentCart = [SELECT id FROM ContentCartItem__c];
		System.assertNotEquals(contentCart, null);
	}

}