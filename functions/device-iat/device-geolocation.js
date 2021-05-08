
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
    // Write the device geolocation into firestore
    const deviceRef = firestore.doc(`sender/${senderID}`);
    try {
        // Ensure the device is also marked as 'online' when state is updated
        await deviceRef.update({ 'Location': {'Latitude': message.json.latitude, 'Longitude': message.json.longitude}});
        await deviceRef.get().then(senderFields=>{
            console.log(`State updated for ${deviceId}`);
            // console.log(`User ID:  ${senderFields.data()}`);
        
            db
            .collection('users')
            .doc(senderFields.data().userID).get().then(doc => {
                if (!doc.exists) {
                    console.log('No such User document!');
                    throw new Error('No such User document!'); //should not occur normally as the notification is a "child" of the user
                  }
                  else{
                    console.log('Document data:', doc.data());
                    console.log('User token:', doc.data().token);
                        var message = {
                            data:{
                                title:  `${doc.data().dogname} Escaped!`,
                                body: `${doc.data().dogname} escaped. The last recorded location was ${newLat} / ${newLng}`, 
                            },
                            token: doc.data().token
                        }
                        // const payload = {
                        //     notification: {
                        //       title: `${doc.data().dogname} Escaped!`,
                        //     //   body: `${doc.data().dogname} escaped. The last recorded location was ${newLatitude} / ${newLongitude}  `,
                        //     body: `${doc.data().dogname} escaped. `,
        
                        //     click_action: 'FLUTTER_NOTIFICATION_CLICK' // required only for onResume or onLaunch callbacks
                        //     }
                        //   };
                        //   admin.messaging().sendToDevice(doc.data().token, payload).then((res) => {
                        //     console.log('Push Success:', res);
                        //     return 0;
                        //   }).catch((error) => {
                        //     console.log('Push Error :', error)
                        //   });
                        admin.messaging().send(message).then((response) => {
                            console.log('Successfully sent message: ', response);
                        }).catch((error)=>{
                            console.log('Error sending message', error);
                        });
                    
                  }
        });
        
         
        });
    } catch (error) {
        console.error(`${deviceId} not yet registered to a user`, error);
    }   
 });