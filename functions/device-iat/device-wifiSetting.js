
const functions = require('firebase-functions');
const { google } = require('googleapis');

const projectIdEnv = 'locatemydog-17a7b';
const cloudRegion = 'us-central1';
const cloudRegistry = 'IAT'; 

// const iot = require('@google-cloud/iot');

/**
 * Return a promise to publish the a device command to Cloud IoT Core
 */
 function updateCommand(client, deviceId, command) {
    return new Promise((resolve, reject) => {

      const projectId = projectIdEnv;

        // const projectId = process.env.GCLOUD_PROJECT;
        // const parentName = `projects/${projectId}/locations/${functions.config().cloudiot.region}`;
        const parentName = `projects/${projectId}/locations/${cloudRegion}`;
        const registryName = `${parentName}/registries/${cloudRegistry}`;

        console.log('Request Name:' + `${registryName}/devices/${deviceId}`);

        // const registryName = `${parentName}/registries/${functions.config().cloudiot.registry}`;

        const request = {
            name: `${registryName}/devices/${deviceId}`,
            binaryData: Buffer.from(command).toString('base64'),

            // binaryData: Buffer.from(JSON.stringify(command)).toString('base64'),
            // subfolder: 'wifiSetting'
        };
        client.projects.locations.registries.devices.sendCommandToDevice(request, (err, resp) => {
            if (err) {
                console.log('Could not send command:', request);
                console.log('Error: ', err);
                return reject(err);
            } else {
                resolve(resp.data);
            }
        });
    });
}

module.exports = functions.firestore.document('gateway-command/{device}').onWrite(async (change, context) => {
    const deviceId = context.params.device;
    // Verify this is either a create or update
    if (!change.after.exists) {
        console.log(`Device command removed for ${deviceId}`);
        return;
    }
    const commandMessage = change.after.data();

    // Create a new Cloud IoT client
    const auth = await google.auth.getClient({
        scopes: ['https://www.googleapis.com/auth/cloud-platform']
    });
    const client = google.cloudiot({
        version: 'v1',
        auth: auth
    });
    // Send the device message through Cloud IoT
    console.log(`Sending command for ${deviceId}`);
    console.log(`Sending Command Data: ${commandMessage.command}`);
    
    // const iotClient = new iot.v1.DeviceManagerClient({
    //     // optional auth parameters.
    //   });
      
    //   const formattedName = iotClient.devicePath(
    //     projectId,
    //     cloudRegion,
    //     registryId,
    //     deviceId
    //   );
    //   const binaryData = Buffer.from(commandMessage);
    //   const request = {
    //     name: formattedName,
    //     binaryData: binaryData,
    //   };
      
      try {
        // const result = await updateConfig(client, deviceId, config.value);
        const result = await updateCommand(client, deviceId, commandMessage.command);

        console.log(result);
    } catch (error) {
        console.error(`Unable to send IoT Core Command for ${deviceId}`, error);
    }

    //   try {
    //     const responses = await iotClient.sendCommandToDevice(request);
      
    //     console.log('Sent WIFI Setting change command: ', responses[0]);
    //   } catch (err) {
    //     console.error('Could not send command:', err);
    //   }
});
