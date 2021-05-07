/**
 * Common module to initialize Firebase Admin SDK
 */

const admin = require("firebase-admin");
var serviceAccount = require("/Users/larinnimalheiros/Documents/MajelTecnologies/Development/flutter_maps/serviceAccountKey.json");

const app = admin.initializeApp({
    credential: admin.credential.cert(serviceAccount),
    // databaseURL: "https://locatemydog-17a7b.firebaseio.com"
});
 
const firestore = app.firestore();
const auth = app.auth();
 
module.exports = {
     auth,
     firestore,
     admin
 }