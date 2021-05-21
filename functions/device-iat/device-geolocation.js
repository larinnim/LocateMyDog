//  const functions = require('firebase-functions');
const { firestore, admin, functions } = require("../admin");
const db = admin.firestore();

/**
 * Cloud Function: Handle device state updates
 */
module.exports = functions.pubsub
  .topic("geolocation")
  .onPublish(async (message, context) => {

    console.log('The function was triggered at: ', context.timestamp);
    console.log('The unique ID for the event is: ', context.eventId);
    console.log('Received: Gateway Battery Level: ', message.json.gatewayBatteryLevel);
    console.log('Received: Tracker Battery Level: ', message.json.trackerBatteryLevel);
    console.log('Received: GatewayID: ', message.json.gatewayID);
    console.log('Received: Escaped: ', message.json.escaped);

    var senderMac = message.json.senderID;
    var senderName = "";
    var senderColor = "";
    var senderID = "SD-" + message.json.senderID;
    var newLat = message.json.latitude;
    var newLng = message.json.longitude;
    var gatewayBatteryLevel = message.json.gatewayBatteryLevel;
    var trackerBatteryLevel = message.json.trackerBatteryLevel;
    var gatewayName = "";
    var gatewayID = message.attributes.deviceId;
    var gatewayMAC = "";
    var gatewayStoredBatteryLevel = 0;
    var userToken = "";
    var notificateGeofence = false;
    var notificateGatewayBatteryLevel = false;
    var notificateTrackerBatteryLevel = false;
    var receivedEscaped = message.json.escaped;

    console.log(`Started code...`);

    // Write the device geolocation into firestore
    var deviceRef = firestore.doc(`sender/${senderID}`);

    var gatewayRef = firestore
      .collection("gateway")
      .doc("GW-" + message.json.gatewayID);

      gatewayMAC = message.json.gatewayID;
      gatewayID = "GW-" + message.json.gatewayID;

      await gatewayRef.get().then((gatewayFields) => {
        if(!gatewayFields.exist){
          console.log(`The following document dont exist on Firestore: ${gatewayRef.id}`);
        }
        gatewayName = gatewayFields.data().name;
        gatewayStoredBatteryLevel = gatewayFields.data().batteryLevel
        console.log(`Gateway Stored Name: " ${gatewayName}`);
        console.log(`Gateway Stored Battery Level: " ${gatewayStoredBatteryLevel}`);
      });
      
      console.log(`Gateway Ref" ${gatewayRef}`);
      console.log(`Gateway REF DOC " ${"GW-" + message.json.gatewayID}`);
      console.log(`Sender Ref" ${deviceRef}`);
      console.log(`Sender REF DOC " ${senderID}`);

    try {
        console.log(`Going to try now.....`);

      await deviceRef.get().then((senderFields) => {
        console.log(`State updated for Sender Mac: ${senderMac}`);
        if(!senderFields.exist){
          console.log(`The following document dont exist on Firestore: ${deviceRef.id}`);
        }
        console.log(`Sender Fields: ${ senderFields.data()}`);

        senderColor = senderFields.data()['color'];
        senderName = senderFields.data()['name'];
        console.log(`Sender Color: ${senderColor}`);
        console.log(`Sender UserID: ${senderFields.data().userID}`);

        var userRef = db.collection("users")
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
                `USER TOKEN?  ${userToken}`
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
                    var messageEscaped = {
                      data: {
                        type: `map`
                      },
                      notification: {
                        title: `${senderFields.data().name} Escaped!`,
                        body: `${
                          senderFields.data().name
                        } escaped. The last recorded location was ${newLat} / ${newLng}`,
                      },
                        // Set Android priority to "high"
                      android: {
                        priority: "high",
                      },
                      token: userToken,
                    };
                    admin
                      .messaging()
                      .send(messageEscaped)
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
                    var messageReturnedHome = {
                      data: {
                        type: `map`
                      },
                      notification: {
                        title: `${senderFields.data().name} has returned to home!`,
                        body: `${senderFields.data().name} is safely back home.`,
                      },
                        // Set Android priority to "high"
                      android: {
                        priority: "high",
                      },
                      token: userToken,
                    };
                    admin
                      .messaging()
                      .send(messageReturnedHome)
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
            console.log(`Tracker Notification enabled? " ${notificateTrackerBatteryLevel}`);
            console.log(`Tracker Battery Level: " ${trackerBatteryLevel}`);
            console.log(`Tracker Sender Fields Battery Level: " ${senderFields.data().batteryLevel}`);
            if (
              notificateTrackerBatteryLevel == true &&
              trackerBatteryLevel < 20 && (senderFields.data().batteryLevel > 20 || senderFields.data().batteryLevel == 0)
            ) {
              var messageTrackerBattery = {
                data: {
                  type: `trackerBatteryLevel`,
                  senderName: String(senderName),
                  senderColor: String(senderColor),
                  batteryLevel: String(trackerBatteryLevel),
                  senderID: String(senderID),
                  gatewayID: String(gatewayID)
                },
                notification: {
                  title: `The tracker ${
                    senderFields.data().name
                  } battery level is low!`,
                  body:`Please charge the tracker ${senderFields.data().name}.`,
                },
                  // Set Android priority to "high"
                android: {
                  priority: "high",
                },
                token: userToken,
              };
              admin
                .messaging()
                .send(messageTrackerBattery)
                .then(async (response) => {
                  console.log("Successfully sent message: ", response);
                  await userRef.set(
                    { "Notification": {"trackerBattery": {'timestamp': Date.now()}}},
                    { merge: true }
                  ).then(function() {
                    console.log("Notification Tracker timestamp successfully added");
                  });
                })
                .catch((error) => {
                  console.log("Error sending message", error);
                });
            }
            // else{
            //   await userRef.set(
            //     {"Notification" : {"trackerBattery": {'timestamp': 0}}},
            //     { merge: true }
            //   ); 
            // }
            console.log(`Gateway Notification enabled? " ${notificateGatewayBatteryLevel}`);
            console.log(`Gateway Battery Level: " ${gatewayBatteryLevel}`);
            if (
              notificateGatewayBatteryLevel == true &&
              gatewayBatteryLevel < 20 && (gatewayStoredBatteryLevel > 20 || gatewayStoredBatteryLevel == 0)
            ) {
              var messageGatewayBattery = {
                data: {
                  type: `gatewayBatteryLevel`,
                  gatewayName: gatewayName,
                  gatewayMAC: gatewayMAC,
                },
                notification: {
                  title: `The gateway ${gatewayName} battery level is low!`,
                  body:`Please charge the gateway ${gatewayName}.`,
                },
                  // Set Android priority to "high"
                android: {
                  priority: "high",
                },
                token: userToken,
              };
              admin
                .messaging()
                .send(messageGatewayBattery)
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
                  batteryLevel: parseInt(trackerBatteryLevel),
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
      console.error(`${senderMac} not yet registered to a user`, error);
    }
  });
