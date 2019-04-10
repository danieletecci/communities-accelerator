@isTest
public class ClusterUtilsTest {

    @testSetup
    static void setup(){
        MockupFactory.generateAcceleratorSetting();
        List<Cluster__c> clusterRoot = MockupFactory.createCluster('CRootTest', null, 1, 'ClusterRoot', 'CRT');
        List<Cluster__c> clustersLevel2 = MockupFactory.createCluster('CL2Test', clusterRoot.get(0).Id, 2, 'ClusterGroup', 'CGT');
        Set<Id> level2Ids = (new Map<Id, SObject>(clustersLevel2)).keySet();
        List<Cluster__c> clustersLevel3 = MockupFactory.createCluster('CL3Test', new List<Id>(level2Ids), 2, 'ClusterGroup', 'es', '', 'CG3');
        Set<Id> level3Ids = (new Map<Id, SObject>(clustersLevel3)).keySet();
        List<Cluster__c> clustersLeaf = MockupFactory.createCluster('CLeafTest', new List<Id>(level3Ids), 2, 'ClusterLeaf', 'es', '', 'CLT');
    }

    @isTest
    static void getClustersParentsTest(){
        //Given
        // Scenario in test setup, a 4 level cluster tree.
        
        //When
        List<Set<String>> parentIds = new List<Set<String>>();
        for (Cluster__c cluster : [SELECT Id FROM Cluster__c WHERE name LIKE 'CLeafTest%']){
            parentIds.add(ClusterUtils.getClustersParents(cluster.Id));
        }

        //Then
        for (Set<String> setOfIds : parentIds){
            system.assertEquals(4, setOfIds.size());
        }
    }

    @isTest
    static void getClustersBelowTest(){
        //Given
        Cluster__c clusterRoot =    [SELECT Id FROM Cluster__c WHERE name LIKE 'CRootTest%' LIMIT 1];
        Cluster__c clusterLevel2 =  [SELECT Id FROM Cluster__c WHERE name LIKE 'CL2Test%' LIMIT 1];
        Cluster__c clusterLevel3 =  [SELECT Id FROM Cluster__c WHERE name LIKE 'CL3Test%' LIMIT 1];
        Cluster__c clusterLeaf =    [SELECT Id FROM Cluster__c WHERE name LIKE 'CLeafTest%' LIMIT 1];

        //When
        ClusterUtils.ClusterWrapper clusterRootRealtedClusters = ClusterUtils.getClustersBelow(clusterRoot.Id);
        ClusterUtils.ClusterWrapper clusterLevel2RealtedClusters = ClusterUtils.getClustersBelow(clusterLevel2.Id);
        ClusterUtils.ClusterWrapper clusterLevel3RealtedClusters = ClusterUtils.getClustersBelow(clusterLevel3.Id);
        ClusterUtils.ClusterWrapper clusterLeafRealtedClusters = ClusterUtils.getClustersBelow(clusterLeaf.Id);

        //Then
        system.assertEquals(2, clusterRootRealtedClusters.relatedClusters.size());
        system.assertEquals(2, clusterLevel2RealtedClusters.relatedClusters.size());
        system.assertEquals(2, clusterLevel3RealtedClusters.relatedClusters.size());
        system.assert(clusterLeafRealtedClusters.relatedClusters.isEmpty());
    }
    
    @isTest
    static void getClusterIdFromMappingObjectTest(){
        //Given
        ClusterUtils.testNetworkName = 'https://www.salesforce.com';

        RecordType rtRoot = [SELECT Id FROM RecordType WHERE SobjectType = 'Cluster__c' AND DeveloperName = 'ClusterRoot'];
        RecordType rtLeaf = [SELECT Id FROM RecordType WHERE SobjectType = 'Cluster__c' AND DeveloperName = 'ClusterLeaf'];

        User u = [SELECT Id, LanguageLocaleKey FROM User WHERE Id =: UserInfo.getUserId()];

        Cluster__c clusterRoot = new Cluster__c(
            Name = 'Root',
            ExternalId__c= 'Root1',
            RecordTypeId = rtRoot.Id,
            CommunityName__c = ClusterUtils.testNetworkName,
            DefaultLanguage__c = u.LanguageLocaleKey == 'es' ? 'en_US' : 'es'
        );
        insert clusterRoot;

        Cluster__c clusterLeaf = new Cluster__c(
            Name = 'Leaf',
            ExternalId__c= 'Leaf1',
            RecordTypeId = rtLeaf.Id,
            ParentCluster__c = clusterRoot.Id,
            DefaultLanguage__c = u.LanguageLocaleKey
        );
        insert clusterLeaf;

        //When
        String result = ClusterUtils.getClusterIdFromMappingObject(UserInfo.getUserId(), '');
        //Then
        system.assertEquals(clusterLeaf.Id, result);
    }

    @isTest
    static void getClusterRootFromNetworkTest(){
        //Given
        ClusterUtils.testNetworkName = 'https://www.salesforce.com';
        Cluster__c clusterRoot = [SELECT Id FROM Cluster__c WHERE Name LIKE 'CRootTest%' LIMIT 1];
        clusterRoot.CommunityName__c = ClusterUtils.testNetworkName;
        update clusterRoot;

        //When
        Cluster__c cluster = ClusterUtils.getClusterRootFromNetwork();

        //Then
        system.assertEquals(clusterRoot.Id, cluster.Id);
    }

}