@isTest
public class ContentUtilsTest {
    @testSetup
    static void generateCustomSettings(){
        MockupFactory.generateAcceleratorSetting();
        List<Cluster__c> clusterRootList = MockupFactory.createCluster('ClusterRootTest', null, 1, 'ClusterRoot', 'CRT');
        insert new CMSUserSettings__c(Name = UserInfo.getUserName(), User__c = UserInfo.getUserId(), Cluster__c = clusterRootList[0].Id);
    }

    @isTest
    static void getContentPageTest(){       
        /* Comment: dado una lista de Ids de Content__c devuelve una lista de Content__c 
        con una lista de sus MediaElement__c  correspondientes.
        */

        // Given
        List<Cluster__c> clusterRootList = [SELECT Id FROM Cluster__c];
        List<Component__c> componentList = MockupFactory.createComponent('Banner', 1);
        Component__c comp = componentList[0];
        componentList = [SELECT Name, TagCriteria__c, ExternalId__c, Datasource__c, Status__c, RecordTypeId, RecordType.DeveloperName, Cluster__c, ExcludePastEvents__c, OrderBy__c, HierarchicalOrderBy__c
                FROM Component__c WHERE Id =: comp.ID];

        List<Content__c> contentList = MockupFactory.createContent('Banner', clusterRootList[0], 1);
        List<ContentAssignment__c> contentAssigmentList = MockupFactory.createContentAssignment(contentList, componentList);
        List<MediaElement__c> mediaElementList = MockupFactory.createMediaElement(1);
        List<MediaElementAssignment__c> mediaElementAssigList = MockupFactory.createMediaElementAssignment(contentList, mediaElementList);

        Set<String> fieldSet =  new Set<String>{'ExternalId__c'};
        Set<String> setContentIds = new Set<String>{contentList[0].Id};
        
        // When
        Test.startTest();
        List<ContentUtils.ContentDataWrapper> cdwList = ContentUtils.getContentPage(setContentIds, fieldSet, 1, 1, 'ExternalId__c', 'Desktop', 'BannerImage');
        Test.stopTest();

        // Then     
        System.assertNotEquals(cdwList, null);
    }

    @isTest
    static void getContentFromComponentTest(){
        // Comment: dado un Component__c y un Cluster__c devuelve el componente correspondiente 

        // Given
        List<Cluster__c> clusterRootList = [SELECT Id FROM Cluster__c];
        List<Component__c> componentList = MockupFactory.createComponent('Event', 1);
        Component__c comp = componentList[0];
        comp.ExcludePastEvents__c = true;
        update comp;

        componentList = [SELECT Name, TagCriteria__c, ExternalId__c, Datasource__c, Status__c, RecordTypeId, RecordType.DeveloperName, Cluster__c, ExcludePastEvents__c, OrderBy__c, HierarchicalOrderBy__c
                FROM Component__c WHERE Id =: comp.ID];

        List<Content__c> contentList = MockupFactory.createContent('Event', clusterRootList[0], 1);
        List<ContentAssignment__c> contentAssigmentList = MockupFactory.createContentAssignment(contentList, componentList);
        List<MediaElement__c> mediaElementList = MockupFactory.createMediaElement(1);
        List<MediaElementAssignment__c> mediaElementAssigList = MockupFactory.createMediaElementAssignment(contentList, mediaElementList);

        Set<String> fieldSet =  new Set<String>{'ExternalId__c'};
        Set<String> setClusterIds = new Set<String>{clusterRootList[0].Id};
        
        // When
        Test.startTest();
        ContentUtils.ContentWrapper cw = ContentUtils.getContentFromComponent(componentList[0], fieldSet, null, null, setClusterIds, 'Desktop');
        Test.stopTest();

        // Then     
        System.assertNotEquals(cw, null);
    }

    @isTest
    static void getContentFromTagTest(){
        // Comment: dado un Component__c y un Cluster__c devuelve el componente correspondiente asignado a un Tag

        // Given
        List<Cluster__c> clusterRootList = [SELECT Id FROM Cluster__c];
        List<Component__c> componentList = MockupFactory.createComponent('Banner', 1,clusterRootList[0]);
        Component__c comp = componentList[0];
        comp.Datasource__c = 'Tags';
        update comp;

        componentList = [SELECT Name, TagCriteria__c, ExternalId__c, Datasource__c,BannerFrameType__c, Status__c, RecordTypeId, RecordType.DeveloperName, Cluster__c, ExcludePastEvents__c, OrderBy__c, HierarchicalOrderBy__c, PageSize__c
                FROM Component__c WHERE Id =: comp.ID];

        List<Content__c> contentList = MockupFactory.createContent('Banner', clusterRootList[0], 1);
        List<Tag__c> tagList = MockupFactory.createTag('TestTag', 'Tag de test', 1, clusterRootList[0].Id);
        List<TagAssignment__c> tagAssigmentList = MockupFactory.createTagAssignment(tagList, componentList, contentList);
        List<MediaElement__c> mediaElementList = MockupFactory.createMediaElement(1);
        List<MediaElementAssignment__c> mediaElementAssigList = MockupFactory.createMediaElementAssignment(contentList, mediaElementList);

        Set<String> fieldSet =  new Set<String>{'ExternalId__c','BannerFrameType__c'};
        Set<String> setClusterIds = new Set<String>{clusterRootList[0].Id};
        
        // When
        Test.startTest();
        ContentUtils.ContentWrapper cw = ContentUtils.getContentFromComponent(componentList[0], fieldSet, null, null, setClusterIds, 'Desktop');
        Test.stopTest();

        // Then     
        System.assertNotEquals(cw, null);
    }

    @isTest
    static void getContentFromCategoriesTest(){
        // Comment: dado un Component__c y un Cluster__c devuelve el componente correspondiente asignado a una Category__c

        // Given
        List<Cluster__c> clusterRootList = [SELECT Id FROM Cluster__c];
        List<Component__c> componentList = MockupFactory.createComponent('Banner', 1, clusterRootList[0]);
        Component__c comp = componentList[0];
        comp.Datasource__c = 'Categories';
        update comp;

        componentList = [SELECT Name, TagCriteria__c, ExternalId__c, Datasource__c, BannerFrameType__c,Status__c, RecordTypeId, RecordType.DeveloperName, Cluster__c, ExcludePastEvents__c, OrderBy__c, HierarchicalOrderBy__c
                FROM Component__c WHERE Id =: comp.ID];

        List<Category__c> categoryList = MockupFactory.createCategory('TestCategory', 1, clusterRootList[0].Id);
        List<CategoryAssignment__c> categoryAssignmentList = MockupFactory.createCategoryAssignment(categoryList, componentList);   
        List<Content__c> contentList = MockupFactory.createContent('Banner', clusterRootList[0], 1);
        List<MediaElement__c> mediaElementList = MockupFactory.createMediaElement(1);
        List<MediaElementAssignment__c> mediaElementAssigList = MockupFactory.createMediaElementAssignment(contentList, mediaElementList);

        Set<String> fieldSet =  new Set<String>{'ExternalId__c','BannerFrameType__c'};
        Set<String> setClusterIds = new Set<String>{clusterRootList[0].Id};
        
        // When
        Test.startTest();
        ContentUtils.ContentWrapper cw = ContentUtils.getContentFromComponent(componentList[0], fieldSet, null, null, setClusterIds, 'Desktop');
        Test.stopTest();

        // Then     
        System.assertNotEquals(cw, null);
    }


    @isTest
    static void getContentFromParentContentTest(){
        // Comment: dado un Component__c y un Cluster__c devuelve el componente correspondiente asignado a una Category__c

        // Given
        List<Cluster__c> clusterRootList = [SELECT Id FROM Cluster__c];
        List<Component__c> componentList = MockupFactory.createComponent('Articles Related', 1, clusterRootList[0]);
        Component__c comp = componentList[0];
        comp.Datasource__c = 'ParentContentTags';
        update comp;

        componentList = [SELECT Name, TagCriteria__c, ExternalId__c, Datasource__c, Status__c, RecordTypeId, RecordType.DeveloperName, Cluster__c, ExcludePastEvents__c, OrderBy__c, HierarchicalOrderBy__c
                FROM Component__c WHERE Id =: comp.ID];

        List<Category__c> categoryList = MockupFactory.createCategory('Test2', 1, clusterRootList[0].Id);
        List<CategoryAssignment__c> categoryAssignmentList = MockupFactory.createCategoryAssignment(categoryList, componentList);   
        List<Content__c> contentList = MockupFactory.createContent('Event', clusterRootList[0], 1);

        Set<String> fieldSet =  new Set<String>{'ExternalId__c'};
        Set<String> setClusterIds = new Set<String>{clusterRootList[0].Id};
        
        List<Content__c> contentListExclude = MockupFactory.createContent('Banner', clusterRootList[0], 1);
        Set<String> setContentToExclude = new Set<String>{contentListExclude[0].Id};

        List<MediaElement__c> mediaElementList = MockupFactory.createMediaElement(1);
        List<MediaElementAssignment__c> mediaElementAssigList = MockupFactory.createMediaElementAssignment(contentList, mediaElementList);

        // When
        Test.startTest();
        ContentUtils.ContentWrapper cw = ContentUtils.getContentFromComponent(componentList[0], fieldSet, null, setContentToExclude, setClusterIds, 'Desktop');
        Test.stopTest();

        // Then     
        System.assertNotEquals(cw, null);
    }

    @isTest
    static void getSetContextDirectTest(){
        // Comment: dado un Component__c y un Cluster__c devuelve el componente correspondiente asignado a una Category__c

        // Given
        List<Cluster__c> clusterRootList = [SELECT Id FROM Cluster__c];
        List<Component__c> componentList = MockupFactory.createComponent('Banner', 1, clusterRootList[0]);
        Component__c comp = componentList[0];
        componentList = [SELECT Name, TagCriteria__c, ExternalId__c, Datasource__c,BannerFrameType__c, Status__c, RecordTypeId, RecordType.DeveloperName, Cluster__c, ExcludePastEvents__c, OrderBy__c, HierarchicalOrderBy__c, PageSize__c
                FROM Component__c WHERE Id =: comp.ID];
        
        Set<String> fieldSet =  new Set<String>{'ExternalId__c','BannerFrameType__c'};
        Set<String> setClusterIds = new Set<String>{clusterRootList[0].Id};
        
        List<Content__c> contentListDirect = MockupFactory.createContent('Banner', clusterRootList[0], 1);
        Set<String> setContentDirect = new Set<String>{contentListDirect[0].Id};

        List<MediaElement__c> mediaElementList = MockupFactory.createMediaElement(1);
        List<MediaElementAssignment__c> mediaElementAssigList = MockupFactory.createMediaElementAssignment(contentListDirect, mediaElementList);

        // When
        Test.startTest();
        ContentUtils.ContentWrapper cw = ContentUtils.getContentFromComponent(componentList[0], fieldSet, setContentDirect, null, setClusterIds, 'Desktop');
        Test.stopTest();

        // Then     
        System.assertNotEquals(cw, null);
    }

    @isTest
    static void getContentWithManualOrder(){
        // Comment: Se prueba con el dataSource ManualAssignment y order by ManualOrder

        // Given
        List<Cluster__c> clusterRootList = [SELECT Id FROM Cluster__c];
        List<Component__c> componentList = MockupFactory.createComponent('Banner', 1,clusterRootList[0]);
        Component__c comp = componentList[0];
        comp.Datasource__c = 'ManualAssignment';
        comp.OrderBy__c = 'Manual Order';
        update comp;

        componentList = [SELECT Name, TagCriteria__c, ExternalId__c, Datasource__c,BannerFrameType__c, Status__c, PageSize__c, RecordTypeId, RecordType.DeveloperName, Cluster__c, ExcludePastEvents__c, OrderBy__c, HierarchicalOrderBy__c
                FROM Component__c WHERE Id =: comp.ID];

        List<Content__c> contentList = MockupFactory.createContent('Banner', clusterRootList[0], 1);
        contentList[0].Status__c = 'Published';
        update contentList;
        List<ContentAssignment__c> contentAssigmentList = MockupFactory.createContentAssignment(contentList, componentList);
        List<MediaElement__c> mediaElementList = MockupFactory.createMediaElement(1);
        List<MediaElementAssignment__c> mediaElementAssigList = MockupFactory.createMediaElementAssignment(contentList, mediaElementList);

        Set<String> fieldSet =  new Set<String>{'ExternalId__c','BannerFrameType__c'};
        Set<String> setClusterIds = new Set<String>{clusterRootList[0].Id};
        
        // When
        Test.startTest();
        ContentUtils.ContentWrapper cw = ContentUtils.getContentFromComponent(componentList[0], fieldSet, null, null, setClusterIds, 'Desktop');
        Test.stopTest();

        // Then
        contentAssigmentList = [SELECT Id, Content__c FROM ContentAssignment__c ORDER BY Order__c];     
        Integer i = 0;
        for(ContentUtils.ContentDataWrapper cont : cw.contentDataPage){
            System.assertEquals(contentAssigmentList[i].Content__c, cont.content.Id);
            i++;
        }       
    }

    @isTest
    static void getContentFromTagFilteredTest(){
        // Comment: dado un Component__c y un Cluster__c devuelve el componente correspondiente asignado a un Tag

        // Given
        List<Cluster__c> clusterRootList = [SELECT Id FROM Cluster__c];
        List<Component__c> componentList = MockupFactory.createComponent('Banner', 1,clusterRootList[0]);
        Component__c comp = componentList[0];
        comp.TagCriteria__c = '1 AND 2';
        comp.Datasource__c = 'Tags';
        update comp;

        componentList = [SELECT Name, TagCriteria__c, ExternalId__c, Datasource__c, BannerFrameType__c,Status__c, RecordTypeId, RecordType.DeveloperName, Cluster__c, ExcludePastEvents__c, OrderBy__c, HierarchicalOrderBy__c, PageSize__c
                FROM Component__c WHERE Id =: comp.ID];

        List<Content__c> contentList = MockupFactory.createContent('Banner', clusterRootList[0], 1);
        List<Tag__c> tagList = MockupFactory.createTag('TestTag', 'Tag de test', 2, clusterRootList[0].Id);
        List<TagAssignment__c> tagAssigmentList = MockupFactory.createTagAssignment(tagList, componentList, contentList);
        List<MediaElement__c> mediaElementList = MockupFactory.createMediaElement(1);
        List<MediaElementAssignment__c> mediaElementAssigList = MockupFactory.createMediaElementAssignment(contentList, mediaElementList);

        Set<String> fieldSet =  new Set<String>{'ExternalId__c','BannerFrameType__c'};
        Set<String> setClusterIds = new Set<String>{clusterRootList[0].Id};
        
        // When
        Test.startTest();
        ContentUtils.ContentWrapper cw = ContentUtils.getContentFromComponent(componentList[0], fieldSet, null, null, setClusterIds, 'Desktop');
        Test.stopTest();

        // Then     
        System.assertNotEquals(cw, null);
    }

    @isTest
    static void createFromTemplateFailure(){

        // Given
        List<Cluster__c> clusterRootList = [SELECT Id FROM Cluster__c];
        List<Content__c> contentList = MockupFactory.createContent('Banner', clusterRootList[0], 1);
        
        // When
        Test.startTest();
        String result = '';
        try{
            result = ContentUtils.createFromTemplate(contentList[0].Id, 'Test Template Name', null);
        }catch(Exception e){
        }
        Test.stopTest();

        // Then     
        System.assert(result == '');
    }


    @isTest
    static void createFromTemplateSuccess(){

        // Given
        List<Cluster__c> clusterRootList = [SELECT Id FROM Cluster__c];
        List<Content__c> contentList = MockupFactory.createContent('Banner', clusterRootList[0], 1);
        contentList[0].IsTemplate__c = true;
        contentList[0].Status__c = 'Published';
        update contentList;
        
        // When
        Test.startTest();
        String result = '';
        try{
            result = ContentUtils.createFromTemplate(contentList[0].Id, 'Test Template Name', null);
        }catch(Exception e){
        }
        Test.stopTest();

        // Then     
        System.assert(result != '');
    }
    
}