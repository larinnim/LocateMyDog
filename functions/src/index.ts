import * as functions from 'firebase-functions';
import * as admin from 'firebase-admin';
import * as firebaseHelper from 'firebase-functions-helper/dist';
import * as express from 'express';
import * as bodyParser from 'body-parser';

admin.initializeApp(functions.config().firebase);
const db = admin.firestore();

const app = express();
const main = express();

// admin.initializeApp({
//     credential: admin.credential.cert(serviceAccount);
//     databaseURL: 'https://LocateMyDog.firebaseio.com'
// });

main.use(bodyParser.json());
main.use(bodyParser.urlencoded({extended: false}));
main.use('/api/v1', app);

const locateDogCollection = 'locateDog';

export const webApi = functions.https.onRequest(main);

app.get('/locateDog/:locateDogId', async (request, response) => {

    try{
        await firebaseHelper.firestore
        .getDocument(db, locateDogCollection, request.params.locateDogId)
        .then(doc => response.status(200).send(doc));
    }catch(error){
        response.status(204).send('Get Error');
    }
})

app.patch('/locateDog/:locateDogId/', async(req, res) => {
    try{
        await firebaseHelper.firestore.updateDocument(db, locateDogCollection, req.params.locateDogId, req.body);
    }catch(error){
        res.send(error);
    }
})