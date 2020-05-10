public without sharing class CalloutErrorHandler {

    public static void checkAndHandleErrors(HttpResponse response, Object state, Boolean dmlAsync) {
        Integer statusCode = response.getStatusCode();
        String responsePayload = response.getBody();
        ContinuationCalloutUtil.StateInfo stateInfo = (ContinuationCalloutUtil.StateInfo) state; 
        Boolean isDebuggingOn = Logger_Settings__c.getInstance().Enable_Debugging__c;
        system.debug('isDebuggingOn::'+isDebuggingOn);
        system.debug('statusCode::'+statusCode);
        //log errors, if errors exist 
        if (statusCode >= 400 && statusCode < 500) {
            if (isDebuggingOn) {
                ErrorLoggerHandler.logCallout(stateInfo.endpoint, stateInfo.requestMethod, stateInfo.requestPayload, responsePayload, String.valueOf(statusCode), stateInfo.methodName);                
            } else {
                removeTechnicalErrorMessage(response);
            }
        } else if (statusCode >= 500 && statusCode < 600) {
            ErrorLoggerHandler.logCallout(stateInfo.endpoint, stateInfo.requestMethod, stateInfo.requestPayload, responsePayload, String.valueOf(statusCode), stateInfo.methodName);
            if (!isDebuggingOn) {
                removeTechnicalErrorMessage(response);
            } 
        } else if (!(statusCode >= 200 && statusCode < 300)) {
            ErrorLoggerHandler.logCallout(stateInfo.endpoint, stateInfo.requestMethod, stateInfo.requestPayload, responsePayload, String.valueOf(statusCode), stateInfo.methodName);
            if (!isDebuggingOn) {
                removeTechnicalErrorMessage(response);
            }
        }     
        ErrorLoggerHandler.saveCalloutLogs(dmlAsync);
    }

    private static void removeTechnicalErrorMessage(HttpResponse response) {
        String jsonString = response.getBody();
        
        ErrorResponseWrapper errorRes = (ErrorResponseWrapper) JSON.deserialize(jsonString, ErrorResponseWrapper.class);
        for (ErrorResponseWrapper.Error err : errorRes.errors) {
            err.additionalErrorMessage = ''; 
        }

        response.setBody(JSON.serialize(errorRes));
    }
}