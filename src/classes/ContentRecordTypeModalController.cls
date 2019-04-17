public class ContentRecordTypeModalController {

    @AuraEnabled(cacheable=true)
    public static String getObjectLabel(String sObjectType){
        sObjectType = GeneralUtils.prefix(sObjectType);
        return Schema.getGlobalDescribe().get(sObjectType).getDescribe().getLabel();
    }

    @AuraEnabled(cacheable=true)
    public static List<RecordType> getContentRecordTypes(String sObjectType){
        sObjectType = GeneralUtils.prefix(sObjectType);
        AcceleratorSettings__c acceleratorSettings = [SELECT Id, ContentLandingRecordTypes__c FROM AcceleratorSettings__c];
        List<String> recordTypeNames = acceleratorSettings.ContentLandingRecordTypes__c.split(',');
        return getSortedRecordTypes(sObjectType, recordTypeNames);
    }

    @AuraEnabled(cacheable=true)
    public static List<RecordType> getTemplateRecordTypes(String sObjectType){
        sObjectType = GeneralUtils.prefix(sObjectType);
        AcceleratorMetadata__mdt acceleratorMetadata = [SELECT Id, ContentTemplateRecordTypes__c FROM AcceleratorMetadata__mdt];
        List<String> recordTypeNames = acceleratorMetadata != null ? acceleratorMetadata.ContentTemplateRecordTypes__c.split(',') : new List<String>();
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