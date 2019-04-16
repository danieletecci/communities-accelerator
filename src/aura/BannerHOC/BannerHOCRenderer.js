({
	afterRender: function (component, helper) {
	    var afterRend = this.superAfterRender();
	    // interact with the DOM here
		
		var widthTotal = component.find("cg_component").getElement().offsetWidth;
		var aspectRatios = {
			widthTotal: String(parseInt(widthTotal)) + 'px',
			height1_1:  String(parseInt(widthTotal)) + 'px',
			height1_2:  String(parseInt(widthTotal / 2)) + 'px',
			height1_3:  String(parseInt(widthTotal / 3)) + 'px',
			height1_4:  String(parseInt(widthTotal / 4)) + 'px',
			height1_5:  String(parseInt(widthTotal / 5)) + 'px',
			height1_6:  String(parseInt(widthTotal / 6)) + 'px',
			height2_1:  String(parseInt(widthTotal * 2)) + 'px',
			height3_1:  String(parseInt(widthTotal * 3)) + 'px',
			height4_1:  String(parseInt(widthTotal * 4)) + 'px',
			height5_1:  String(parseInt(widthTotal * 5)) + 'px',
			height6_1:  String(parseInt(widthTotal * 6)) + 'px'
		};
		component.set('v.aspectRatios', aspectRatios);

		return afterRend;
	}
})