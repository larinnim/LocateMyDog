"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.webApi = void 0;
const functions = require("firebase-functions");
const admin = require("firebase-admin");
const firebaseHelper = require("firebase-functions-helper/dist");
const express = require("express");
const bodyParser = require("body-parser");
admin.initializeApp(functions.config().firebase);
const db = admin.firestore();
const app = express();
const main = express();
// admin.initializeApp({
//     credential: admin.credential.cert(serviceAccount);
//     databaseURL: 'https://LocateMyDog.firebaseio.com'
// });
main.use(bodyParser.json());
main.use(bodyParser.urlencoded({ extended: false }));
main.use('/api/v1', app);
const locateDogCollection = 'locateDog';
exports.webApi = functions.https.onRequest(main);
// const time = admin.firestore.FieldValue.serverTimestamp();
app.get('/locateDog/:locateDogId', async (request, response) => {
    try {
        await firebaseHelper.firestore
            .getDocument(db, locateDogCollection, request.params.locateDogId)
            .then(doc => response.status(200).send(doc));
    }
    catch (error) {
        response.status(204).send('Get Error');
    }
});
// app.patch('/locateDog/:locateDogId/', async(req, res) => {
//     try{
//         await firebaseHelper.firestore.updateDocument(db, locateDogCollection, req.params.locateDogId, req.body);
//         res.send("Updated!");
//     }catch(error){
//         res.send(error);
//     }
// })
app.patch('/locateDog/:locateDogId/', async (req, res) => {
    try {
        await firebaseHelper.firestore.updateDocument(db, locateDogCollection, req.params.locateDogId, req.body)
            .then((value) => {
            // Update the timestamp field with the value from the server
            db.collection('locateDog').doc(req.params.locateDogId).set({
                timestamp: admin.firestore.FieldValue.serverTimestamp(),
            }, { merge: true }).then(() => { console.log('Write succeeded!'); }).catch(() => { console.log('ERROR!'); });
        }).catch((error) => { console.log('Error!'); });
        // res.send("Updated!");
        res.send("Updated!" + req.params.locateDogId + admin.firestore.FieldValue.serverTimestamp());
    }
    catch (error) {
        res.send(error);
    }
});
// app.patch('/locateDog/:locateDogId/', (req, res) => {
//     (async () => {
//         try{
//             await db.collection('locateDog').doc('/' + req.body.id + '/').update
//         } 
//         catch(error){
//         }
//     })();
// });
//# sourceMappingURL=index.js.map