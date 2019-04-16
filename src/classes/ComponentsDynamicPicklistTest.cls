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
        List<Component__c> componentList = MockupFactory.createComponent('Event Detail',2);
                            
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
    static void setValuesInpicklistEventsRelated(){
        //Given
        List<Component__c> componentList = MockupFactory.createComponent('EventsRelated',2);        
                    
        //When
        Test.startTest();
        EventsRelatedDynamicPicklist picklistValues = new EventsRelatedDynamicPicklist();
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
        List<Component__c> componentList = MockupFactory.createComponent('Article',2);        
                    
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
        List<Component__c> componentList = MockupFactory.createComponent('Article Detail',2);
        
                    
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
    static void setValuesInpicklistArticlesRelated(){
        //Given

        List<Component__c> componentList = MockupFactory.createComponent('ArticlesRelated',2);
                            
        //When
        Test.startTest();
        ArticlesRelatedDynamicPicklist picklistValues = new ArticlesRelatedDynamicPicklist();
        picklistValues.getDefaultValue();
        picklistValues.getValues();
        Test.stopTest();
                
        //Then
        System.assertEquals(true, picklistValues.getValues().get(1).getLabel().equals(componentList[0].Name));
        System.assertEquals(true, picklistValues.getValues().get(2).getLabel().equals(componentList[1].Name));
        
    }

}