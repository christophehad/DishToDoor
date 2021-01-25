// functions for searching generic dishes and sending add requests
const database = require('../../../../database/database');
const dishCategories = require('../../api_config').gendishCategories;

/**
 * Callback for gendish routes
 * @callback genDishCallback
 * @param {String} err
 * @param {database.schemes.GenDish[]} [ret]
 * @param {String} [message]
*/

// adding a gendish (later becomes add request) 
exports.add = function add(name,category,done) {
    if (!name || !category) return done(null,false,'missing_fields');
    if (!dishCategories.includes(category.toLowerCase())) return done(null,false,'wrong_category');

    database.genDishAdd(name,category,undefined,(err,id) => {
        if (err) return done(err);
        return done(null,id);
    })
}

/**
 * searching for a gendish with a query
 * @param {genDishCallback} done 
 */
exports.search = function search(query,done) {
    if (!query) return done(null,false,'missing_query');
    database.genDishSearch(query, (err,gendishes) => {
        if (err) return done(err);
        if (gendishes.length == 0) return done(null,false,'no_match');
        return done(null,gendishes);
    })
}