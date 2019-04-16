public with sharing class TranslationController {
    
	public class RecordsWrapper{
		@auraEnabled public String defaultLanguage;
		@auraEnabled public List<Couple> language;
		@auraEnabled public List<Couple> dataObject;
		@auraEnabled public String response;
		public RecordsWrapper(){
			this.language = new List<Couple>();
			this.dataObject = new List<Couple>();
		}
	}

	public class Couple{
		@auraEnabled public String value;
		@auraEnabled public String label;
		@auraEnabled public String typeF;		
		@auraEnabled public String name;
		@auraEnabled public String idCouple;	
		
		public Couple(String value, String label, String typeF, String name){
			this.value = value;
			this.label = label;
			this.typeF = typeF;
			this.name = name;
		}
	}

	private static String getLookupObjectName(String parentLookupName, String objectName){
		Schema.DescribeFieldResult f = Schema.getGlobalDescribe()
		    .get(objectName)
		    .getDescribe()
		    .fields
		    .getMap()
		    .get(parentLookupName)
		    .getDescribe();

		for(Schema.SObjectType reference : f.getReferenceTo()) {
		    return reference.getDescribe().getName();
		}
		return null;
	}
	
	@auraEnabled
	public static RecordsWrapper getLanguages(String parentLookupName, String fieldSet, String recordId){
		RecordsWrapper rw = new RecordsWrapper();		
		List<String> langs= new List<String>();
		SObject content = Database.query('SELECT id, Cluster__r.DefaultLanguage__c, Cluster__r.OtherLanguages__c  FROM ' + getLookupObjectName(parentLookupName, 'Translation__c') + ' WHERE id=: recordId');
		System.debug('Query: ' + 'SELECT id, Cluster__r.DefaultLanguage__c, Cluster__r.OtherLanguages__c  FROM ' + getLookupObjectName(parentLookupName, 'Translation__c') + ' WHERE id=: recordId');
		System.debug('Object: ' + JSON.serialize(content));
		//Content__c content = [SELECT id, Cluster__r.DefaultLanguage__c, Cluster__r.OtherLanguages__c  FROM Content__c where id=: recordId];
		langs.add((String)content.getSobject('Cluster__r').get('DefaultLanguage__c'));
		if(content.getSobject('Cluster__r').get('OtherLanguages__c')!=null){
			String[] tmpString = ((String) content.getSobject('Cluster__r').get('OtherLanguages__c')).split(';');
			langs.addAll(tmpString);
		}	

		Schema.DescribeSObjectResult sobjectDescribe = Schema.getGlobalDescribe().get('Translation__c').getDescribe();
		for (Schema.PicklistEntry lan : sobjectDescribe.fields.getMap().get('LanguageCode__c').getDescribe().getPickListValues()){
			if(langs.contains(lan.getValue()) && lan.isActive()){	
				rw.language.add(new Couple(lan.getValue(), lan.getLabel(), '', ''));
			}
			
		}

		if(GeneralUtils.isSafeObject(parentLookupName, true)) {
			Map<String,Schema.SObjectField> sobjectDescribeMap = Schema.getGlobalDescribe().get(parentLookupName).getDescribe().fields.getMap();
			List<String> fieldNameList = fieldSet.deleteWhitespace().split(',');
			
			for(String fieldName : fieldNameList){
				if(GeneralUtils.isSafeField(parentLookupName, fieldName, true)){
					Schema.DescribeFieldResult fieldDescribe = sobjectDescribeMap.get(fieldName).getDescribe();
					String typeField;

					if (fieldDescribe.getType() == Schema.DisplayType.TEXTAREA) {
					    if (!fieldDescribe.isHtmlFormatted()) {
					        typeField = 'TextArea';
					    } else if (fieldDescribe.isHtmlFormatted()) {
					        typeField = 'TextAreaRich';
					    }
					} else if (fieldDescribe.getType() == Schema.DisplayType.STRING) {
						typeField = 'Text';
					} else if (fieldDescribe.getType() == Schema.DisplayType.EMAIL) {
						typeField = 'Email';
					} else if (fieldDescribe.getType() == Schema.DisplayType.URL) {
						typeField = String.valueOf(fieldDescribe.getType());
					}
					
					rw.dataObject.add(new Couple('', fieldDescribe.getLabel(), typeField, String.escapeSingleQuotes(fieldName)));				
				}			
			}
		}
		rw.defaultLanguage = 'None';
		return rw;
	}

	@auraEnabled
	public static RecordsWrapper changeLanguage(String parentLookupName, String language, String recordId, String recordsWr){
		RecordsWrapper rw = (RecordsWrapper)JSON.deserialize(recordsWr, RecordsWrapper.class);
		List<String> fieldNameList = new List<String>();
		
		for(Integer i = 0; i < rw.dataObject.size(); i++){
			fieldNameList.add(rw.dataObject[i].name);
			rw.dataObject[i].value = '';
			rw.dataObject[i].idCouple = '';
		}
		
		if(GeneralUtils.isSafeObject(parentLookupName, true)) {
			language = String.escapeSingleQuotes(language);
			recordId = String.escapeSingleQuotes(recordId);
			
			String parentLookupNameRefer = parentLookupName.substringBeforeLast('__c') + '__r.name';
			String translationQuery = 'SELECT Id, FieldApiName__c, FieldType__c, TranslationText__c, TranslationTextArea__c, TranslationTextAreaRich__c, TranslationURL__c, ' + parentLookupNameRefer + 
					' FROM Translation__c  WHERE ' + parentLookupName + ' =: recordId AND LanguageCode__c =: language AND FieldApiName__c IN: fieldNameList ' ;
			
			Map<String, SObject> translationbyNameMap = new Map<String, SObject>();
			for(sObject sobj : Database.query(translationQuery)){
				translationbyNameMap.put((String)sobj.get('FieldApiName__c'), sobj);
			}

			if(translationbyNameMap.size() > 0){ 
				for(Integer i = 0; i < rw.dataObject.size(); i++){
					if(translationbyNameMap.containsKey(rw.dataObject[i].name)){
						String nameType = 'Translation' + rw.dataObject[i].typeF + '__c';
						rw.dataObject[i].value = (String)translationbyNameMap.get(rw.dataObject[i].name).get(nameType);
						rw.dataObject[i].idCouple = (String)translationbyNameMap.get(rw.dataObject[i].name).get('Id');
					}				
				}	
			}
		}
		rw.defaultLanguage = language;
		return rw;
	}

	@auraEnabled
	public static RecordsWrapper saveTranslation(String parentLookupName, String recordId, String recordsWr){
		RecordsWrapper rw = (RecordsWrapper)JSON.deserialize(recordsWr, RecordsWrapper.class);
		List<Translation__c> upsertTranslationList = new List<Translation__c>();
		List<Translation__c> deleteTranslationList = new List<Translation__c>();
		Map<String, Integer> mapPositionValues = new Map<String, Integer>();
		
		if(GeneralUtils.isSafeObject(parentLookupName, true)) {
			recordId = String.escapeSingleQuotes(recordId);
			String nameCouple = (String) Database.query('SELECT Name FROM ' + parentLookupName + ' WHERE Id =: recordId')[0].get('Name');
			nameCouple = GeneralUtils.getSubstring(nameCouple, 40);

			for(Integer i = 0 ; i < rw.dataObject.size(); i++){
				String nameType = 'Translation' + rw.dataObject[i].typeF + '__c';
				Translation__c trans = new Translation__c();
				Boolean needDML = false;

				if(!String.isBlank(rw.dataObject[i].idCouple)){
					trans.put('Id', rw.dataObject[i].idCouple);
					if(String.isBlank(rw.dataObject[i].value)){
						deleteTranslationList.add(trans);
					} else {
						needDML = true;					
					}

				} else if(!String.isBlank(rw.dataObject[i].value)){
					needDML = true;
					String nameTranslation = GeneralUtils.getSubstring(nameCouple + ' - ' + GeneralUtils.getSubstring(rw.dataObject[i].label, 25) + ' - ' + rw.defaultLanguage, 80);
					trans.put('Name', nameTranslation);
					trans.put('LanguageCode__c', rw.defaultLanguage);
					trans.put(parentLookupName, recordId);
					trans.put('FieldApiName__c', rw.dataObject[i].name);
					trans.put('FieldType__c', rw.dataObject[i].typeF);

					//Save position to be used after upsert
					mapPositionValues.put((String)trans.get('Name'), i);				
				}
				if(needDML){				
					trans.put(nameType, rw.dataObject[i].value);
					upsertTranslationList.add(trans);
				}			
			}
			rw.response = 'OK';
		}

		Savepoint sp = Database.setSavepoint();
		try{
			if(upsertTranslationList.size() > 0){
				upsert upsertTranslationList;
				for(Translation__c trans : upsertTranslationList){
					if(!String.isBlank(trans.name)){
						rw.dataObject[mapPositionValues.get(trans.name)].idCouple = trans.Id;
					}				
				}
			}

			if(deleteTranslationList.size() > 0){
				delete deleteTranslationList;
			}

		}catch(Exception e){
			Database.rollback(sp);
			rw.response = e.getMessage();
			System.debug(e.getMessage());
		}		
		return rw;
	}
}