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
        String recordTypeId = [SELECt id, name, SobjectType FROM RecordType WHERE SobjectType =: GeneralUtils.prefix('[CMS]Component__c') AND DeveloperName = 'ArticleList' LIMIT 1].id;
        Component__c componentArticle = new Component__c (Name='Article', ExternalId__c='Article', RecordTypeId = recordTypeId, Datasource__c = 'ManualAssignment',HierarchicalOrderBy__c = 'ASC', LinkDetail__c = nav.id);
        insert componentArticle;
        //Content Article Record
        String RTArticleId = [SELECt id, name, SobjectType FROM RecordType WHERE SobjectType =: GeneralUtils.prefix('[CMS]Content__c') AND DeveloperName = 'Article'].id;
        Content__c contentArticle = new Content__c(Name = 'Article1', RecordTypeId = RTArticleId);
        insert contentArticle;
        //Component Related Article Record
        recordTypeId = [SELECt id, name, SobjectType FROM RecordType WHERE SobjectType =: GeneralUtils.prefix('[CMS]Component__c') AND DeveloperName = 'ArticlesRelated' LIMIT 1].id;
        Component__c componentRN = new Component__c (Name='RN', ExternalId__c='RN', RecordTypeId = recordTypeId, Datasource__c = 'ParentComponentBehaviour', ArticleType__c = 'Landscape', PageSize__c = 1,HierarchicalOrderBy__c = 'ASC', LinkDetail__c = nav.id);
        insert componentRN;
        //When
        test.startTest();
        CG_BaseComponentController.ComponentWrapper cw = CG_BaseComponentController.getComponentWrapper(componentRN.ExternalId__c, 'ArticlesRelated', componentArticle.Id, contentArticle.Id, null, 'DESKTOP');
        test.stopTest();
        //Then
        system.assertNotEquals(null, cw);
        system.assertEquals(componentRN.id, cw.component.id);
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
        List<CG_BaseComponentController.ContentWrapper> listContentWrapper = CG_BaseComponentController.getPage(listContentId, 'ArticleList', '1', '1', GeneralUtils.prefix('[CMS]ExternalId__c'), 'DESKTOP');
        test.stopTest();
        //Then
        system.assertNotEquals(null, listContentWrapper);
    }
}