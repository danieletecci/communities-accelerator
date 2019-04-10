@isTest
private class DatatableElementTriggersTest {
    
    @testSetup
    static void generateAcceleratorSetting(){
        MockupFactory.generateAcceleratorSetting();
    }
    
    @isTest
    static void createDatabaseElementWithExternalId() {
        Test.startTest();
        
        List<Cluster__c> clustersRoot = MockUpFactory.createCluster('DummyRootCluster', null, 1, 'ClusterRoot', 'CRT');
        
        Id clusterId = clustersRoot.get(0).Id;
        
        List<Datatable__c> datatables = MockupFactory.createDatatables('DummyDatatable', 'DummyDatatable', 'Account', 1, clusterId);
        
        List<DatatableElement__c> datatableElements = MockupFactory.createDatatableElements('DummyDatatableElement', 'DummyDatatableElement', 2, datatables[0].Id);
        
        Test.stopTest();
    }
    
    @isTest
    static void createDatabaseElementWithoutExternalId() {
        Test.startTest();
        
        List<Cluster__c> clustersRoot = MockUpFactory.createCluster('DummyRootCluster', null, 1, 'ClusterRoot', 'CRT');
        
        Id clusterId = clustersRoot.get(0).Id;
        
        List<Datatable__c> datatables = MockupFactory.createDatatables('DummyDatatable', null, 'Account', 1, clusterId);
        
        List<DatatableElement__c> datatableElements = MockupFactory.createDatatableElements('DummyDatatableElement', null, 2, datatables.get(0).Id);
        
        Test.stopTest();      
    }
    
    @isTest
    static void updateDatabaseElementWithExternalId() {
        Test.startTest();
        
        List<Cluster__c> clustersRoot = MockUpFactory.createCluster('DummyRootCluster', null, 1, 'ClusterRoot', 'CRT');
        
        Id clusterId = clustersRoot.get(0).Id;
        
        List<Datatable__c> datatables = MockupFactory.createDatatables('DummyDatatable', 'DummyDatatable', 'Account', 1, clusterId);
        
        List<DatatableElement__c> datatableElements = MockupFactory.createDatatableElements('DummyDatatableElement', 'DummyDatatableElement', 2, datatables.get(0).Id);
        
        DatatableElement__c de = datatableElements.get(0);
        de.Name = 'AnotherDataElementName';
        
        update de;
        
        Test.stopTest();
    }
    
    @isTest
    static void updateDatabaseElementWithoutExternalId() {
        Test.startTest();
        
        List<Cluster__c> clustersRoot = MockUpFactory.createCluster('DummyRootCluster', null, 1, 'ClusterRoot', 'CRT');
        
        Id clusterId = clustersRoot.get(0).Id;
        
        List<Datatable__c> datatables = MockupFactory.createDatatables('DummyDatatable', null, 'Account', 1, clusterId);
        
        List<DatatableElement__c> datatableElements = MockupFactory.createDatatableElements('DummyDatatableElement', null, 2, datatables.get(0).Id);
        
        DatatableElement__c de = datatableElements.get(0);
        de.Name = 'AnotherDataElementName';
        
        update de;
        
        Test.stopTest();        
    }
}