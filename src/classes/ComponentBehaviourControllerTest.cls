@istest
public class ComponentBehaviourControllerTest {
    
    @isTest 
    static void manualAssignmentTest(){
        //Given
        MockupFactory.generateAcceleratorSetting();
        List<Cluster__c> clusterRoot = MockupFactory.createCluster('CRoot', '', 1, 'ClusterRoot', 'CRT');
        List<Cluster__c> clusterGroup = MockupFactory.createCluster('CGroup', clusterRoot.get(0).id, 1, 'ClusterGroup', 'CGT');
        List<Cluster__c> clusterLeaf = MockupFactory.createCluster('CLeaf', clusterGroup.get(0).id, 2, 'ClusterLeaf', 'CLT');
        List<Component__c> components = MockupFactory.createComponent('Advance Content', 1, clusterRoot.get(0));
        components.get(0).DataSource__c = 'ManualAssignment'; 
        update components;
        List<Content__c> contents = MockupFactory.createContent('Advance Content', clusterLeaf.get(0), 1);
        contents.get(0).StructureComponent__c = components.get(0).Id;
        update contents;

        //When
        String componentBehaviour = ComponentBehaviourController.getComponentBehaviour(contents.get(0).Id);

        //Then
        System.assertEquals(Label.ComponentBehaviourManualAssignment, componentBehaviour);
    }

    @isTest 
    static void tagsCategoriesTest(){
        //Given
        MockupFactory.generateAcceleratorSetting();
        List<Cluster__c> clusterRoot = MockupFactory.createCluster('CRoot', '', 1, 'ClusterRoot', 'CRT');
        List<Cluster__c> clusterGroup = MockupFactory.createCluster('CGroup', clusterRoot.get(0).id, 1, 'ClusterGroup', 'CGT');
        List<Cluster__c> clusterLeaf = MockupFactory.createCluster('CLeaf', clusterGroup.get(0).id, 2, 'ClusterLeaf', 'CLT');
        List<Component__c> components = MockupFactory.createComponent('Banner', 1, clusterRoot.get(0));
        components.get(0).DataSource__c = 'TagsCategories'; 
        update components;
        List<Content__c> contents = MockupFactory.createContent('Banner', clusterLeaf.get(0), 1);
        contents.get(0).StructureComponent__c = components.get(0).Id;
        update contents;
        List<Tag__c> tags = MockupFactory.createTag('Tag Test', '', 2, clusterLeaf.get(0).id);
        List<Category__c> categories = MockupFactory.createCategory('Category Test', 2, clusterLeaf.get(0).id);
        MockupFactory.createTagAssignment(tags, components, contents);
        MockupFactory.createCategoryAssignment(categories, components);
        update components;

        //When
        String componentBehaviour = ComponentBehaviourController.getComponentBehaviour(contents.get(0).Id);

        //Then
        System.assert(componentBehaviour.contains(Label.ComponentBehaviourTags));
        System.assert(componentBehaviour.contains(Label.ComponentBehaviourCategories));
        System.assert(componentBehaviour.contains('Tag Test'));
        System.assert(componentBehaviour.contains('Category Test'));
        System.assert(componentBehaviour.contains('Banner type'));
    }

}