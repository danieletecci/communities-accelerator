@isTest
public class FE_DatatableUtilsTest {
    @testSetup
    static void generateCustomSettings(){
        MockupFactory.generateAcceleratorSetting();
        List<Cluster__c> clusterRootList = MockupFactory.createCluster('ClusterRootTest', null, 1, 'ClusterRoot', 'DRC');
        List<Datatable__c> datatableList = MockupFactory.createDatatables('Table Test', 'TableTest', 'Component__c', 1, clusterRootList[0].Id);
        
        System.debug('datatableExternalId: ' + datatableList.get(0).ExternalId__c);
        
    	List<DatatableElement__c> dataElementList = MockupFactory.createDatatableElements('Name', 'DataElementExternalId', 2, datatableList[0].Id);
    }
    
	@isTest
    public static void processSearchTermTest01() {
        Test.startTest();
        Datatable__c datatable = FE_DatatableUtils.getDatatableInfo('TableTest_0');
        
        datatable.NumberOfColumns__c = '10';
        update datatable;
        
        List<DatatableElement__c> elems = new List<DatatableElement__c>();
        DatatableElement__c ele = new DatatableElement__c();
        ele.Name = 'DatatableElementTest1';
        ele.Searchable__c = true;
        ele.FieldApiName__c = 'Name';
        ele.Datatable__c = datatable.Id;
        ele.Label__c = 'Name';
        
        elems.add(ele);
        insert elems;
        
        datatable = FE_DatatableUtils.getDatatableInfo('TableTest_0');
        
        String searchTerm = 'test';
            
        FE_DatatableUtils.processSearchTerm(datatable, searchTerm);
        
        Test.stopTest();
    }
    
    @isTest
    public static void doGetRecordsTest() {
        Test.startTest();
        
        Cluster__c clus = MockupFactory.createCluster('DummyCluster', null, 1, 'ClusterRoot', 'DummyCluster').get(0);
        
        Datatable__c datatable = new Datatable__c();
        datatable.Name = 'DummyDatatable';
        datatable.ObjectApiName__c = 'User';
        
        datatable.Cluster__c = clus.Id;
        datatable.RecordsPerPage__c = 2;
        datatable.NumberOfColumns__c = '2';
        datatable.OrderBy__c = 'Name ASC';
        datatable.WhereCondition__c = 'WHERE Name != null';
        insert datatable;
        
        DatatableElement__c elem = new DatatableElement__c();
        elem.Name = 'DummyDatatableElement';
        elem.Datatable__c = datatable.Id;
        elem.FieldApiName__c = 'CreatedDate';
        elem.Label__c = 'Created Date'; 
        
        insert elem;
        
        Datatable__c d = [SELECT Id, WhereCondition__c, ObjectApiName__c, OrderBy__c
                          		, RecordsPerPage__c
                          		, (SELECT Id, FieldApiName__c, Navigation__c FROM DatatableElements__r) 
                          	FROM Datatable__c WHERE Name = 'DummyDatatable'];
        FE_DatatableController.DatatableWrapper wrapper = new FE_DatatableController.DatatableWrapper();
        
        FE_DatatableUtils.doGetRecords(d, 0, wrapper);
        
        Test.stopTest();
    }
    
    @isTest
    public static void mapDatatableDataToWrappersTest() {
        Test.startTest();
        
        Cluster__c clus = MockupFactory.createCluster('DummyCluster', null, 1, 'ClusterRoot', 'DummyCluster').get(0);
        
        Datatable__c datatable = new Datatable__c();
        datatable.Name = 'DummyDatatable';
        datatable.ObjectApiName__c = 'User';
        
        datatable.Cluster__c = clus.Id;
        datatable.RecordsPerPage__c = 2;
        datatable.NumberOfColumns__c = '2';
        datatable.OrderBy__c = 'Name ASC';
        datatable.WhereCondition__c = 'WHERE Name != null';
        insert datatable;
        
        DatatableElement__c elem = new DatatableElement__c();
        elem.Name = 'DummyDatatableElement';
        elem.Datatable__c = datatable.Id;
        elem.FieldApiName__c = 'CreatedDate';
        elem.Label__c = 'Created Date';
        elem.DisplaySettings__c = 'Both';
        
        insert elem;
        
        elem = new DatatableElement__c();
        elem.Name = 'DummyDatatableElement2';
        elem.Datatable__c = datatable.Id;
        elem.FieldApiName__c = 'DigestFrequency';
        elem.Label__c = 'DigestFrequency';
        elem.DisplaySettings__c = 'Both';
        
        insert elem;
        
        List<User> users = [SELECT Id, Username, CreatedDate, DigestFrequency FROM User];
        
        System.debug('users: ' + users);
        
        Datatable__c d = [SELECT Id, WhereCondition__c, ObjectApiName__c, OrderBy__c
                          		, RecordsPerPage__c
                          		, (SELECT Id, FieldApiName__c, Label__c, Type__c, ColumnInformation__c
                                   		, DisplaySettings__c, Searchable__c, Filtrable__c, Sortable__c
                                   		, Navigation__c, ExcludedPicklistValues__c
                                   		, Datatable__c, Datatable__r.ObjectApiName__c
                                   	FROM DatatableElements__r) 
                          	FROM Datatable__c WHERE Name = 'DummyDatatable'];
        
        List<FE_DatatableController.DatatableElementWrapper> elems = FE_DatatableUtils.mapDatatableElementsToWrappers(d.DatatableElements__r);
        FE_DatatableUtils.mapDatatableDataToWrappers(users, elems);
        
        Test.stopTest();
    }
    
    @isTest
    public static void getDatatableInfoTest01() {
        
        Test.startTest();
        
        Datatable__c dat = FE_DatatableUtils.getDatatableInfo('TableTest_0');
        FE_DatatableController.DatatableWrapper dw = FE_DatatableUtils.mapDatatableToWrapper(dat);
        
        Test.stopTest();
    }
        
    @isTest
    public static void mapDatatableActionsToWrappersTest01() {
        Test.startTest();
        
        List<DatatableAction__c> actions = new List<DatatableAction__c>();
        
        List<FE_DatatableController.DatatableActionWrapper> daw = FE_DatatableUtils.mapDatatableActionsToWrappers(actions);
        
        Test.stopTest();
    }
    
    @isTest
    public static void processAppliedFiltersTest01() {
        Test.startTest();
        
        List<FE_DatatableController.DatatableFilterWrapper> appliedFilters = new List<FE_DatatableController.DatatableFilterWrapper>();
        FE_DatatableController.DatatableFilterFieldWrapper filt;
        FE_DatatableController.DatatableFilterWrapper af;
        
        af = new FE_DatatableController.DatatableFilterWrapper();
        af.value1 = 'aloha';
        filt = new FE_DatatableController.DatatableFilterFieldWrapper();
        filt.name = 'Name';
        filt.type = String.valueOf(Schema.DisplayType.STRING);
        af.filter = filt;
        
        appliedFilters.add(af);
        
        af = new FE_DatatableController.DatatableFilterWrapper();
        af.value1 = String.valueOf(Datetime.now());
        filt = new FE_DatatableController.DatatableFilterFieldWrapper();
        filt.name = 'CreatedDate';
        filt.type = String.valueOf(Schema.DisplayType.DATETIME);
        af.filter = filt;
        
        appliedFilters.add(af);
        
        af = new FE_DatatableController.DatatableFilterWrapper();
        af.value1 = String.valueOf(5);
        filt = new FE_DatatableController.DatatableFilterFieldWrapper();
        filt.name = 'NumbOfDays__c';
        filt.type = String.valueOf(Schema.DisplayType.INTEGER);
        af.filter = filt;
        
        appliedFilters.add(af);
        
            
        FE_DatatableUtils.processAppliedFilters(appliedFilters);
        
        Test.stopTest();
    }
    
    @isTest
    public static void processAppliedFiltersTest02() {
        Test.startTest();
        
        List<FE_DatatableController.DatatableFilterWrapper> appliedFilters = new List<FE_DatatableController.DatatableFilterWrapper>();
        FE_DatatableController.DatatableFilterFieldWrapper filt;
        FE_DatatableController.DatatableFilterWrapper af;
        
        af = new FE_DatatableController.DatatableFilterWrapper();
        af.value1 = 'aloha';
        filt = new FE_DatatableController.DatatableFilterFieldWrapper();
        filt.name = 'Name';
        filt.type = String.valueOf(Schema.DisplayType.STRING);
        af.filter = filt;
        
        appliedFilters.add(af);
        
        af = new FE_DatatableController.DatatableFilterWrapper();
        af.value1 = String.valueOf(Datetime.now());
        af.value2 = String.valueOf(Datetime.now());
        filt = new FE_DatatableController.DatatableFilterFieldWrapper();
        filt.name = 'CreatedDate';
        filt.type = String.valueOf(Schema.DisplayType.DATETIME);
        af.filter = filt;
        
        appliedFilters.add(af);
        
        af = new FE_DatatableController.DatatableFilterWrapper();
        af.value1 = String.valueOf(5);
        af.value2 = String.valueOf(8);
        filt = new FE_DatatableController.DatatableFilterFieldWrapper();
        filt.name = 'NumbOfDays__c';
        filt.type = String.valueOf(Schema.DisplayType.INTEGER);
        af.filter = filt;
        
        appliedFilters.add(af);
        
        FE_DatatableUtils.processAppliedFilters(appliedFilters);
        
        Test.stopTest();
    }
    
    @isTest
    public static void processAppliedFiltersTest03() {
        Test.startTest();
        
        List<FE_DatatableController.DatatableFilterWrapper> appliedFilters = new List<FE_DatatableController.DatatableFilterWrapper>();
        FE_DatatableController.DatatableFilterFieldWrapper filt;
        FE_DatatableController.DatatableFilterWrapper af;
        
        af = new FE_DatatableController.DatatableFilterWrapper();
        af.value1 = 'aloha';
        filt = new FE_DatatableController.DatatableFilterFieldWrapper();
        filt.name = 'Name';
        filt.type = String.valueOf(Schema.DisplayType.STRING);
        af.filter = filt;
        
        appliedFilters.add(af);
        
        af = new FE_DatatableController.DatatableFilterWrapper();
        af.value2 = String.valueOf(Datetime.now());
        filt = new FE_DatatableController.DatatableFilterFieldWrapper();
        filt.name = 'CreatedDate';
        filt.type = String.valueOf(Schema.DisplayType.DATETIME);
        af.filter = filt;
        
        appliedFilters.add(af);
        
        af = new FE_DatatableController.DatatableFilterWrapper();
        af.value2 = String.valueOf(5);
        filt = new FE_DatatableController.DatatableFilterFieldWrapper();
        filt.name = 'NumbOfDays__c';
        filt.type = String.valueOf(Schema.DisplayType.INTEGER);
        af.filter = filt;
        
        appliedFilters.add(af);
        
        FE_DatatableUtils.processAppliedFilters(appliedFilters);
        
        Test.stopTest();
    }

}