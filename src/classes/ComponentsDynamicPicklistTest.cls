@isTest
public class ComponentsDynamicPicklistTest {
   @isTest 
    static void setValuesInpicklistAdvanceContent(){
        //Given
        List<Component__c> componentList = MockupFactory.createComponent('Advance Content',2);
                    
        //When
        Test.startTest();
        AdvanceContentDynamicPicklist picklistValues = new AdvanceContentDynamicPicklist();
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
        BannerDynamicPicklist picklistValues = new BannerDynamicPicklist();
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
        ClusterSelectorDynamicPicklist picklistValues = new ClusterSelectorDynamicPicklist();
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
        EventDynamicPicklist picklistValues = new EventDynamicPicklist();
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
        EventDetailDynamicPicklist picklistValues = new EventDetailDynamicPicklist();
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
        EventRelatedDynamicPicklist picklistValues = new EventRelatedDynamicPicklist();
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
        FAQDynamicPicklist picklistValues = new FAQDynamicPicklist();
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
        LanguageSelectorDynamicPicklist picklistValues = new LanguageSelectorDynamicPicklist();
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
        MenuDynamicPicklist picklistValues = new MenuDynamicPicklist();
        picklistValues.getDefaultValue();
        picklistValues.getValues();
        Test.stopTest();        
        
        //Then
        System.assertEquals(true, picklistValues.getValues().get(1).getLabel().equals(componentList[0].Name));
        System.assertEquals(true, picklistValues.getValues().get(2).getLabel().equals(componentList[1].Name));
    
    }
    
    
    
    @isTest 
    static void setValuesInpicklistArticle(){
        //Given
        List<Component__c> componentList = MockupFactory.createComponent('News',2);        
                    
        //When
        Test.startTest();
        ArticleDynamicPicklist picklistValues = new ArticleDynamicPicklist();
        picklistValues.getDefaultValue();
        picklistValues.getValues();
        Test.stopTest();        
        
        //Then
        System.assertEquals(true, picklistValues.getValues().get(1).getLabel().equals(componentList[0].Name));
        System.assertEquals(true, picklistValues.getValues().get(2).getLabel().equals(componentList[1].Name));
    
    }

    @isTest 
    static void setValuesInpicklistArticleDetail(){
        //Given
        List<Component__c> componentList = MockupFactory.createComponent('News Detail',2);
        
                    
        //When
        Test.startTest();
        ArticleDetailDynamicPicklist picklistValues = new ArticleDetailDynamicPicklist();
        picklistValues.getDefaultValue();
        picklistValues.getValues();
        Test.stopTest();
        
        
        //Then
        System.assertEquals(true, picklistValues.getValues().get(1).getLabel().equals(componentList[0].Name));
        System.assertEquals(true, picklistValues.getValues().get(2).getLabel().equals(componentList[1].Name));
    
    }
    
    @isTest 
    static void setValuesInpicklistRelatedArticle(){
        //Given
        List<Component__c> componentList = MockupFactory.createComponent('Related News',2);
                            
        //When
        Test.startTest();
        ArticleRelatedDynamicPicklist picklistValues = new ArticleRelatedDynamicPicklist();
        picklistValues.getDefaultValue();
        picklistValues.getValues();
        Test.stopTest();
                
        //Then
        System.assertEquals(true, picklistValues.getValues().get(1).getLabel().equals(componentList[0].Name));
        System.assertEquals(true, picklistValues.getValues().get(2).getLabel().equals(componentList[1].Name));
        
    }

}