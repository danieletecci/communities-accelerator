public with sharing class RecordListLayoutTriggers extends TriggersHandler{
	private Boolean hasError = false;

	public RecordListLayoutTriggers(List<SObject> p_triggerNew, List<SObject> p_triggerOld){
        super(p_triggerNew, p_triggerOld);

		allow_masterLoop_BeforeInsert = true;
		allow_masterLoop_BeforeUpdate = true; 
    }


    //Master loops
    public override void masterLoop_BeforeInsert(SObject recNew) {
        setExternalId((RecordListLayout__c)recNew);
    	checkSobjectAPIName((RecordListLayout__c)recNew);
    	checkFieldsAPIName((RecordListLayout__c)recNew);
    	checkRecordTypeDevName((RecordListLayout__c)recNew);
    }
    public override void masterLoop_BeforeUpdate(SObject recNew, SObject recOld) {
        setExternalId((RecordListLayout__c)recNew);
    	checkSobjectAPIName((RecordListLayout__c)recNew);
    	checkFieldsAPIName((RecordListLayout__c)recNew);
    	checkRecordTypeDevName((RecordListLayout__c)recNew);
    }

    private void checkSobjectAPIName(RecordListLayout__c recNew){
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

    private void checkFieldsAPIName(RecordListLayout__c recNew){
    	if(!hasError){

	    	List<String> 						fieldsToShow 	= recNew.FieldsToShow__c.split(',');
	    	List<String> 						fieldsToSearch 	= recNew.FieldsToSearch__c.split(',');
	    	Map<String, Schema.SObjectType> 	schemaMap 		= Schema.getGlobalDescribe();
			Schema.SObjectType 					objectSchema 	= schemaMap.get(recNew.ObjectAPIName__c);
			Map<String, Schema.SObjectField>	objectFieldsMap = objectSchema.getDescribe().fields.getMap();
			Set<String> 						objectFields 	= objectFieldsMap.keySet();

			for(String field : fieldsToShow){
				if(!objectFields.contains(field.toLowerCase())) {
					recNew.addError(String.format(Label.GlobalSearchWrongField, new List<String> {field, recNew.ObjectAPIName__c}));
					return;
				}
			}
			for(String field : fieldsToSearch){
				if(!objectFields.contains(field.toLowerCase())) {
					recNew.addError(String.format(Label.GlobalSearchWrongField, new List<String> {field, recNew.ObjectAPIName__c}));
					return;
				}
				if(!objectFieldsMap.get(field).getDescribe().isFilterable()){
					recNew.addError(String.format(Label.GlobalSearchFieldNotFilterable, new List<String> {field, recNew.ObjectAPIName__c}));
					return;
				}
			}
		}
    }

    private void checkRecordTypeDevName(RecordListLayout__c recNew){
    	if(!String.isBlank(recNew.RecordTypeDevName__c) && !hasError){
	        Map<String, Schema.SObjectType> 	schemaMap 	= Schema.getGlobalDescribe();
			Map<String,Schema.RecordTypeInfo> 	recordTypes	= schemaMap.get(recNew.ObjectAPIName__c).getDescribe().getRecordTypeInfosByDeveloperName();
			if(!recordTypes.containsKey(recNew.RecordTypeDevName__c)){
					recNew.addError(String.format(Label.GlobalSearchWrongRT, new List<String> {recNew.RecordTypeDevName__c, recNew.ObjectAPIName__c}));
			}
		}
    }

    private void setExternalId(RecordListLayout__c recNew){
        if(!canMethod('setExternalId')){return;}

        if(recNew.ExternalID__c == null){
            recNew.ExternalID__c = GeneralUtils.generateExternalId(recNew.Name, recNew.Cluster__c, recNew.getSObjectType().getDescribe().getName());
        }
    }
}