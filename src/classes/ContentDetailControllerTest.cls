@isTest
public with sharing class ContentDetailControllerTest {
    
    @testSetup
	static void generateCustomSettings(){
		MockupFactory.generateAcceleratorSetting();
		List<Cluster__c> clusterRoot = MockupFactory.createCluster('CRoot', '', 1, 'ClusterRoot', 'CRT');
        List<Cluster__c> clusterGroup = MockupFactory.createCluster('CGroup', clusterRoot.get(0).id, 1, 'ClusterGroup', 'CGT');
        List<Cluster__c> clusterLeaf = MockupFactory.createCluster('CLeaf', clusterGroup.get(0).id, 2, 'ClusterLeaf', 'CLT');
        MockupFactory.createComponent('FAQ', 1, clusterRoot.get(0));
        MockupFactory.createComponent('Article', 1, clusterRoot.get(0));
        MockupFactory.createClusterUser(clusterRoot.get(0).id, UserInfo.getUserId(), 1, 'Read/Write');
        List<Tag__c> tags = MockupFactory.createTag('Tag Name', '', 2, clusterLeaf.get(0).id);
        List<Category__c> categories = MockupFactory.createCategory('Category', 2, clusterLeaf.get(0).id);
        MockupFactory.createContent('FAQ', clusterLeaf.get(0), 3);
        MockupFactory.createMediaElement(1);       
        
        List<Component__c> components = [SELECT id FROM Component__c ORDER BY Name ASC];
        components.get(0).DataSource__c = 'TagsCategories';
        components.get(1).DataSource__c = 'ManualAssignment';
        
        List<Content__c> contents = [SELECT id FROM Content__c];
        MockupFactory.createTagAssignment(tags, components, contents);
        MockupFactory.createCategoryAssignment(categories, components);
        update components;
    }

    @isTest 
    static void getDataTest(){
        //Given
        Component__c component = [SELECT id FROM Component__c LIMIT 1];
        MediaElement__c me = [SELECT id FROM MediaElement__c LIMIT 1];
        Content__c content = [SELECT id FROM Content__c LIMIT 1];
        Tag__c tag = [SELECT id FROM Tag__c LIMIT 1];
        insert new MediaElementAssignment__c(Content__c = content.id, MediaElement__c = me.id);
        insert new TagAssignment__c(Content__c = content.id, Tag__c = tag.id);
        ContentDetailController.DataWrapper dataWrapper= ContentDetailController.getData(content.Id);
        //When
        Boolean saveSuccess = ContentDetailController.saveContent(dataWrapper.content, JSON.serialize(dataWrapper.visibilitySelectors), me.id, 'Published', dataWrapper.content.Tags__r);
        //Then
        system.assert(saveSuccess);

    }    
}