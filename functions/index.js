const functions = require('firebase-functions');

// // Create and Deploy Your First Cloud Functions
// // https://firebase.google.com/docs/functions/write-firebase-functions
//
// exports.helloWorld = functions.https.onRequest((request, response) => {
//   functions.logger.info("Hello logs!", {structuredData: true});
//   response.send("Hello from Firebase!");
// });

var admin = require("firebase-admin");

admin.initializeApp();

const db = admin.firestore();
const fcm = admin.messaging();

exports.updateLocation = functions.firestore
  .document('locateDog/{userId}')
  .onUpdate((change, context) => {

    db
      .collection('locateDog')
      .doc(context.params.userId).get().then(locateDogFields => {
        var originGeo = {lat: locateDogFields.data().Geofence.Circle.initialLat, lng: locateDogFields.data().Geofence.Circle.initialLng};
        var radiusKM = locateDogFields.data().Geofence.Circle.radius / 1000;

        const querySnapshot = db
          .collection('users')
          .doc(context.params.userId);
        return querySnapshot
          .get()
          .then(doc => {
            if (!doc.exists) {
              console.log('No such User document!');
              throw new Error('No such User document!'); //should not occur normally as the notification is a "child" of the user
            } else {
              console.log('Document data:', doc.data());
              console.log('Document data:', doc.data().token);

              const newValue = change.after.data();
              const previousValue = change.before.data();
              const previousLatitude = previousValue.Sender1.Location.Latitude;
              const previousLongitude = previousValue.Sender1.Location.Longitude;
              const newLatitude = newValue.Sender1.Location.Latitude;
              const newLongitude = newValue.Sender1.Location.Longitude;

              var newGeo = { lat: newLatitude, lng: newLongitude };

              if (newLatitude !== previousLatitude || newLongitude !== previousLongitude) {
                if (!arePointsNear(newGeo, originGeo, radiusKM)) {
                  const token = doc.data().token;
                  const payload = {
                    notification: {
                      title: `${locateDogFields.data().dogname} Escaped!`,
                      body: `${locateDogFields.data().dogname} escaped. The last recorded location was ${newLatitude} / ${newLongitude}  `,
                      click_action: 'FLUTTER_NOTIFICATION_CLICK' // required only for onResume or onLaunch callbacks
                    }
                  };

                  admin.messaging().sendToDevice(token, payload).then((res) => {
                    console.log('Push Success:', res);
                    return 0;
                  }).catch((error) => {
                    console.log('Push Error :', error)
                  });
                }
              }
              return true;
            }
          })
          .catch(err => {
            console.log('Error getting document', err);
            return false;
          });
      }).catch(err => {
        console.log('Error getting document', err);
        return false;
      });
  }
  );

  function arePointsNear(checkPoint, centerPoint, km) {
    var ky = 40000 / 360;
    var kx = Math.cos(Math.PI * centerPoint.lat / 180.0) * ky;
    var dx = Math.abs(centerPoint.lng - checkPoint.lng) * kx;
    var dy = Math.abs(centerPoint.lat - checkPoint.lat) * ky;
    return Math.sqrt(dx * dx + dy * dy) <= km;
  }