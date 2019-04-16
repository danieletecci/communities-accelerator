({
	afterRender : function(component){
		this.superAfterRender();
		var overlayQuadrant = component.get('v.contentData.OverlayQuadrant__c');
		if(overlayQuadrant && document.getElementById(overlayQuadrant)){
			document.getElementById(overlayQuadrant).classList.add('selectedLayout');
		}
	}
})