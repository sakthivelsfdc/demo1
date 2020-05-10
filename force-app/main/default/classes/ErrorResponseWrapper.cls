public class ErrorResponseWrapper {

    @AuraEnabled
    public List<Error> errors;

    public ErrorResponseWrapper() {

    }

    public class Error {
        @AuraEnabled
        public String message;
        @AuraEnabled
        public String code;
        @AuraEnabled
        public String source;
        @AuraEnabled
        public String type;
        @AuraEnabled
        public String field;
        @AuraEnabled
        public String additionalErrorMessage;
    }
}