public class ContentRecordTypeModalController {

    @AuraEnabled(cacheable=true)
    public static String getObjectLabel(String sObjectType){
        sObjectType = GeneralUtils.prefix(sObjectType);
        return Schema.getGlobalDescribe().get(sObjectType).getDescribe().getLabel();
    }

    @AuraEnabled(cacheable=true)
    public static List<RecordType> getContentRecordTypes(String sObjectType){
        sObjectType = GeneralUtils.prefix(sObjectType);
        CMSContentSettings__c contentSetting = [SELECT Id, ContentLandingRecordTypes__c FROM CMSContentSettings__c];
        List<String> recordTypeNames = contentSetting.ContentLandingRecordTypes__c.split(',');
        return getSortedRecordTypes(sObjectType, recordTypeNames);
    }

    @AuraEnabled(cacheable=true)
    public static List<RecordType> getTemplateRecordTypes(String sObjectType){
        sObjectType = GeneralUtils.prefix(sObjectType);
        CMSContentSettings__c contentSetting = [SELECT Id, ContentTemplateRecordTypes__c FROM CMSContentSettings__c];
        List<String> recordTypeNames = contentSetting != null ? contentSetting.ContentTemplateRecordTypes__c.split(',') : new List<String>();
        return getSortedRecordTypes(sObjectType, recordTypeNames);
    }

    static List<RecordType> getSortedRecordTypes(String sObjectType, List<String> recordTypeNames){
        sObjectType = GeneralUtils.prefix(sObjectType);
        List<RecordType> recordTypesTemp = [SELECT Id, DeveloperName, Name, Description FROM RecordType WHERE SobjectType =: sObjectType AND DeveloperName IN :recordTypeNames];
        RecordType [] recordTypesToReturn = new RecordType [recordTypeNames.size()];
        for(RecordType recordType : recordTypesTemp){
            recordTypesToReturn[recordTypeNames.indexOf(recordType.DeveloperName)] = recordType;
        }
        return recordTypesToReturn;
    }
    
}