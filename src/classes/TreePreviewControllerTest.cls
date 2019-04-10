@isTest(seeAllData = false)
public with sharing class TreePreviewControllerTest {
	
	@isTest
	static void getTreeTest() {
		/* Comment: Comprueba el arbol de categorias devuelve como root la categoría sin ParentCategory__c. */

		//Given
		MockupFactory.generateAcceleratorSetting();

		String name = 'Argentina';
        String nameGroup = 'Buenos Aires';
        List<Cluster__c> clusterRootList = MockupFactory.createCluster(name, null, 1, 'ClusterRoot', 'CRT');
        Cluster__c cg = clusterRootList[0];
        List<Category__c> catList = MockupFactory.createCategory(nameGroup, 8, cg.Id);
        Category__c rootCat = catList[0];
        catList[1].ParentCategory__c = catList[0].Id;
        catList[2].ParentCategory__c = catList[1].Id;
        catList[3].ParentCategory__c = catList[2].Id;
        catList[4].ParentCategory__c = catList[3].Id;
        catList[5].ParentCategory__c = catList[4].Id;
        catList[6].ParentCategory__c = catList[5].Id;
        catList[7].ParentCategory__c = catList[5].Id;

        update catList;

		//When
		Test.startTest();
			TreePreviewController.ItemWrapper wrap = TreePreviewController.getTree(catList[5].Id, 'Category__c', 'ParentCategory__c');
		Test.stopTest();

		//Then
	
		System.assertEquals(wrap.Id, rootCat.Id);		
	}
}