({
    doInit : function(component, event, helper) {
        var formData = component.get("v.formData");
        var fieldConfiguration = component.get("v.fieldConfiguration");
        var defaultValueSet = false;
        if(formData) {
            //We set the input value with the formData, if there's no data for this field, we set the default value set in the form element.
            var inputValue = formData[fieldConfiguration.objApiName][fieldConfiguration.apiName];
            if(inputValue == null){
                inputValue = fieldConfiguration.defaultValue;
                if(inputValue != null){
                    defaultValueSet = true;
                }
            }
            
            //For multi-picklist and checkbox fields, we need to set the values in arrays
            if(fieldConfiguration.displayType == 'Multi-Picklist' || fieldConfiguration.displayType == 'Multi-Checkbox'){
                //We set the possible values
                var picklistValues = fieldConfiguration.picklistValues;
                var multiPicklistValues = [];
                for(var i = 0; i < picklistValues.length ; i++){
                    multiPicklistValues.push({value:picklistValues[i], label : picklistValues[i]});
                }
                component.set("v.multiPicklistValues", multiPicklistValues);
                //we set the selected values
                if(inputValue != null)
               		component.set("v.multiPicklistSelectedValues", inputValue.split(';'));
            }
            component.set("v.inputValue", inputValue);
            if(defaultValueSet)
            	helper.setValueOnFormData(component);
        }
    },
    //This method updates the formData with the value of the field modified.
    setValueOnFormData : function(component){
        var fieldConfiguration = component.get("v.fieldConfiguration");
        var formData = component.get("v.formData");
        if(fieldConfiguration.displayType == 'Multi-Picklist' || fieldConfiguration.displayType == 'Multi-Checkbox'){
            var inputValue = component.get('v.multiPicklistSelectedValues').join(';');
            formData[fieldConfiguration.objApiName][fieldConfiguration.apiName] = inputValue;
            component.set("v.inputValue", inputValue);
        }else{
            formData[fieldConfiguration.objApiName][fieldConfiguration.apiName] = component.get("v.inputValue");
        }        
        component.set("v.lastFieldModified", fieldConfiguration.objApiName + '.' + fieldConfiguration.apiName);
        component.set("v.formData", formData);
    },
    //This method does all the validations, and sets the error message
    validate : function(component, event, helper){
        var fieldConfiguration = component.get("v.fieldConfiguration");
        var inputValue = component.get('v.inputValue');
        var validationErrors = component.get("v.validationErrors");
        
        var requiredFailed = fieldConfiguration.isRequired && !fieldConfiguration.readOnly && helper.validateNotEmpty(component, fieldConfiguration, inputValue);//Nada
        var regexFailed = fieldConfiguration.hasValidation && !fieldConfiguration.readOnly && helper.regexValidation(component, event,helper, fieldConfiguration, false);
        var confirmationFailed = fieldConfiguration.hasConfirmation && inputValue != '' && inputValue != null && helper.validateConfirmation(component, event, helper);
        //if the fieldConfiguration has no errors, we remove the error from the array and clear the error message
        if(!requiredFailed && !regexFailed && !confirmationFailed){
            helper.removeValidationError(component);
            this.updateValidationErrorObject(component, '');
            if(fieldConfiguration.hasConfirmation)
            	helper.removeValidationError(component, true);
        }else if(requiredFailed){
            helper.setValidationError(component, (fieldConfiguration.label ? fieldConfiguration.label : 'This field') + ' is required.');
            this.updateValidationErrorObject(component, 'requiredFieldErrors');
        }else if(regexFailed){
            helper.setValidationError(component, fieldConfiguration.validationErrorMessage);
            this.updateValidationErrorObject(component, 'formatErrors');
        }else if(confirmationFailed){
            helper.removeValidationError(component);
            this.setValidationError(component, fieldConfiguration.confirmationErrMessage, true);
            this.updateValidationErrorObject(component, 'confirmationErrors');
        }
    },
    //Validations done when confirmation field has been modified
    validateConfirmationOnBlur : function(component, event, helper){
        component.set('v.confirmationHasBeenModified', true);
        helper.validate(component, event, helper);
        var fieldConfiguration = component.get("v.fieldConfiguration");
        var confirmationRequiredFailed = fieldConfiguration.hasConfirmation && helper.validateNotEmptyConfirmation(component, fieldConfiguration);
        if(confirmationRequiredFailed){
            helper.setValidationError(component, fieldConfiguration.label + ' is required.', true);
            this.updateValidationErrorObject(component, 'requiredFieldErrors');
        }
    },
    //Does all the validations, but doesn't show the error messages. Mainly used on form first load.
    validateWithoutErrorMessage : function(component, event, helper){
        var fieldConfiguration = component.get("v.fieldConfiguration");
        var inputValue = component.get("v.inputValue");
        var requiredFailed = fieldConfiguration.isRequired && !fieldConfiguration.readOnly && helper.validateNotEmpty(component, fieldConfiguration, inputValue);
        var regexFailed = fieldConfiguration.hasValidation && !fieldConfiguration.readOnly && helper.regexValidation(component, event,helper, fieldConfiguration);
        var confirmationFailed = fieldConfiguration.hasConfirmation && inputValue != '' && inputValue != null && helper.validateConfirmation(component, event, helper);
        if(!requiredFailed && !regexFailed && !confirmationFailed){
            this.updateValidationErrorObject(component, '');
        }else if(requiredFailed){
            this.updateValidationErrorObject(component, 'requiredFieldErrors'); 
        }else if(regexFailed){
            this.updateValidationErrorObject(component, 'formatErrors');
        }else if(confirmationFailed){
            helper.removeValidationError(component);
            this.updateValidationErrorObject(component, 'confirmationErrors');
        }
    },
    
    regexValidation : function(component, event, helper, fieldConfiguration, noErrorMsg){
        var regex = new RegExp(fieldConfiguration.validationRegExp);
        var inputValue = component.get("v.inputValue");
        if(inputValue != null && inputValue != '' && !inputValue.toLowerCase().match(regex)){
            return true;
        }
        return false;
    },
    validateNotEmpty : function(component, fieldConfiguration, inputValue){
        if(inputValue == null || inputValue.length == 0){
            return true;
        }
        return false;
    },
    validateNotEmptyConfirmation : function(component, fieldConfiguration){
        var inputValue = component.get('v.confirmationInputValue');
        if(fieldConfiguration.isRequired && (inputValue == null || inputValue.length == 0)){
            return true;
        }
        return false;
    },
    
    maxLengthValidation : function(component, event, helper, fieldConfiguration, noErrorMsg){
        var inputValue = component.get("v.inputValue");
        var max = fieldConfiguration.maxLength;
        if(inputValue.length > max) {
            component.set("v.inputValue", inputValue.substring(0,max));
            //MIGRACION
			//AGREGAR SETEO DE ERROR USANDO LABEL, VER EN DEV4
        }else{
            if(component.get('v.fieldConfiguration.displayType')== 'Numeric'){
                component.set("v.inputValue", inputValue.replace(' ',''));
            }
        }  
    },
    /*
    	This method validates the confirmation fieldConfiguration
    */
    validateConfirmation : function(component, event, helper){
        var inputValue = component.get('v.inputValue');
        var confirmationInputValue = component.get('v.confirmationInputValue');
        if(inputValue != confirmationInputValue){
            return true;
        }else{
            return false
        }
    },
    updateValidationErrorObject : function(component, errorType){
        var fieldConfiguration = component.get('v.fieldConfiguration');
        var previousValidationError = component.get("v.previousValidationError");
        var validationErrors = component.get("v.validationErrors");
        
        //If error type is different than the previous one then we need to remove the error from the other error array
        if(previousValidationError != errorType){
            if(previousValidationError != null && previousValidationError != ''){
                var arrayOfErrors = validationErrors[previousValidationError];
                for(var i = 0; i < arrayOfErrors.length; i++){ 
                    if ( arrayOfErrors[i] === fieldConfiguration.objApiName + '.' + fieldConfiguration.apiName) {
                        arrayOfErrors.splice(i, 1); 
                    }
                }
            }
            //Add error to errortype array
            if(errorType != ""){
                if(!validationErrors[errorType]){
                    validationErrors[errorType] = [];
                }
                validationErrors[errorType].push(fieldConfiguration.objApiName + '.' + fieldConfiguration.apiName);
            }
            if((!validationErrors.requiredFieldErrors || validationErrors.requiredFieldErrors.length == 0) && 
               (!validationErrors.formatErrors || validationErrors.formatErrors.length == 0) && 
               (!validationErrors.confirmationErrors || validationErrors.confirmationErrors.length == 0)){
                validationErrors.formHasErrors = false;
            }else{
                validationErrors.formHasErrors = true;
            }
            component.set("v.validationErrors", validationErrors);
        }
        component.set("v.previousValidationError", errorType);
    },
    //Styles the field as error, and displays the error message
    setValidationError : function(component, msg, isConfirmationError){
        if(isConfirmationError){
            if(component.get('v.confirmationHasBeenModified')){
                component.find("confirmation-error-msg").getElement().innerHTML = msg;
                component.set("v.onConfirmationError", true);
            }
        }else{
            component.find("error-msg").getElement().innerHTML = msg;
        	component.set("v.onError", true);
        }
        
	},
    //removes the error style on the field, and stops displaying error message
    removeValidationError : function(component, isConfirmationError){
        if(isConfirmationError){
            component.find("confirmation-error-msg").getElement().innerHTML = "";
        	component.set("v.onConfirmationError", false);
        }else{
            component.find("error-msg").getElement().innerHTML = "";
        	component.set("v.onError", false);
        }
    }
})