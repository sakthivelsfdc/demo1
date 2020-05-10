public with sharing class generateStoneWebPage {
    @AuraEnabled 
    public static List<ContentVersion> fetchContentDocument(id recordId){

        List<ContentDocumentLink> contentDocumentLinkList = [SELECT ContentDocumentId FROM ContentDocumentLink WHERE LinkedEntityId =:recordId];
        set<Id> documentIds = new set<Id>();
        if(contentDocumentLinkList != null) {
            for(ContentDocumentLink cd: contentDocumentLinkList) {
                documentIds.add(cd.ContentDocumentId);
            }
        }
        //Select Id ,Title from ContentDocument Where ID In :[CONTENTDOCUMENTLIST]
        //[SELECT Id, LinkedEntityId, ContentDocumentId,Visibility, IsDeleted, ShareType,ContentDocument.Title,ContentDocument.createdDate, ContentDocument.FileType FROM ContentDocumentLink WHERE LinkedEntityId =:parentIds and ContentDocument.FileType!= 'SNOTE'];
        //SELECT Id, ContentDocumentId, ContentUrl, IsLatest, ContentBodyId, VersionNumber, Description, Title, ContentSize, VersionData, FileExtension, PublishStatus, FileType, TextPreview, ContentLocation, Origin, FirstPublishLocationId, Category__c FROM ContentVersion Where ContentDocumentId='0690k000000lov6AAA'
        //return [Select Id, Title, FileType, FileExtension, CreatedBy.Name, ContentSize From contentDocument where Id=: documentIds];

        return [SELECT Id, ContentDocumentId, ContentUrl, IsLatest, ContentBodyId, VersionNumber, Description, Title, ContentSize, 
                    VersionData, FileExtension, PublishStatus, FileType, TextPreview, ContentLocation, Origin, FirstPublishLocationId, Category__c,
                    CreatedDate 
                    FROM ContentVersion 
                    Where ContentDocumentId =:documentIds];
    }
}