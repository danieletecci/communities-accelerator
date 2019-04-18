@isTest
private class ComponentManagerTest {
	
	@testSetup
	static void generateCustomSettings(){
		MockupFactory.generateAcceleratorSetting();
		List<Cluster__c> clusterRoot = MockupFactory.createCluster('Cluster Root', '', 1, 'ClusterRoot', 'CRT');
        List<Cluster__c> clusterGroup = MockupFactory.createCluster('Cluster Group', clusterRoot.get(0).id, 1, 'ClusterGroup', 'CGT');
        List<Cluster__c> clusterLeaf = MockupFactory.createCluster('Cluster Leaf', clusterGroup.get(0).id, 2, 'ClusterLeaf', 'CLT');
        List<Component__c> componentList = MockupFactory.createComponent('AdvanceContent', 1, clusterRoot[0]);
		List<Content__c> contentList = MockupFactory.createContent('AdvanceContent', clusterRoot[0], 1);
		MockupFactory.createContentAssignment(contentList, componentList);
	}

	@isTest 
	static void getCWTest() {
		//Given
		List<Component__c> componentList = [SELECT Id, ExternalId__c, Cluster__c FROM Component__c LIMIT 1];

		ComponentManager componentManag = new ComponentManager();
		componentManag.customPermissionEdit = 'AdvanceContent Edit Frame';
        componentManag.customPermissionView = 'AdvanceContent View Frame';
        componentManag.componentFieldSet = new Set<String>();        
        componentManag.componentExternalId = componentList[0].ExternalId__c;
        componentManag.clusterId = componentList[0].Cluster__c;
        componentManag.device = 'Desktop';

		//When
		Test.startTest();
		ComponentManager.ComponentWrapper componentWr = componentManag.getCW();
		Test.stopTest();

		//Then
		System.assertNotEquals(componentWr.data, null);
	}
}