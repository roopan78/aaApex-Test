@IsTest
private class UtilsTest {

    @IsTest
    static void testExtractSessionId_Success() {
        String dummySessionId = '00Dxx0000001ABC!AQ0AQFakeSession123456789';
        String fakeContent = 'RandomText Start_Of_Session_Id' + dummySessionId + ' End_Of_Session_Id MoreText';

        String extracted = Utils.extractSessionId(fakeContent);

        System.assertEquals(dummySessionId, extracted, 'Session ID should match expected value');
    }

    @IsTest
    static void testExtractSessionId_MissingMarkers() {
        String invalidContent = 'No session markers here';
        Boolean exceptionThrown = false;
        try {
            Utils.extractSessionId(invalidContent);
        } catch (Exception e) {
            exceptionThrown = true;
        }

        System.assert(exceptionThrown, 'Should throw an exception if markers are missing');
    }
}