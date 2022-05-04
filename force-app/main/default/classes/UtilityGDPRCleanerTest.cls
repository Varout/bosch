/**
 * Class: UtilityGDPRCleanerTest.cls
 * @desc: Test class for UtilityGDPRCleaner
 */
@isTest
private class UtilityGDPRCleanerTest {

    /**
     * Test a random string is created different from the original of length 50
     */
    @isTest
    static void testRandomString() {
        String randomString = 'Hello World';
        randomString = UtilityGDPRCleaner.randString();

        System.assertEquals(50, randomString.length());
        System.assertNotEquals('Hello World', randomString);
    }

    /**
     * Test a random number is created different from the original of length 10
     */
    @isTest
    static void testRandomNumber() {
        Decimal randomNumber = 12345678900.0;   //  This is length 11
        randomNumber = UtilityGDPRCleaner.randNumber();

        System.assertNotEquals(12345678900.0, randomNumber);
    }

    @isTest
    static void testGetMDTFieldsAccount() {
        Map<String, String> testMap = UtilityGDPRCleaner.getMDTFieldsAccount();

        //  There is a chance the metadata is not populated, so we're testing the map is not a null value, but an empty map
        System.assertNotEquals(null, testMap);
    }

    @isTest
    static void testGetMDTFieldsCase() {
        Map<String, String> testMap = UtilityGDPRCleaner.getMDTFieldsCase();

        //  There is a chance the metadata is not populated, so we're testing the map is not a null value, but an empty map
        System.assertNotEquals(null, testMap);
    }

    @isTest
    static void testGetMDTFieldsContact() {
        Map<String, String> testMap = UtilityGDPRCleaner.getMDTFieldsContact();

        //  There is a chance the metadata is not populated, so we're testing the map is not a null value, but an empty map
        System.assertNotEquals(null, testMap);
    }

    /**
     * Expect an empty list as there will be no records created. Must not be null
     */
    @isTest
    static void testRetrieveGeneratedDebugRecords() {
        List<Debug_Log__c> testDebugLogs = UtilityGDPRCleaner.retrieveGeneratedDebugRecords();

        System.assertNotEquals(null, testDebugLogs);
        System.assert(testDebugLogs.isEmpty());
    }

    @isTest
    static void testCreateBaseDebugLog() {
        Debug_Log__c testDebugLog = UtilityGDPRCleaner.createBaseDebugLog('UtilityGDPRCleanerTest', '00100000djbFkel');

        System.assertEquals('UtilityGDPRCleanerTest', testDebuglog.Class_Name__c);
        System.assert(testDebuglog.Related_Record_Id__c.contains('00100000djbFkel'));
    }

    /**
     * Manually define the metadata values to test all exceptions are handled correctly
     */
    @isTest
    static void testCleanAccountsOne() {
        Account testAccount = createGDPRAccount();
        UtilityGDPRCleaner.metadataFieldsAccount = new Map<String, String>();
        UtilityGDPRCleaner.metadataFieldsAccount.put('Name', 'Lookup');
        UtilityGDPRCleaner.metadataFieldsAccount.put('BillingStreet', 'Text');
        UtilityGDPRCleaner.metadataFieldsAccount.put('', 'Text');
        UtilityGDPRCleaner.metadataFieldsAccount.put('Desc', 'Text');
        UtilityGDPRCleaner.metadataFieldsAccount.put('NumberOfEmployees', 'Number');
        UtilityGDPRCleaner.metadataFieldsAccount.put('Subject', 'TextBox');

        Test.startTest();
        List<Account> testAccounts = UtilityGDPRCleaner.cleanDataAccounts(new List<Account>{testAccount});
        Test.stopTest();

        //  Because no type checks have been made yet, invalid data can still exist in the fields when using the record.put('field name', data) method
        //  So we expect the valid fields to have the correct values as if the record was cleaned according to above's settings.
        System.assertEquals(null, testAccounts[0].Name);
        System.assertEquals(50, testAccounts[0].BillingStreet.length());
        System.assertNotEquals(null, testAccounts[0].NumberOfEmployees);

        //  Make sure the debug log was created as expected and contains data we expect it to have
        List<Debug_Log__c> testDebugLogs = UtilityGDPRCleaner.retrieveGeneratedDebugRecords();
        System.assertEquals(1, testDebugLogs.size());
        System.assertEquals(testAccount.Id, testDebugLogs[0].Related_Record_Id__c);
        System.assertEquals('UtilityGDPRCleaner', testDebugLogs[0].Class_Name__c);
        System.assert(testDebugLogs[0].Error_Message__c.contains('Subject'));
    }

    /**
     * Test that the UtilityGDPRCleaner.metadataFieldsAccount Map is initialised and does not have a value of null
     */
    @isTest
    static void testCleanAccountsTwo() {
        Account testAccount = createGDPRAccount();

        Test.startTest();
        List<Account> testAccounts = UtilityGDPRCleaner.cleanDataAccounts(new List<Account>{testAccount});
        Test.stopTest();

        System.assertNotEquals(null, UtilityGDPRCleaner.metadataFieldsAccount);
    }

    /**
     * Test an empty list is returned when a null value is passed
     * Test an empty list is returned when an empty list is passed
     */
    @isTest
    static void testCleanAccountsThree() {
        Test.startTest();
        List<Account> testAccountsNull = UtilityGDPRCleaner.cleanDataAccounts(null);
        List<Account> testAccountsEmpty = UtilityGDPRCleaner.cleanDataAccounts(new List<Account>());
        Test.stopTest();

        System.assertNotEquals(null, testAccountsNull);
        System.assertEquals(0, testAccountsNull.size());
        System.assertNotEquals(null, testAccountsEmpty);
        System.assertEquals(0, testAccountsEmpty.size());
    }

    /**
     * Manually define the metadata values to test all exceptions are handled correctly
     */
    @isTest
    static void testCleanCasesOne() {
        Case testCase = createGDPRCase();
        UtilityGDPRCleaner.metadataFieldsCase = new Map<String, String>();
        UtilityGDPRCleaner.metadataFieldsCase.put('AccountId', 'Lookup');   //  Right field name, right type
        UtilityGDPRCleaner.metadataFieldsCase.put('ContactId', 'Text');     //  Right field name, wrong type
        UtilityGDPRCleaner.metadataFieldsCase.put('Description', 'Text');   //  Right field name, right type
        UtilityGDPRCleaner.metadataFieldsCase.put('', 'Text');              //  No field name, valid type
        UtilityGDPRCleaner.metadataFieldsCase.put('Desc', 'Text');          //  Invalid field name, valid type
        UtilityGDPRCleaner.metadataFieldsCase.put('Year_Born__c', 'Number');    //  Right field name, right type
        UtilityGDPRCleaner.metadataFieldsCase.put('Subject', 'TextBox');    //  Right field name, invalid type - unlikely scenario

        Test.startTest();
        List<Case> testCases = UtilityGDPRCleaner.cleanDataCases(new List<Case>{testCase});
        Test.stopTest();

        //  Because no type checks have been made yet, invalid data can still exist in the fields when using the record.put('field name', data) method
        //  So we expect the valid fields to have the correct values as if the record was cleaned according to above's settings.
        System.assertEquals(null, testCases[0].AccountId);
        String tempContactId = testCases[0].ContactId;
        System.assertEquals(50, tempContactId.length());
        System.assertEquals(50, testCases[0].Description.length());
        Decimal tempYearBorn = testCases[0].Year_Born__c;
        System.assertNotEquals(null, tempYearBorn);

        //  Make sure the debug log was created as expected and contains data we expect it to have
        List<Debug_Log__c> testDebugLogs = UtilityGDPRCleaner.retrieveGeneratedDebugRecords();
        System.assertEquals(1, testDebugLogs.size());
        System.assertEquals(testCase.Id, testDebugLogs[0].Related_Record_Id__c);
        System.assertEquals('UtilityGDPRCleaner', testDebugLogs[0].Class_Name__c);
        System.assert(testDebugLogs[0].Error_Message__c.contains('Subject'));
    }

    /**
     * Test that the UtilityGDPRCleaner.metadataFieldsCase Map is initialised and does not have a value of null
     */
    @isTest
    static void testCleanCasesTwo() {
        Case testCase = createGDPRCase();

        Test.startTest();
        List<Case> testCases = UtilityGDPRCleaner.cleanDataCases(new List<Case>{testCase});
        Test.stopTest();

        System.assertNotEquals(null, UtilityGDPRCleaner.metadataFieldsCase);
    }

    /**
     * Test an empty list is returned when a null value is passed
     * Test an empty list is returned when an empty list is passed
     */
    @isTest
    static void testCleanCasesThree() {
        Test.startTest();
        List<Case> testCasesNull = UtilityGDPRCleaner.cleanDataCases(null);
        List<Case> testCasesEmpty = UtilityGDPRCleaner.cleanDataCases(new List<Case>());
        Test.stopTest();

        System.assertNotEquals(null, testCasesNull);
        System.assertEquals(0, testCasesNull.size());
        System.assertNotEquals(null, testCasesEmpty);
        System.assertEquals(0, testCasesEmpty.size());
    }

    /**
     * Manually define the metadata values to test all exceptions are handled correctly
     */
    @isTest
    static void testCleanContactsOne() {
        Contact testContact = createGDPRContact();
        UtilityGDPRCleaner.metadataFieldsContact = new Map<String, String>();
        UtilityGDPRCleaner.metadataFieldsContact.put('FirstName', 'Lookup');
        UtilityGDPRCleaner.metadataFieldsContact.put('LastName', 'Text');
        UtilityGDPRCleaner.metadataFieldsContact.put('Phone', 'Number');
        UtilityGDPRCleaner.metadataFieldsContact.put('Desc', 'Text');
        UtilityGDPRCleaner.metadataFieldsContact.put('Subject', 'TextBox');

        Test.startTest();
        List<Contact> testContacts = UtilityGDPRCleaner.cleanDataContacts(new List<Contact>{testContact});
        Test.stopTest();

        //  Because no type checks have been made yet, invalid data can still exist in the fields when using the record.put('field name', data) method
        //  So we expect the valid fields to have the correct values as if the record was cleaned according to above's settings.
        System.assertEquals(null, testContacts[0].FirstName);
        System.assertEquals(50, testContacts[0].LastName.length());
        System.assertNotEquals(null, testContacts[0].Phone);

        //  Make sure the debug log was created as expected and contains data we expect it to have
        List<Debug_Log__c> testDebugLogs = UtilityGDPRCleaner.retrieveGeneratedDebugRecords();
        System.assertEquals(1, testDebugLogs.size());
        System.assertEquals(testContact.Id, testDebugLogs[0].Related_Record_Id__c);
        System.assertEquals('UtilityGDPRCleaner', testDebugLogs[0].Class_Name__c);
        System.assert(testDebugLogs[0].Error_Message__c.contains('Subject'));
    }

    /**
     * Test that the UtilityGDPRCleaner.metadataFieldsCase Map is initialised and does not have a value of null
     */
    @isTest
    static void testCleanContactsTwo() {
        Contact testContact = createGDPRContact();

        Test.startTest();
        List<Contact> testContacts = UtilityGDPRCleaner.cleanDataContacts(new List<Contact>{testContact});
        Test.stopTest();

        System.assertNotEquals(null, UtilityGDPRCleaner.metadataFieldsContact);
    }

    /**
     * Test an empty list is returned when a null value is passed
     * Test an empty list is returned when an empty list is passed
     */
    @isTest
    static void testCleanContactsThree() {
        Test.startTest();
        List<Contact> testContactsNull = UtilityGDPRCleaner.cleanDataContacts(null);
        List<Contact> testContactsEmpty = UtilityGDPRCleaner.cleanDataContacts(new List<Contact>());
        Test.stopTest();

        System.assertNotEquals(null, testContactsNull);
        System.assertEquals(0, testContactsNull.size());
        System.assertNotEquals(null, testContactsEmpty);
        System.assertEquals(0, testContactsEmpty.size());
    }

    /** -------------------------------------------------------------------
     *  Methods used to create test data. Usually would be put in a TestDataFactory-type class
     *  ------------------------------------------------------------------- */

    /**
     * Creates a fake record Id for an SObject of length 15
     * @param   SObjectType
     */
    static Integer recordNumber = 1;
    static String getFakeId(Schema.SObjectType testSObjType) {
        String result = String.valueOf(recordNumber++);
        return testSObjType.getDescribe().getKeyPrefix() + '0'.repeat(12 - result.length()) + result;
    }

    static Account createGDPRAccount() {
        return new Account(
            Id = getFakeId(Account.getSObjectType()),
            Name = 'Test Account',
            BillingStreet = '137 Golden Ratio Ave.',
            BillingCity = 'Taupo',
            NumberOfEmployees = 36
        );
    }

    static Case createGDPRCase() {
        return new Case(
            Id = getFakeId(Case.getSObjectType()),
            AccountId = getFakeId(Account.getSObjectType()),
            ContactId = getFakeId(Contact.getSObjectType()),
            Description = 'A test descriptoin'
        );
    }

    static Contact createGDPRContact() {
        return new Contact(
            Id = getFakeId(Contact.getSObjectType()),
            FirstName = 'Mx.',
            LastName = 'Tester',
            Phone = '4325596'
        );
    }
}