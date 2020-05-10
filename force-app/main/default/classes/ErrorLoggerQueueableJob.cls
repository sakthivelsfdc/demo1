public with sharing class ErrorLoggerQueueableJob implements Queueable {
    private List<Error_Log__c> logs{get;set;}

    public ErrorLoggerQueueableJob(List<Error_Log__c> logs) {
        this.logs = logs;
    }

    public void execute(QueueableContext context) {
        if (logs.size() > 0) {
            insert logs;
        } 
    }

}