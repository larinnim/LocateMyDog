
const functions = require('firebase-functions');
const { google } = require('googleapis');

const projectIdEnv = 'locatemydog-17a7b';
const cloudRegion = 'us-central1';
const cloudRegistry = 'IAT'; 
/**
 * Return a promise to publish the new device config to Cloud IoT Core
 */
function updateConfig(client, deviceId, config) {
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
            versionToUpdate: 0,
            binaryData: Buffer.from(JSON.stringify(config)).toString('base64')
        };
        client.projects.locations.registries.devices.modifyCloudToDeviceConfig(request, (err, resp) => {
            if (err) {
                return reject(err);
            } else {
                resolve(resp.data);
            }
        });
    });
}

/**
 * Cloud Function: Handle device configuration changes
 */
module.exports = functions.firestore.document('gateway-config/{device}').onWrite(async (change, context) => {
    const deviceId = context.params.device;

    // Verify this is either a create or update
    if (!change.after.exists) {
        console.log(`Device configuration removed for ${deviceId}`);
        return;
    }
    const config = change.after.data();

    // Create a new Cloud IoT client
    const auth = await google.auth.getClient({
        scopes: ['https://www.googleapis.com/auth/cloud-platform']
    });
    const client = google.cloudiot({
        version: 'v1',
        auth: auth
    });

    // Send the device message through Cloud IoT
    console.log(`Sending configuration for ${deviceId}`);
    console.log(`Sending Data: ${config}`);

    try {
        // const result = await updateConfig(client, deviceId, config.value);
        const result = await updateConfig(client, deviceId, config);

        console.log(result);
    } catch (error) {
        console.error(`Unable to send IoT Core configuration for ${deviceId}`, error);
    }
});
