({
    doInit:function(component,event,helper){
        var opts = component.get("v.options");
        var selectedOptions = [];
        for(var i=0; i<opts.length; i++){
            if(opts[i].isSelected){
                selectedOptions.push(opts[i]);
            }
        }
        component.set("v.selectedOptions",selectedOptions);
        helper.setValueText(component, selectedOptions.length);
    },
    openDropdown:function(component,event,helper){
        if(component.get("v.hasEditAccess")){
            $A.util.addClass(component.find('dropdown'),'slds-is-open');
            $A.util.removeClass(component.find('dropdown'),'slds-is-close');
        }
    },
    closeDropDown:function(component,event,helper){
        if(component.get("v.hasEditAccess")){
            $A.util.addClass(component.find('dropdown'),'slds-is-close');
            $A.util.removeClass(component.find('dropdown'),'slds-is-open');
        }
    },
    selectOption:function(component,event,helper){        
        var value = event.currentTarget.id.split("#BP#")[0];
        var isCheck = event.currentTarget.id.split("#BP#")[1];
        helper.selectOptionHelper(component,value,isCheck);
    },
    handleRemove:function(component,event,helper){
        console.log(event.getSource().get("v.name"));
        var value = event.getSource().get("v.name");
        helper.selectOptionHelper(component, value, 'true');
    }
})