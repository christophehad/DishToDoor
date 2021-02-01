// functions for adding, retrieving cook dishes
const database = require('../../../../database/database');
const { DEBUG } = require('../../api_config');

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