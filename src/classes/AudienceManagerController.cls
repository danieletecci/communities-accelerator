public with sharing class AudienceManagerController {

    public class RecordsWrapper{
        @auraEnabled public String fieldNameLabel;
        @auraEnabled public String secondaryObjectLabelPlural;
        @auraEnabled public List<SecondaryObjectWrapper> recordsSelected;
        @auraEnabled public List<SecondaryObjectWrapper> recordsToSelect;

        public RecordsWrapper(){
            this.recordsSelected = new List<SecondaryObjectWrapper>();
            this.recordsToSelect = new List<SecondaryObjectWrapper>();
        }
    }

    public class SecondaryObjectWrapper{
        @auraEnabled public String idRecord;
        @auraEnabled public String externalId;
        @auraEnabled public String name;

        public SecondaryObjectWrapper(String idRecord, String name, String externalId){
            this.idRecord = idRecord;
            this.name = name;
            this.externalId = externalId;
        }
    }
    

    @auraEnabled
    public static RecordsWrapper getRecords(String recordId, String objectName){
        RecordsWrapper rw = new RecordsWrapper();
    	List<Audience__c> selectedAudience = new List<Audience__c>();
    	List<Audience__c> notSelectedAudience = new List<Audience__c>();

        String sobjectName = GeneralUtils.prefix('[CMS]Audience__c');
        rw.fieldNameLabel =  Schema.getGlobalDescribe().get(sobjectName).getDescribe().fields.getMap().get('name').getDescribe().getLabel();
        rw.secondaryObjectLabelPlural =  Schema.getGlobalDescribe().get(sobjectName).getDescribe().getLabelPlural();
		String querySObject = 'Select id, name, [CMS]ExternalId__c, [CMS]Cluster__c  from [CMS]Audience__c where [CMS]Cluster__c in (SELECT [CMS]Cluster__c FROM '+objectName+' WHERE Id = \''+recordId+'\') and recordtype.developerName != \'AudienceGroup\'';
		List<Audience__c> audienceList = Database.query(GeneralUtils.prefix(querySObject));  
		String querySelectedIds = 'SELECT [CMS]Audience__c FROM '+objectName+' WHERE Id = \''+recordId+'\'';
		List<SObject> objList = Database.query(GeneralUtils.prefix(querySelectedIds));
		String idAudienceGroup = (String) objList[0].get(GeneralUtils.prefix('[CMS]Audience__c'));
		List<String> externalIdlist= new List<String>();
		if(String.isNotBlank(idAudienceGroup)){
			List<Audience__c> audienceGroupList =[SELECT id, ReferenceAudienceExternalIds__c FROM Audience__c WHERE id =: idAudienceGroup];
			externalIdlist = audienceGroupList[0].ReferenceAudienceExternalIds__c.split(';');  
			//system.debug('DEBUG externalIdlist ' + externalIdlist);
			//selectedAudience=[SELECT id, name, ExternalId__c, Cluster__c  FROM Audience__c WHERE ExternalId__c in : externalIdlist]; 
	
		}
		for(Audience__c audience : audienceList){
			if(externalIdlist.contains(audience.ExternalId__c)){
				rw.recordsSelected.add(new SecondaryObjectWrapper(audience.id, audience.name, audience.ExternalId__c));
			}else{
				rw.recordsToSelect.add(new SecondaryObjectWrapper(audience.id, audience.name, audience.ExternalId__c));
			}
		}
        return rw;
    }

    @auraEnabled
	public static String saveRelationships(String recordId, String objectAPIName, List<String> listSelectedIds){
		
		objectAPIName = GeneralUtils.prefix(objectAPIName);
		Set<String> selectedIds = new Set<String>();
		selectedIds.addAll(listSelectedIds);

		String queryCluster ='SELECT id, [CMS]Cluster__c, [CMS]Audience__c FROM '+objectAPIName+' WHERE Id = \''+recordId+'\'';
		List<SObject> objList = Database.query(GeneralUtils.prefix(queryCluster));
		Sobject toUpdate = objList[0];
		String clusterId = (String) toUpdate.get(GeneralUtils.prefix('[CMS]Cluster__c'));
		String audienceGroupId =  AudienceUtils.audienceGroupCreation(new List<String>(selectedIds), clusterId);		
		toUpdate.put(GeneralUtils.prefix('[CMS]Audience__c'), audienceGroupId);
		String response = 'OK';
		Savepoint sp = Database.setSavepoint();
		try{

			update toUpdate;

		}catch(Exception e){
			Database.rollback(sp);
			response = e.getMessage();
			system.debug(e.getMessage());
		}
		
		return response;
	}

}