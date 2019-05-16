@isTest
public class ContentLandingRecordListControllerTest {

    static void generalTestSetup(){
        MockupFactory.generateAcceleratorSetting();
        Cluster__c clusterTest = MockupFactory.createCluster('ClusterTest', null, 1, 'ClusterRoot', 'CRT')[0];     
        Content__c bannerTest = MockupFactory.createContent('Banner', clusterTest, 1)[0];
        bannerTest.Status__c = 'Draft'; update bannerTest;
        Content__c articleTest = MockupFactory.createContent('Article', clusterTest, 1)[0];
        articleTest.Status__c = 'Published'; 
        articleTest.isTemplate__c = false; 
        update articleTest;
    }

    @isTest
    static void testDefaultCondition(){
        
        //Given
        generalTestSetup();

        //When
        ContentLandingRecordListController.TableWrapper tableWrapperTest = ContentLandingRecordListController.buildTableWrapper(null, null, null, null, null, null, false, 0, 5);

        //Then
        System.assertEquals(2, tableWrapperTest.contentWrappers.size());
    }

    @isTest
    static void testCustomCondition(){
        
        //Given
        MockupFactory.generateAcceleratorSetting();
        Cluster__c clusterTest = MockupFactory.createCluster('ClusterTest', null, 1, 'ClusterRoot', 'CRT')[0];
        List<Content__c> contents = MockupFactory.createContent('Banner', clusterTest, 2);
        Content__c bannerTest1 = contents[0];
        Content__c bannerTest2 = contents[1];
        String bannerRecordTypeId = bannerTest1.RecordTypeId;
        Category__c categoryTest = MockupFactory.createCategory('CategoryTest', 1, clusterTest.Id)[0];
        Tag__c TagTest1 = MockupFactory.createTag('TagTest1', 'DescriptionTest', 1, clusterTest.Id)[0];
        Tag__c TagTest2 = MockupFactory.createTag('TagTest2', 'DescriptionTest', 1, clusterTest.Id)[0];
        Component__c componentTest = MockupFactory.createComponent('Banner', 1)[0];
        bannerTest1.Category__c = categoryTest.Id; bannerTest1.Status__c = 'Draft'; update bannerTest1;
        bannerTest2.Category__c = categoryTest.Id; bannerTest1.Status__c = 'Draft'; update bannerTest2;
        insert new TagAssignment__c(Component__c = componentTest.Id, Content__c = bannerTest1.Id, Tag__c = TagTest1.Id);
        insert new TagAssignment__c(Component__c = componentTest.Id, Content__c = bannerTest1.Id, Tag__c = TagTest2.Id);
        insert new TagAssignment__c(Component__c = componentTest.Id, Content__c = bannerTest2.Id, Tag__c = TagTest2.Id);

        //When
        ContentLandingRecordListController.TableWrapper tableWrapperTest = ContentLandingRecordListController.buildTableWrapper(bannerRecordTypeId, clusterTest.Id, categoryTest.Id, (String)TagTest1.Id + ',' + (String)TagTest2.Id, 'Draft', null, false, 0, 5);

        //Then
        System.assertEquals(1, tableWrapperTest.contentWrappers.size());
        System.assertEquals('Banner 0', tableWrapperTest.contentWrappers[0].fieldWrappers[1].value);
    }

    @isTest
    static void testSearch(){

        //Given
        generalTestSetup();

        //When
        ContentLandingRecordListController.TableWrapper tableWrapperTest = ContentLandingRecordListController.buildTableWrapper(null, null, null, null, null, 'Banner', false, 0, 5);
        
        //Then
        System.assertEquals(1, tableWrapperTest.contentWrappers.size());        
        System.assertEquals('Banner 0', tableWrapperTest.contentWrappers[0].fieldWrappers[1].value);
    }

    @isTest
    static void testEmpty(){

        //Given
        generalTestSetup();

        //When
        ContentLandingRecordListController.TableWrapper tableWrapperTest = ContentLandingRecordListController.buildTableWrapper(null, null, null, null, null, 'String Inexistente', false, 0, 5);
        
        //Then  
        System.assertEquals(True, tableWrapperTest.title == null);
    }

    @isTest
    static void testJSON(){

        //Given
        generalTestSetup();
        String bannerContentTestId = [SELECT Id FROM Content__c WHERE RecordType.DeveloperName = 'Banner' LIMIT 1].Id;

        //When
        ContentLandingRecordListController.TableWrapper tableWrapperTest1 = ContentLandingRecordListController.buildTableWrapper(null, null, null, null, null, null, false, 0, 5);
        String tableWrapperJSON = ContentLandingRecordListController.getTableWrapper(null, null, null, null, null, null, false, 0, 5);
        ContentLandingRecordListController.TableWrapper tableWrapperTest2 = (ContentLandingRecordListController.TableWrapper) JSON.deserialize(tableWrapperJSON, ContentLandingRecordListController.TableWrapper.class);

        //Then
        System.debug(tableWrapperTest1.contentWrappers +' '+ tableWrapperTest2.contentWrappers);
        System.assertEquals(True, tableWrapperTest1.title == tableWrapperTest2.title);
        System.assertEquals(True, tableWrapperTest1.columnSet == tableWrapperTest2.columnSet);
        //System.assertEquals(True, bannerContentTestId == tableWrapperTest2.contentWrappers.get(0).contentId);
        System.assertEquals(True, tableWrapperTest2.contentWrappers.get(1).actions.size() > 1);
    }

    @isTest
    static void testJSONNotCacheable(){

        //Given
        generalTestSetup();
        String bannerContentTestId = [SELECT Id FROM Content__c WHERE RecordType.DeveloperName = 'Banner' LIMIT 1].Id;

        //When
        ContentLandingRecordListController.TableWrapper tableWrapperTest1 = ContentLandingRecordListController.buildTableWrapper(null, null, null, null, null, null, false, 0, 5);
        String tableWrapperJSON = ContentLandingRecordListController.getUpdatedTableWrapper(null, null, null, null, null, null, false, 0, 5);
        ContentLandingRecordListController.TableWrapper tableWrapperTest2 = (ContentLandingRecordListController.TableWrapper) JSON.deserialize(tableWrapperJSON, ContentLandingRecordListController.TableWrapper.class);

        //Then
        System.debug(tableWrapperTest1.contentWrappers +' '+ tableWrapperTest2.contentWrappers);
        System.assertEquals(True, tableWrapperTest1.title == tableWrapperTest2.title);
        System.assertEquals(True, tableWrapperTest1.columnSet == tableWrapperTest2.columnSet);
        //System.assertEquals(True, bannerContentTestId == tableWrapperTest2.contentWrappers.get(0).contentId);
        System.assertEquals(True, tableWrapperTest2.contentWrappers.get(1).actions.size() > 1);
    }
    
    @isTest
    static void testDeleteContent(){

        //Given
        generalTestSetup();
        List<Content__c> contentRecords = [SELECT Id FROM Content__c];

        //When
        ContentLandingRecordListController.DeleteContent(contentRecords.get(0).Id);

        //Then
        System.assertEquals(contentRecords.size() - 1, [SELECT Count() FROM Content__c]);
    }
}