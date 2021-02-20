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
* CookDish info callback
* @callback cookDishInfoCallback
* @param {String} err
* @param {CookDish} cookdish
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
 * @property {String} opening_time
 * @property {String} closing_time
 * @property {CookDish[]} dishes
*/

/**
 * Cook Profile Info
 * @typedef CookProfile
 * @property {Number} cook_id
 * @property {String} first_name
 * @property {String} last_name
 * @property {String} logo
 * @property {Number} lat
 * @property {Number} lon
 * @property {String} opening_time
 * @property {String} closing_time
*/

/**
 * @returns {CookProfile}
 */
exports.cookProfile = function(cook_id,f_name,l_name,logo,lat,lon,open,close) {
    return {
        cook_id:cook_id, first_name:f_name, last_name:l_name, logo:logo, lat:lat, lon:lon,
        opening_time:open, closing_time: close
    }
}

/**
  * Cook Profile Callback
  * @callback cookProfileCallback
  * @param {String} err
  * @param {CookProfile} cook
*/

/**
 * @param {CookDish[]} dishes
 * @returns {CookMap}
 */
exports.cookMap = function(cook_id,f_name,l_name,logo,lat,lon,distance,open,close,dishes) {
    return {
        cook_id:cook_id, first_name:f_name, last_name:l_name, logo:logo, lat:lat, lon:lon, 
        distance:distance, opening_time:open, closing_time:close, dishes:dishes
    }
}

/**
  * Cook Map Callback
  * @callback cookMapCallback
  * @param {String} err
  * @param {CookMap[]} cooks
*/


/**
 * Eater Cart Entry
 * @typedef {Object} EaterCartEntry
 * @property {CookDish} cookdish
 * @property {Number} quantity
 * @property {Boolean} delivery
*/

/**
  * Eater Cart Callback
  * @callback eaterCartCallback
  * @param {String} err
  * @param {EaterCartEntry[]} cart
*/

/**
 * 
 * @param {CookDish} cookdish 
 * @returns {EaterCartEntry}
 */
exports.eaterCartEntry = function(cookdish,quantity,delivery) {
    return {
        cookdish: cookdish, quantity:quantity, delivery:delivery
    }
}

const OrderStatus = {
    pending: 'pending',
    approved: 'approved',
    rejected: 'rejected',
    cancelled: 'cancelled',
    ready: 'ready',
    completed: 'completed'
}
exports.OrderStatus = Object.freeze(OrderStatus);

/**
 * Dish Tuple
 * @typedef {Object} DishTuple
 * @property {Number} dish_id
 * @property {Number} quantity
*/

/**
 * Order
 * @typedef {Object} Order
 * @property {Number} order_id
 * @property {Number} eater_id
 * @property {Number} cook_id
 * @property {Number} total_price
 * @property {String} general_status
 * @property {String} prepared_status
 * @property {String} packaged_status
 * @property {String} message
 * @property {Date} scheduled_time
 * @property {DishTuple[]} dishes
*/

/**
 * @param {DishTuple[]} dishes
 * @returns {Order}
 */
exports.order = function(order_id,eater_id,cook_id,total,general_status,prepared_status,packaged_status,message,time,dishes) {
    return {
        order_id:order_id, eater_id:eater_id, cook_id:cook_id, total_price:total, general_status:general_status, prepared_status:prepared_status,
        packaged_status:packaged_status, message:message, scheduled_time:time, dishes:dishes
    }
}

/**
  * Order Callback
  * @callback orderCallback
  * @param {String} err
  * @param {Order[]} orders
*/