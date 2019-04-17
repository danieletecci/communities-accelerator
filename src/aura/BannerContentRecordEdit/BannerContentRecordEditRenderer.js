({
	afterRender : function(component){
		this.superAfterRender();
		var overlayQuadrant = component.get('v.contentData.OverlayQuadrant');
		if(overlayQuadrant && document.getElementById(overlayQuadrant)){
			document.getElementById(overlayQuadrant).classList.add('selectedLayout');
		}
	}
})