@isTest
private class DatatableTriggersTest {
    
    @testSetup
    static void generateCustomSettings(){
        MockupFactory.generateAcceleratorSetting();
    }
    
    @isTest
    static void createValidDatatable() {
        
        Test.startTest();
        List<Cluster__c> clusters = MockUpFactory.createCluster('DummyCluster', null, 1, 'ClusterRoot', 'CRT');
        
        List<Datatable__c> datatables = MockupFactory.createDatatables('DummyDatatable', 'DummyDatatable', 'Account', 2, clusters.get(0).Id);
        
        System.assert(datatables.size() > 0);
        
        Test.stopTest();
    }
    
    @isTest
    static void updateValidDatatable() {
        
        Test.startTest();
        List<Cluster__c> clustersRoot = MockUpFactory.createCluster('DummyRootCluster', null, 1, 'ClusterRoot', 'CRT');
        List<Cluster__c> clustersLeaf = MockUpFactory.createCluster('DummyLeafCluster', clustersRoot[0].Id, 1, 'ClusterLeaf', 'CLT');
        
        Cluster__c leaf = clustersLeaf[0];
        
        List<Datatable__c> datatables = MockupFactory.createDatatables('DummyDatatable', 'DummyDatatable', 'Account', 2, leaf.Id);
        
        System.assert(datatables.size() > 0);
        
        Datatable__c a = datatables.get(0);
        a.Name = 'DummyDatatable2';
        a.Cluster__c = clustersRoot[0].Id;
        
        update a;
        
       /* a = datatables.get(0);
        a.Name = 'DummyDatatable2';
        a.Cluster__c = null;
        
        update a;*/
        
        Test.stopTest();
    }
    
    @isTest
    static void updateObjectOfValidDatatable() {
        
        Test.startTest();
        List<Cluster__c> clustersRoot = MockUpFactory.createCluster('DummyRootCluster', null, 1, 'ClusterRoot', 'CRT');
        List<Cluster__c> clustersLeaf = MockUpFactory.createCluster('DummyLeafCluster', clustersRoot[0].Id, 1, 'ClusterLeaf', 'CLT');
        
        Cluster__c leaf = clustersLeaf[0];
        
        List<Datatable__c> datatables = MockupFactory.createDatatables('DummyDatatable', 'DummyDatatable', 'Account', 2, leaf.Id);
        
        System.assert(datatables.size() > 0);
        
        Datatable__c a = datatables.get(0);
        a.Name = 'DummyDatatable2';
        a.ObjectApiName__c = 'Case';
        a.Cluster__c = clustersRoot[0].Id;
        
        update a;
        
       /* a = datatables.get(0);
        a.Name = 'DummyDatatable2';
        a.Cluster__c = null;
        
        update a;*/
        
        Test.stopTest();
    }
    
    @isTest
    static void createInvalidDatatableWithExternalId() {
        
        Test.startTest();
        List<Cluster__c> clusters = MockUpFactory.createCluster('DummyCluster', null, 1, 'ClusterRoot', 'CRT');
        List<Datatable__c> datatables = new List<Datatable__c>();
        
        String name = 'DummyDatatable';
        
        Datatable__c datatable = new Datatable__c();
        datatable.Name = name;
        datatable.Cluster__c = clusters.get(0).Id;
        datatable.ExternalId__c = name;
        datatable.ObjectApiName__c = 'DummyObject';
        
        datatables.add(datatable);
        
        List<Database.SaveResult> results = Database.insert(datatables, false);
        
        Test.stopTest();
    }
    
    @isTest
    static void createInvalidDatatableWithoutExternalId() {
        
        Test.startTest();
        List<Cluster__c> clusters = MockUpFactory.createCluster('DummyCluster', null, 1, 'ClusterRoot', 'CRT');
        List<Datatable__c> datatables = new List<Datatable__c>();
        
        String name = 'DummyDatatable';
        
        Datatable__c datatable = new Datatable__c();
        datatable.Name = name;
        datatable.Cluster__c = clusters.get(0).Id;
        datatable.ExternalId__c = null;
        datatable.ObjectApiName__c = 'DummyObject';
        
        datatables.add(datatable);
        
        List<Database.SaveResult> results = Database.insert(datatables, false);
        
        Test.stopTest();
    }

    //CMS-315 Apex Sharing on Datatable
    @isTest
    static void updateDatatableSharing(){
        // Given
        List<Cluster__c> clusterRootList = MockupFactory.createCluster('ClusterRootTest', null, 1, 'ClusterRoot', 'DRC');
        List<Datatable__c> datatableList = MockupFactory.createDatatables('Table Test', 'TableTest', GeneralUtils.prefix('[CMS]Component__c'), 1, clusterRootList[0].Id);
        List<DatatableElement__c> dataElementList = MockupFactory.createDatatableElements('Name', 'DataElementExternalId', 2, datatableList[0].Id);
        datatableList[0].Cluster__c = clusterRootList[0].Id;
        
        // When
        Test.startTest();
        update datatableList[0];
        Test.stopTest();

        // Then
        List<Datatable__Share> shareList = [SELECT Id, ParentId FROM Datatable__Share WHERE ParentId = :datatableList[0].Id AND RowCause =: GeneralUtils.prefix('[CMS]Clustering__c')];
        System.assertEquals(3, shareList.size());
    }
}