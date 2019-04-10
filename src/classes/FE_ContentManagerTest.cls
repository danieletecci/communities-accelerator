@isTest
private class FE_ContentManagerTest {
	
	@testSetup
	static void generateCustomSettings(){
		MockupFactory.generateAcceleratorSetting();
		List<Cluster__c> clusterRoot = MockupFactory.createCluster('Cluster Root', '', 1, 'ClusterRoot', 'CRT');
        List<Cluster__c> clusterGroup = MockupFactory.createCluster('Cluster Group', clusterRoot.get(0).id, 1, 'ClusterGroup', 'CGT');
        List<Cluster__c> clusterLeaf = MockupFactory.createCluster('Cluster Leaf', clusterGroup.get(0).id, 2, 'ClusterLeaf', 'CLT');
        List<Component__c> componentList = MockupFactory.createComponent('Advance Content', 1, clusterRoot[0]);
		List<Content__c> contentList = MockupFactory.createContent('Advance Content', clusterRoot[0], 1);
		MockupFactory.createContentAssignment(contentList, componentList);
	}

	@isTest 
	static void getCWTest() {
		//Given
		String device = 'Desktop';
		List<Component__c> componentList = [SELECT Id, ExternalId__c, Cluster__c, Recordtype.DeveloperName, Recordtype.Id, Datasource__c, OrderBy__c, OrderByAdvance__c, HierarchicalOrderBy__c, TagCriteria__c, PageSize__c  FROM Component__c LIMIT 1];

		Set<String> contentSetFields = new Set<String>{
            'HTMLContent__c'
        };
		
		//When
		Test.startTest();
		FE_ComponentManager.DataWrapper data = FE_ContentManager.getCMSContent(componentList[0].Cluster__c, componentList[0], contentSetFields, device);
		Test.stopTest();

		//Then
		System.assertNotEquals(data, null);
	}
}