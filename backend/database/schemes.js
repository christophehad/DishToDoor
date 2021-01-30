// Templates of returned database objects

/**
 * @typedef {Object} GenDish
 * @property {Number} id
 * @property {String} name
 * @property {String} category
*/

/**
 * GenDish search callback
 * @callback genDishSearchCallback
 * @param {String} err
 * @param {GenDish[]} gendishes
*/

/**
 * Generate a GenDish
 * @returns {GenDish}
 */
exports.genDish = function (id,name,category) {
    return {
        id: id, name: name, category: category
    }
}

/**
 * @typedef {Object} CookDish
 * @property {Number} dish_id
 * @property {Number} gendish_id
 * @property {Number} cook_id
 * @property {String} name
 * @property {Number} price
 * @property {String} category
 * @property {String} label
 * @property {String} description
 * @property {String} dish_pic
 */

 /**
  * Generate a CookDish
  * @returns {CookDish}
  */
 exports.cookDish = function (dish_id,gendish_id,cook_id,name,price,category,label,description,dish_pic) {
     return {
         dish_id: dish_id, gendish_id: gendish_id, cook_id: cook_id, name: name, price: price, category: category,
         label: label, description: description, dish_pic: dish_pic
     }
 }

/**
* CookDish search callback
* @callback cookDishSearchCallback
* @param {String} err
* @param {CookDish[]} cookdishes
*/

/**
 * Cook and Dishes on Map
 * @typedef CookMap
 * @property {Number} cook_id
 * @property {String} first_name
 * @property {String} last_name
 * @property {String} logo
 * @property {Number} lat
 * @property {Number} lon
 * @property {Number} distance
 * @property {CookDish[]} dishes
*/

/**
 * @param {CookDish[]} dishes
 * @returns {CookMap}
 */
exports.cookMap = function(cook_id,f_name,l_name,logo,lat,lon,distance,dishes) {
    return {
        cook_id:cook_id, first_name:f_name, last_name:l_name, logo:logo, lat:lat, lon:lon, distance:distance, dishes:dishes
    }
}

/**
  * Cook Map Callback
  * @callback cookMapCallback
  * @param {String} err
  * @param {CookMap[]} cooks
*/