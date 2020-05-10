/**
 * @File Name          : AccountController.cls
 * @Description        : 
 * @Author             : ChangeMeIn@UserSettingsUnder.SFDoc
 * @Group              : 
 * @Last Modified By   : ChangeMeIn@UserSettingsUnder.SFDoc
 * @Last Modified On   : 5/10/2020, 11:17:41 AM
 * @Modification Log   : 
 * Ver       Date            Author      		    Modification
 * 1.0    5/10/2020   ChangeMeIn@UserSettingsUnder.SFDoc     Initial Version
**/
public with sharing class AccountController {

    integer numValue =0;
    string accountName;
    
    //Demo 
    @AuraEnabled
    public static List<Account> findAll() {
    return [SELECT id, name, website
            FROM Account
            Where Website != NULL LIMIT 10];
    } 

    @AuraEnabled (cacheable = true)
    public static List<Account> searchAccount(String accName) {
        string strAccName = '%'+ accName + '%';
        return [Select Id, Name, Type, Industry, Phone, Website from Account WHERE Name LIKE: strAccName ];
    }

    
    @AuraEnabled(Cacheable = true)
    public static List<Account> getAccount(){
        return [Select Id, Name, Type, Industry, Phone, Website FROM Account ORDER BY Name limit 5];
    }

     @AuraEnabled(Cacheable = true)
    public static List<Account> getAllAccount(){
        return [Select Id, Name, Type, Industry, Phone, Website FROM Account ORDER BY Name];
    }
    
    @AuraEnabled
    public static void deleteAccount(list<Id> lstAccountIds){
        try {
            list<Account> lstAccountToDelete = new list<Account>();
            System.debug('lstAccountIds ====> '+lstAccountIds);
            for(Id idAcc : lstAccountIds) {
                lstAccountToDelete.add(new Account(Id = idAcc));
            }
            if(!lstAccountToDelete.isEmpty()) {
                delete lstAccountToDelete;
            }
        }
        catch(Exception ex) {
            throw new AuraHandledException(ex.getMessage());
        }
    }
    
    /*
    Method: retriveAccount
    Para: strDate
    here passing the date format 2014-07-07 and fetching all the account records based on the last modified date
    */
    public static list<Account> retriveAccount(String strDate) {
         list<Account> lstAccount;
         if(strDate != '') { 
             strDate = strDate +' 00:00:00';
             system.debug('strDate:::::'+strDate);
             
             DateTime dt = DateTime.valueOf(strDate);
             
             lstAccount = [Select Id, Name from Account where LastModifiedDate >=: dt];
             system.debug('lstAccount::::' + lstAccount);
         }
         return lstAccount;  
    }
    
    /*
    Method: updateAccount
    Para: AccountId, Fname
    here passing the Account Id and Name values and its updated to respective account
    */
    public static void updateAccount(Id AccountId, String Fname) {
         
         try {
             if(AccountId != null && Fname !='') {
                 list<Account>  lstAccount = [Select Id, Name from Account where Id =: AccountId];
                 lstAccount[0].name = Fname;
                 update lstAccount[0];
             }
         } catch (DMLException ex) {
            system.debug('Error:' + ex);        
         }
    }

}