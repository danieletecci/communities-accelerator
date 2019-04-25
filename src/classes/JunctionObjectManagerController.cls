public with sharing class JunctionObjectManagerController {

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
		@auraEnabled public String order;

		public SecondaryObjectWrapper(String idRecord, String name, String order, String idJunction){
			this.idRecord = idRecord;
			this.name = name;
			this.order = order;
			this.idJunction = idJunction;
		}
	}
	
	@auraEnabled(cacheable=false)
	public static RecordsWrapper getRecords(String recordId, String junctionObjectAPIName, String parentLookup, String secondaryLookup, String whereCondition, String orderBy){
		
		junctionObjectAPIName = GeneralUtils.prefix(junctionObjectAPIName);
		parentLookup = GeneralUtils.prefix(parentLookup);
		secondaryLookup = GeneralUtils.prefix(secondaryLookup);
		whereCondition = GeneralUtils.prefix(whereCondition);
		orderBy = GeneralUtils.prefix(orderBy);

		RecordsWrapper rw = new RecordsWrapper();
		String primaryObjectName = Schema.getGlobalDescribe().get(junctionObjectAPIName).getDescribe().fields.getMap().get(parentLookup).getDescribe().getReferenceTo()[0].getDescribe().getName();
		String secondaryObjectName = Schema.getGlobalDescribe().get(junctionObjectAPIName).getDescribe().fields.getMap().get(secondaryLookup).getDescribe().getReferenceTo()[0].getDescribe().getName();

		rw.fieldNameLabel = Schema.getGlobalDescribe().get(secondaryObjectName).getDescribe().fields.getMap().get('name').getDescribe().getLabel();
		rw.secondaryObjectLabelPlural = Schema.getGlobalDescribe().get(secondaryObjectName).getDescribe().getLabelPlural();

		//Query to Junction Object
		Map<Id, String> mapSelectedRecords = new Map<Id, String>();
		String relatedObject = secondaryLookup;
		relatedObject = (relatedObject.contains('__c') ? relatedObject.replace('__c', '__r') : relatedObject.replace('Id', ''));

		String joQuery = 'SELECT Id, ' + secondaryLookup + ', ' + relatedObject + + '.Name';
		if(!String.isBlank(orderBy)){
			joQuery += ', ' + orderBy;
		}
		joQuery += ' FROM ' + junctionObjectAPIName + ' WHERE ' + parentLookup + ' =: recordId';
		if(!String.isBlank(orderBy)){
			joQuery += ' ORDER BY ' + orderBy;
		}

		for(SObject rec: Database.query(joQuery)){
			String orderByValue = !String.isBlank(orderBy) && rec.get(orderBy) != null ? String.valueOf(rec.get(orderBy)) : '0';
			mapSelectedRecords.put(String.valueOf(rec.get(secondaryLookup)), orderByValue + ',' + rec.get('id'));
			rw.recordsSelected.add(new SecondaryObjectWrapper(String.valueOf(rec.get(secondaryLookup)), String.valueOf(rec.getSObject(relatedObject).get('Name')), orderByValue, String.valueOf(rec.get('id'))));
		}
		Set<Id> idSelectedRecordSet = new Set<Id>();
		idSelectedRecordSet = mapSelectedRecords.keySet();
		//Query to selected records
		String secordaryObjectSelectedQuery = 'SELECT Id, Name FROM ' + secondaryObjectName + ' WHERE Id IN: idSelectedRecordSet';

		for(SObject rec: Database.query(secordaryObjectSelectedQuery)){
			//rw.recordsSelected.add(new SecondaryObjectWrapper(String.valueOf(rec.get('Id')), String.valueOf(rec.get('Name')), mapSelectedRecords.get(String.valueOf(rec.get('Id')))));
		}

		//Query to NOT selected or available records
		if(whereCondition != null && whereCondition != ''){
			whereCondition = whereCondition.replace('[!rec', '[!' + primaryObjectName.toLowerCase());
			whereCondition = GeneralUtils.replaceDynamicFields(whereCondition, primaryObjectName, recordId, true);

			if(whereCondition.startsWith('WHERE')){
				whereCondition = whereCondition.replace('WHERE', ' WHERE (Id NOT IN: idSelectedRecordSet) AND ');
			}else{
				whereCondition = ' WHERE (Id NOT IN: idSelectedRecordSet) ' + whereCondition;
			}
		}else{
			whereCondition = ' WHERE (Id NOT IN: idSelectedRecordSet)';
		}

		String relatedRecQuery = 'SELECT Id, Name FROM ' + secondaryObjectName + whereCondition;

		for(SObject rec: Database.query(relatedRecQuery)){
			rw.recordsToSelect.add(new SecondaryObjectWrapper(String.valueOf(rec.get('Id')), String.valueOf(rec.get('Name')), '', ''));
		}
		return rw;
	}

	@auraEnabled(cacheable=false)
	public static String saveRelationships(String recordId, String junctionObjectAPIName, String parentLookup, String secondaryLookup, List<String> listSelectedIds, String orderBy, String isReorder){
		
		junctionObjectAPIName = GeneralUtils.prefix(junctionObjectAPIName);
		parentLookup = GeneralUtils.prefix(parentLookup);
		secondaryLookup = GeneralUtils.prefix(secondaryLookup);
		orderBy = GeneralUtils.prefix(orderBy);

		Set<String> selectedIds = new Set<String>();
		selectedIds.addAll(listSelectedIds);
		Integer lastOrderBy = 0;

		List<SObject> recToDelete = new List<SObject>();
		List<SObject> recToInsert = new List<SObject>();
		List<SObject> recToUpdate = new List<SObject>();

		if(!Boolean.valueOf(isReorder)){
			String joQuery = 'SELECT Id, ' + secondaryLookup;
			if(!String.isBlank(orderBy)){
				joQuery += ', ' + orderBy;
			}
			joQuery += ' FROM ' + junctionObjectAPIName + ' WHERE ' + parentLookup + ' =: recordId';
			if(!String.isBlank(orderBy)){
				joQuery += ' ORDER BY ' + orderBy;
			}
			List<SObject> junctionObjectList = Database.query(joQuery);

			for(SObject rec: junctionObjectList){
				if(!selectedIds.contains(String.valueOf(rec.get(secondaryLookup)))){
					recToDelete.add(rec);
				}else{
					recToUpdate.add(rec);
					selectedIds.remove(String.valueOf(rec.get(secondaryLookup)));
				}
			}

			if(!String.isBlank(orderBy)){
				for(lastOrderBy = 0; lastOrderBy < recToUpdate.size(); lastOrderBy++){
					recToUpdate.get(lastOrderBy).put(orderBy, lastOrderBy + 1);
				}
			}

			for(String idsNotInDB: selectedIds){
				sObject sObj = Schema.getGlobalDescribe().get(junctionObjectAPIName).newSObject();
				sObj.put(parentLookup, recordId);
				sObj.put(secondaryLookup, idsNotInDB);
				if(!String.isBlank(orderBy)){
					sObj.put(orderBy, ++lastOrderBy);				
				}
				recToInsert.add(sObj);
			}
		} else {
			for(String rec: selectedIds){
				sObject sObj = Schema.getGlobalDescribe().get(junctionObjectAPIName).newSObject();
				sObj.put('id', (Id)rec);
				sObj.put(orderBy, ++lastOrderBy);
				recToUpdate.add(sObj);
			}
		}


		String response = 'OK';
		Savepoint sp = Database.setSavepoint();
		try{
			if(recToDelete != null) delete recToDelete;
			if(recToInsert != null) insert recToInsert;
			if(recToUpdate != null) update recToUpdate;
		}catch(Exception e){
			Database.rollback(sp);
			response = e.getMessage();
			system.debug(e.getMessage());
		}
		
		return response;
	}

}