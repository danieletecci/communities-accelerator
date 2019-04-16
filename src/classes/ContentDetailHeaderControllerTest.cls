@isTest
public class ContentDetailHeaderControllerTest {

    @testSetup
    static void generateCustomSettings(){
        MockupFactory.generateAcceleratorSetting();
        List<Cluster__c> clusterRoot = MockupFactory.createCluster('Cluster Root', '', 1, 'ClusterRoot', 'CRT');
        List<Cluster__c> clusterGroup = MockupFactory.createCluster('Cluster Group', clusterRoot.get(0).id, 1, 'ClusterGroup', 'CGT');
        List<Cluster__c> clusterLeaf = MockupFactory.createCluster('Cluster Leaf', clusterGroup.get(0).id, 2, 'ClusterLeaf', 'CLT');
        MockupFactory.createComponent('FAQ', 1, clusterRoot.get(0));
        MockupFactory.createComponent('ArticleList', 1, clusterRoot.get(0));
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
    public static void getData(){
        List<Content__c> contents = [SELECT id FROM Content__c];
        ContentDetailHeaderController.getData(contents.get(0).Id);
    }
    
    @isTest
    public static void setName(){
        List<Content__c> contents = [SELECT id FROM Content__c];
        ContentDetailHeaderController.setName(contents.get(0).Id, 'New Name');
    }

    @isTest
    public static void deleteContent(){
        List<Content__c> contents = [SELECT id FROM Content__c];
        ContentDetailHeaderController.deleteContent(contents.get(0).Id);
    }

    @isTest
    public static void setStatus(){
        List<Content__c> contents = [SELECT id FROM Content__c];
        ContentDetailHeaderController.setStatus(contents.get(0).Id, 'Published', null, null);
    }

    @isTest
    public static void createFromTemplate(){
        List<Content__c> contents = [SELECT id FROM Content__c];
        contents.get(0).IsTemplate__c = true;
        contents.get(0).Status__c = 'Published';
        update contents.get(0);
        ContentDetailHeaderController.createFromTemplate(contents.get(0).Id);
    }
}