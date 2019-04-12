@isTest
public class FE_DatatableControllerTest {
    
    @testSetup
    static void generateCustomSettings(){
        MockupFactory.generateAcceleratorSetting();
        List<Cluster__c> clusterRootList = MockupFactory.createCluster('ClusterRootTest', null, 1, 'ClusterRoot', 'DRC');
        List<Datatable__c> datatableList = MockupFactory.createDatatables('Table Test', 'TableTest', 'Component__c', 1, clusterRootList[0].Id);
    	List<DatatableElement__c> dataElementList = MockupFactory.createDatatableElements('Name', 'DataElementExternalId', 2, datatableList[0].Id);
    }
    
    @isTest
    static void testDoInit(){       
        // Given
		Datatable__c data = [Select ExternalId__c from Datatable__c where ExternalId__c like'TableTest%' Limit 1];
        // When
        Test.startTest();
        String jsonTest = FE_DatatableController.doInit(data.ExternalId__c);
        Test.stopTest();
        // Then
        System.assertNotEquals(jsonTest, null);
    }
    
    @isTest
    static void testGetPage(){     
        // Given
        Datatable__c data = [Select ExternalId__c from Datatable__c where ExternalId__c like'TableTest%' Limit 1];
        
        FE_DatatableController.DatatableWrapper jsonWrapper = new FE_DatatableController.DatatableWrapper();
        jsonWrapper.componentExternalId = data.ExternalId__c;
        jsonWrapper.pagingType = 'Bottom';
        jsonWrapper.numberOfColumns = 3;
        jsonWrapper.recordsPerPage = 2;

        // When
        Test.startTest();        
        String jsonTest = FE_DatatableController.getPage(JSON.serialize(jsonWrapper),1);
        Test.stopTest();
        
        // Then
        System.assertNotEquals(jsonTest, null);
    }
    
    @isTest
    static void testHandleDelete(){       
       // Given
        Datatable__c data = [Select ExternalId__c from Datatable__c where ExternalId__c like'TableTest%' Limit 1];
        String jsonComponentWrapper = FE_DatatableController.doInit(data.ExternalId__c);
        // When
        Test.startTest();
       	List<Id> ids=new List<Id>();
        String jsonTest = FE_DatatableController.handleDelete(jsonComponentWrapper, ids);
        Test.stopTest();
        // Then
        System.assertEquals(jsonTest, '');
    }
    
    @isTest
    static void testhandleFilter(){
       // Given
        Datatable__c data = [Select ExternalId__c from Datatable__c where ExternalId__c like'TableTest%' Limit 1];

        FE_DatatableController.DatatableWrapper jsonWrapper = new FE_DatatableController.DatatableWrapper();
        jsonWrapper.componentExternalId = data.ExternalId__c;
        jsonWrapper.pagingType = 'Bottom';
        jsonWrapper.numberOfColumns = 3;
        jsonWrapper.recordsPerPage = 2;
		
        jsonWrapper.name ='Test';
        jsonWrapper.totalRows = 1;
        FE_DatatableController.DatatableRowWrapper row = new FE_DatatableController.DatatableRowWrapper();
        row.columnName = 'Name column test';
        row.rowValue = 'test value';
        List<FE_DatatableController.DatatableRowWrapper> rowList = new List<FE_DatatableController.DatatableRowWrapper>();
        rowList.add(row);
        jsonWrapper.tableData = new List<Map<String, String>>();
        //jsonWrapper.tableData.add(rowList);
             
        // When
        Test.startTest();
        String jsonTest = FE_DatatableController.handleFilter(JSON.serialize(jsonWrapper));
        Test.stopTest();
        // Then
        System.assertNotEquals(jsonTest, null);
    }

	@isTest
    static void testhandleSort(){ 
	
     // Given
        Datatable__c data = [Select ExternalId__c from Datatable__c where ExternalId__c like'TableTest%' Limit 1];
        
        FE_DatatableController.DatatableWrapper jsonWrapper = new FE_DatatableController.DatatableWrapper();
        jsonWrapper.componentExternalId = data.ExternalId__c;
        jsonWrapper.pagingType = 'Bottom';
        jsonWrapper.numberOfColumns = 3;
        jsonWrapper.recordsPerPage = 2;
        
        // When   
        Test.startTest();
       	
        String jsonTest = FE_DatatableController.handleSort(JSON.serialize(jsonWrapper), 'Name', 'ASC');
        Test.stopTest();
        // Then
        System.assertNotEquals(jsonTest, null);
    }

	@isTest
    static void TestprocessAppliedFilters(){   
        
        //Given
        FE_DatatableController.DatatableFilterFieldWrapper filterFieldWrStr = new FE_DatatableController.DatatableFilterFieldWrapper(); 
        filterFieldWrStr.name='TestFilterField';
        filterFieldWrStr.type='String';
        FE_DatatableController.DatatableFilterWrapper dataFilterWrStr =new FE_DatatableController.DatatableFilterWrapper();
        dataFilterWrStr.filter=filterFieldWrStr;
        dataFilterWrStr.value1 = 'test';
        dataFilterWrStr.value2 = 'table';
        
        FE_DatatableController.DatatableFilterFieldWrapper filterFieldWrInt = new FE_DatatableController.DatatableFilterFieldWrapper(); 
        filterFieldWrInt.name='TestFilterField';
        filterFieldWrInt.type='Integer';    
        FE_DatatableController.DatatableFilterWrapper dataFilterWrInt =new FE_DatatableController.DatatableFilterWrapper();
        dataFilterWrInt.filter=filterFieldWrInt;
        dataFilterWrInt.value1 = '123';
        dataFilterWrInt.value2 = '890';
        FE_DatatableController.DatatableFilterWrapper dataFilterWrIntV1 =new FE_DatatableController.DatatableFilterWrapper();
        dataFilterWrIntV1.filter=filterFieldWrInt;
        dataFilterWrIntV1.value1 = '123';
        dataFilterWrIntV1.value2 = null;  
        FE_DatatableController.DatatableFilterWrapper dataFilterWrIntV2 =new FE_DatatableController.DatatableFilterWrapper();
        dataFilterWrIntV2.filter=filterFieldWrInt;
        dataFilterWrIntV2.value1 = null;
        dataFilterWrIntV2.value2 = '890';
        
        FE_DatatableController.DatatableFilterFieldWrapper filterFieldWrDouble = new FE_DatatableController.DatatableFilterFieldWrapper(); 
        filterFieldWrDouble.name='TestFilterField';
        filterFieldWrDouble.type='Double';
        FE_DatatableController.DatatableFilterWrapper dataFilterWrDouble =new FE_DatatableController.DatatableFilterWrapper();
        dataFilterWrDouble.filter=filterFieldWrDouble;
        dataFilterWrDouble.value1 = null;
        dataFilterWrDouble.value2 = '890.5';

        FE_DatatableController.DatatableFilterFieldWrapper filterFieldWrDate = new FE_DatatableController.DatatableFilterFieldWrapper(); 
        filterFieldWrDate.name='TestFilterField';
        filterFieldWrDate.type='Date';    
        FE_DatatableController.DatatableFilterWrapper dataFilterWrDate =new FE_DatatableController.DatatableFilterWrapper();
        dataFilterWrDate.filter=filterFieldWrDate;
        dataFilterWrDate.value1 = '2019-03-28';
        dataFilterWrDate.value2 = '2019-03-29';
        FE_DatatableController.DatatableFilterWrapper dataFilterWrDateV1 =new FE_DatatableController.DatatableFilterWrapper();
        dataFilterWrDateV1.filter=filterFieldWrDate;
        dataFilterWrDateV1.value1 = null;
        dataFilterWrDateV1.value2 = '2019-03-29';
        FE_DatatableController.DatatableFilterWrapper dataFilterWrDateV2 =new FE_DatatableController.DatatableFilterWrapper();
        dataFilterWrDateV2.filter=filterFieldWrDate;
        dataFilterWrDateV2.value1 = '2019-03-28';
        dataFilterWrDateV2.value2 = null;
        
        List<FE_DatatableController.DatatableFilterWrapper> appliedFilters = new List<FE_DatatableController.DatatableFilterWrapper>();
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
        String result = FE_DatatableUtils.processAppliedFilters(appliedFilters);
        Test.stopTest();
        // Then
        System.assertNotEquals(result, null);
        
    }
    
 	@isTest
    static void TestmapDatatableActionsToWrappers(){ 
        
        //Given
        Datatable__c data = [Select id, ExternalId__c from Datatable__c where ExternalId__c like'TableTest%' Limit 1];
        RecordType recordT = [SELECT id FROM RecordType WHERE SobjectType = 'DatatableAction__c' AND DeveloperName = 'RowAction' LIMIT 1];
        List<DatatableAction__c> actionList = MockupFactory.createDatatableActions('testAction', 'testActionExternalId', 1, data.Id, recordT.Id);

        // When   
        Test.startTest();      	
        List<FE_DatatableController.DatatableActionWrapper> result = FE_DatatableUtils.mapDatatableActionsToWrappers(actionList);
        Test.stopTest();
        // Then
        System.assertNotEquals(result, null); 
    }

 	@isTest
    static void TestmapDatatableDataToWrappers(){ 
        
        //Given
		FE_DatatableController.DatatableElementWrapper dataW = new FE_DatatableController.DatatableElementWrapper();
        dataw.fieldName = 'Name';
        List<FE_DatatableController.DatatableElementWrapper> listDataw= new List<FE_DatatableController.DatatableElementWrapper>();
        listDataw.add(dataw);
        List<SObject> SOlist = new List<SObject>();
        
        // When   
        Test.startTest();
        List<Map<String,String>> result = FE_DatatableUtils.mapDatatableDataToWrappers(SOlist, listDataw);
        Test.stopTest();
        // Then
        System.assertNotEquals(result, null); 
    }    
    
}