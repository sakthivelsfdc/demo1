trigger accountContentTrigger on ContentVersion (before insert, before update) {
    
    Set<Id> contentDocumentIdSet = new Set<Id>();
    
    for(ContentVersion cv:trigger.new)
    {
        if(cv.ContentDocumentId != null)
        {
            contentDocumentIdSet.add(cv.ContentDocumentId);
        }
    }
    
     Id profileId=userinfo.getProfileId();
   String profileName=[Select Id,Name from Profile where Id=:profileId].Name;
    system.debug('profileName::'+profileName);
    system.debug('contentDocumentIdSet::'+contentDocumentIdSet);
    
     for(ContentVersion documents : Trigger.New) {
    	 if (profileName == 'System Administrator'){
        	documents.addError('Can\'t Upload');
         }
  }
    
}