

// admin.initializeApp({
//   credential: admin.credential.cert(serviceAccount),
//   databaseURL: "https://locatemydog-17a7b.firebaseio.com"
// });

// const functions = require('firebase-functions');
// const { admin } = require('googleapis/build/src/apis/admin');
const { admin } = require('./admin');

var registrationToken = 'fZdyJ8kBQpiB2PfnrCmbC0:APA91bF1aNsAkgUozes_1X91jTw2tUTbYynwlJAsSPUZ6_EokLUPpvMIFMa7f47FHWxq8nWiZPs7AFPYpTYAZ0vJQM1yc7N8_R4dLkE8ElD-Ab42R1rQzclXxdZsjUnHmHW8jCZuSPc8'



var message = {
    data:{
        title: 'Your dog escaped',
        body: 'Attention. YOU CUTECUTE is not around'
    },
    token: registrationToken
}

admin.messaging().send(message).then((response) => {
    console.log('Successfully sent message: ', response);
}).catch((error)=>{
    console.log('Error sending message', error);
});