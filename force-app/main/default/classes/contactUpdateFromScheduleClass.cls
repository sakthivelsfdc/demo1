global class contactUpdateFromScheduleClass implements Schedulable {
    /*
	This is a ScheduleClass to run every hours after 6 mins to update contact records
	*/
	// Execute below code in developer console
	// It schedules this class to run every hour after 6 minutes (like 8:06, 9:06, 10:06, etc..)
	// This is one minute after the exchange rates are fetched from Open Exchange Rates.
	/*
	contactUpdateFromScheduleClass contactUpdate = new contactUpdateFromScheduleClass();
	// Seconds Minutes Hours Day_of_month Month Day_of_week optional_year
	String schedule = '0 6 * * * ?';
	String jobID = System.schedule('Contact Update', schedule, contactUpdate);
	*/
	
	global void execute(SchedulableContext sc)  {

		//Fetch to All Contact Records       
		List<Contact> listContact = new List<Contact>([SELECT Id, FirstName, LastName, Email
								    FROM Contact]);
		// Loop through list and update Contact Name
		for (Contact con : listContact){
		    con.Description = con.FirstName + ' - ' + con.LastName +' Update from Schedulable Class';       
		}

		update listContact;
	}
}