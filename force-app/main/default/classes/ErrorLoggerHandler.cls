public with sharing class ErrorLoggerHandler {

    private static List<Error_Log__c> exceptions = new List<Error_Log__c>();
    private static List<Error_Log__c> events = new List<Error_Log__c>();
    private static Error_Log__c log = new Error_Log__c(Message__c='');
    private static List<Error_Log__c> calloutLogs = new List<Error_Log__c>();
    
    private static Id recordtypeIdException = Schema.SObjectType.Error_Log__c.getRecordTypeInfosByName().get('Exception').getRecordTypeId();
    private static Id recordtypeIdDebug = Schema.SObjectType.Error_Log__c.getRecordTypeInfosByName().get('Debug').getRecordTypeId();
    private static Id recordtypeIdEvent = Schema.SObjectType.Error_Log__c.getRecordTypeInfosByName().get('Event').getRecordTypeId();
    private static Id recordTypeIdCallout = Schema.SObjectType.Error_Log__c.getRecordTypeInfosByName().get('Callout').getRecordTypeId();
    private static Boolean enableDebugging = Logger_Settings__c.getInstance().Enable_Debugging__c;
    
    public static void error(Exception e, String function) {
        if(!isCustomValidationException(e)) {
            Error_Log__c newException = new Error_Log__c();
        
            newException.Message__c = e.getMessage();
            newException.Exception_Type__c = e.getTypeName();
            newException.Line_Number__c = e.getLineNumber();
            newException.Stack_Trace__c = e.getStackTraceString();
            newException.RecordTypeId = recordtypeIdException;
            newException.User__c = UserInfo.getUserId();
            newException.Function__c = function;
            exceptions.add(newException);
        }
    }
 
    public static void error(Exception e){
        
        if(!isCustomValidationException(e)) {
            Error_Log__c newException = new Error_Log__c();
        
            newException.Message__c = e.getMessage();
            newException.Exception_Type__c = e.getTypeName();
            newException.Line_Number__c = e.getLineNumber();
            newException.Stack_Trace__c = e.getStackTraceString();
            newException.RecordTypeId = recordtypeIdException;
            newException.User__c = UserInfo.getUserId();
    
            exceptions.add(newException);
        }
        
    }
    
    public static void debug(String message, String function){
    
        if (enableDebugging){

            DateTime currentDateTime = datetime.now();
            String currentDate = currentDateTime.format('MMMMM dd, yyyy hh:mm:ss SSS');
            
            log.Message__c += currentDate + ' | ' + message + '\n\n';
            log.recordTypeId = recordtypeIdDebug;
            log.User__c = UserInfo.getUserId();
            log.Function__c = function;
            System.debug(message);
        } 
    }

    public static void debug(String message){
    
        if (enableDebugging){

            DateTime currentDateTime = datetime.now();
            String currentDate = currentDateTime.format('MMMMM dd, yyyy hh:mm:ss SSS');
            
            log.Message__c += currentDate + ' | ' + message + '\n\n';
            log.recordTypeId = recordtypeIdDebug;
            log.User__c = UserInfo.getUserId();
            System.debug(message);
        } 
    }

    public static void event(Id recordId, String message, String function) {

        Error_Log__c newEvent = new Error_Log__c();
    
        newEvent.Message__c = message;
        newEvent.RecordTypeId = recordtypeIdEvent;
        newEvent.User__c = UserInfo.getUserId();
        newEvent.Function__c = function;
        /*
        newEvent.Payment__c = null != recordId && getObjectName(recordId).equalsIgnoreCase('cve__Payment__c') 
                ? recordId : null;
        newEvent.Payment_Specification__c = null != recordId && getObjectName(recordId).equalsIgnoreCase('cve__PaymentSpecification__c') 
                ? recordId : null;    
        */                     
        events.add(newEvent);
    }



    public static void saveEvent(Id recordId, String message, String function){        

        event(recordId, message, function);
        insert events;
        events = new List<Error_Log__c>();
    }
    
    
    public static void save(){
        
        insert exceptions;
        exceptions = new List<Error_Log__c>();
                    
        if (log.Message__c != ''){
            Blob theBlob = Blob.valueOf(log.Message__c);
            log.Message__c = log.Message__c.abbreviate(130000);
            insert log;
            
            Attachment att = new Attachment();
            att.Body = theBlob;
            att.name = 'debug.txt';
            att.ParentId = log.Id;
            insert att; 
            
            log = new Error_Log__c(Message__c='');    
        }
    }
    
    public static void saveError(Exception e){
        error(e);
        save();
    }
    
    public static void saveError(Exception e, String function){
        error(e,function);
        save();
    }    

    public static void logCallout(String calloutEndpoint, String calloutRequestMethod, String requestPayload, String responsePayload, String responseStatusCode, String methodName) {
        Error_Log__c log = new Error_Log__c();

        log.User__c = UserInfo.getUserId();
        log.RecordTypeId = recordTypeIdCallout;
        log.Callout_Endpoint__c = calloutEndpoint;
        log.Callout_Request_Method__c = calloutRequestMethod;
        log.Request_Payload__c = requestPayload; 
        log.Response_Payload__c = responsePayload;
        log.Response_Status_Code__c = responseStatusCode;
        log.Stack_Trace__c = methodName;        

        calloutLogs.add(log);
    }


    public static void saveCalloutLogs() {
        saveCalloutLogs(false);
    }

    public static void saveCalloutLogs(Boolean useAsync) {
        if (calloutLogs.size() > 0) {
            if (useAsync) {
                System.enqueueJob(new ErrorLoggerQueueableJob(calloutLogs));  
            } else {            
                insert calloutLogs;
            }
            calloutLogs = new List<Error_Log__c>();
        }
    }


    private static String getObjectName(Id recordId) {
        return  recordId.getSObjectType().getDescribe().getName();   
    }     

    private static boolean isCustomValidationException(Exception e) {
        return e != null && e.getMessage() != null && e.getMessage().contains('FIELD_CUSTOM_VALIDATION_EXCEPTION');
    }

}