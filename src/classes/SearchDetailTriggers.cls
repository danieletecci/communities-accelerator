public with sharing class SearchDetailTriggers extends TriggersHandler{
    private Boolean hasError = false;

    public SearchDetailTriggers (List<SObject> p_triggerNew, List<SObject> p_triggerOld){
        super(p_triggerNew, p_triggerOld);

        allow_masterLoop_BeforeInsert = true;
        allow_masterLoop_BeforeUpdate = true; 
    }


    //Master loops
    public override void masterLoop_BeforeInsert(SObject recNew) {
        setExternalId((SearchDetail__c)recNew);
        checkSobjectAPIName((SearchDetail__c)recNew);
        checkFieldsAPIName((SearchDetail__c)recNew);
        checkURLParameterField((SearchDetail__c)recNew);
        checkRecordTypeDevName((SearchDetail__c)recNew);
    }
    public override void masterLoop_BeforeUpdate(SObject recNew, SObject recOld) {
        setExternalId((SearchDetail__c)recNew);
        checkSobjectAPIName((SearchDetail__c)recNew);
        checkFieldsAPIName((SearchDetail__c)recNew);
        checkURLParameterField((SearchDetail__c)recNew);
        checkRecordTypeDevName((SearchDetail__c)recNew);
    }

    private void checkSobjectAPIName(SearchDetail__c recNew){
        Boolean exist = false;
        for (Schema.SObjectType sObjectType : Schema.getGlobalDescribe().values() ) {
            String sobjName = String.valueOf(sObjectType);
            if (sobjName.equalsIgnoreCase(recNew.ObjectAPIName__c) ) {
                exist = true;
            }
        }
        if(!exist){
            hasError = true;
            recNew.addError(Label.GlobalSearchWrongSobject);
        }
    }

    private void checkFieldsAPIName(SearchDetail__c recNew){
        if(!hasError){

            List<String>                        fieldsToShow    = recNew.FieldsToShow__c.split(',');
            List<String>                        fieldsToSearch  = recNew.FieldsToSearch__c.split(',');
            Map<String, Schema.SObjectType>     schemaMap       = Schema.getGlobalDescribe();
            Schema.SObjectType                  objectSchema    = schemaMap.get(recNew.ObjectAPIName__c);
            Map<String, Schema.SObjectField>    objectFieldsMap = objectSchema.getDescribe().fields.getMap();
            Set<String>                         objectFields    = objectFieldsMap.keySet();

            for(String field : fieldsToShow){
                if(!objectFields.contains(field.toLowerCase())) {
                    recNew.addError(String.format(Label.GlobalSearchWrongField, new List<String> {field, recNew.ObjectAPIName__c}));
                    hasError = true;
                    return;
                }
            }
            for(String field : fieldsToSearch){
                if(!objectFields.contains(field.toLowerCase())) {
                    recNew.addError(String.format(Label.GlobalSearchWrongField, new List<String> {field, recNew.ObjectAPIName__c}));
                    hasError = true;
                    return;
                }
                if(!objectFieldsMap.get(field).getDescribe().isFilterable()){
                    recNew.addError(String.format(Label.GlobalSearchFieldNotFilterable, new List<String> {field, recNew.ObjectAPIName__c}));
                    hasError = true;
                    return;
                }
            }
        }
    }

    private void checkURLParameterField(SearchDetail__c recNew){
        if(!hasError){

            String                              urlParameterField   = recNew.URLParameterField__c;
            Map<String, Schema.SObjectType>     schemaMap           = Schema.getGlobalDescribe();
            Schema.SObjectType                  objectSchema        = schemaMap.get(recNew.ObjectAPIName__c);
            Map<String, Schema.SObjectField>    objectFieldsMap     = objectSchema.getDescribe().fields.getMap();
            Set<String>                         objectFields        = objectFieldsMap.keySet();

            if(!objectFields.contains(urlParameterField.toLowerCase())) {
                recNew.addError(String.format(Label.GlobalSearchWrongField, new List<String> {urlParameterField, recNew.ObjectAPIName__c}));
                hasError = true;
                return;
            }
        }
    }

    private void checkRecordTypeDevName(SearchDetail__c recNew){
        if(!String.isBlank(recNew.RecordTypeDevName__c) && !hasError){
            Map<String, Schema.SObjectType>     schemaMap   = Schema.getGlobalDescribe();
            Map<String,Schema.RecordTypeInfo>   recordTypes = schemaMap.get(recNew.ObjectAPIName__c).getDescribe().getRecordTypeInfosByDeveloperName();
            if(!recordTypes.containsKey(recNew.RecordTypeDevName__c)){
                    recNew.addError(String.format(Label.GlobalSearchWrongRT, new List<String> {recNew.RecordTypeDevName__c, recNew.ObjectAPIName__c}));
            }
        }
    }

    private void setExternalId(SearchDetail__c recNew){
        if(!canMethod('setExternalId')){return;}

        if(recNew.ExternalID__c == null){
            recNew.ExternalID__c = GeneralUtils.generateExternalId(recNew.Name, recNew.Cluster__c, recNew.getSObjectType().getDescribe().getName());
        }
    }
}