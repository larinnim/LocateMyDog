/**
 * Common module to initialize Firebase Admin SDK
 */

const admin = require("firebase-admin");
var serviceAccount = require("./serviceAccountKey.json");
const functions = require('firebase-functions');

const app = admin.initializeApp({
    credential: admin.credential.cert(serviceAccount),
    // databaseURL: "https://locatemydog-17a7b.firebaseio.com"
});
 
const firestore = app.firestore();
const auth = app.auth();
 
module.exports = {
     auth,
     firestore,
     admin,
     functions
 }