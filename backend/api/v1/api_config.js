module.exports.DEBUG = true;
module.exports.tmpPath = 'tmp/';

// Communication with API
module.exports.successJSON = function successJSON() {
    return {
        success: true,
        token: ''
    };
}

/**
 * Failure JSON to be returned
 * @param {String} error 
 */
module.exports.failureJSON = function failureJSON(error) {
    return {
        success: false,
        error: error
    }
}

module.exports.genDish = function genDish(id,name,category) {
    return {
        id: id, name: name, category: category
    }
}

// Allowed categories (for now, on long run we get them from database)
module.exports.gendishCategories = ['appetizer','main dish', 'dessert', 'salad'];

/**
 * API CookDish
 * @typedef {Object} CookDishAPI
 * @property {Number} dish_id
 * @property {Number} gendish_id
 * @property {String} name
 * @property {Number} price
 * @property {String} category
 * @property {String} description
 * @property {String} dish_pic
*/

/**
 * @returns {CookDishAPI}
 */
module.exports.cookDish = function cookDish(dish_id,gendish_id,name,price,category,description,dish_pic) {
    return {
        dish_id:dish_id, gendish_id:gendish_id, name:name, price: price, category: category, 
        description:description, dish_pic:dish_pic
}}

/**
 * API CookMap
 * @typedef {Object} CookMapAPI
 * @property {String} first_name
 * @property {String} last_name
 * @property {String} logo
 * @property {Number} lat
 * @property {Number} lon
 * @property {Number} distance
 * @property {CookDishAPI[]} dishes
*/

/**
 * @param {CookDishAPI[]} dishes
 * @returns {CookMapAPI} 
 */
module.exports.cookMap = function cookMap(f_name,l_name,logo,lat,lon,distance,dishes) {
    return {
        first_name:f_name, last_name:l_name, logo:logo, lat, lon, distance:distance, dishes:dishes
}}