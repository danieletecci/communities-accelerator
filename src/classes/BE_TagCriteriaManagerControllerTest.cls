@isTest 
public with sharing class BE_TagCriteriaManagerControllerTest {

@isTest 
    static void getTagsFromComponentTest(){
        //Given
        MockupFactory.generateAcceleratorSetting();
        List<Cluster__c> cluster = MockupFactory.createCluster('Global',null, 1,'ClusterRoot');
        List<Component__c> comp = MockupFactory.createComponent('Banner', 1);
        List<Content__c> cont = MockupFactory.createContent('Banner',cluster[0],1);
        List<Tag__c> tags = MockupFactory.createTag('TestTag','TestDescription',1,cluster[0].Id);
        List<TagAssignment__c> tagsAss = MockupFactory.createTagAssignment(tags,comp,cont);

        //List<ContentAssignment__c> contAssign = MockupFactory.createContentAssignment(cont,comp);

        //When 
        Test.startTest();
        BE_TagCriteriaManagerController.RecordsWrapper rw = BE_TagCriteriaManagerController.getRecords(comp[0].Id);
        Test.stopTest();

        //Then    
        System.assertNotEquals(null, rw.recordsToSelect);
    }

    @isTest 
    static void saveTagsWithValidFormulaAndCriteriaTest() {

        // Given
        MockupFactory.generateAcceleratorSetting();
        List<Cluster__c> cluster = MockupFactory.createCluster('Global', null, 1, 'ClusterRoot');
        List<Component__c> comp = MockupFactory.createComponent('Banner', 1);
        List<Tag__c> tags = MockupFactory.createTag('TestTag','TestDescription',2,cluster[0].Id);
        List<String> listSelectedIds = new List<String>(); 
        listSelectedIds.add(tags[0].Id);
        listSelectedIds.add(tags[1].Id);

        // When 
        Test.startTest();
        String response = BE_TagCriteriaManagerController.saveRelationships(comp[0].Id, listSelectedIds, 'ANY', '1 AND 2');
        Test.stopTest();

        // Then
        System.assertEquals('OK', response);
    }

    @isTest 
    static void saveTagsWithInvalidFormulaTest() {

        // Given
        MockupFactory.generateAcceleratorSetting();
        List<Cluster__c> cluster = MockupFactory.createCluster('Global', null, 1, 'ClusterRoot');
        List<Component__c> comp = MockupFactory.createComponent('Banner', 1);
        List<Tag__c> tags = MockupFactory.createTag('TestTag','TestDescription',2,cluster[0].Id);
        List<String> listSelectedIds = new List<String>(); 
        listSelectedIds.add(tags[0].Id);
        listSelectedIds.add(tags[1].Id);

        // When 
        Test.startTest();
        String response = BE_TagCriteriaManagerController.saveRelationships(comp[0].Id, listSelectedIds, 'ANY', '1 AD');
        Test.stopTest();

        // Then
        System.assertNotEquals('OK', response);
    }

    @isTest 
    static void saveNoTagsSelectedWithNoCriteriaTest() {

        // Given
        MockupFactory.generateAcceleratorSetting();
        List<Cluster__c> cluster = MockupFactory.createCluster('Global', null, 1, 'ClusterRoot');
        List<Component__c> comp = MockupFactory.createComponent('Banner', 1);
        List<Tag__c> tags = MockupFactory.createTag('TestTag','TestDescription',3,cluster[0].Id);
        List<String> listSelectedIds = new List<String>(); 

        // When 
        Test.startTest();
        String response = BE_TagCriteriaManagerController.saveRelationships(comp[0].Id, listSelectedIds, 'ANY', '');
        Test.stopTest();

        // Then
        System.assertEquals('OK', response);
    }

    @isTest 
    static void saveTagsSelectedWithNoCriteriaTest() {

        // Given
        MockupFactory.generateAcceleratorSetting();
        List<Cluster__c> cluster = MockupFactory.createCluster('Global', null, 1, 'ClusterRoot');
        List<Component__c> comp = MockupFactory.createComponent('Banner', 1);
        List<Tag__c> tags = MockupFactory.createTag('TestTag','TestDescription',3,cluster[0].Id);

        List<String> listSelectedIds = new List<String>(); 
        listSelectedIds.add(tags[0].Id);
        listSelectedIds.add(tags[1].Id);

        // When 
        Test.startTest();
        String response = BE_TagCriteriaManagerController.saveRelationships(comp[0].Id, listSelectedIds, 'ANY', '');
        Test.stopTest();

        // Then
        System.assertEquals(Label.CriteriaListInBlank, response);
    }
    
    @isTest 
    static void getSelectedRecordsTest() {

        // Given
        MockupFactory.generateAcceleratorSetting();
        List<Cluster__c> cluster = MockupFactory.createCluster('Global', null, 1, 'ClusterRoot');
        List<Component__c> comp = MockupFactory.createComponent('Banner', 1);
        List<Tag__c> tags = MockupFactory.createTag('TestTag','TestDescription',3,cluster[0].Id);

        List<String> listSelectedIds = new List<String>(); 
        listSelectedIds.add(tags[0].Id);
        listSelectedIds.add(tags[1].Id);
        BE_TagCriteriaManagerController.RecordsWrapper rw = BE_TagCriteriaManagerController.getRecords(comp[0].Id);

        // When
        Test.startTest();
        BE_TagCriteriaManagerController.RecordsWrapper response = BE_TagCriteriaManagerController.getSelectedRecords(JSON.serialize(rw), listSelectedIds);
        Test.stopTest();

        // Then
        System.assertEquals(2, response.recordsSelected.size());
    }
}