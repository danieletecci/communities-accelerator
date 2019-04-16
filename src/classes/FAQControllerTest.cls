@isTest
private class FAQControllerTest{

	@testSetup
	static void generateCustomSettings(){
		MockupFactory.generateAcceleratorSetting();
		List<Cluster__c> clusterRoot = MockupFactory.createCluster('Cluster Root', '', 1, 'ClusterRoot', 'CRT');
        List<Cluster__c> clusterGroup = MockupFactory.createCluster('Cluster Group', clusterRoot.get(0).id, 1, 'ClusterGroup', 'CGT');
        List<Cluster__c> clusterLeaf = MockupFactory.createCluster('Cluster Leaf', clusterGroup.get(0).id, 2, 'ClusterLeaf', 'CLT');
        List<Component__c> componentList = MockupFactory.createComponent('FAQ', 1, clusterRoot[0]);
		List<Content__c> contentList = MockupFactory.createContent('FAQ', clusterRoot[0], 1);
		MockupFactory.createContentAssignment(contentList, componentList);     
	}

	@isTest 
	static void getComponentWrapperTest() {
		// Given
		List<Component__c> componentList = [SELECT id, ExternalId__c, Cluster__c FROM Component__c LIMIT 1];
		List<Content__c> contentList = [SELECT id, Title__c, Body__c FROM Content__c LIMIT 1];
		contentList[0].Title__c = 'title example';
		contentList[0].Body__c = 'Body example';
		update contentList;
        
        //Navigation Record
        Navigation__c nav = new Navigation__c(Name = 'NavTest', URL__c = 'testNav');
        insert nav;

		// When
		Test.startTest();
		ComponentManager.ComponentWrapper componentWr = FAQController.getComponentWrapper(componentList[0].ExternalId__c, componentList[0].Cluster__c, 'Desktop','s/' + nav.Url__c);
		Test.stopTest();

		// Then
		System.assertNotEquals(componentWr, null);
		System.assertNotEquals(componentWr.data, null);
	}	
}