@isTest(seeAllData = false)
public with sharing class CG_BaseComponentControllerTest {
    @testSetup
    static void setup(){
        // Given in all cases
        MockupFactory.generateAcceleratorSetting();
        MockupFactory.createCluster('global', null, 1, 'ClusterRoot', 'CRT');
    }
    @isTest 
    static void CASE_1(){
        /*  Comment: dado un String correspondiente al ExternalId__c de un Component__c se retorna un Wrapper 
            con el Component correspondiente, es un related new con datasourse 'Parent Component Behaviour' y un pagesize */
    
        //Given
        //Navigation Record
        Navigation__c nav = new Navigation__c(Name = 'Nav', URL__c = 'https:google.com');
        //Component Article Record
        String recordTypeId = [SELECt id, name, SobjectType FROM RecordType WHERE SobjectType = 'Component__c' AND Name = 'Article' LIMIT 1].id;
        Component__c componentArticle = new Component__c (Name='Article', ExternalId__c='Article', RecordTypeId = recordTypeId, Datasource__c = 'ManualAssignment',HierarchicalOrderBy__c = 'ASC', LinkDetail__c = nav.id);
        insert componentArticle;
        //Content Article Record
        String RTArticleId = [SELECt id, name, SobjectType FROM RecordType WHERE SobjectType = 'Content__c' AND Name = 'Article'].id;
        Content__c contentArticle = new Content__c(Name = 'Article1', RecordTypeId = RTArticleId);
        insert contentArticle;
        //Component Related Article Record
        recordTypeId = [SELECt id, name, SobjectType FROM RecordType WHERE SobjectType = 'Component__c' AND Name = 'Related Article' LIMIT 1].id;
        Component__c componentRN = new Component__c (Name='RN', ExternalId__c='RN', RecordTypeId = recordTypeId, Datasource__c = 'ParentComponentBehaviour', ArticleType__c = 'Landscape', PageSize__c = 1,HierarchicalOrderBy__c = 'ASC', LinkDetail__c = nav.id);
        insert componentRN;
        //When
        test.startTest();
        CG_BaseComponentController.ComponentWrapper cw = CG_BaseComponentController.getComponentWrapper(componentRN.ExternalId__c, 'RelatedArticle', componentArticle.Id, contentArticle.Id, null, 'DESKTOP');
        test.stopTest();
        //Then
        system.assertNotEquals(null, cw);
        system.assertEquals(componentRN.id, cw.component.id);
    }   
    @isTest 
    static void CASE_2(){
        /*  Comment: dado un String correspondiente al ExternalId__c de un Component__c se retorna un Wrapper 
            con el Component correspondiente, es un Banner con datasourse 'Manual Assigment'  */
    
        //Given
        String clusterId = [SELECT id FROM Cluster__c LIMIT 1].Id;
        //Component Banner Record
        String recordTypeId = [SELECt id, name, SobjectType FROM RecordType WHERE SobjectType = 'Component__c' AND Name = 'Banner' LIMIT 1].id;
        Component__c componentBanner = new Component__c (Name='Article', ExternalId__c='Article', RecordTypeId = recordTypeId, Datasource__c = 'ManualAssignment',HierarchicalOrderBy__c = 'ASC');
        insert componentBanner;
        //Content Banner Record
        String RTBannerId = [SELECt id, name, SobjectType FROM RecordType WHERE SobjectType = 'Content__c' AND Name = 'Banner'].id;
        Content__c contentBanner = new Content__c(Name = 'Article1', RecordTypeId = RTBannerId);
        insert contentBanner;
        // Component Content Junction Record
        ContentAssignment__c ca = new ContentAssignment__c(Component__c=componentBanner.id, Content__c=contentBanner.id);
        insert ca;
        //When
        test.startTest();
        CG_BaseComponentController.ComponentWrapper cw = CG_BaseComponentController.getComponentWrapper(componentBanner.ExternalId__c, 'Banner', null, null, null, 'DESKTOP');
        test.stopTest();
        //Then
        system.assertNotEquals(null, cw);
        system.assertEquals(componentBanner.id, cw.component.id);
    }
    @isTest 
    static void CASE_3(){
        /*  Comment: Prueba del paginado */
    
        //Given
        Cluster__c cluster = [SELECT id FROM Cluster__c LIMIT 1];
        List<String> listContentId = new List<String>();
        for(Content__c con : MockupFactory.createContent('Article', cluster, 3)){
            listContentId.add(con.Id);
        }
        //When
        test.startTest();
        List<CG_BaseComponentController.ContentWrapper> listContentWrapper = CG_BaseComponentController.getPage(listContentId, 'Article', '1', '1', 'ExternalId__c', 'DESKTOP');
        test.stopTest();
        //Then
        system.assertNotEquals(null, listContentWrapper);
    }
}