/**
    @description Callback class to handle the result of deploying Custom Metadata Types for digital signing.
    @author RT
    @date 18DEC25

    Version        Date            Author          Description
    1.0             18DEC25        RT              Initial version
 */
global with sharing class DigitalSignCMDTCallback implements Metadata.DeployCallback {

    // RT 18DEC25 - Implemented to handle the callback after deploying CMDT for digital signing
    global void handleResult(
        Metadata.DeployResult result,
        Metadata.DeployCallbackContext context
    ) {
        if (result == null) { return; }

        if (!result.success) {
            System.debug(
                'Digital Sign CMDT deployment failed: ' +
                result.status
            );
        }
    }
}