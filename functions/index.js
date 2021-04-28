
/**
 * Copyright 2019, Google LLC
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *    http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

 module.exports = {
  // Device Cloud Functions
  deviceConfiguration: require('./device-cloud/device-configuration'),
  deviceState: require('./device-cloud/device-state'),
  onlineState: require('./device-cloud/online-state'),
  registerDevice: require('./device-cloud/register-device'),
  // IAT device Functions
  token: require('./device-iat/token'),
  fulfillment: require('./device-iat/fulfillment'),
  reportState: require('./device-iat/report-state'),
  syncOnAdd: require('./device-iat/request-sync').add,
  syncOnRemove: require('./device-iat/request-sync').remove,
};

// const functions = require('firebase-functions');

// var admin = require("firebase-admin");

// admin.initializeApp();

// const db = admin.firestore();
// const fcm = admin.messaging();

// var unit = 'meter';
// var radiusKM = 0;

// exports.updateLocation = functions.firestore
//   .document('locateDog/{userId}')
//   .onUpdate((change, context) => {

//     unit = db
//     .collection('users')
//     .doc(context.params.userId).get().then(usersFields => {
//       return locateDogFields.data().units;
//     });

//     db
//       .collection('locateDog')
//       .doc(context.params.userId).get().then(locateDogFields => {
//         var originGeo = {lat: locateDogFields.data().Geofence.Circle.initialLat, lng: locateDogFields.data().Geofence.Circle.initialLng};
//         if (unit === 'miles'){
//           radiusKM = locateDogFields.data().Geofence.Circle.radius * 1.60934 / 1000;
//         } else{
//           radiusKM = locateDogFields.data().Geofence.Circle.radius / 1000;
//         }
        

//         const querySnapshot = db
//           .collection('users')
//           .doc(context.params.userId);
//         return querySnapshot
//           .get()
//           .then(doc => {
//             if (!doc.exists) {
//               console.log('No such User document!');
//               throw new Error('No such User document!'); //should not occur normally as the notification is a "child" of the user
//             } else {
//               console.log('Document data:', doc.data());
//               console.log('Document data:', doc.data().token);

//               const newValue = change.after.data();
//               const previousValue = change.before.data();
//               const previousLatitude = previousValue.Sender1.Location.Latitude;
//               const previousLongitude = previousValue.Sender1.Location.Longitude;
//               const newLatitude = newValue.Sender1.Location.Latitude;
//               const newLongitude = newValue.Sender1.Location.Longitude;
//               var newGeo = { lat: newLatitude, lng: newLongitude };

//               if (newLatitude !== previousLatitude || newLongitude !== previousLongitude) {
//                 if (!arePointsNear(newGeo, originGeo, radiusKM)) {
//                   const token = doc.data().token;
//                   const payload = {
//                     notification: {
//                       title: `${locateDogFields.data().dogname} Escaped!`,
//                       body: `${locateDogFields.data().dogname} escaped. The last recorded location was ${newLatitude} / ${newLongitude}  `,
//                       click_action: 'FLUTTER_NOTIFICATION_CLICK' // required only for onResume or onLaunch callbacks
//                     }
//                   };

//                   admin.messaging().sendToDevice(token, payload).then((res) => {
//                     console.log('Push Success:', res);
//                     return 0;
//                   }).catch((error) => {
//                     console.log('Push Error :', error)
//                   });
//                 }
//               }
//               return true;
//             }
//           })
//           .catch(err => {
//             console.log('Error getting document', err);
//             return false;
//           });
//       }).catch(err => {
//         console.log('Error getting document', err);
//         return false;
//       });
//   }
//   );

//   function arePointsNear(checkPoint, centerPoint, km) {
//     var ky = 40000 / 360;
//     var kx = Math.cos(Math.PI * centerPoint.lat / 180.0) * ky;
//     var dx = Math.abs(centerPoint.lng - checkPoint.lng) * kx;
//     var dy = Math.abs(centerPoint.lat - checkPoint.lat) * ky;
//     return Math.sqrt(dx * dx + dy * dy) <= km;
//   }