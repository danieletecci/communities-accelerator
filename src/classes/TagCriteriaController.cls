/*
*@Name : TagCriteriaController
*@Author : Damián Marino
*@Description : Gets tags from component and saves the relationship between the tag and the component with its match criteria (validating the criteria list)
*@Date : 04/03/2019
*/


public with sharing class TagCriteriaController {

    public class RecordsWrapper{
        @auraEnabled public String fieldNameLabel;
        @auraEnabled public String secondaryObjectLabelPlural;
        @auraEnabled public List<SecondaryObjectWrapper> recordsSelected;
        @auraEnabled public List<SecondaryObjectWrapper> recordsToSelect;
        @auraEnabled public String matchCriteria;
        @auraEnabled public String tagCriteria;
        @auraEnabled public List<String> matchOptions;
        
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
    

    /*
    *@description This method will return a RecordsWrapper.
    *@param String recordId
    *@return RecordsWrapper
    *@throws NA
    */
    @auraEnabled
    public static RecordsWrapper getRecords(String recordId){
        RecordsWrapper rw = new RecordsWrapper();
        rw.fieldNameLabel =  Schema.getGlobalDescribe().get('Tag__c').getDescribe().fields.getMap().get('name').getDescribe().getLabel();
        rw.secondaryObjectLabelPlural =  Schema.getGlobalDescribe().get('Tag__c').getDescribe().getLabelPlural();

        List<Component__c> comp = [SELECT Id, MatchCriteria__c, TagCriteria__c FROM Component__c WHERE Id =: recordId LIMIT 1];
        rw.tagCriteria = comp[0].TagCriteria__c;
        rw.matchCriteria = comp[0].MatchCriteria__c;

        //Query to Junction Object
        Map<Id, String> mapSelectedRecords = new Map<Id, String>();

        String joQuery = 'SELECT Id, Tag__c, Tag__r.Name, Order__c FROM TagAssignment__c WHERE Component__c =: recordId ORDER BY Order__c';
    
        
        for(SObject rec: Database.query(joQuery)){
            mapSelectedRecords.put(String.valueOf(rec.get('Tag__c')), String.valueOf(rec.get('Order__c')) + ',' + rec.get('id'));
            rw.recordsSelected.add(new SecondaryObjectWrapper(String.valueOf(rec.get('Tag__c')), String.valueOf(rec.getSObject('Tag__r').get('Name')), String.valueOf(rec.get('Order__c')), String.valueOf(rec.get('Id'))));
        }
        Set<Id> idSelectedRecordSet = new Set<Id>();
        idSelectedRecordSet = mapSelectedRecords.keySet();
        
        String relatedRecQuery = 'SELECT Id, Name FROM Tag__c WHERE (Id NOT IN: idSelectedRecordSet) ORDER BY Name';

        for(SObject rec: Database.query(relatedRecQuery)){
            rw.recordsToSelect.add(new SecondaryObjectWrapper(String.valueOf(rec.get('Id')), String.valueOf(rec.get('Name')), '', ''));
        }


        rw.matchOptions = new List<String>();
        List<Schema.PicklistEntry> picklistValues = Schema.getGlobalDescribe().get('Component__c').getDescribe().fields.getMap().get('MatchCriteria__c').getDescribe().getPickListValues();
        for(Schema.PicklistEntry pickListVal : picklistValues){
            rw.matchOptions.add(pickListVal.getValue());
        }        

        return rw;
    }



    /*
    *@description This method will return a string which is the response of the action done. Also this method will validate the criteria list.
    *@param String recordId, List<String> listSelectedIds, String matchCriteria, String tagCriteria
    *@return String
    *@throws NA
    */
    @auraEnabled
    public static String saveRelationships(String recordId, List<String> listSelectedIds, String matchCriteria, String tagCriteria){
        Set<String> selectedIds = new Set<String>();
        selectedIds.addAll(listSelectedIds);
        Integer lastOrderBy = 0;
        String response = 'OK';

        List<SObject> recToDelete = new List<SObject>();
        List<TagAssignment__c> recToInsert = new List<TagAssignment__c>();
        List<SObject> recToUpdate = new List<SObject>();
        
        tagCriteria = tagCriteria != null ? tagCriteria.toUpperCase() : '';
        String tempCriteria = tagCriteria;
        Integer quantity = listSelectedIds.size(); //Save the quantity of tags selected to check it out later.
        List<Integer> myList = new List<Integer>();
        
        List<Component__c> compToUpdate = [SELECT Id, MatchCriteria__c, TagCriteria__c FROM Component__c WHERE Id =: recordId];

        compToUpdate[0].MatchCriteria__c = matchCriteria;
        compToUpdate[0].TagCriteria__c = tagCriteria;
        
        Savepoint sp1 = Database.setSavepoint();
        try{
            update compToUpdate; //Update triggers validates criteria list expression. If pass, then it's ok.
        }catch(DmlException e) {
            response = e.getMessage();
            return response;
        }
        
        if (String.isNotBlank(tagCriteria)){
            Set<Integer> valuesToEval = new Set<Integer>();
            for (Integer i = 0; i < quantity;){
                valuesToEval.add(++i);
            }
            
            if(!BooleanExpressionUtils.validateExpression(tagCriteria, valuesToEval)){
                Database.rollback(sp1); // Rollback because i already updated the component with the criteria list.
                response = Label.TagValidation; //Setting up response label.
                return response;
            }            
        }else{
            if (quantity != null && quantity != 0){
                Database.rollback(sp1); // Rollback because i already updated the component with the criteria list.
                response = Label.CriteriaListInBlank;
                return response;
            }
        }
            
       
        String joQuery = 'SELECT Id, Tag__c, Order__c FROM TagAssignment__c WHERE Component__c =: recordId ORDER BY Order__c';          
        List<SObject> junctionObjectList = Database.query(joQuery);
        for(SObject rec: junctionObjectList){
            if(!selectedIds.contains(String.valueOf(rec.get('Tag__c')))){
                recToDelete.add(rec);
            }else{
                recToUpdate.add(rec);
                selectedIds.remove(String.valueOf(rec.get('Tag__c')));
            }
        }        
        
        for(lastOrderBy = 0; lastOrderBy < recToUpdate.size(); lastOrderBy++){
            recToUpdate.get(lastOrderBy).put('Order__c', lastOrderBy + 1);
        }
        
        
        for(String idsNotInDB: selectedIds){
            TagAssignment__c sObj = new TagAssignment__c();
            sObj.Component__c = recordId;
            sObj.Tag__c = idsNotInDB;
            sObj.Order__c = ++lastOrderBy;
            recToInsert.add(sObj);
        }

        Savepoint sp = Database.setSavepoint();
        try{
            if(recToDelete != null) delete recToDelete;
            if(recToInsert != null) upsert recToInsert;
            if(recToUpdate != null) update recToUpdate;
        }catch(Exception e){
            Database.rollback(sp);
            response = e.getMessage();
        }
        
        return response;
    }
    
    /*
    *@description This method will return a RecordsWrapper with the data temporary.
    *@param String data, List<String> listSelectedIds
    *@return RecordsWrapper
    *@throws NA
    */
    @auraEnabled
    public static RecordsWrapper getSelectedRecords(String data, List<String> listSelectedIds){
        RecordsWrapper rw = (RecordsWrapper)JSON.deserialize(data, RecordsWrapper.class);        
        Map<Id, Tag__c> selectedRecordMap = new Map<Id, Tag__c> ([SELECT Id, Name FROM Tag__c WHERE Id IN: listSelectedIds]);
        Map<String, String> tagAssignmentMap = new Map<String, String>();
        
        for(TagAssignment__c ta : [SELECT Id, Tag__c FROM TagAssignment__c WHERE Tag__c IN: listSelectedIds]){
       		tagAssignmentMap.put(ta.Tag__c, ta.Id);
        }
        
        rw.recordsSelected = new List<SecondaryObjectWrapper>();
        for(Integer i = 0; i < listSelectedIds.size(); i++){
            if(listSelectedIds[i] == selectedRecordMap.get(listSelectedIds[i]).Id){
                String var = tagAssignmentMap.containsKey(listSelectedIds[i]) ? tagAssignmentMap.get(listSelectedIds[i]) : '';
                rw.recordsSelected.add(new SecondaryObjectWrapper(listSelectedIds[i], selectedRecordMap.get(listSelectedIds[i]).Name, String.valueOf(i+1), var));                
            }            
        }
        
        List<Tag__c> tagList = [SELECT Id, Name FROM Tag__c WHERE (Id NOT IN: listSelectedIds) ORDER BY Name];
		for(Tag__c rec: tagList){
            rw.recordsToSelect.add(new SecondaryObjectWrapper(rec.Id, rec.Name, '', ''));
        }
        
        return rw;
    }
}