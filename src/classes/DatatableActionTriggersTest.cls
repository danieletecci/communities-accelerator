@isTest
private class DatatableActionTriggersTest {
    
    @testSetup
    static void generateAcceleratorSetting(){
        MockupFactory.generateAcceleratorSetting();
    }
    
    @isTest
    static void createDatabaseActionWithExternalId() {
        Test.startTest();
        
        List<Cluster__c> clustersRoot = MockUpFactory.createCluster('DummyRootCluster', null, 1, 'ClusterRoot', 'CRT');
        
        Id clusterId = clustersRoot.get(0).Id;
        String sobjectName = GeneralUtils.prefix('[CMS]DatatableAction__c');

        RecordType rt = [SELECT Id FROM RecordType WHERE SobjectType =: sobjectName AND DeveloperName = 'GlobalAction'];
        
        List<Datatable__c> datatables = MockupFactory.createDatatables('DummyDatatable', 'DummyDatatable', 'Account', 1, clusterId);
        
        List<DatatableAction__c> datatableActions = MockupFactory.createDatatableActions('DummyDatatableAction', 'DummyDatatableAction', 2, datatables.get(0).Id, rt.Id);
        
        Test.stopTest();
    }
    
    @isTest
    static void createDatabaseActionWithoutExternalId() {
        Test.startTest();
        
        List<Cluster__c> clustersRoot = MockUpFactory.createCluster('DummyRootCluster', null, 1, 'ClusterRoot', 'CRT');
        String sobjectName = GeneralUtils.prefix('[CMS]DatatableAction__c');

        Id clusterId = clustersRoot.get(0).Id;
        RecordType rt = [SELECT Id FROM RecordType WHERE SobjectType =: sobjectName AND DeveloperName = 'GlobalAction'];
        
        List<Datatable__c> datatables = MockupFactory.createDatatables('DummyDatatable', null, 'Account', 1, clusterId);
        
        List<DatatableAction__c> datatableActions = MockupFactory.createDatatableActions('DummyDatatableAction', null, 2, datatables.get(0).Id, rt.Id);
        
        Test.stopTest();      
    }
    
    @isTest
    static void updateDatabaseElementWithExternalId() {
        Test.startTest();
        
        List<Cluster__c> clustersRoot = MockUpFactory.createCluster('DummyRootCluster', null, 1, 'ClusterRoot', 'CRT');
        String sobjectName = GeneralUtils.prefix('[CMS]DatatableAction__c');

        Id clusterId = clustersRoot.get(0).Id;
        RecordType rt = [SELECT Id FROM RecordType WHERE SobjectType =: sobjectName AND DeveloperName = 'GlobalAction'];
        
        List<Datatable__c> datatables = MockupFactory.createDatatables('DummyDatatable', 'DummyDatatable', 'Account', 1, clusterId);
        
        List<DatatableAction__c> datatableActions = MockupFactory.createDatatableActions('DummyDatatableAction', 'DummyDatatableAction', 2, datatables.get(0).Id, rt.Id);
        
        DatatableAction__c de = datatableActions.get(0);
        de.Name = 'AnotherDataActionName';
        
        update de;
        
        Test.stopTest();
    }
    
    @isTest
    static void updateDatabaseElementWithoutExternalId() {
        Test.startTest();
        
        List<Cluster__c> clustersRoot = MockUpFactory.createCluster('DummyRootCluster', null, 1, 'ClusterRoot', 'CRT');
        String sobjectName = GeneralUtils.prefix('[CMS]DatatableAction__c');
        
        Id clusterId = clustersRoot[0].Id;
        RecordType rt = [SELECT Id FROM RecordType WHERE SobjectType =: sobjectName AND DeveloperName = 'GlobalAction'];
        
        List<Datatable__c> datatables = MockupFactory.createDatatables('DummyDatatable', null, 'Account', 1, clusterId);
        
        List<DatatableAction__c> datatableActions = MockupFactory.createDatatableActions('DummyDatatableAction', 'DummyDatatableAction', 2, datatables.get(0).Id, rt.Id);
        
        DatatableAction__c de = datatableActions.get(0);
        de.Name = 'AnotherDataActionName';
        
        update de;
        
        Test.stopTest();        
    }
}