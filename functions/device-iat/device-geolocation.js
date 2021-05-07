
 const functions = require('firebase-functions');
 const { firestore } = require('../admin');
 
 /**
  * Cloud Function: Handle device state updates
  */
 module.exports = functions.pubsub.topic('geolocation').onPublish(async (message) => {
    const deviceId = message.attributes.deviceId;
    const senderID = 'GW-'+message.json.senderID;
    // Write the device geolocation into firestore
    const deviceRef = firestore.doc(`sender/${senderID}`);
    try {
        // Ensure the device is also marked as 'online' when state is updated
        await deviceRef.update({ 'Location': {'Latitude': message.json.latitude, 'Longitude': message.json.longitude}});
        console.log(`State updated for ${deviceId}`);
    } catch (error) {
        console.error(`${deviceId} not yet registered to a user`, error);
    }   
 });