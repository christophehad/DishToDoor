var admin = require("firebase-admin");

var serviceAccount = require('../../../cert/firebaseAccountKey.json');

admin.initializeApp({
    credential: admin.credential.cert(serviceAccount)
});