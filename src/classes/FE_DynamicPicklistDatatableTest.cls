@isTest
public class FE_DynamicPicklistDatatableTest {
    
    @testSetup
    public static void testSetup() {
        MockupFactory.generateAcceleratorSetting();
        List<Cluster__c> clusters = MockupFactory.createCluster('DummyCluster', null, 1, 'ClusterRoot', 'DummyCluster');
        
        List<Datatable__c>  datatables = MockupFactory.createDatatables('DatatableDummy', 'DatatableDummy', 'Case', 1, clusters.get(0).Id);		            
    }
    
    @isTest
    public static void getDefaultValueTest01() {
        Test.startTest();
        FE_DynamicPicklistDatatable dp = new FE_DynamicPicklistDatatable();
        
        System.debug(dp.getDefaultValue());
        
        Test.stopTest();
    }
    
    @isTest
    public static void getValuesTest01() {
        Test.startTest();
        FE_DynamicPicklistDatatable dp = new FE_DynamicPicklistDatatable();
        
        System.debug(dp.getValues());
        
        Test.stopTest();
    }
}