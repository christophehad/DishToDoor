const database = require('../../../../database/database');
const notification = require('../../common/notification');
const apiConfig = require('../../api_config');
const async = require('async');

// dishlist is a list of dishes with dish_id, quantity and price
function getTotal(dishlist) {
    let total = 0;
    for (const dish of dishlist) {
        total += dish.quantity * dish.price;
    }
    return total;
}

/**
 * returns true if successful
 * @param {database.schemes.DishTuple[]} dishes
 */
exports.checkout = function checkout(eater_id,datetime,dishes,total,done) {
    if (!datetime || !dishes || !total) return done(null,false,'missing_fields');
    if (!dishes[0].dish_id || !dishes[0].quantity) return done(null, false, 'missing_fields');

    // organize dishes by cook_ids and add prices to the dishes
    let cookDishes = {}, scheduled_time = new Date(datetime);
    async.eachOf(dishes, (dish,index,inner_callback) => {
        database.cookDishInfo(dish.dish_id, (err,cookdish) => {
            if (err) return inner_callback(err);
            let cook_id = cookdish.cook_id;
            dish.price = cookdish.price; // add price to the dish object
            if (cook_id in cookDishes)
                cookDishes[cook_id].push(dish);
            else
                cookDishes[cook_id] = [dish];
            inner_callback();
        })
    }, (err) => {
        if (err) return done(err);

        // check that the total price is correct
        let calculated_total = 0; let orderTotals = {};
        for (const [cook_id,dishlist] of Object.entries(cookDishes)) {
            let ordertotal = getTotal(dishlist);
            orderTotals[cook_id] = ordertotal;
            calculated_total += ordertotal;
        }
        if (calculated_total != total) return done(null,false,'total_price_wrong');

        async.eachOf(cookDishes, (dishlist,cook_id,inner_callback) => {
            let ordertotal = orderTotals[cook_id];
            database.orderCreate(eater_id,cook_id,undefined,scheduled_time,ordertotal,dishlist, (err,added) => {
                if (err) return inner_callback(err);
                inner_callback();
            })
        }, (err) => {
            if (err) return done(err);
            // alert the cooks of orders
            for (const [cook_id,dishes] of Object.entries(cookDishes)) {
                notification.cookNewOrder(cook_id);
            }
            return done(null,true); 
        })
    })
}

/**
 * @typedef {Object} OrderWrapper
 * @property {database.schemes.Order} order
 * @property {database.schemes.CookProfile} cook
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
 * returns all the orders for an eater
 * @param {orderWrapperCallback} done 
 */
exports.getOrdersAll = function getOrdersAll(eater_id,done) {
    database.orderGet_Eater(eater_id,undefined,(err,orders) => {
        if (err) return done(err);
        if (orders.length == 0) return done(null,false,'no_orders');
        /** @type {OrderWrapper[]} */
        let toRet = [];
        async.eachOf(orders, (order,index,inner_callback) => {
            // get cook info
            database.cookGetProfile(order.cook_id, (err,cookprofile) => {
                if (err) return inner_callback(err);
                /** @type {apiConfig.OrderDishAPI[]} */
                let dishes = [];
                async.eachOf(order.dishes,(dishtuple,index2,inner_callback2) => {
                    database.cookDishInfo(dishtuple.dish_id, (err,cookdish) => {
                        if (err) return inner_callback2(err);
                        dishes.push(apiConfig.orderDishAPI(dishtuple.dish_id,cookdish.name,dishtuple.quantity,cookdish.price,cookdish.dish_pic,dishtuple.rated));
                        inner_callback2();
                    })
                }, (err) => {
                    if (err) return inner_callback(err);
                    // we now have all dishes info and cook info
                    toRet.push({order: order, cook: cookprofile, dishes: dishes});
                    inner_callback();
                })
            })
        }, (err) => {
            if (err) return done(err);
            return done(null,toRet);
        })
    })
}

exports.rateDish = function(eater_id,dish_id,order_id,rating,done) {
    if (!dish_id || !rating || !order_id) return done(null,false,'missing_fields');
    if (rating < 0 || rating > 5) return done(null,false,'wrong_rating');
    database.cookDishRate(eater_id,dish_id,order_id,rating, (err,success) => {
        if (err) return done(err);
        if (!success) return done(null,false,'already_rated');
        return done(null,true);
    })
}