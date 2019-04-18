@isTest
public with sharing class SearchSettingTriggersTest {
    
    @testSetup
    static void setup(){
        SearchSetting__c rll = createSearchDetail('Banner','banner',GeneralUtils.prefix('[CMS]Content__c'),'Name',GeneralUtils.prefix('Name,[CMS]Description__c'),'Banner');
        update rll;
    }

    @isTest
    static void updateSearchDetail(){
        SearchSetting__c rll = [SELECT Id,Name,ExternalId__c,ObjectAPIName__c,FieldsToSearch__c,FieldsToShow__c,RecordTypeDevName__c 
                                    FROM SearchSetting__c 
                                    LIMIT 1];
        rll.FieldsToShow__c = 'Name';
        update rll;
    }

    @isTest
    static void updateWrongSobject(){
        SearchSetting__c rll = [SELECT Id,Name,ExternalId__c,ObjectAPIName__c,FieldsToSearch__c,FieldsToShow__c,RecordTypeDevName__c 
                                    FROM SearchSetting__c 
                                    LIMIT 1];
        rll.ObjectAPIName__c = 'NoExistingSobject';
        try{
            update rll;
        } catch(Exception e){
            Boolean expectedExceptionThrown =  (e.getMessage().contains(Label.GlobalSearchWrongSobject)) ? true : false;
            System.AssertEquals(expectedExceptionThrown, true);
        }
    }

    @isTest
    static void updateWrongField(){
        SearchSetting__c rll = [SELECT Id,Name,ExternalId__c,ObjectAPIName__c,FieldsToSearch__c,FieldsToShow__c,RecordTypeDevName__c 
                                    FROM SearchSetting__c 
                                    LIMIT 1];

        rll.FieldsToSearch__c = 'NoExistingField';
        rll.FieldsToShow__c = 'Name';
        try{
            update rll;
        } catch(Exception e){
            Boolean expectedExceptionThrown =  (e.getMessage().contains(String.format(Label.GlobalSearchWrongField, new List<String> {'NoExistingField', rll.ObjectAPIName__c}))) ? true : false;
            System.AssertEquals(expectedExceptionThrown, true);
        }

        rll.FieldsToSearch__c = 'Name';
        rll.FieldsToShow__c = 'NoExistingField';
        try{
            update rll;
        } catch(Exception e){
            Boolean expectedExceptionThrown =  (e.getMessage().contains(String.format(Label.GlobalSearchWrongField, new List<String> {'NoExistingField', rll.ObjectAPIName__c}))) ? true : false;
            System.AssertEquals(expectedExceptionThrown, true);
        }

        rll.FieldsToSearch__c = GeneralUtils.prefix('Name,[CMS]Description__c');
        rll.FieldsToShow__c = 'Name';
        try{
            update rll;
        } catch(Exception e){
            Boolean expectedExceptionThrown =  (e.getMessage().contains(String.format(Label.GlobalSearchFieldNotFilterable, new List<String> {GeneralUtils.prefix('[CMS]Description__c'), rll.ObjectAPIName__c}))) ? true : false;
            System.AssertEquals(expectedExceptionThrown, true);
        }


    }

    @isTest
    static void updateWrongRT(){
        SearchSetting__c rll = [SELECT Id,Name,ExternalId__c,ObjectAPIName__c,FieldsToSearch__c,FieldsToShow__c,RecordTypeDevName__c 
                                    FROM SearchSetting__c 
                                    LIMIT 1];

        rll.RecordTypeDevName__c = 'NoExistingRT';
        try{
            update rll;
        } catch(Exception e){
            Boolean expectedExceptionThrown =  (e.getMessage().contains(String.format(Label.GlobalSearchWrongRT, new List<String> {'NoExistingRT', rll.ObjectAPIName__c}))) ? true : false;
            System.AssertEquals(expectedExceptionThrown, true);
        }
    }
    
     @isTest
    static void updateUrlParameterField(){
        SearchSetting__c rll = [SELECT Id,Name,ExternalId__c,ObjectAPIName__c,FieldsToSearch__c,FieldsToShow__c,RecordTypeDevName__c 
                                    FROM SearchSetting__c 
                                    LIMIT 1];

        rll.URLParameterField__c = 'NoExistingField';
        try{
            update rll;
        } catch(Exception e){
            Boolean expectedExceptionThrown =  (e.getMessage().contains(String.format(Label.GlobalSearchWrongField, new List<String> {'NoExistingField', rll.ObjectAPIName__c}))) ? true : false;
            System.AssertEquals(expectedExceptionThrown, true);
        }
    }


    static SearchSetting__c createSearchDetail(String name, String sectionApiName, String objectApiName, String fieldsToSearch, String fieldsToShow, String recordTypeDevName){
        SearchSetting__c rll = new SearchSetting__c (
                                                            Name                    = name,
                                                            ObjectAPIName__c        = objectApiName,
                                                            FieldsToSearch__c       = fieldsToSearch,
                                                            FieldsToShow__c         = fieldsToShow,
                                                            RecordTypeDevName__c    = recordTypeDevName
        );
        insert rll;
        return rll;
    }
}