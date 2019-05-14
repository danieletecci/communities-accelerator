@isTest
public class DatatableControllerTest {
    
    @testSetup
    static void generateCustomSettings(){
        MockupFactory.generateAcceleratorSetting();
        List<Cluster__c> clusterRootList = MockupFactory.createCluster('ClusterRootTest', null, 1, 'ClusterRoot', 'DRC');
        List<Datatable__c> datatableList = MockupFactory.createDatatables('Table Test', 'TableTest', GeneralUtils.prefix('[CMS]Component__c'), 1, clusterRootList[0].Id);
        List<DatatableElement__c> dataElementList = MockupFactory.createDatatableElements('Name', 'DataElementExternalId', 2, datatableList[0].Id);
    }
    
    @isTest
    static void testDoInit(){       
        // Given
        Datatable__c data = [Select ExternalId__c from Datatable__c where ExternalId__c like'TableTest%' Limit 1];
        // When
        Test.startTest();
        String jsonTest = DatatableController.doInit(data.ExternalId__c,null,null);
        Test.stopTest();
        // Then
        System.assertNotEquals(jsonTest, null);
    }
    
    @isTest
    static void testGetPage(){     
        // Given
        Datatable__c data = [Select ExternalId__c from Datatable__c where ExternalId__c like'TableTest%' Limit 1];
        
        DatatableController.DatatableWrapper jsonWrapper = new DatatableController.DatatableWrapper();
        jsonWrapper.componentExternalId = data.ExternalId__c;
        jsonWrapper.pagingType = 'Bottom';
        jsonWrapper.numberOfColumns = 3;
        jsonWrapper.recordsPerPage = 2;

        // When
        Test.startTest();        
        String jsonTest = DatatableController.getPage(JSON.serialize(jsonWrapper),1);
        Test.stopTest();
        
        // Then
        System.assertNotEquals(jsonTest, null);
    }
    
    @isTest
    static void testHandleDelete(){       
       // Given
        Datatable__c data = [Select ExternalId__c from Datatable__c where ExternalId__c like'TableTest%' Limit 1];
        String jsonComponentWrapper = DatatableController.doInit(data.ExternalId__c,null,null);
        // When
        Test.startTest();
        List<Id> ids=new List<Id>();
        String jsonTest = DatatableController.handleDelete(jsonComponentWrapper, ids);
        Test.stopTest();
        // Then
        System.assertEquals(jsonTest, '');
    }
    
    @isTest
    static void testhandleFilter(){
       // Given
        Datatable__c data = [Select ExternalId__c from Datatable__c where ExternalId__c like'TableTest%' Limit 1];

        DatatableController.DatatableWrapper jsonWrapper = new DatatableController.DatatableWrapper();
        jsonWrapper.componentExternalId = data.ExternalId__c;
        jsonWrapper.pagingType = 'Bottom';
        jsonWrapper.numberOfColumns = 3;
        jsonWrapper.recordsPerPage = 2;
        
        jsonWrapper.name ='Test';
        jsonWrapper.totalRows = 1;
        DatatableController.DatatableRowWrapper row = new DatatableController.DatatableRowWrapper();
        row.columnName = 'Name column test';
        row.rowValue = 'test value';
        List<DatatableController.DatatableRowWrapper> rowList = new List<DatatableController.DatatableRowWrapper>();
        rowList.add(row);
        jsonWrapper.tableData = new List<Map<String, String>>();
        //jsonWrapper.tableData.add(rowList);
             
        // When
        Test.startTest();
        String jsonTest = DatatableController.handleFilter(JSON.serialize(jsonWrapper));
        Test.stopTest();
        // Then
        System.assertNotEquals(jsonTest, null);
    }

    @isTest
    static void testhandleSort(){ 
    
     // Given
        Datatable__c data = [Select ExternalId__c from Datatable__c where ExternalId__c like'TableTest%' Limit 1];
        
        DatatableController.DatatableWrapper jsonWrapper = new DatatableController.DatatableWrapper();
        jsonWrapper.componentExternalId = data.ExternalId__c;
        jsonWrapper.pagingType = 'Bottom';
        jsonWrapper.numberOfColumns = 3;
        jsonWrapper.recordsPerPage = 2;
        
        // When   
        Test.startTest();
        
        String jsonTest = DatatableController.handleSort(JSON.serialize(jsonWrapper), 'Name', 'ASC');
        Test.stopTest();
        // Then
        System.assertNotEquals(jsonTest, null);
    }

    @isTest
    static void TestprocessAppliedFilters(){   
        
        //Given
        DatatableController.DatatableFilterFieldWrapper filterFieldWrStr = new DatatableController.DatatableFilterFieldWrapper(); 
        filterFieldWrStr.name='TestFilterField';
        filterFieldWrStr.type='String';
        DatatableController.DatatableFilterWrapper dataFilterWrStr =new DatatableController.DatatableFilterWrapper();
        dataFilterWrStr.filter=filterFieldWrStr;
        dataFilterWrStr.value1 = 'test';
        dataFilterWrStr.value2 = 'table';
        
        DatatableController.DatatableFilterFieldWrapper filterFieldWrInt = new DatatableController.DatatableFilterFieldWrapper(); 
        filterFieldWrInt.name='TestFilterField';
        filterFieldWrInt.type='Integer';    
        DatatableController.DatatableFilterWrapper dataFilterWrInt =new DatatableController.DatatableFilterWrapper();
        dataFilterWrInt.filter=filterFieldWrInt;
        dataFilterWrInt.value1 = '123';
        dataFilterWrInt.value2 = '890';
        DatatableController.DatatableFilterWrapper dataFilterWrIntV1 =new DatatableController.DatatableFilterWrapper();
        dataFilterWrIntV1.filter=filterFieldWrInt;
        dataFilterWrIntV1.value1 = '123';
        dataFilterWrIntV1.value2 = null;  
        DatatableController.DatatableFilterWrapper dataFilterWrIntV2 =new DatatableController.DatatableFilterWrapper();
        dataFilterWrIntV2.filter=filterFieldWrInt;
        dataFilterWrIntV2.value1 = null;
        dataFilterWrIntV2.value2 = '890';
        
        DatatableController.DatatableFilterFieldWrapper filterFieldWrDouble = new DatatableController.DatatableFilterFieldWrapper(); 
        filterFieldWrDouble.name='TestFilterField';
        filterFieldWrDouble.type='Double';
        DatatableController.DatatableFilterWrapper dataFilterWrDouble =new DatatableController.DatatableFilterWrapper();
        dataFilterWrDouble.filter=filterFieldWrDouble;
        dataFilterWrDouble.value1 = null;
        dataFilterWrDouble.value2 = '890.5';

        DatatableController.DatatableFilterFieldWrapper filterFieldWrDate = new DatatableController.DatatableFilterFieldWrapper(); 
        filterFieldWrDate.name='TestFilterField';
        filterFieldWrDate.type='Date';    
        DatatableController.DatatableFilterWrapper dataFilterWrDate =new DatatableController.DatatableFilterWrapper();
        dataFilterWrDate.filter=filterFieldWrDate;
        dataFilterWrDate.value1 = '2019-03-28';
        dataFilterWrDate.value2 = '2019-03-29';
        DatatableController.DatatableFilterWrapper dataFilterWrDateV1 =new DatatableController.DatatableFilterWrapper();
        dataFilterWrDateV1.filter=filterFieldWrDate;
        dataFilterWrDateV1.value1 = null;
        dataFilterWrDateV1.value2 = '2019-03-29';
        DatatableController.DatatableFilterWrapper dataFilterWrDateV2 =new DatatableController.DatatableFilterWrapper();
        dataFilterWrDateV2.filter=filterFieldWrDate;
        dataFilterWrDateV2.value1 = '2019-03-28';
        dataFilterWrDateV2.value2 = null;
        
        List<DatatableController.DatatableFilterWrapper> appliedFilters = new List<DatatableController.DatatableFilterWrapper>();
        appliedFilters.add(dataFilterWrStr);
        appliedFilters.add(dataFilterWrInt);
        appliedFilters.add(dataFilterWrIntV1);
        appliedFilters.add(dataFilterWrIntV2);
        appliedFilters.add(dataFilterWrDouble);
        appliedFilters.add(dataFilterWrDate);
        appliedFilters.add(dataFilterWrDateV1);
        appliedFilters.add(dataFilterWrDateV2);
          
        // When   
        Test.startTest();       
        String result = DatatableUtils.processAppliedFilters(appliedFilters);
        Test.stopTest();
        // Then
        System.assertNotEquals(result, null);
        
    }
    
    @isTest
    static void TestmapDatatableActionsToWrappers(){ 
        
        //Given
        Datatable__c data = [Select id, ExternalId__c from Datatable__c where ExternalId__c like'TableTest%' Limit 1];
        RecordType recordT = [SELECT id FROM RecordType WHERE SobjectType =: GeneralUtils.prefix('[CMS]DatatableAction__c') AND DeveloperName = 'RowAction' LIMIT 1];
        List<DatatableAction__c> actionList = MockupFactory.createDatatableActions('testAction', 'testActionExternalId', 1, data.Id, recordT.Id);

        // When   
        Test.startTest();       
        List<DatatableController.DatatableActionWrapper> result = DatatableUtils.mapDatatableActionsToWrappers(actionList);
        Test.stopTest();
        // Then
        System.assertNotEquals(result, null); 
    }

    @isTest
    static void TestmapDatatableDataToWrappers(){ 
        
        //Given
        DatatableController.DatatableElementWrapper dataW = new DatatableController.DatatableElementWrapper();
        dataw.fieldName = 'Name';
        List<DatatableController.DatatableElementWrapper> listDataw= new List<DatatableController.DatatableElementWrapper>();
        listDataw.add(dataw);
        List<SObject> SOlist = new List<SObject>();
        
        // When   
        Test.startTest();
        List<Map<String,String>> result = DatatableUtils.mapDatatableDataToWrappers(SOlist, listDataw);
        Test.stopTest();
        // Then
        System.assertNotEquals(result, null); 
    }    
    
}