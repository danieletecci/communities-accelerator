({
    afterRender : function(component, helper){
        this.superAfterRender();
        if(component.get('v.inputValue') == null){
            helper.validateWithoutErrorMessage(component, event, helper);
        }else{
            helper.validate(component, event, helper);
        }
    },
    
    unrender : function(component){
        this.superUnrender();
        component.destroy();
    }
})