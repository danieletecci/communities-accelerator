({
    onInit: function(component, event, helper) {
        helper.init(component, event, helper);;
    },
    handleChangeCards: function(component, event, helper) {
        helper.displayCards(component, event, helper);
    },
    handleChangeCurrentPage: function(component, event, helper) {
        //helper.updateDots(component, event, helper);
    },
    handleClickDot: function(component, event, helper) {
        var page = parseInt(event.target.dataset.page,10);
        helper.scrollToPage(component, event, helper, page);
    },
    handleClickPrevious: function(component, event, helper) {
        helper.goToPreviousPage(component, event, helper);
    },
    handleClickNext: function(component, event, helper) {
        helper.goToNextPage(component, event, helper);
    }
})