@isTest
public class CG_DynamicPicklistComponentsTest {
    
    @testSetup
    public static void testSetup() {
        MockupFactory.generateAcceleratorSetting();
        List<Cluster__c> clusters = MockupFactory.createCluster('DummyCluster', null, 1, 'ClusterRoot', 'DummyCluster');
        
        List<Datatable__c>  datatables = MockupFactory.createDatatables('DatatableDummy', 'DatatableDummy', 'Case', 1, clusters.get(0).Id);		            
    }
    
    @isTest 
	static void setValuesInpicklist(){
	//When
	List<Component__c> componentList = MockupFactory.createComponent('Banner',2);

	//Then
	Test.startTest();
	CG_DynamicPicklistComponent picklistValues = new CG_DynamicPicklistComponent();
	picklistValues.getDefaultValue();
	picklistValues.getValues();
	Test.stopTest();
	
	}
    
    @isTest
    public static void getDefaultValueDatatableTest01() {
        Test.startTest();
        FE_DynamicPicklistDatatable dp = new FE_DynamicPicklistDatatable();
        
        System.debug(dp.getDefaultValue());
        
        Test.stopTest();
    }
    
    @isTest
    public static void getValuesDatatableTest01() {
        Test.startTest();
        FE_DynamicPicklistDatatable dp = new FE_DynamicPicklistDatatable();
        
        System.debug(dp.getValues());
        
        Test.stopTest();
    }

   @isTest 
    static void setValuesInpicklistAdvanceContent(){
    //Given
    List<Component__c> componentList = MockupFactory.createComponent('Advance Content',2);
    
    //When
    Test.startTest();
    CG_DynamicPicklistAdvanceContent picklistValues = new CG_DynamicPicklistAdvanceContent();
    picklistValues.getDefaultValue();
    picklistValues.getValues();
    Test.stopTest();
    
   

    //Then
    System.assertEquals(true, picklistValues.getValues().get(1).getLabel().equals(componentList[0].Name));
    System.assertEquals(true, picklistValues.getValues().get(2).getLabel().equals(componentList[1].Name));
    }
    
    @isTest 
    static void setValuesInpicklistBanner(){
    //Given
    List<Component__c> componentList = MockupFactory.createComponent('Banner',2);
    
                
    //When
    Test.startTest();
    CG_DynamicPicklistBanner picklistValues = new CG_DynamicPicklistBanner();
    picklistValues.getDefaultValue();
    picklistValues.getValues();
    Test.stopTest();
    
    
    //Then
    System.assertEquals(true, picklistValues.getValues().get(1).getLabel().equals(componentList[0].Name));
    System.assertEquals(true, picklistValues.getValues().get(2).getLabel().equals(componentList[1].Name));
    
    }
    
    
    
    
    @isTest 
    static void setValuesInpicklistBrandDetail(){
    //Given
    List<Component__c> componentList = MockupFactory.createComponent('Brand Detail',2);
    
                
    //When
    Test.startTest();
    CG_DynamicPicklistBrandDetail picklistValues = new CG_DynamicPicklistBrandDetail();
    picklistValues.getDefaultValue();
    picklistValues.getValues();
    Test.stopTest();
    
    
    //Then
    System.assertEquals(true, picklistValues.getValues().get(1).getLabel().equals(componentList[0].Name));
    System.assertEquals(true, picklistValues.getValues().get(2).getLabel().equals(componentList[1].Name));
    
    }
    
    @isTest 
    static void setValuesInpicklistClusterSelector(){
    //Given
    List<Component__c> componentList = MockupFactory.createComponent('Cluster Selector',2);
    
                
    //When
    Test.startTest();
    CG_DynamicPicklistClusterSelector picklistValues = new CG_DynamicPicklistClusterSelector();
    picklistValues.getDefaultValue();
    picklistValues.getValues();
    Test.stopTest();
    
    
    //Then
    System.assertEquals(true, picklistValues.getValues().get(1).getLabel().equals(componentList[0].Name));
    System.assertEquals(true, picklistValues.getValues().get(2).getLabel().equals(componentList[1].Name));
    
    }
    
    
    @isTest 
    static void setValuesInpicklistEvent(){
    //Given
    List<Component__c> componentList = MockupFactory.createComponent('Event',2);
    
                
    //When
    Test.startTest();
    CG_DynamicPicklistEvent picklistValues = new CG_DynamicPicklistEvent();
    picklistValues.getDefaultValue();
    picklistValues.getValues();
    Test.stopTest();
    
    
    //Then
    System.assertEquals(true, picklistValues.getValues().get(1).getLabel().equals(componentList[0].Name));
    System.assertEquals(true, picklistValues.getValues().get(2).getLabel().equals(componentList[1].Name));
    
    }
    
    @isTest 
    static void setValuesInpicklistEventsDetail(){
    //Given
    List<Component__c> componentList = MockupFactory.createComponent('Events Detail',2);
    
                
    //When
    Test.startTest();
    CG_DynamicPicklistEventsDetail picklistValues = new CG_DynamicPicklistEventsDetail();
    picklistValues.getDefaultValue();
    picklistValues.getValues();
    Test.stopTest();
    
    
    //Then
    System.assertEquals(true, picklistValues.getValues().get(1).getLabel().equals(componentList[0].Name));
    System.assertEquals(true, picklistValues.getValues().get(2).getLabel().equals(componentList[1].Name));
    
    }


    @isTest 
    static void setValuesInpicklistRelatedEvents(){
    //Given
    List<Component__c> componentList = MockupFactory.createComponent('Related Events',2);
    
                
    //When
    Test.startTest();
    CG_DynamicPicklistEventsRelated picklistValues = new CG_DynamicPicklistEventsRelated();
    picklistValues.getDefaultValue();
    picklistValues.getValues();
    Test.stopTest();
    
    
    //Then
    System.assertEquals(true, picklistValues.getValues().get(1).getLabel().equals(componentList[0].Name));
    System.assertEquals(true, picklistValues.getValues().get(2).getLabel().equals(componentList[1].Name));
    
    }
    
    
    @isTest 
    static void setValuesInpicklistFAQ(){
    //Given
    List<Component__c> componentList = MockupFactory.createComponent('FAQ',2);
    
                
    //When
    Test.startTest();
    CG_DynamicPicklistFAQ picklistValues = new CG_DynamicPicklistFAQ();
    picklistValues.getDefaultValue();
    picklistValues.getValues();
    Test.stopTest();
    
    
    //Then
    System.assertEquals(true, picklistValues.getValues().get(1).getLabel().equals(componentList[0].Name));
    System.assertEquals(true, picklistValues.getValues().get(2).getLabel().equals(componentList[1].Name));
    }
    
    
    @isTest 
    static void setValuesInpicklistLanguageSelector(){
    //Given
    List<Component__c> componentList = MockupFactory.createComponent('Language Selector',2);
    
                
    //When
    Test.startTest();
    CG_DynamicPicklistLanguageSelector picklistValues = new CG_DynamicPicklistLanguageSelector();
    picklistValues.getDefaultValue();
    picklistValues.getValues();
    Test.stopTest();
    
    
    //Then
    System.assertEquals(true, picklistValues.getValues().get(1).getLabel().equals(componentList[0].Name));
    System.assertEquals(true, picklistValues.getValues().get(2).getLabel().equals(componentList[1].Name));
    
    }


    @isTest 
    static void setValuesInpicklistNavigation(){
    //Given
    List<Component__c> componentList = MockupFactory.createComponent('Menu',2);
    
                
    //When
    Test.startTest();
    CG_DynamicPicklistMenu picklistValues = new CG_DynamicPicklistMenu();
    picklistValues.getDefaultValue();
    picklistValues.getValues();
    Test.stopTest();
    
    
    //Then
    System.assertEquals(true, picklistValues.getValues().get(1).getLabel().equals(componentList[0].Name));
    System.assertEquals(true, picklistValues.getValues().get(2).getLabel().equals(componentList[1].Name));
    
    }
    
    
    
    @isTest 
    static void setValuesInpicklistNews(){
    //Given
    List<Component__c> componentList = MockupFactory.createComponent('News',2);
    
                
    //When
    Test.startTest();
    CG_DynamicPicklistNews picklistValues = new CG_DynamicPicklistNews();
    picklistValues.getDefaultValue();
    picklistValues.getValues();
    Test.stopTest();
    
    
    //Then
    System.assertEquals(true, picklistValues.getValues().get(1).getLabel().equals(componentList[0].Name));
    System.assertEquals(true, picklistValues.getValues().get(2).getLabel().equals(componentList[1].Name));
    
    }

    @isTest 
    static void setValuesInpicklistNewsDetail(){
    //Given
    List<Component__c> componentList = MockupFactory.createComponent('News Detail',2);
    
                
    //When
    Test.startTest();
    CG_DynamicPicklistNewsDetail picklistValues = new CG_DynamicPicklistNewsDetail();
    picklistValues.getDefaultValue();
    picklistValues.getValues();
    Test.stopTest();
    
    
    //Then
    System.assertEquals(true, picklistValues.getValues().get(1).getLabel().equals(componentList[0].Name));
    System.assertEquals(true, picklistValues.getValues().get(2).getLabel().equals(componentList[1].Name));
    
    }
    
    @isTest 
    static void setValuesInpicklistRelatedNews(){
    //Given
    List<Component__c> componentList = MockupFactory.createComponent('Related News',2);
    
                
    //When
    Test.startTest();
    CG_DynamicPicklistNewsRelated picklistValues = new CG_DynamicPicklistNewsRelated();
    picklistValues.getDefaultValue();
    picklistValues.getValues();
    Test.stopTest();
    
    
    //Then
    System.assertEquals(true, picklistValues.getValues().get(1).getLabel().equals(componentList[0].Name));
    System.assertEquals(true, picklistValues.getValues().get(2).getLabel().equals(componentList[1].Name));
    
    }

}