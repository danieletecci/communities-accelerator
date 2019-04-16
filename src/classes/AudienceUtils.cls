public with sharing class AudienceUtils {

    public static Id rtAudienceGroup = Schema.SObjectType.Audience__c.getRecordTypeInfosByDeveloperName().get('AudienceGroup').getRecordTypeId();
    public static Id rtAudience = Schema.SObjectType.Audience__c.getRecordTypeInfosByDeveloperName().get('Audience').getRecordTypeId();

    /*
    Description: This method filter the records received based on the Audiences of a User
    The records received in the "records" list must have queried the relation Audience__r.ReferenceAudienceExternalIds__c
    */
    public static void filterRecords(Id userId, List<SObject> records, String audienceLookupApiName){
        //Get user audiences
        Set<String> userAudiences = CMSUserSettingsUtils.getUserAudiences(userId);
        
        //Loop records to be filtered
        for(Integer i=0; i < records.size(); i++){
            
            //Get audiences of each record
            String audiencesExternalIds;
            try{audiencesExternalIds = String.ValueOf(GeneralUtils.getFieldValue(records[i], audienceLookupApiName.removeEndIgnoreCase('__c') + '__r.ReferenceAudienceExternalIds__c'));}catch(Exception e){}
            
            if(audiencesExternalIds != null){
                for(String audExtId: audiencesExternalIds.split(';')){
                    //if any audience on the record doesn't match with the user audiences, that record is removed from the original list
                    if(!userAudiences.contains(audExtId)){
                        records.remove(i);
                        i--;
                        break;
                    }
                }
            }
        }
    }
    
    /*
    Description: This method returns or creates and return an Audience Group based on a combination of Audiences
    */
    public static String audienceGroupCreation(List<String> audienceExternalIdsList, String clusterId){
        if(audienceExternalIdsList == null || audienceExternalIdsList.isEmpty()){return null;}

        //Check if the clusterId received exists
        Cluster__c cluster;
        try{cluster = [SELECT Id FROM Cluster__c WHERE Id =: clusterId];}catch(Exception e){}

        String audienceGroupId;
        if(cluster != null){
            
            //Query the external ids received to validate if all of them exists
            List<Audience__c> audiencesList = [SELECT Id, ExternalId__c FROM Audience__c WHERE RecordType.DeveloperName = 'Audience' AND Cluster__c =: clusterId AND ExternalId__c IN: audienceExternalIdsList];

            if(audienceExternalIdsList.size() == audiencesList.size()){
                //Conversion of the original list of External Ids to SF Ids to match exactly in the record
                List<String> audiencesIdsList = new List<String>();
                for(Audience__c aud: audiencesList){
                    audiencesIdsList.add(String.ValueOf(aud.Id).substring(0,15));
                }
                audiencesIdsList.sort();
                String audienceIdsSorted = String.join(audiencesIdsList, ';');

                //Looking for the record with the exactly combination (and sorted) of SF Ids
                Audience__c audienceGroup;
                try{audienceGroup = [SELECT Id FROM Audience__c WHERE RecordType.DeveloperName = 'AudienceGroup' AND ReferenceAudience__c =: audienceIdsSorted];}catch(Exception e){}
                
                if(audienceGroup == null){
                    //if the Audience Group doen't exists with the combination of SF Ids, a new Audience is created
                    audienceGroup = new Audience__c(
                        RecordTypeId = rtAudienceGroup,
                        Cluster__c = clusterId,
                        ReferenceAudienceExternalIds__c = String.join(audienceExternalIdsList, ';')
                    );
                    insert audienceGroup;
                }

                //Assignment to the returning variable of the Audience queried of created
                audienceGroupId = String.ValueOf(audienceGroup.Id);
            }else{
                //exception
            }
        }else{
            //exception
        }

        return audienceGroupId;
    }

    /*
    Description: This method calculates the Audiences that apply for a User based on the Audiences Criteria
    */
    public static List<String> audienceUserCalculation(set<id> audiencesIdsSet, Id accountId, Id contactId, Id acRelationId, Id customRecordId){
        List<String> audiencesIdsToReturnList = new List<String>();

        Account account;
        Contact contact;
        SObject acRelation;
        SObject customRecord;
        Set<String> accountFieldsSet = new Set<String>();
        Set<String> contactFieldsSet = new Set<String>();
        Set<String> acRelationFieldsSet = new Set<String>();
        Set<String> customObjectFieldsSet = new Set<String>();

        //Get the SObject Type from the customRecordId
        String customObjectType;
        if(customRecordId != null){
            try{customObjectType = ((Id)customRecordId).getSObjectType().getDescribe().getName();}catch(Exception e){}
        }

        //Get active Audiences records
        List<Audience__c> audiences = [SELECT Id, Cluster__c, ExternalId__c, MatchCriteria__c, AudienceCriteria__c,
                                      (SELECT Id, Audience__c, ExternalId__c, MainObjectType__c, FieldAPIName__c, Operator__c, Order__c, Value__c, ValueType__c
                                      FROM AudienceCriteria__r ORDER BY Order__c)
                                      FROM Audience__c
                                      WHERE RecordType.DeveloperName = 'Audience' AND Id IN: audiencesIdsSet AND Status__c = 'Active'];
        
        //Collect fields for each main objects type (Account, Contact, AccountContactRelation (if it exists), and a cofigured custom object)
        for(Audience__c aud: audiences){
            for(AudienceCriterion__c audc: aud.AudienceCriteria__r){
                if(accountId != null && audc.MainObjectType__c.toUpperCase() == 'Account'.toUpperCase()){
                    accountFieldsSet.add(audc.FieldAPIName__c);
                }
                if(contactId != null && audc.MainObjectType__c.toUpperCase() == 'Contact'.toUpperCase()){
                    contactFieldsSet.add(audc.FieldAPIName__c);
                }
                if(acRelationId != null && audc.MainObjectType__c.toUpperCase() == 'AccountContactRelation'.toUpperCase()){
                    acRelationFieldsSet.add(audc.FieldAPIName__c);
                }
                if(customRecordId != null && audc.MainObjectType__c.toUpperCase() == customObjectType.toUpperCase()){
                    customObjectFieldsSet.add(audc.FieldAPIName__c);
                }
            }
        }

        //Query for each main objects
        if(!accountFieldsSet.isEmpty()){
            account = Database.query('SELECT Id, ' + GeneralUtils.joinFields(accountFieldsSet) + ' FROM Account WHERE Id =: accountId');
        }
        if(!contactFieldsSet.isEmpty()){
            contact = Database.query('SELECT Id, ' + GeneralUtils.joinFields(contactFieldsSet) + ' FROM Contact WHERE Id =: contactId');
        }
        if(Schema.getGlobalDescribe().get('AccountContactRelation') != null && !acRelationFieldsSet.isEmpty()){
            acRelation = Database.query('SELECT Id, ' + GeneralUtils.joinFields(acRelationFieldsSet) + ' FROM AccountContactRelation WHERE Id =: acRelationId');
        }
        if(!customObjectFieldsSet.isEmpty()){
            customRecord = Database.query('SELECT Id, ' + GeneralUtils.joinFields(customObjectFieldsSet) + ' FROM ' + customObjectType + ' WHERE Id =: customRecordId');
        }

        //Loop audience records to check if it apply for the main objects according to the criteria
        for(Audience__c aud: audiences){
            Boolean applyAudience = false;
            
            //Audience Criteria "All"
            if(aud.MatchCriteria__c == 'All' || aud.MatchCriteria__c == null){
                applyAudience = true;
                for(AudienceCriterion__c audc: aud.AudienceCriteria__r){
                    SObject recordMain = getAudienceCriterionMainRecord(audc, account, contact, acRelation, customObjectType, customRecord);
                    if(!audienceCriterionApply(audc, recordMain)){
                        applyAudience = false;
                        break;
                    }
                }
            }

            //Audience Criteria "Any"
            if(aud.MatchCriteria__c == 'Any'){
                for(AudienceCriterion__c audc: aud.AudienceCriteria__r){
                    SObject recordMain = getAudienceCriterionMainRecord(audc, account, contact, acRelation, customObjectType, customRecord);
                    if(audienceCriterionApply(audc, recordMain)){
                        applyAudience = true;
                        break;
                    }
                }
            }

            //Audience Criteria "Custom"
            if(aud.MatchCriteria__c == 'Custom'){
                map<Integer, Boolean> criterionNumberApplyMap = new map<Integer, Boolean>();
                for(AudienceCriterion__c audc: aud.AudienceCriteria__r){
                    SObject recordMain = getAudienceCriterionMainRecord(audc, account, contact, acRelation, customObjectType, customRecord);
                    criterionNumberApplyMap.put(Integer.ValueOf(audc.Order__c), audienceCriterionApply(audc, recordMain));
                }
                for(Integer audcNumber: criterionNumberApplyMap.keySet()){
                    aud.AudienceCriteria__c = aud.AudienceCriteria__c.replace(String.ValueOf(audcNumber), String.valueOf(criterionNumberApplyMap.get(audcNumber)).toUpperCase());
                }
                applyAudience = BooleanExpression.eval(aud.AudienceCriteria__c);
            }
            
            //If the Audience apply add it to the list
            if(applyAudience){
                audiencesIdsToReturnList.add(aud.ExternalId__c);
            }
        }

        return audiencesIdsToReturnList;
    }

    private static SObject getAudienceCriterionMainRecord(AudienceCriterion__c audc, Account account, Contact contact, SObject acRelation, String customObjectType, SObject customRecord){
        //Return the main object to be used to evaulate each criterion (each criterion can only evaluate a main object)
        SObject recordMain;
        if(account != null && audc.MainObjectType__c == 'Account'){recordMain = account;}
        if(contact != null && audc.MainObjectType__c == 'Contact'){recordMain = contact;}
        if(acRelation != null && audc.MainObjectType__c == 'AccountContactRelation'){recordMain = acRelation;}
        if(customRecord != null && audc.MainObjectType__c.toUpperCase() == customObjectType.toUpperCase()){recordMain = customRecord;}
        return recordMain;
    }

    private static Boolean audienceCriterionApply(AudienceCriterion__c ac, SObject recordMain){
        //Evaluation of criterion "field of main object - operator - value on criterion"

        Boolean audienceCriterionApply = false;
        
        if(ac.ValueType__c == 'Checkbox'){
            Boolean recordValue = (Boolean)GeneralUtils.getFieldValue(recordMain, ac.FieldAPIName__c);
            audienceCriterionApply = booleanOperators(ac.Operator__c, Boolean.ValueOf(ac.Value__c), recordValue);

        }else if(ac.ValueType__c == 'Currency' || ac.ValueType__c == 'Number' || ac.ValueType__c == 'Percent'){
            Decimal recordValue = (Decimal)GeneralUtils.getFieldValue(recordMain, ac.FieldAPIName__c);
            audienceCriterionApply = decimalOperators(ac.Operator__c, Decimal.ValueOf(ac.Value__c), recordValue);

        }else if(ac.ValueType__c == 'Text' || ac.ValueType__c == 'Email' || ac.ValueType__c == 'Lookup' || ac.ValueType__c == 'Picklist'){
            String recordValue = (String)GeneralUtils.getFieldValue(recordMain, ac.FieldAPIName__c);
            audienceCriterionApply = stringOperators(ac.Operator__c, ac.Value__c, recordValue);
        }

        return audienceCriterionApply;
    }

    private static Boolean booleanOperators(String operator, Boolean acValue, Boolean recordValue){
        Boolean apply = false;
        if(operator == 'equals'){
            apply = acValue == recordValue;
        }else if(operator == 'not equals'){
            apply = acValue != recordValue;
        }
        return apply;
    }

    private static Boolean decimalOperators(String operator, Decimal acValue, Decimal recordValue){
        Boolean apply = false;
        if(operator == 'equals'){
            apply = acValue == recordValue;
        }else if(operator == 'not equals'){
            apply = acValue != recordValue;
        }else if(operator == 'greater than'){
            apply = acValue < recordValue;
        }else if(operator == 'greater or equal than'){
            apply = acValue <= recordValue;
        }else if(operator == 'less than'){
            apply = acValue > recordValue;
        }else if(operator == 'less or equal than'){
            apply = acValue >= recordValue;
        }
        return apply;
    }

    private static Boolean stringOperators(String operator, String acValue, String recordValue){
        Boolean apply = false;
        if(operator == 'equals'){
            apply = acValue == recordValue;
        }else if(operator == 'not equals'){
            apply = acValue != recordValue;
        }else if(operator == 'contains'){
            apply = recordValue.contains(acValue);
        }else if(operator == 'not contains'){
            apply = !recordValue.contains(acValue);
        }
        return apply;
    }

}