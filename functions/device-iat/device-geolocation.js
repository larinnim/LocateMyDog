
//  const functions = require('firebase-functions');
 const { firestore, admin, functions } = require('../admin');
 const db = admin.firestore();

 /**
  * Cloud Function: Handle device state updates
  */
 module.exports = functions.pubsub.topic('geolocation').onPublish(async (message) => {
    const deviceId = message.attributes.deviceId;
    const senderID = 'SD-'+message.json.senderID;
    const newLat = message.json.latitude;
    const newLng = message.json.longitude;
    const gatewayName = '';
    const userToken = '';
    const notificateGeofence = false;
    const notificateGatewayBatteryLevel = false;
    const notificateTrackerBatteryLevel = false;

    // Write the device geolocation into firestore
    const deviceRef = firestore.doc(`sender/${senderID}`);

    const gatewayRef = firestore.collection('gateway').doc('GW-' + message.json.gatewayID);
    

    await gatewayRef.get().then(gatewayFields=>{
        gatewayName = gatewayFields.data().name;
    });

    db
    .collection('users')
    .doc(senderFields.data().userID).get().then(userDoc => {
        if (!userDoc.exists) {
            console.log('No such User document!');
            throw new Error('No such User document!'); //should not occur normally as the notification is a "child" of the user
            }
            else{
                userToken = userDoc.data().token;
                notificateGeofence = userDoc.data().Notification.escapedGeofence;
                notificateGatewayBatteryLevel = userDoc.data().Notification.gatewayBattery;
            }
        });
  
    try {      
        await deviceRef.get().then(senderFields=>{
            console.log(`State updated for ${deviceId}`);
            if(message.json.escaped == true){
                if(senderFields.data().escaped == false){
                    //Escaped. First time notification
                    await deviceRef.set({ 'Escape Timestamp': Date.now(), 'escaped': true}, { merge: true }); //milliseconds elapsed since January 1, 1970
                    if(notificateGeofence == true){
                        var message = {
                            data:{
                                title:  `${senderFields.data().name} Escaped!`,
                                body: `${senderFields.data().name} escaped. The last recorded location was ${newLat} / ${newLng}`, 
                            },
                            token: userToken
                        }
                        admin.messaging().send(message).then((response) => {
                            console.log('Successfully sent message: ', response);
                        }).catch((error)=>{
                            console.log('Error sending message', error);
                        });
                    }
                } //else dont update the DB and dont send notification
            }else{
                if(senderFields.data().escaped == true){
                    await deviceRef.set({ 'Escape Timestamp': null, 'escaped': false}, { merge: true }); //milliseconds elapsed since January 1, 1970
                }
                if(notificateGeofence == true){
                    var message = {
                        data:{
                            title:  `${senderFields.data().name} has returned to home!`,
                            body: `${senderFields.data().name} is safely back home.`, 
                        },
                        token: userToken
                    }
                    admin.messaging().send(message).then((response) => {
                        console.log('Successfully sent message: ', response);
                    }).catch((error)=>{
                        console.log('Error sending message', error);
                    });
                }
            }
            if(notificateTrackerBatteryLevel == true && message.json.trackerBatteryLevel < 20){
                //Less than 20% is considered Low level Battery
                var message = {
                    data:{
                        title:  `The tracker ${senderFields.data().name} battery level is low!`,
                        body: `Please charge the tracker ${senderFields.data().name}.`, 
                    },
                    token: userToken
                }
                admin.messaging().send(message).then((response) => {
                    console.log('Successfully sent message: ', response);
                }).catch((error)=>{
                    console.log('Error sending message', error);
                });
            }
            if(notificateGatewayBatteryLevel == true &&  message.json.gatewayBatteryLevel < 20){
                //Less than 20% is considered Low level Battery
                var message = {
                    data:{
                        title:  `The gateway ${gatewayName} battery level is low!`,
                        body: `Please charge the gateway ${gatewayName}.`, 
                    },
                    token: userToken
                }
                admin.messaging().send(message).then((response) => {
                    console.log('Successfully sent message: ', response);
                }).catch((error)=>{
                    console.log('Error sending message', error);
                });
                }
            await deviceRef.set({ 'Location': {'Latitude': message.json.latitude, 'Longitude': message.json.longitude, 'batteryLevel': message.json.senderBatteryLevel}}, { merge: true });
            await  gatewayRef.set({
                batteryLevel: message.json.gatewayBatteryLevel
            }, { merge: true });
        });
    } catch (error) {
        console.error(`${deviceId} not yet registered to a user`, error);
    }   
 });