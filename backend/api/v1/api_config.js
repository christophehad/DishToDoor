const {DateTime} = require('luxon');
const schemes = require('../../database/schemes');

module.exports.DEBUG = true;
module.exports.tmpPath = 'tmp/';
module.exports.clientTimeZone = 'Asia/Beirut';

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
 * @property {String} opening_time
 * @property {String} closing_time
 * @property {CookDishAPI[]} dishes
*/

// append today's date in ISO format to time
var addDateISO = module.exports.addDateISO = function (time) {
    let today = DateTime.local().setZone(this.clientTimeZone);
    let dateISO = today.toISODate(); // yyyy-mm-dd
    return dateISO + " " + time;
}

/**
 * returns a string with the format yyyy-mm-dd hh:mm:ss
 * @param {Date} datetime 
 */
var datetimeAPI = module.exports.datetimeAPI = function(datetime) {
    return DateTime.fromJSDate(datetime).toFormat('yyyy-LL-dd hh:mm:ss');
}

/**
 * @param {CookDishAPI[]} dishes
 * @returns {CookMapAPI} 
 */
module.exports.cookMap = function cookMap(f_name,l_name,logo,lat,lon,distance,open,close,dishes) {
    return {
        first_name:f_name, last_name:l_name, logo:logo, lat:lat, lon:lon,
        distance:distance, opening_time:open, closing_time:close, dishes:dishes
}}

/**
 * Cook Profile API
 * @typedef CookProfileAPI
 * @property {String} first_name
 * @property {String} last_name
 * @property {String} logo
 * @property {Number} lat
 * @property {Number} lon
 * @property {String} opening_time
 * @property {String} closing_time
*/

/**
 * @param {String} open
 * @param {String} close
 * @returns {CookProfileAPI}
 */
var cookProfileAPI = module.exports.cookProfileAPI = function (f_name,l_name,logo,lat,lon,open,close) {
    let open_with_date = addDateISO(open), close_with_date = addDateISO(close);
    return {
        first_name:f_name, last_name:l_name, logo:logo, lat:lat, lon:lon, opening_time:open_with_date,
        closing_time:close_with_date
    }
}

/**
 * Cook Account API
 * @typedef CookAccountAPI
 * @property {String} email
 * @property {String} phone
 * @property {Boolean} is_verified
 * @property {String} date_added
 * @property {CookProfileAPI} profile
*/

/**
 * @param {schemes.CookAccount} cook
 * @returns {CookAccountAPI}
 */
module.exports.cookAccountAPI = function (cook) {
    let date_api = datetimeAPI(cook.date_added);
    let is_verified_api = cook.is_verified == true;
    let cookprofile = cookProfileAPI(cook.profile.first_name,cook.profile.last_name,cook.profile.logo,
                                        cook.profile.lat,cook.profile.lon,cook.profile.opening_time,cook.profile.closing_time);
    return {
        email:cook.email,phone:cook.phone,is_verified:is_verified_api,date_added:date_api,profile:cookprofile
    }
}

/**
 * Eater Profile API
 * @typedef EaterProfileAPI
 * @property {String} first_name
 * @property {String} last_name
*/

/**
 * @returns {EaterProfileAPI}
 */
var eaterProfileAPI = module.exports.eaterProfileAPI = function(f_name,l_name) {
    return {
        first_name:f_name, last_name:l_name
    }
}

/**
 * Eater Account API
 * @typedef EaterAccountAPI
 * @property {String} email
 * @property {String} phone
 * @property {String} date_added
 * @property {EaterProfileAPI} profile
*/

/**
 * @param {schemes.EaterAccount} eater 
 * @returns {EaterAccountAPI}
 */
module.exports.eaterAccountAPI = function(eater) {
    let date_api = datetimeAPI(eater.date_added);
    let eater_profile_api = eaterProfileAPI(eater.profile.first_name,eater.profile.last_name);
    return {
        email:eater.email, phone:eater.phone, date_added:date_api, profile: eater_profile_api
    }
}

/**
 * Order Dish API
 * @typedef {Object} OrderDishAPI
 * @property {Number} dish_id
 * @property {String} name
 * @property {Number} quantity
 * @property {Number} price
 * @property {String} dish_pic
*/

/**
 * @returns {OrderDishAPI}
 */
module.exports.orderDishAPI = function orderDishAPI(dish_id,name,quantity,price,dish_pic) {
    return {
        dish_id:dish_id, name:name, quantity:quantity, price:price, dish_pic:dish_pic
    }
}

module.exports.OrderStatus = require('../../database/schemes').OrderStatus;

/**
 * API Order Eater
 * @typedef {Object} EaterOrderAPI
 * @property {Number} order_id
 * @property {CookProfileAPI} cook
 * @property {Number} total_price
 * @property {String} general_status
 * @property {Date} scheduled_time
 * @property {OrderDishAPI[]} dishes
*/

/**
 * @param {Date} sched_time
 * @param {CookProfileAPI} cookprofile 
 * @param {OrderDishAPI[]} dishes
 * @returns {EaterOrderAPI}
 */
module.exports.eaterOrderAPI = function eaterOrderAPI(order_id,cookprofile,total_price,gen_status,sched_time,dishes) {
    let sched_timeAPI = sched_time? datetimeAPI(sched_time) : null; // if sched_time null keep it null
    return {
        order_id:order_id, cook:cookprofile, total_price:total_price, general_status:gen_status, scheduled_time:sched_timeAPI,
        dishes:dishes
    }
}

/**
 * API Order Cook
 * @typedef {Object} CookOrderAPI
 * @property {Number} order_id
 * @property {EaterProfileAPI} eater
 * @property {Number} total_price
 * @property {String} general_status
 * @property {Date} scheduled_time
 * @property {OrderDishAPI[]} dishes
*/

/**
 * @param {Date} sched_time
 * @param {EaterProfileAPI} eaterprofile 
 * @param {OrderDishAPI[]} dishes
 * @returns {CookOrderAPI}
 */
module.exports.cookOrderAPI = function (order_id,eaterprofile,total_price,gen_status,sched_time,dishes) {
    let sched_timeAPI = sched_time? datetimeAPI(sched_time) : null; // if sched_time null keep it null
    return {
        order_id:order_id, eater:eaterprofile, total_price:total_price, general_status:gen_status, scheduled_time:sched_timeAPI,
        dishes:dishes
    }
}