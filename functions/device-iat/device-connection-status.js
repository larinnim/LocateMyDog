//  const functions = require('firebase-functions');
const { firestore, admin, functions } = require("../admin");
const db = admin.firestore();

/**
 * Cloud Function: Handle device state updates
 */
 module.exports = functions.pubsub.topic('gatewayConnectionStatus').onPublish(async (message) => {
    const logEntry = JSON.parse(Buffer.from(message.data, 'base64').toString());
    const deviceId = logEntry.labels.device_id;
  
    let online;
    switch (logEntry.jsonPayload.eventType) {
      case 'CONNECT':
        online = true;
        break;
      case 'DISCONNECT':
        online = false;
        break;
      default:
        throw new Error('Invalid message type');
    }

    try {
        console.log(`Updating Connection Status for ${deviceId} ...`);

        const result = await db.collection('gateway').doc(deviceId).set({connectionStatus: online}, {merge:true});
        console.log('Result from updating the Connection Status: ', result);
    } catch (error) {
        console.error(`Unable to send IoT Core configuration for ${deviceId}`, error);
    }
    // ...write updated state to Firebase...
  
  });