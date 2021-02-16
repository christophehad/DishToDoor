// functions for adding, retrieving cook dishes
const { DateTime } = require('luxon');
const database = require('../../../../database/database');
const { DEBUG, clientTimeZone } = require('../../api_config');

/**
 * Callback for cookdish routes
 * @callback cookDishCallback
 * @param {String} err
 * @param {database.schemes.CookDish[]} [ret]
 * @param {String} [message]
*/

// adding a cookdish (after getting the gendish)
exports.add = function add(gendish_id, cook_id, custom_name, price, category, description, dish_pic_path, dish_pic_name, done) {
    if (!gendish_id || !cook_id || !price || !category || !description)
        return done(null,false,'missing_fields');
    if (!dish_pic_path) {
        // handle what to store on database
        dish_pic_path = null;
    }

    // upload pic to database and get url
    if (dish_pic_path) {
        database.uploadCookDishPic(dish_pic_name,dish_pic_path).then(cloud_url => {
            if (DEBUG) console.log("Pic uploaded!");
            database.cookDishAdd(gendish_id, cook_id, custom_name, price, category, undefined, description, cloud_url, (err, cookdish_id) => {
                if (err) return done(err);
                return done(null, cookdish_id);
            })
        }).catch(err => {return done(null,false,'cloud_problem');})
    }
    else {
        database.cookDishAdd(gendish_id, cook_id, custom_name, price, category, undefined, description, dish_pic_path, (err, cookdish_id) => {
            if (err) return done(err);
            return done(null, cookdish_id);
        })
    }
}

/**
 * Get all the dishes the cook has (regardless of status)
 * @param {cookDishCallback} done 
 */
exports.getAll = function getAll(cook_id,done) {
    database.cookDishGetAll(cook_id, (err,cookdishes) => {
        if (err) return done(err);
        if (cookdishes.length == 0) return done(null,false,'no_dishes');
        return done(null,cookdishes);
    })
}

/**
 * Get the available dishes the cook has today
 * @param {cookDishCallback} done 
 */
exports.getAvailable = function getAvailable(cook_id,done) {
    let today = DateTime.local().setZone(clientTimeZone).toSQLDate();
    database.cookDishGetAvailable(cook_id, today, (err,cookdishes) => {
        if (err) return done(err);
        if (cookdishes.length == 0) return done(null,false,'no_dishes');
        return done(null,cookdishes);
    })
}

exports.makeAvailable = function makeAvailable(cook_id,dish_id,done) {
    if (!dish_id) return done(null,false,'missing_fields');
    // check if dish belongs to cook/exists
    database.cookDishExists(dish_id,cook_id,(err,exists) => {
        if (err) return done(err);
        if (!exists) return done(null,false,'dish_not_for_cook');
        
        let curDate = new Date();
        // date in time zone of client (represented as a Date object)
        let clientDate = new Date(curDate.toLocaleString('en-US',{timeZone: clientTimeZone}));
        database.cookDishMakeAvailable(dish_id,clientDate, (err,added) => {
            if (err) return done(err);
            if (!added) return done(null,false,'database_problem');
            return done(null,true);
        })
    })
}

exports.makeUnavailable = function makeUnavailable(cook_id, dish_id, done) {
    if (!dish_id) return done(null, false, 'missing_fields');
    // check if dish belongs to cook/exists
    database.cookDishExists(dish_id, cook_id, (err, exists) => {
        if (err) return done(err);
        if (!exists) return done(null, false, 'dish_not_for_cook');

        database.cookDishMakeUnavailable(dish_id, (err, added) => {
            if (err) return done(err);
            if (!added) return done(null, false, 'database_problem');
            return done(null, true);
        });
    })
}