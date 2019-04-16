@isTest
public class ContentCreateModalControllerTest {

    @testSetup
    static void generateCustomSettings(){
        MockupFactory.generateAcceleratorSetting();
        List<Cluster__c> clusterRoot = MockupFactory.createCluster('Cluster Root', '', 1, 'ClusterRoot', 'CRT');
        List<Cluster__c> clusterGroup = MockupFactory.createCluster('Cluster Group', clusterRoot.get(0).id, 1, 'ClusterGroup', 'CGT');
        List<Cluster__c> clusterLeaf = MockupFactory.createCluster('Cluster Leaf', clusterGroup.get(0).id, 2, 'ClusterLeaf', 'CLT');
        MockupFactory.createComponent('FAQ', 1, clusterRoot.get(0));
    }

    @isTest
    static void getRecordTypeName(){

        //Given
        RecordType rt = [SELECT Id FROM RecordType WHERE SobjectType = 'Content__c' AND DeveloperName = 'Banner'];
        String recordTypeLabel = Schema.SObjectType.Content__c.getRecordTypeInfosById().get(rt.Id).getName();

        //When
        String responseLabel = ContentCreateModalController.getRecordTypeName(rt.Id);

        //Then
        system.assertEquals(recordTypeLabel, responseLabel);

    }

    @isTest
    static void getClusters(){
        Cluster__c cluster = [SELECT id FROM Cluster__c WHERE Name LIKE: '%Cluster Root%' LIMIT 1];
        MockupFactory.createClusterUser(cluster.Id, UserInfo.getUserId(), 1, 'Read/Write');
        try{
            ContentCreateModalController.getClusters();
        } catch(Exception e){
            System.assertEquals(e.getMessage(), 'You have no cluster associated');
        }
    }

    @isTest
    static void createNewContent(){

        //Given
        Component__c component = [SELECT id FROM Component__c LIMIT 1];
        RecordType rt = [SELECT Id FROM RecordType WHERE SobjectType = 'Content__c' AND DeveloperName = 'FAQ'];
        Cluster__c cluster = [SELECT id FROM Cluster__c LIMIT 1];

        //When
        String response = ContentCreateModalController.createNewContent((String) rt.Id, false, (String) component.Id, null, 'Test FAQ', cluster.Id, null);

        //Then
        system.assert(response != null);
        List<Content__c> content = [SELECT Id, Name FROM Content__c WHERE Name = 'Test FAQ' LIMIT 1];
        system.assert(!content.isEmpty());

    }


    @isTest
    static void createNewContentFail(){

        //Given
        RecordType rt = [SELECT Id FROM RecordType WHERE SobjectType = 'Content__c' AND DeveloperName = 'FAQ'];
        Cluster__c cluster = [SELECT id FROM Cluster__c LIMIT 1];

        String response = '';
        //When
        try{
            response = ContentCreateModalController.createNewContent(rt.Id, true, rt.Id, null, 'Test FAQ', cluster.Id, null);
        }catch(Exception e){
            
        }

        //Then
        system.assert(response == '');

    }
    
}