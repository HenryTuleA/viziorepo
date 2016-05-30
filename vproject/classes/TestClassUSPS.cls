/**
 * Test class to test the USPS interface
 * VizioSupport_USPS; VizioSupport_USPSAddress; VizioSupport_USPSHttpCalloutMock;
 * VizioSupport_USPSAddress_Comp_Controller
 *
 * @author		Stela Zhang
 * @version		1.0
 * @since		1.0
 */
 
@isTest (SeeAllData=false)
private class TestClassUSPS {
	
	
	static testMethod void TestUSPSAddress() {
			
			Test.StartTest();
			
			VizioSupport_USPSAddress MyAddress = new VizioSupport_USPSAddress();
			
			// test the has data method
				MyAddress.HasData();
				
				MyAddress.Address1 = '6406 IVY LN';
				MyAddress.HasData();
	
				MyAddress.Address1 = '';
				MyAddress.Address2 = '6406 IVY LN';
				MyAddress.HasData();
	
				MyAddress.Address2 = '';
				MyAddress.City = 'Greenbelt';
				MyAddress.HasData();			
				
				MyAddress.City = '';
				MyAddress.State = 'MD';
				MyAddress.HasData();			
	
				MyAddress.State = '';
				MyAddress.Zip5 = '20770';
				MyAddress.HasData();			
	
				MyAddress.Zip5 = '';
				MyAddress.Zip4 = '1441';
				MyAddress.HasData();			
				
				MyAddress.Zip4 = '';
				MyAddress.USPS_Returned_Error = true;
				MyAddress.HasData();
				
				MyAddress.USPS_Returned_Error = false;
				MyAddress.USPS_ERROR_CODE = 'Test';
				MyAddress.HasData();
	
				MyAddress.USPS_ERROR_CODE = '';
				MyAddress.USPS_ERROR_DESC = 'Test';
				MyAddress.HasData();
				
				MyAddress.USPS_ERROR_DESC = '';
				MyAddress.USPS_ERROR_SOURCE = 'Test';
				MyAddress.HasData();
			
				// the object should now be empty for other testing ...
				MyAddress.USPS_ERROR_SOURCE = '';
			// end testing of has data method

			// test CanCheckAddress method			
				MyAddress.Address2 = '6406 IVY LN';
				MyAddress.Zip5 = '20770';
				MyAddress.CanCheckAddress();
	
				MyAddress.Zip5 = '';
				MyAddress.City = 'Greenbelt';
				MyAddress.State = 'MD';
				MyAddress.CanCheckAddress();
			// end testing of CanCheckAddress method
			
			// Test GetZip Method
				MyAddress.Zip5 = '20770';			
				MyAddress.Zip4 = '1441';
				MyAddress.getZip();
			// end testing of GetZip Method
			
			Test.StopTest();
		} // TestUSPSAddress
		
		static testMethod void TestUSPS() {
	
		Test.StartTest();
		
		VizioSupport_USPSAddress MyAddress = new VizioSupport_USPSAddress();
		
		// will return the default address		
		VizioSupport_USPS.CheckAddress(MyAddress,'Test');
		
		// This should return an error message
		MyAddress.City = 'ERROR';
		VizioSupport_USPS.CheckAddress(MyAddress,'Test');

		// and this shoudl return a blank address 
		// so we can test the generic error message
		MyAddress.City = 'NULL';
		VizioSupport_USPS.CheckAddress(MyAddress,'Test');
		
		Test.StopTest();
	} // TestUSPS
		
		static testMethod void TestUSPS_Address_Comp_Controller() {
		
		Contact TestContact = new Contact();

		// I am using the standard USPS test request #1 here because
		// it will match the results but any address you pass in
		// during testing will return this test data.
		TestContact.MailingStreet = '6406 IVY LN';
		TestContact.MailingCity = 'GREENBELT';
		TestContact.MailingStateCode = 'MD';
		TestContact.MailingPostalCode = '20770';
		TestContact.LastName = 'Test';
		
		Test.StartTest();
		
		VizioSupport_USPSAddress_Comp_Controller MyController = new VizioSupport_USPSAddress_Comp_Controller();
		
		MyController.CurrentContact = TestContact;
		
		// setting the id makes the call out to validate the address
		// the USPS class has a mock HTML Call out class for use with testing
		// so you can set your USPS ID to any non blank value and get a result		
		MyController.USPS_USERID = 'TEST';
		
		MyController.AddressFromUSPS.getZip();
		
		MyController.UseCorrectedAddress();
		
		TestContact.MailingPostalCode = '';
		// setting the id makes the call out to validate the address
		MyController.USPS_USERID = 'TEST';
		MyController.Dismiss();
		
		// testing for AddressesAreDifferent
		MyController.AddressFromUSPS.Address1 = 'test';
		MyController.AddressesAreDifferent(false);
		
		MyController.AddressFromUSPS.Address1 = MyController.Address2Check.Address1;
		MyController.AddressFromUSPS.Address2 = 'test';
		MyController.AddressesAreDifferent(false);

		MyController.AddressFromUSPS.Address2 = MyController.Address2Check.Address2;
		MyController.AddressFromUSPS.City = 'test';
		MyController.AddressesAreDifferent(false);

		MyController.AddressFromUSPS.City = MyController.Address2Check.City;
		MyController.AddressFromUSPS.State = 'AL';
		MyController.AddressesAreDifferent(false);		

		MyController.AddressFromUSPS.State = MyController.Address2Check.State;
		MyController.AddressFromUSPS.Zip5 = '90210';
		MyController.AddressesAreDifferent(false);		

		MyController.AddressFromUSPS.Zip5 = MyController.Address2Check.Zip5;
		MyController.AddressFromUSPS.Zip4 = '1234';
		MyController.AddressesAreDifferent(false);		
		MyController.AddressesAreDifferent(true);
		// end testing for AddressesAreDifferent
		
		// testing for DidTheAddressChange
		MyController.PreviousAddress.Address2 = 'Test';
		MyController.DidTheAddressChange();

		MyController.PreviousAddress.Address2 = MyController.Address2Check.Address2;
		MyController.PreviousAddress.City = 'Test';
		MyController.DidTheAddressChange();

		MyController.PreviousAddress.City = MyController.Address2Check.City;
		MyController.PreviousAddress.State = 'AL';
		MyController.DidTheAddressChange();
		// end testing for DidTheAddressChange
		
		Test.StopTest();
		
	} // TestUSPS_Address_Comp_Controller
}