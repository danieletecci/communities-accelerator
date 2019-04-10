@isTest
public class ContentSearchFiltersControllerTest {

    @isTest 
    static void getFiltersTest(){
        //Given
        MockupFactory.generateAcceleratorSetting();
		List<Cluster__c> clusterRoot = MockupFactory.createCluster('CRoot', '', 1, 'ClusterRoot', 'CRT');
        List<Cluster__c> clusterGroup = MockupFactory.createCluster('CGroup', clusterRoot.get(0).id, 1, 'ClusterGroup', 'CGT');
        List<Cluster__c> clusterLeaf = MockupFactory.createCluster('CLeaf', clusterGroup.get(0).id, 2, 'ClusterLeaf', 'CLT');
		MockupFactory.createCategory('Category', 2, clusterLeaf.get(0).id);
		MockupFactory.createClusterUser(clusterRoot.get(0).id, UserInfo.getUserId(), 1, 'Read/Write');
        MockupFactory.createTag('Tag Name', '', 2, clusterLeaf.get(0).id);
        MockupFactory.createContent('Event', clusterLeaf.get(0), 3);
        
		//When
		Test.startTest();
		ContentSearchFiltersController.FilterWrapper filterWrapper = ContentSearchFiltersController.getFilters('Content__c');
		Test.stopTest();

		//Then
		System.assertEquals(filterWrapper.filters.size(), 4);
        System.assertEquals(filterWrapper.filters.get(0).values.size(), 4);
        List<RecordType> contentRecordTypes = [SELECT id FROM RecordType WHERE SObjectType = 'Content__c'];
        System.assertEquals(filterWrapper.filters.get(1).values.size(), contentRecordTypes.size());
        System.assertEquals(filterWrapper.filters.get(2).values.size(), 2);
        System.assertEquals(filterWrapper.filters.get(3).values.size(), 2);
    }
}