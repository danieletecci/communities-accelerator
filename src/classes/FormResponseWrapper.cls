global class FormResponseWrapper {
    	@AuraEnabled global String status{get;set;}
        @AuraEnabled global String message{get;set;}
        @AuraEnabled global String newUserId{get;set;}

        global FormResponseWrapper() {
            this.status = 'new';
            this.message = null;
            this.newUserId = '';
        }
    	global FormResponseWrapper(String status, String message) {
            this.status = status;
            this.message = message;
        }
}