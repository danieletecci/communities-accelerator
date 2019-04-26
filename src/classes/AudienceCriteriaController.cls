public with sharing class AudienceCriteriaController {

    public class AudienceWrapper{
        @auraEnabled public String audienceId;
		@auraEnabled public String matchCriteria;
        @auraEnabled public String audienceCriteria;
        @auraEnabled public List<FieldSelectOption> fields;
        @auraEnabled public List<CriterionWrapper> criteria;
        @auraEnabled public List<String> booleanOperators;
        @auraEnabled public List<String> decimalOperators;
        @auraEnabled public List<String> stringOperators;
        @auraEnabled public LabelList labels;
        public AudienceWrapper(){
            this.booleanOperators = new List<String>{Label.Equals, Label.NotEquals};
            this.decimalOperators = new List<String>{Label.Equals, Label.NotEquals, Label.GreaterThan, Label.GreaterOrEqualThan, Label.LessThan, Label.LessOrEqualThan};
            this.stringOperators = new List<String>{Label.Equals, Label.NotEquals, Label.Contains, Label.NotContains};
            this.labels = new LabelList();
        }
	}

    //Metadata of selectable fields
    public class FieldSelectOption{
        @auraEnabled public String fieldPath;
        @auraEnabled public String fieldLabel;
        @auraEnabled public String fieldType;
        @auraEnabled public List<PicklistValues> values;
        @auraEnabled public Boolean isSeparator;
        public FieldSelectOption(String p_fieldPath, String p_fieldLabel, String p_fieldType, List<PicklistValues> p_values, Boolean p_isSeparator){
            this.fieldPath = p_fieldPath;
            this.fieldLabel = p_fieldLabel;
            this.fieldType = p_fieldType;
            this.values = p_values;
            this.isSeparator = p_isSeparator;
        }
	}

    //Criterias wrapper
    public class CriterionWrapper{
		@auraEnabled public Decimal order;
        @auraEnabled public String field;
		@auraEnabled public String operator;
        @auraEnabled public String valueType;
		@auraEnabled public String value;
        public CriterionWrapper(Decimal p_order, String p_field, String p_operator, String p_valueType, String p_value){
            this.order = p_order;
            this.field = p_field;
            this.operator = p_operator;
            this.valueType = p_valueType;
            this.value = p_value;
        }
	}

    public class LabelList{
        @auraEnabled public String matchCriteriaFieldLabel;
        @auraEnabled public String matchCriteriaHelp;
        @auraEnabled public String matchCriteriaAll;
        @auraEnabled public String matchCriteriaAny;
        @auraEnabled public String matchCriteriaCustom;
        public LabelList(){
            this.matchCriteriaFieldLabel = Audience__c.MatchCriteria__c.getDescribe().getLabel();
            this.matchCriteriaHelp = Audience__c.MatchCriteria__c.getDescribe().getInlineHelpText();
            for(Schema.PicklistEntry f: Audience__c.MatchCriteria__c.getDescribe().getPicklistValues()){
                if(f.getValue() == 'All'){this.matchCriteriaAll = f.getLabel();}
                if(f.getValue() == 'Any'){this.matchCriteriaAny = f.getLabel();}
                if(f.getValue() == 'Custom'){this.matchCriteriaCustom = f.getLabel();}
            }
        }
    }

    private class FieldPathDescribe{
		private String fieldPathLabel;
        private String fieldType;
        private List<PicklistValues> values;
	}

    private class PicklistValues{
        private String apiVal;
        private String label;
        private PicklistValues(String p_apiVal, String p_label){
            this.apiVal = p_apiVal;
            this.label = p_label;
        }
    }

    private static map<String, String> describeTypeToCriterionTypeMap = new map<String, String>{
        'ADDRESS' => 'Text',
        'BOOLEAN' => 'Checkbox',
        'CURRENCY' => 'Currency',
        //'DATE' => 'Date',
        'DOUBLE' => 'Number',
        'EMAIL' => 'Email',
        'INTEGER' => 'Number',
        'LONG' => 'Number',
        'PERCENT' => 'Percent',
        'PICKLIST' => 'Picklist',
        'MULTIPICKLIST' => 'Picklist',
        'REFERENCE' => 'Lookup',
        'STRING' => 'Text'
    };

    @auraEnabled
    public static String getCriteria(String audienceId){
        AudienceWrapper aw = new AudienceWrapper();

        try{
            //Audience record query
            Audience__c aud = [SELECT Id, Cluster__c, Cluster__r.AudienceFieldsAccount__c, Cluster__r.AudienceFieldsContact__c, Cluster__r.AudienceFieldsAccountContact__c,
                            Cluster__r.AudienceCustomObjectType__c, Cluster__r.AudienceFieldsCustomObject__c, MatchCriteria__c, AudienceCriteria__c, 
                            (SELECT Id, Audience__c, Order__c, MainObjectType__c, FieldAPIName__c, Operator__c, ValueType__c, Value__c
                            FROM AudienceCriteria__r ORDER BY Order__c)
                            FROM Audience__c
                            WHERE Id =: audienceId];
            
            //Creation of main wrapper
            aw.audienceId = aud.Id;
            aw.matchCriteria = aud.MatchCriteria__c != null ? aud.MatchCriteria__c : 'All';
            aw.audienceCriteria = aud.AudienceCriteria__c;
            aw.fields = new List<FieldSelectOption>();
            completeFieldOptions(aw.fields, aud.Cluster__r.AudienceFieldsAccount__c, 'Account');
            completeFieldOptions(aw.fields, aud.Cluster__r.AudienceFieldsContact__c, 'Contact');
            completeFieldOptions(aw.fields, aud.Cluster__r.AudienceFieldsAccountContact__c, 'AccountContactRelation');
            completeFieldOptions(aw.fields, aud.Cluster__r.AudienceFieldsCustomObject__c, aud.Cluster__r.AudienceCustomObjectType__c);

            //Criteria on DB to wrapper
            aw.criteria = new List<CriterionWrapper>();
            for(AudienceCriterion__c audc: aud.AudienceCriteria__r){
                aw.criteria.add(new CriterionWrapper(
                    audc.Order__c,
                    audc.MainObjectType__c + '.' + audc.FieldAPIName__c,
                    audc.Operator__c,
                    audc.ValueType__c,
                    audc.Value__c
                ));
            }
        }catch(Exception e){
            throw new AuraHandledException(e.getMessage());
        }

        return JSON.serialize(aw);
    }

    @auraEnabled
    public static void saveCriteria(String audienceId, String matchCriteria, String audienceCriteria, String criteriaWrapper){
        List<CriterionWrapper> criteria = (List<CriterionWrapper>)JSON.deserialize(criteriaWrapper, List<CriterionWrapper>.class);
        
        Savepoint sp = Database.setSavepoint();
        try{
            //Update Audience
            Audience__c aud = new Audience__c(
                Id = audienceId,
                MatchCriteria__c = matchCriteria,
                AudienceCriteria__c = audienceCriteria
            );

            //Upsert Audience Criteria
            
            //Creation of a map with Order and Audience Criteria on DB
            map<Integer, AudienceCriterion__c> audienceCritariaMap = new map<Integer, AudienceCriterion__c>();
            for(AudienceCriterion__c audc: [SELECT Id, Audience__c, Order__c, MainObjectType__c, FieldAPIName__c, Operator__c, ValueType__c, Value__c FROM AudienceCriterion__c WHERE Audience__c =: aud.Id]){
                audienceCritariaMap.put(Integer.ValueOf(audc.Order__c), audc);
            }
            
            //Creation of a map with Order and Audience Criteria Wrapper modified
            map<Integer, CriterionWrapper> audienceCritariaWrapperMap = new map<Integer, CriterionWrapper>();
            for(CriterionWrapper criterion: criteria){
                audienceCritariaWrapperMap.put(Integer.ValueOf(criterion.order), criterion); 
            }

            List<AudienceCriterion__c> audienceCriteriaToDelete = new List<AudienceCriterion__c>();
            //Max audience criteria per Audience is 10
            for(Integer i=0; i<10; i++){
                if(audienceCritariaMap.containsKey(i) || audienceCritariaWrapperMap.containsKey(i)){
                    if(audienceCritariaMap.containsKey(i) && audienceCritariaWrapperMap.containsKey(i)){
                        if(audienceCritariaWrapperMap.get(i).field != '' && audienceCritariaWrapperMap.get(i).field != null){
                            //Update criterion
                            audienceCritariaMap.get(i).Order__c = audienceCritariaWrapperMap.get(i).order;
                            audienceCritariaMap.get(i).MainObjectType__c = audienceCritariaWrapperMap.get(i).field.split('\\.', 2)[0];
                            audienceCritariaMap.get(i).FieldAPIName__c = audienceCritariaWrapperMap.get(i).field.split('\\.', 2)[1];
                            audienceCritariaMap.get(i).Operator__c = audienceCritariaWrapperMap.get(i).operator;
                            audienceCritariaMap.get(i).ValueType__c = audienceCritariaWrapperMap.get(i).valueType;
                            audienceCritariaMap.get(i).Value__c = audienceCritariaWrapperMap.get(i).value;
                        }else{
                            //Delete criterion if the order exists but the field is empty
                            audienceCriteriaToDelete.add(audienceCritariaMap.remove(i));
                        }

                    }else if(audienceCritariaWrapperMap.containsKey(i)){
                        if(audienceCritariaWrapperMap.get(i).field != '' && audienceCritariaWrapperMap.get(i).field != null){
                            //Insert criterion
                            AudienceCriterion__c criterion = new AudienceCriterion__c(
                                Audience__c = audienceId,
                                Order__c = audienceCritariaWrapperMap.get(i).order,
                                MainObjectType__c = audienceCritariaWrapperMap.get(i).field.split('\\.', 2)[0],
                                FieldAPIName__c = audienceCritariaWrapperMap.get(i).field.split('\\.', 2)[1],
                                Operator__c = audienceCritariaWrapperMap.get(i).operator,
                                ValueType__c = audienceCritariaWrapperMap.get(i).valueType,
                                Value__c = audienceCritariaWrapperMap.get(i).value
                            );
                            audienceCritariaMap.put(i, criterion);
                        }

                    }else if(audienceCritariaMap.containsKey(i)){
                        //Delete criterion
                        audienceCriteriaToDelete.add(audienceCritariaMap.remove(i));
                    }
                }
            }
            delete audienceCriteriaToDelete;

            //Set the new order to avoid missing order numbers
            for(Integer i=0; i<audienceCritariaMap.values().size(); i++){
                audienceCritariaMap.values()[i].Order__c = Decimal.ValueOf(i+1);
            }
            upsert audienceCritariaMap.values();

            update aud;

        }catch(DMLException e){
            Database.rollback(sp);
            system.debug(e.getDMLMessage(0));
            throw new AuraHandledException(e.getDMLMessage(0));
        }catch(Exception e){
            Database.rollback(sp);
            system.debug(e.getMessage());
            throw new AuraHandledException(e.getMessage()); 
        }
    }

    //This method receives a list of paths and get the describe of each one
    private static void completeFieldOptions(List<FieldSelectOption> fields, String fieldCommaSeparated, String mainObject){
        if(mainObject != null && fieldCommaSeparated != null){
            fields.add(new FieldSelectOption(null, Schema.getGlobalDescribe().get(GeneralUtils.prefix(mainObject)).getDescribe().getLabel() + ' ' + Label.ObjectFieldsLabel, null, null, true));
            for(String fieldPath: fieldCommaSeparated.split(',')){
                FieldPathDescribe fDesc = getFieldPathDescribe(fieldPath.replace(' ',''), mainObject);
                if(fDesc != null){
                    fields.add(new FieldSelectOption(
                        mainObject + '.' + fieldPath.replace(' ', ''),
                        fDesc.fieldPathLabel,
                        fDesc.fieldType,
                        fDesc.values,
                        false
                    ));
                }
            }
        }
    }

    //This method receives a field path and get their describe (Label, final field type, and values in case of picklist type)
    private static FieldPathDescribe getFieldPathDescribe(String fieldPath, String mainObject){
        FieldPathDescribe fDescribe = new FieldPathDescribe();
        try{
            fDescribe.fieldPathLabel = Schema.getGlobalDescribe().get(GeneralUtils.prefix(mainObject)).getDescribe().getLabel();
            fieldPath = fieldPath.replace('__r.', '__c.');

            for(String field: fieldPath.split('\\.')){
                Map<String, Schema.SObjectField> mapFields = Schema.getGlobalDescribe().get(GeneralUtils.prefix(mainObject)).getDescribe().fields.getMap();
                Schema.DescribeFieldResult fDesc;
                if(mapFields.containsKey(field)){
                    fDesc = mapFields.get(field).getDescribe();
                }else if(mapFields.containsKey(field + 'Id')){
                    fDesc = mapFields.get(field + 'Id').getDescribe();
                }else{
                    fDescribe = null;
                    break;
                }
                if(String.ValueOf(fDesc.getType()).toUpperCase() == 'REFERENCE'){
                    mainObject = fDesc.getReferenceTo()[0].getDescribe().getName();

                }else if(String.ValueOf(fDesc.getType()).toUpperCase() == 'PICKLIST' || String.ValueOf(fDesc.getType()).toUpperCase() == 'MULTIPICKLIST'){
                    fDescribe.values = new List<PicklistValues>();
                    for(Schema.PicklistEntry f : fDesc.getPicklistValues()){
                        fDescribe.values.add(new PicklistValues(f.getLabel(), f.getValue()));
                    }
                }
                fDescribe.fieldPathLabel += ' > ' + fDesc.getLabel();
                fDescribe.fieldType = describeTypeToCriterionTypeMap.get(String.ValueOf(fDesc.getType()).toUpperCase());
            }
        }catch(Exception e){
            fDescribe = null;
        }

        return fDescribe;
    }

}