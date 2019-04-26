public class FormResponseWrapper {
 		public String status{get;set;}
        public String message{get;set;}
        public String newUserId{get;set;}

        public FormResponseWrapper() {
            this.status = 'new';
            this.message = null;
            this.newUserId = '';
        }
    	public FormResponseWrapper(String status, String message) {
            this.status = status;
            this.message = message;
        }
}