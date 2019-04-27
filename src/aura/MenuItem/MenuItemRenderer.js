({
	afterRender : function(component, event, helper) {
		this.superAfterRender();

		var delayEndTime;
		if( !component.get("v.component").HasDelay){
			delayEndTime = 1;
		} else{
			delayEndTime = component.get('v.component').DelayTime;
		}

		if(component.get("v.item").subMenus.length > 0){
            var index = component.get('v.index');
            var menuLevel = component.get('v.menuLevel');
            var divEl = component.getElement().getElementsByClassName('div-' + menuLevel + '-' + index)[0];
            if(menuLevel < 2){
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
	}
})