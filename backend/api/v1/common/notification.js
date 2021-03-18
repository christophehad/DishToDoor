var admin = require("firebase-admin");
const database = require('../../../database/database');

const apiConfig = require('../api_config');
const DEBUG = apiConfig.DEBUG;

var serviceAccount = require('../../../cert/firebaseAccountKey.json');

admin.initializeApp({
    credential: admin.credential.cert(serviceAccount)
});

function sendNotificationTyped(user_id,title,body,type,done) {
    // get device token
    database.deviceGetToken(user_id, (err,token) => {
        if (err) return done(err);
        if (!token) return done('no device registered');
        var message = {
            notification: {
                title: title, body: body
            },
            token: token,
            data: {
                type: type
            }
        };
        admin.messaging().send(message)
            .then((response) => {
                return done(null,response);
            })
            .catch((err) => {
                return done(err);
            })
    })
}

exports.cookNewOrder = function(cook_id) {
    sendNotificationTyped(cook_id,'New Order Received','You received a new order request!','cook_order_pending', (err,res) => {
        if (DEBUG) {
            if (err) console.log('Error sending notification: ',err);
            else console.log('Successfully sent notification: ',res);
        }
    })
}

exports.eaterOrderApproved = function (eater_id) {
    sendNotificationTyped(eater_id, 'Order Approved', 'Your order was approved and is in progress. Tap to track it.', 'eater_order_approved', (err, res) => {
        if (DEBUG) {
            if (err) console.log('Error sending notification: ', err);
            else console.log('Successfully sent notification: ', res);
        }
    })
}

exports.eaterOrderRejected = function (eater_id) {
    sendNotificationTyped(eater_id, 'Order Rejected', 'Your order was rejected by the cook.', 'eater_order_rejected', (err, res) => {
        if (DEBUG) {
            if (err) console.log('Error sending notification: ', err);
            else console.log('Successfully sent notification: ', res);
        }
    })
}

exports.eaterOrderCancelled = function (eater_id) {
    sendNotificationTyped(eater_id, 'Order Cancelled', 'Your order was cancelled by the cook.', 'eater_order_cancelled', (err, res) => {
        if (DEBUG) {
            if (err) console.log('Error sending notification: ', err);
            else console.log('Successfully sent notification: ', res);
        }
    })
}

exports.eaterOrderReadyPickup = function (eater_id) {
    sendNotificationTyped(eater_id, 'Order Ready', 'Your order is ready for pickup!', 'eater_order_ready', (err, res) => {
        if (DEBUG) {
            if (err) console.log('Error sending notification: ', err);
            else console.log('Successfully sent notification: ', res);
        }
    })
}

exports.eaterOrderComplete = function (eater_id) {
    sendNotificationTyped(eater_id, 'Order Complete', 'Your order was completed successfully. Thank you for your trust.', 'eater_order_complete', (err, res) => {
        if (DEBUG) {
            if (err) console.log('Error sending notification: ', err);
            else console.log('Successfully sent notification: ', res);
        }
    })
}

