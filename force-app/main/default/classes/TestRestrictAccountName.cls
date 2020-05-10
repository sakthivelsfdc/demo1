@isTest
private class TestRestrictAccountName {
    @isTest static void test() {
        Account acc = new Account(Name = 'THEBLOGREADERS.COM');
        Database.SaveResult result = Database.insert(acc, false);
        System.assertEquals('THEBLOGREADERS.COM is not allowed for Account Creations',result.getErrors()[0].getMessage());
    }
}