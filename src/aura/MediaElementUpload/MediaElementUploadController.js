({
    doInit: function (component, event, helper) {
        helper.getMediaElementRecord(component, helper);
    },

    handleUploadFinishedDesktop: function (component, event, helper) {
        var uploadedFiles = event.getParam("files");
        helper.retrieveFile(component, helper, uploadedFiles[0].documentId, uploadedFiles[0].name, 'Desktop');
    },
    
    handleUploadFinishedTablet: function (component, event, helper) {
        var uploadedFiles = event.getParam("files");
        helper.retrieveFile(component, helper, uploadedFiles[0].documentId, uploadedFiles[0].name, 'Tablet');
    },
 
    handleUploadFinishedMobile: function (component, event, helper) {
        var uploadedFiles = event.getParam("files");
        helper.retrieveFile(component, helper, uploadedFiles[0].documentId, uploadedFiles[0].name, 'Mobile');
    },

    handleSelect: function (cmp, event, helper) {
        // This will contain the string of the "value" attribute of the selected
        // lightning:menuItem
        var selectedMenuItemValue = event.getParam("value");
        helper.menuSelected(cmp,helper,selectedMenuItemValue);
    }

})