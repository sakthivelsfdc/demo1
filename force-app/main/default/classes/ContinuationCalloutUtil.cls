public with sharing class ContinuationCalloutUtil {
    public static Continuation callout(Option op){
        StateInfo state = new StateInfo();
        Continuation con = callout(op, state);
        return con; 
    }

    public static Continuation callout(Option op, StateInfo state){
        Http http = new Http();
        HttpRequest req = new HttpRequest(); 
        req.setEndpoint(op.endpoint); 
        req.setMethod(op.method);

        if(op.method != 'GET'){
            req.setBody(op.body);
        }
        
        for(String key: op.header.keySet()){
            req.setHeader(key, op.header.get(key)); 
        }
        
        req.setTimeout(op.requestTimeout); 
        

        Continuation con = new Continuation(op.contiTimeout);
        con.ContinuationMethod = op.callbackMethod;
        con.addHttpRequest(req);

        state.endpoint = req.getEndpoint();
        state.requestPayload = req.getBody();
        state.requestMethod = req.getMethod();
        con.state = state;
        return con;
    }

    public class Option{
        public String endpoint{get;set;}
        public Map<String, String> header{get; private set;} 
        public String body{get;set;}

        public Option(String endpoint, String httpMethod){
            init(endpoint, httpMethod);
        }
    
        public Option(String settingName, Map<String, String> valueMap){

            Connector_Settings__c settings = Connector_Settings__c.getAll().get(settingName);            
            String url = settings.End_Point_URL__c;
            for(String key : valueMap.keySet()){
                String placeholder = '${' + key + '}';
                url = url.replace(placeholder, valueMap.get(key));
            }
            if(String.isBlank(url)){
                throw new ApplicationException(settingName + ' setting is missing');
            }
            init(url, settings.HTTP_Method__c);
        }

        private void init(String endpoint, String httpMethod){
            this.endpoint = endpoint;
            this.method = httpMethod;

            header = new Map<String, String>();
            header.put('Content-Type','application/json');
        }
        
        public String callbackMethod{
            get{return callbackMethod == null? 'callback': callbackMethod;}
            set{callbackMethod = value;}
        }

        public String method{
            get{return method == null ? 'GET' : method;}
            set{method = value;}
        }

        public Integer contiTimeout{
            get { return contiTimeout == null ? 120 : contiTimeout;}
            set {contiTimeout= value;}
        }

        public Integer requestTimeout{
            get { return requestTimeout == null ? 120000 : requestTimeout;}
            set { requestTimeout = value;}
        }
        
    }

    public class StateInfo{
        public String methodName{get;set;} //Used for logging purpose. Format: 'ApexClassName.methodName'
        public Id recordId{get;set;}
        public String endpoint{get;set;}
        public String requestMethod{get;set;}
        public String requestPayload{get;set;}
        public Map<String, String> context{get;set;}
        public StateInfo(){
            this.context = new Map<String, String>();
        }
    }
}