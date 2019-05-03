({
	openAccordion : function(component, event, helper){
        var btnClicked = event.currentTarget;
        var btnClickedSiblings = event.currentTarget.nextSibling;
        btnClicked.classList.toggle("active");
        btnClickedSiblings.classList.toggle("scale-out-ver-top");
        content.scrollIntoView();
    }
})