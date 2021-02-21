const express = require('express');

const apiConfig = require('../api_config');
const DEBUG = apiConfig.DEBUG;
// to be returned in the HTTP requests
const eaterProfileAPI = apiConfig.eaterProfileAPI;
const cookOrderAPI = apiConfig.cookOrderAPI;
const generalStatus = apiConfig.OrderStatus;
const successJSON = apiConfig.successJSON;
const failureJSON = apiConfig.failureJSON;

const router = express.Router();

const order = require('./orders/order');

router.get('/orders/get', (req, res, next) => {
    if (DEBUG) console.log(req.query);

    let cook_id = req.user;
    if (Object.keys(req.query).length == 0) {
        // get all the orders
        order.getOrdersAll(cook_id, (err, orderwrappers, message) => {
            if (err) return next(err);
            if (!orderwrappers) return res.json(failureJSON(message));
            let toSend = successJSON();
            /** @type {apiConfig.CookOrderAPI[]} */
            let pending_orders = [], current_orders = [], past_orders = [];
            for (const orderwrapper of orderwrappers) {
                let eaterProfile = eaterProfileAPI(orderwrapper.eater.first_name,orderwrapper.eater.last_name);
                let curOrder = cookOrderAPI(
                    orderwrapper.order.order_id, eaterProfile, orderwrapper.order.total_price,
                    orderwrapper.order.general_status, orderwrapper.order.scheduled_time, orderwrapper.dishes
                );
                // divide orders depending on status
                let past_statuses = [generalStatus.completed, generalStatus.rejected, generalStatus.cancelled];
                if (curOrder.general_status == generalStatus.pending)
                    pending_orders.push(curOrder);
                else {
                    if (past_statuses.includes(curOrder.general_status))
                        past_orders.push(curOrder);
                    else
                        current_orders.push(curOrder);
                }
            }
            toSend.pending_orders=pending_orders, toSend.current_orders=current_orders, toSend.past_orders=past_orders;
            res.json(toSend);
        })
    }
    else {
        res.sendStatus(400);
    }
});

router.get('/orders/approve', (req,res,next) => {
    if (DEBUG) console.log(req.query);

    let order_id=req.query.order_id;
    order.approve(order_id, (err,success, message) => {
        if (err) return next(err);
        if (!success) return res.json(failureJSON(message));
        res.json(successJSON());
    })
})

router.get('/orders/reject', (req, res, next) => {
    if (DEBUG) console.log(req.query);

    let order_id = req.query.order_id;
    order.reject(order_id, (err, success, message) => {
        if (err) return next(err);
        if (!success) return res.json(failureJSON(message));
        res.json(successJSON());
    })
})

router.get('/orders/cancel', (req, res, next) => {
    if (DEBUG) console.log(req.query);

    let order_id = req.query.order_id;
    order.cancel(order_id, (err, success, message) => {
        if (err) return next(err);
        if (!success) return res.json(failureJSON(message));
        res.json(successJSON());
    })
})

router.get('/orders/ready', (req, res, next) => {
    if (DEBUG) console.log(req.query);

    let order_id = req.query.order_id;
    order.ready(order_id, (err, success, message) => {
        if (err) return next(err);
        if (!success) return res.json(failureJSON(message));
        res.json(successJSON());
    })
})


router.get('/orders/complete', (req, res, next) => {
    if (DEBUG) console.log(req.query);

    let order_id = req.query.order_id;
    order.complete(order_id, (err, success, message) => {
        if (err) return next(err);
        if (!success) return res.json(failureJSON(message));
        res.json(successJSON());
    })
})

module.exports = router;