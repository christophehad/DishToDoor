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
 * @typedef {Object} DishRating
 * @property {EaterProfile} eater
 * @property {Number} rating
 * @property {Date} date
*/

/**
 * @param {EaterProfile} eater
 * @returns {DishRating}
 */
exports.dishRating = function(eater,rating,date) {
    return {
        eater:eater, rating:rating, date:date
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
 * @property {Number} avg_rating
 * @property {DishRating[]} ratings
 */

 /**
  * Generate a CookDish
  * @param {DishRating[]} ratings
  * @returns {CookDish}
  */
 exports.cookDish = function (dish_id,gendish_id,cook_id,name,price,category,label,description,dish_pic,avg_rating,ratings) {
     return {
         dish_id: dish_id, gendish_id: gendish_id, cook_id: cook_id, name: name, price: price, category: category,
         label: label, description: description, dish_pic: dish_pic, avg_rating:avg_rating, ratings
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
 * @property {Boolean} share_phone
 * @property {String} phone
*/

/**
 * @returns {CookProfile}
 */
exports.cookProfile = function(cook_id,f_name,l_name,logo,lat,lon,open,close,share_phone,phone) {
    return {
        cook_id:cook_id, first_name:f_name, last_name:l_name, logo:logo, lat:lat, lon:lon,
        opening_time:open, closing_time: close, share_phone:share_phone, phone:phone
    }
}

/**
  * Cook Profile Callback
  * @callback cookProfileCallback
  * @param {String} err
  * @param {CookProfile} cook
*/

/**
 * Cook Account Info
 * @typedef CookAccount
 * @property {Number} cook_id
 * @property {String} email
 * @property {String} phone
 * @property {Boolean} is_verified
 * @property {Date} date_added
 * @property {CookProfile} profile
*/

/**
 * @param {CookProfile} cookprofile 
 * @returns {CookAccount}
 */
exports.cookAccount = function(cook_id,email,phone,is_ver,date,cookprofile) {
    return {
        cook_id:cook_id, email:email, phone:phone, is_verified:is_ver, date_added:date, profile:cookprofile
    }
}

/**
  * Cook Account Callback
  * @callback cookAccountCallback
  * @param {String} err
  * @param {CookAccount} cook
*/


/**
 * Eater Profile Info
 * @typedef EaterProfile
 * @property {Number} eater_id
 * @property {String} first_name
 * @property {String} last_name
*/

/**
 * @returns {EaterProfile}
 */
exports.eaterProfile = function (eater_id, f_name, l_name) {
    return {
        eater_id: eater_id, first_name: f_name, last_name: l_name
    }
}

/**
  * Eater Profile Callback
  * @callback eaterProfileCallback
  * @param {String} err
  * @param {EaterProfile} eater
*/

/**
 * Eater Account Info
 * @typedef EaterAccount
 * @property {Number} eater_id
 * @property {String} email
 * @property {String} phone
 * @property {Number} pickup_radius
 * @property {Date} date_added
 * @property {EaterProfile} profile
*/

/**
 * @param {EaterProfile} eaterprofile 
 * @returns {EaterAccount}
 */
exports.eaterAccount = function (eater_id, email, phone, pickup, date, eaterprofile) {
    return {
        eater_id: eater_id, email: email, phone: phone, pickup_radius:pickup, date_added: date, profile: eaterprofile
    }
}

/**
  * Eater Account Callback
  * @callback eaterAccountCallback
  * @param {String} err
  * @param {EaterAccount} eater
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
 * @property {Boolean} rated
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

/**
  * Order Info Callback
  * @callback orderInfoCallback
  * @param {String} err
  * @param {Order} order
*/

/**
 * CookVerification
 * @typedef {Object} CookVerification
 * @property {CookAccount} account
 * @property {String} experience
 * @property {Boolean} certified_chef
 * @property {Boolean} willing_training
 * @property {Boolean} consent_inspection
 * @property {String[]} kitchen_pics
 */

/**
 * @param {CookAccount} account 
 * @param {String[]} pics
 * @returns {CookVerification} 
 */
exports.cookVerification = function (account, exp, chef, train, inspect, pics) {
    chef = chef == true, train = train == true, inspect = inspect == true;
    return {
        account: account, experience: exp, certified_chef: chef, willing_training: train, consent_inspection: inspect,
        kitchen_pics: pics
    }
}

/**
  * Cook Verification List Callback
  * @callback cookGetVerificationsCallback
  * @param {String} err
  * @param {CookVerification[]} cooks
*/