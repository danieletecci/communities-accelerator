({
	afterRender : function(component, event, helper) {
		this.superAfterRender();

        var delayEndTime;
        if(component.get("v.component")){
            if(!component.get("v.component").HasDelay){
                delayEndTime = 500;
            } else{
                delayEndTime = component.get('v.component').DelayTime;
            }
        }
        var index = component.get('v.index');
        var menuLevel = component.get('v.menuLevel');

		if(component.get("v.item").subMenus.length > 0){
            var divEl = component.getElement().getElementsByClassName('div-' + menuLevel + '-' + index)[0];
            if(menuLevel < 3){
                divEl.classList.add('slds-hide');
                var liEl = component.getElement().getElementsByClassName('li-level-' + menuLevel)[0];
                var setTimeoutConst, setTimeoutConst2;
                
                liEl.addEventListener('mouseover', function(){
                    setTimeoutConst = setTimeout(function(){
                        divEl.classList.remove('slds-hide');
                    }, 100);
                    clearTimeout(setTimeoutConst2);
                })
                liEl.addEventListener('mouseout', function(){
                    clearTimeout(setTimeoutConst );
                    setTimeoutConst2 = setTimeout(function(){
                        divEl.classList.add('slds-hide');
                    },delayEndTime);
                });
            }
        }

        var url = 'sfsites/c/resource/Assets/Assets/Icons/' + component.get("v.item").iconName;
        var divIcon = component.getElement().getElementsByClassName('div-icon-' + menuLevel + '-' + index)[0];
        // var divIcon = component.getElement().querySelector('.div-icon-' + menuLevel + '-' + index)[0];
        var mask = `
            -webkit-mask: url(${url}) no-repeat 50% 50%;
            -moz-mask: url(${url}) no-repeat 50% 50%;
            -o-mask: url(${url}) no-repeat 50% 50%;
            -ms-mask: url(${url}) no-repeat 50% 50%;
            mask: url(${url}) no-repeat 50% 50%;
        `
        var a = `<style type="text/css" id="icon">
        .div-icon-${menuLevel}-${index}:after{
            ${mask}
        }
        </style>`
        component.set("v.mask", a);
	}
})