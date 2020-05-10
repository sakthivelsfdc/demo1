trigger AccountTrigger on Account(before insert, before update) {
    
    for (Account acc : Trigger.New) {
        if(acc.Name == 'THEBLOGREADERS.COM') {   
            acc.AddError('THEBLOGREADERS.COM is not allowed for Account Creations');
        }
    }
}