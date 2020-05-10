@isTest 
public class contactUpdateFromScheduleClassTest {

	@isTest static void contactUpdateTest_Schedule() {

		Contact cont = new Contact(FirstName ='First Name', LastName ='Last Name', Email='sakthi@theblogreaders.com');
		insert cont;

		// Seconds Minutes Hours Day_of_month Month Day_of_week optional_year
		String CRON_EXP = '0 6 * * * ?';
		
		Test.startTest();

		String jobId = System.schedule('Update Contacts',  CRON_EXP, new contactUpdateFromScheduleClass());
		CronTrigger ct = [SELECT Id, CronExpression, TimesTriggered, NextFireTime FROM CronTrigger WHERE id = :jobId];
		System.assertEquals(CRON_EXP, ct.CronExpression);
		System.assertEquals(0, ct.TimesTriggered);
		
		Test.stopTest();

	}
         
}