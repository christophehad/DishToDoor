const database = require('../../../../database/database');
const async = require('async');

/**
 * returns true if successful
 * @param {database.schemes.DishTuple[]} dishes
 */
exports.checkout = function checkout(eater_id,datetime,dishes,done) {
    if (!datetime || !dishes) return done(null,false,'missing_fields');
    if (!dishes[0].dish_id || !dishes[0].quantity) return done(null, false, 'missing_fields');

    // organize dishes by cook_ids
    let cookDishes = {}, scheduled_time = new Date(datetime);
    async.eachOf(dishes, (dish,index,inner_callback) => {
        database.cookDishInfo(dish.dish_id, (err,cookdish) => {
            if (err) return inner_callback(err);
            let cook_id = cookdish.cook_id;
            if (cook_id in cookDishes)
                cookDishes[cook_id].push(dish);
            else
                cookDishes[cook_id] = [dish];
            inner_callback();
        })
    }, (err) => {
        if (err) return done(err);
        async.eachOf(cookDishes, (dishlist,cook_id,inner_callback) => {
            database.orderCreate(eater_id,cook_id,undefined,scheduled_time,dishlist, (err,added) => {
                if (err) return inner_callback(err);
                inner_callback();
            })
        }, (err) => {
            if (err) return done(err);
            return done(null,true);
            // should alert the cooks of orders
        })
    })
}

// TODO get price