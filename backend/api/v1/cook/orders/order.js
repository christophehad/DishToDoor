const database = require('../../../../database/database');
const apiConfig = require('../../api_config');
const async = require('async');

/**
 * @typedef {Object} OrderWrapper
 * @property {database.schemes.Order} order
 * @property {database.schemes.EaterProfile} eater
 * @property {apiConfig.OrderDishAPI[]} dishes
*/

/**
 * Callback for passing OrderWrapper
 * @callback orderWrapperCallback
 * @param {String} err
 * @param {OrderWrapper[]} [orderWrappers]
 * @param {String} [message]
*/

/**
 * returns all the orders for a cook
 * @param {orderWrapperCallback} done 
 */
exports.getOrdersAll = function getOrdersAll(cook_id, done) {
    database.orderGet_Cook(cook_id, undefined, (err, orders) => {
        if (err) return done(err);
        if (orders.length == 0) return done(null, false, 'no_orders');
        /** @type {OrderWrapper[]} */
        let toRet = [];
        async.eachOf(orders, (order, index, inner_callback) => {
            // get cook info
            database.eaterGetProfile(order.eater_id, (err, eaterprofile) => {
                if (err) return inner_callback(err);
                /** @type {apiConfig.OrderDishAPI[]} */
                let dishes = [];
                async.eachOf(order.dishes, (dishtuple, index2, inner_callback2) => {
                    database.cookDishInfo(dishtuple.dish_id, (err, cookdish) => {
                        if (err) return inner_callback2(err);
                        dishes.push(apiConfig.orderDishAPI(dishtuple.dish_id, cookdish.name, dishtuple.quantity, cookdish.price, cookdish.dish_pic));
                        inner_callback2();
                    })
                }, (err) => {
                    if (err) return inner_callback(err);
                    // we now have all dishes info and eater info
                    toRet.push({ order: order, eater: eaterprofile, dishes: dishes });
                    inner_callback();
                })
            })
        }, (err) => {
            if (err) return done(err);
            return done(null, toRet);
        })
    })
}

exports.approve = function(order_id,done) {
    if (!order_id) return done(null, false, 'missing_fields');
    database.orderApprove(order_id,done);
}

exports.reject = function(order_id,done) {
    if (!order_id) return done(null, false, 'missing_fields');
    database.orderReject(order_id,done);
}

exports.cancel = function(order_id,done) {
    if (!order_id) return done(null, false, 'missing_fields');
    database.orderCancel(order_id,done);
}

exports.ready = function(order_id,done) {
    if (!order_id) return done(null, false, 'missing_fields');
    database.orderReady(order_id,done);
}

exports.complete = function(order_id,done) {
    if (!order_id) return done(null, false, 'missing_fields');
    database.orderComplete(order_id,done);
}