global class FormResponseWrapper {
 		global String status{get;set;}
        global String message{get;set;}
        global String newUserId{get;set;}

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
