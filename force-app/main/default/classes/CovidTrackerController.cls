/*
* This Apex class is used to  
* Author:-  
* Description:- 
* Date:- 
* Comments:- 
*/
public with sharing class CovidTrackerController {

    public static final string covid19Summary = Connector_Settings__c.getAll().get('Covid19 Summary').End_Point_URL__c;

    /*
    * This method is used to  
    * param:- 
    */ 
    //getCovidSummary
    @AuraEnabled(continuation=true cacheable=true)
    public static Continuation getCovidSummary(){ 
        //String endpoint = 'https://api.covid19api.com/summary'; // add End Point URL in Remote Site Settings (from Setup -> Security ->Remote Site Settings)
        //String endpoint = covid19Summary;
                    String endpoint = 'https://premiumalter.getsandbox.com/error_handler';
        return requestGenerator('GET', endpoint, null, 'CovidTrackerController.getCovidSummary');
    }

    // passing http method and end point url
    public static Continuation requestGenerator(String httpMethod, String requestUrl, String requestPayload, String apexMethodName){
        /*
        HttpRequest req = new HttpRequest();
        req.setEndpoint(requestUrl);
        req.setMethod(httpMethod);

        Continuation con = new Continuation(120);
        con.ContinuationMethod = 'callback';
        con.addHttpRequest(req);
        return con;
        */
                ContinuationCalloutUtil.Option option = new ContinuationCalloutUtil.Option(requestUrl, httpMethod);
                option.body = requestPayload;
        ContinuationCalloutUtil.StateInfo state = new ContinuationCalloutUtil.StateInfo();
        state.methodName = apexMethodName;

        return ContinuationCalloutUtil.callout(option, state); 
    }
 
    @AuraEnabled(cacheable=true) 
    public static Object callback(List<String> labels, Object state) {
        //HttpResponse res = Continuation.getResponse(labels[0]); 
        //system.debug('res:'+res);
        //return res.getBody();

        HttpResponse res = Continuation.getResponse(labels[0]); 
        CalloutErrorHandler.checkAndHandleErrors(res, state, true);
        return res.getBody();
    } 
}