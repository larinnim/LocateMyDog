//  const functions = require('firebase-functions');
const { firestore, admin, functions } = require("../admin");
const db = admin.firestore();

/**
 * Cloud Function: Handle device state updates
 */
module.exports = functions.pubsub
  .topic("geolocation")
  .onPublish(async (message, context) => {

    console.log('The function was triggered at ', context.timestamp);
    console.log('The unique ID for the event is', context.eventId);
    // console.log(
    //     `Message JSONN:  +
    //       ${message.json}`
    //   );
    //   console.log(
    //     `Message JSONN ESCAPED:  +
    //       ${message.json.escaped}`
    //   );
    //   console.log(
    //     `Message JSONN Latitude:  +
    //       ${message.json.latitude}`
    //   );
    const deviceId = message.attributes.deviceId;
    const senderID = "SD-" + message.json.senderID;
    var newLat = message.json.latitude;
    var newLng = message.json.longitude;
    var gatewayBatteryLevel = message.json.gatewayBatteryLevel;
    var trackerBatteryLevel = message.json.trackerBatteryLevel;
    var gatewayName = "";
    var gatewayStoredBatteryLevel = 0;
    var userToken = "";
    var notificateGeofence = false;
    var notificateGatewayBatteryLevel = false;
    var notificateTrackerBatteryLevel = false;
    var receivedEscaped = message.json.escaped;

    console.log(`Started code...`);

    // Write the device geolocation into firestore
    const deviceRef = firestore.doc(`sender/${senderID}`);

    const gatewayRef = firestore
      .collection("gateway")
      .doc("GW-" + message.json.gatewayID);
      
    await gatewayRef.get().then((gatewayFields) => {
      gatewayName = gatewayFields.data().name;
      gatewayStoredBatteryLevel = gatewayFields.data().batteryLevel
      console.log(`Gateway Name: " ${gatewayName}`);
    });

    try {
        console.log(`Going to try now.....`);

      await deviceRef.get().then(async (senderFields) => {
        console.log(`State updated for ${deviceId}`);
        
        const userRef = db.collection("users")
        .doc(senderFields.data().userID);
        
          userRef
          .get()
          .then(async (userDoc) => {
            if (!userDoc.exists) {
              console.log("No such User document!");
              throw new Error("No such User document!"); //should not occur normally as the notification is a "child" of the user
            } else {
              userToken = userDoc.data().token;
              notificateGeofence = userDoc.data().Notification['geofence']['enabled'];
              notificateGatewayBatteryLevel = userDoc.data().Notification['gatewayBattery']['enabled']
              notificateTrackerBatteryLevel = userDoc.data().Notification['trackerBattery']['enabled']
              console.log(`Looking to get the Escape message.....`);
              console.log(
                `Received Escaped?  ${receivedEscaped}`
              );    
            if (receivedEscaped == true) {
                console.log(
                    `Configuring batteryLevel, latitude and longitude....`
                  );   
               
                  
              if (senderFields.data().escaped == false) {
                console.log(
                    `DOG escaped...update timestamp and escaped status`
                  );
                //Escaped. First time notification
                await deviceRef.set(
                  {escaped: true },
                  { merge: true }
                ).then(value => {
                  if (notificateGeofence == true) {
                    var message = {
                      data: {
                        title: `${senderFields.data().name} Escaped!`,
                        body: `${
                          senderFields.data().name
                        } escaped. The last recorded location was ${newLat} / ${newLng}`,
                      },
                      token: userToken,
                    };
                    admin
                      .messaging()
                      .send(message)
                      .then(async (response) => {
                        console.log("Successfully sent message: ", response);
                        await userRef.set(
                          { "Notification" : {"geofence": {'timestamp': Date.now()}}},
                          { merge: true }
                        ); 
                      })
                      .catch((error) => {
                        console.log("Error sending message", error);
                      });
                  }
                }); //milliseconds elapsed since January 1, 1970
              } //else dont update the DB and dont send notification
            } else {
              if (senderFields.data().escaped == true) {
                console.log(
                    `DOG returned Home...`
                  );
                await deviceRef.set(
                  {escaped: false },
                  { merge: true }
                ).then(value => {
                  if (notificateGeofence == true) {
                    var message = {
                      data: {
                        title: `${senderFields.data().name} has returned to home!`,
                        body: `${senderFields.data().name} is safely back home.`,
                      },
                      token: userToken,
                    };
                    admin
                      .messaging()
                      .send(message)
                      .then(async (response) => {
                        console.log("Successfully sent message: ", response);
                        await userRef.set(
                          {"Notification" : {"geofence": {'timestamp': 0}}},
                          { merge: true }
                        ); 
                      })
                      .catch((error) => {
                        console.log("Error sending message", error);
                      });
                  }
                }); //milliseconds elapsed since January 1, 1970
              }
            }
            if (
              notificateTrackerBatteryLevel == true &&
              trackerBatteryLevel < 20 && senderFields.data().batteryLevel > 20
            ) {
              //Less than 20% is considered Low level Battery
              var message = {
                data: {
                  title: `The tracker ${
                    senderFields.data().name
                  } battery level is low!`,
                  body: `Please charge the tracker ${senderFields.data().name}.`,
                },
                token: userToken,
              };
              admin
                .messaging()
                .send(message)
                .then(async (response) => {
                  console.log("Successfully sent message: ", response);
                  await userRef.set(
                    { "Notification": {"trackerBattery": {'timestamp': Date.now()}}},
                    { merge: true }
                  ); 
                })
                .catch((error) => {
                  console.log("Error sending message", error);
                });
            }
            else{
              await userRef.set(
                {"Notification" : {"trackerBattery": {'timestamp': 0}}},
                { merge: true }
              ); 
            }
            if (
              notificateGatewayBatteryLevel == true &&
              gatewayBatteryLevel < 20 && gatewayStoredBatteryLevel > 20
            ) {
              //Less than 20% is considered Low level Battery and the notification has not been sent
              var message = {
                data: {
                  title: `The gateway ${gatewayName} battery level is low!`,
                  body: `Please charge the gateway ${gatewayName}.`,
                },
                token: userToken,
              };
              admin
                .messaging()
                .send(message)
                .then(async (response) => {
                  console.log("Successfully sent message: ", response);
                  await userRef.set(
                    {"Notification": {"gatewayBattery": {'timestamp': Date.now()}}},
                    { merge: true }
                  ); 
                })
                .catch((error) => {
                  console.log("Error sending message", error);
                });
              }
              else{
                userRef.set(
                  {"Notification" : {"gatewayBattery": {'timestamp': 0}}},
                  { merge: true }
                ); 
              }
              await deviceRef.set(
                {
                  Location: {
                    Latitude: newLat,
                    Longitude: newLng,
                  },
                  batteryLevel: trackerBatteryLevel,
                },
                { merge: true }
              );
              await gatewayRef.set(
                {
                  batteryLevel: gatewayBatteryLevel,
                },
                { merge: true }
              );
          }
        });
      });
    } catch (error) {
      console.error(`${deviceId} not yet registered to a user`, error);
    }
  });
