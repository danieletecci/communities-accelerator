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
        @auraEnabled public String idJunction;
        @auraEnabled public String name;

        public SecondaryObjectWrapper(String idRecord, String name, String idJunction){
            this.idRecord = idRecord;
            this.name = name;
            this.idJunction = idJunction;
        }
    }
    

    /*
    *@description This method will return a RecordsWrapper.
    *@param String recordId
    *@return RecordsWrapper
    *@throws NA
    */
    @auraEnabled
    public static RecordsWrapper getRecords(String recordId, String objectName){
        RecordsWrapper rw = new RecordsWrapper();
    	List<Audience__c> selectedAudience = new List<Audience__c>();

        String sobjectName = GeneralUtils.prefix('[CMS]Audience__c');
        rw.fieldNameLabel =  Schema.getGlobalDescribe().get(sobjectName).getDescribe().fields.getMap().get('name').getDescribe().getLabel();
        rw.secondaryObjectLabelPlural =  Schema.getGlobalDescribe().get(sobjectName).getDescribe().getLabelPlural();

		String querySObject = 'Select id, name, [CMS]Cluster__c  from [CMS]Audience__c where [CMS]Cluster__c in (SELECT [CMS]Cluster__c FROM '+objectName+' WHERE Id = \''+recordId+'\') and recordtype.developerName != \'AudienceGroup\'';
	
		system.debug('DEBUG querySObject '+ querySObject);	
	
		List<Audience__c> audienceList = Database.query(GeneralUtils.prefix(querySObject));  
		
		String querySelectedIds = 'SELECT [CMS]Audience__c FROM '+objectName+' WHERE Id = \''+recordId+'\'';

		system.debug('DEBUG querySelectedIds '+ querySelectedIds);

		List<SObject> objList = Database.query(GeneralUtils.prefix(querySelectedIds));
		String idAudienceGroup = (String) objList[0].get(GeneralUtils.prefix('[CMS]Audience__c'));

		if(String.isNotBlank(idAudienceGroup)){

			List<Audience__c> audienceGroupList =[SELECT id, ReferenceAudienceExternalIds__c FROM Audience__c WHERE id =: idAudienceGroup];

			String externalIdlist = audienceGroupList[0].ReferenceAudienceExternalIds__c.replaceAll(';','\',\'');
			externalIdlist = externalIdlist.removeEnd(',\'');   
			String querySelectedAudience = 'SELECT id, name FROM [CMS]Audience__c WHERE [CMS]ExternalId__c in ('+ externalIdlist +')';

			system.debug('DEBUG querySelectedAudience '+ querySelectedAudience);

			selectedAudience=Database.query(GeneralUtils.prefix(querySelectedAudience));  
		}

		system.debug('DEBUG selectedAudience '+ selectedAudience);
		system.debug('DEBUG audienceList '+ audienceList);
		for(Audience__c audience : audienceList){
			if(selectedAudience.contains(audience)){
				rw.recordsSelected.add(new SecondaryObjectWrapper(audience.id, audience.name, idAudienceGroup));
				system.debug('DEBUG recordsSelected '+ rw.recordsSelected);
			}else{
				rw.recordsToSelect.add(new SecondaryObjectWrapper(audience.id, audience.name, idAudienceGroup));
				system.debug('DEBUG recordsToSelect '+ rw.recordsToSelect);
			}
		}

        return rw;
    }

}