({
	afterRender : function(component, event, helper) {
        this.superAfterRender();
        
        var componentName = component.get("v.item.menu.ComponentName");
        if(componentName){            
            $A.createComponent(componentName,{},
                function(newcomponent){
                   if(component.isValid()){
                       var dynamicComponent = component.get("v.dynamicComponent");
                       dynamicComponent.push(newcomponent);
                       component.set("v.dynamicComponent", dynamicComponent);
                    }
                }              
        	);
        }
        var url = '/sfsites/c/resource/DiageoCMS__Assets/Assets/Icons/' + component.get("v.item").iconName;
        var divIcon = component.getElement().getElementsByClassName('div-icon')[0];
        var mask = `
            -webkit-mask: url(${url}) no-repeat 50% 50%;
            -moz-mask: url(${url}) no-repeat 50% 50%;
            -o-mask: url(${url}) no-repeat 50% 50%;
            -ms-mask: url(${url}) no-repeat 50% 50%;
            mask: url(${url}) no-repeat 50% 50%;
        `
        var a = `<style type="text/css" id="icon">
        .div-icon:after{
            ${mask}
        }
        </style>`
        component.set("v.mask", a);
    }
})