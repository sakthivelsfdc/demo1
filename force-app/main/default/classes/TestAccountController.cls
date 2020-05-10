@isTest
private class TestAccountController{

	@testSetup static void setup(){

		Account accountObj = new Account (
			Type ='Prospect', 
			Phone = '1234567890', 
			Website = 'www.google.com', 
			Industry ='Agriculture', 
			Name = 'test value'
		);
		insert accountObj;
		 
	}

	@isTest static void testMethod1() {
		// code_block	
	}

	@isTest static void testMethod2() {
		// code_block	
	}
}