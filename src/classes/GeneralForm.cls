public without sharing class GeneralForm{
    public FormSettings formSettings;
    public Map<String, SObject> formData{get;set;}
    
    public GeneralForm(String formUniqueName, Set<Id> clusterIds){
        generateGeneralFormData(formUniqueName, clusterIds);
    }
    
    public GeneralForm(String formUniqueName, Set<Id> clusterIds, String recordId){
        generateGeneralFormData(formUniqueName, clusterIds);
        if(recordId != null && this.formSettings.retrievalClass != null){
            runMethod(this.formSettings.retrievalClass, this.formData, recordId);    
        }
    }
    
    public void generateGeneralFormData(String formUniqueName, Set<Id> clusterIds){
        if(clusterIds == null){
            clusterIds = new Set<Id>{null};
        }
        formData = new map<String, SObject>();
        List<FormSection__c> formSections = [SELECT  SectionTitle__c, StyleClass__c, Order__c, ColumnWidth__c,
                                                		Form__r.StyleClass__c, Form__r.ExternalID__c, Form__r.RetrievalClass__c, Form__r.SaveClass__c,
                                                		(SELECT FieldAPIName__c, FieldLabel__c, PlaceHolder__c, FieldType__c, HelpText__c, PicklistValues__c, IsRequired__c, ReadOnly__c, DefaultValue__c,
                                                         		StyleClass__c,ObjectAPIName__c , TextAreaRows__c,
                                                         		FormValidation__r.Status__c, FormValidation__r.ErrorMessage__c, FormValidation__r.RegularExpression__c,MaxLength__c,
		                                                    	ConfirmationRequired__c, ConfirmationLabel__c, ConfirmationError__c, ConfirmationPlaceholder__c 
           	                                          	   FROM FormFields__r 
                                                      	  WHERE Status__c = 'Active' 
                                                   	   ORDER BY Order__c ASC)
                                                  FROM FormSection__c 
                                                 WHERE Form__r.ExternalID__c =: formUniqueName AND Form__r.Status__c = 'Active' AND Form__r.Cluster__c IN :clusterIds ORDER BY Order__c ASC];
        

        System.debug('GeneralForm.generateGeneralFormData() method. formSections: ' + formSections);
        
        if(!formSections.isEmpty()){
            formSettings = new FormSettings(formSections.get(0).Form__r.ExternalID__c, formSections.get(0).Form__r.StyleClass__c,
                                            formSections.get(0).Form__r.RetrievalClass__c, formSections.get(0).Form__r.SaveClass__c
                                           );
            Map<String,Schema.SObjectType> globalDescribe = Schema.getGlobalDescribe();

            for(FormSection__c formSection : formSections){
                Section currentSection = new Section(formSection);
                formSettings.sections.add(currentSection);
                for(FormElement__c formField : formSection.FormFields__r){
                    Boolean isCalculatedOrFormula = getIsCalculatedOrFormulaField(globalDescribe, formField.ObjectAPIName__c, formField.FieldAPIName__c);
                    String fieldValue = formField.DefaultValue__c != null ? formField.DefaultValue__c : null;
                    currentSection.fields.add(new Element(formField));
                    if(!formData.containsKey(formField.ObjectAPIName__c)){
                    	SObject obj = globalDescribe.get(formField.ObjectAPIName__c).newSobject();
                        formData.put(formField.ObjectAPIName__c, obj);
                    }
                    if(!isCalculatedOrFormula){
                        formData.get(formField.ObjectAPIName__c).put(formField.FieldAPIName__c, fieldValue);
                    }else{
                        formData.put(formField.ObjectAPIName__c, addNonEditableField(JSON.serialize(formData.get(formField.ObjectAPIName__c)), formField.FieldAPIName__c, fieldValue,formField.FieldType__c, formField.ObjectAPIName__c));
                    }
                }
            }
        }else{
            throw new FormConstructionException('No Form was found with name: ' + formUniqueName);
        }
    }
    
    private static void runMethod(String className, Map<String, SObject> formData, String recordId){
        Type t  = Type.forName(className);
        if(t != null){
            FormRetrievalInterface formRetrieval = (FormRetrievalInterface)t.newInstance();
            formData = formRetrieval.execute(formData, recordId);
        }
    }
    
    public static FormResponseWrapper saveForm(String formSettingsString, Map<String, SObject> formData){
        FormSettings formSettings = (FormSettings)JSON.deserialize(formSettingsString, FormSettings.class);
        if(!Test.isRunningTest()){
            Type t  = Type.forName(formSettings.saveClass);
            if(t != null){
                FormSaveInterface formSave = (FormSaveInterface)t.newInstance();
                return formSave.execute(formData);
            }
        }
        return null;
    }
    /*
		As a work around to add non editable fields to the form data, we serialize the object, add the field, then deserialize it.
	*/
    private sObject addNonEditableField(String serializedObject, String fieldApiName, String fieldValue, String fieldType, String objectType){
        serializedObject = serializedObject.substring(0, serializedObject.lastIndexOf('}'));
        if(fieldValue != null)
			serializedObject = serializedObject + ',"' + fieldApiName + '":"' + fieldValue + '"}';
        else{
             	serializedObject = serializedObject + ',"' + fieldApiName + '":null}';
            
        }
        system.debug('serializedobj' + serializedObject);
        return (SObject)JSON.deserialize(serializedObject, Type.forName(objectType));
        
    }
    
    private Boolean getIsCalculatedOrFormulaField(Map<String,Schema.SObjectType> globalDescribe, String objName, String fieldName){
        return fieldName == 'createdDate' ||
            fieldName == 'lastModifiedDate' || 
            globalDescribe.get(objName).getDescribe().fields.getMap().get(fieldName).getDescribe().isCalculated() || 
            globalDescribe.get(objName).getDescribe().fields.getMap().get(fieldName).getDescribe().isAutonumber();
    }
    
    class FormConstructionException extends Exception{}
    
    @TestVisible
    class FormSettings{
        public String saveClass;
        public String retrievalClass;
        public String styleClass;
        public String uniqueFormName;
        public List<Section> sections;
        
        public FormSettings(String uniqueFormName, String styleClass, String retrievalClass, String saveClass){
            this.styleClass = styleClass;
            this.uniqueFormName = uniqueFormName;
            this.sections = new List<Section>();
            this.retrievalClass = retrievalClass;
            this.saveClass = saveClass;
        }
    }
    class Section{
        public String SectionTitle;
        public String styleClass;
        public Integer order;
        public List<Element> fields;
        public String sectionWidth;
        
        public Section(FormSection__c formSection){
            this.sectionTitle = formSection.SectionTitle__c;
            this.styleClass = formSection.StyleClass__c;
            this.order = (Integer)formSection.Order__c;
            this.fields = new List<Element>();
            this.sectionWidth = formSection.ColumnWidth__c;
            if(formSection.FormFields__r.isEmpty()){
                throw new FormConstructionException('A section does not have any field');
            }
        }
    }
    class Element{
        public String objApiName;
        public String apiName;
        public String displayType;
        public String label;
        public String placeHolder;
        public String helpText;
        public Boolean isRequired;
        public Boolean readOnly;
        public String defaultValue;
        public String styleClass;
        public List<String> picklistValues;
        public Boolean hasValidation;
        public String validationErrorMessage;
        public String validationRegExp;
        public String fieldMask;
        public Integer maxLength;
        public Boolean hasConfirmation;
        public String confirmationLabel;
        public String confirmationPlaceholder;
        public String confirmationErrMessage;
        public Integer textAreaRows;
        
        public Element(FormElement__c field){
            this.objApiName = field.ObjectAPIName__c;
            this.apiName = field.FieldAPIName__c;
            this.displayType = field.FieldType__c;
            this.textAreaRows = Integer.valueOf(field.TextAreaRows__c);
            this.label = field.FieldLabel__c;
            this.placeHolder = field.PlaceHolder__c;
            this.helpText = field.HelpText__c;
            this.isRequired = field.IsRequired__c;
            this.readOnly = field.ReadOnly__c;
            this.defaultValue = field.defaultValue__c;
            this.styleClass = field.StyleClass__c;
            this.picklistValues = field.PicklistValues__c != null ? field.PicklistValues__c.split(';') : null;
            if(field.FormValidation__r != null){
                this.hasValidation = field.FormValidation__r.Status__c == 'Active' ? field.FormValidation__r != NULL : false;
                this.validationErrorMessage = field.FormValidation__r.Status__c == 'Active' ? field.FormValidation__r.ErrorMessage__c : null;
                this.validationRegExp = field.FormValidation__r.Status__c == 'Active' ? field.FormValidation__r.RegularExpression__c : null;
            }
            this.maxLength = (Integer)field.MaxLength__c;
            this.hasConfirmation = field.ConfirmationRequired__c;
            this.confirmationLabel = field.ConfirmationLabel__c;
            this.confirmationPlaceholder = field.ConfirmationPlaceholder__c;
            this.confirmationErrMessage = field.ConfirmationError__c;            
            
        }
    }
}