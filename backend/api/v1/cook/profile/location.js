const database = require('../../../../database/database');
const router = require('../routes_dish');

exports.set = function set(cook_id,lat,lon,done) {
    if (!lat || !lon) return done(null,false,'missing_fields');
    database.cookSetLocation(cook_id,lat,lon, (err,modified) => {
        if (err) return done(err);
        if (!modified) return done(null,false,'no_row_affected');
        return done(null,true);
    });
}

/**
 * Callback for location routes
 * @callback cookLocationCallback
 * @param {String} err
 * @param {Number[]} [ret]
 * @param {String} [message]
*/

/**
 * @param {cookLocationCallback} done 
 */
exports.get = function get(cook_id,done) {
    database.cookGetLocation(cook_id, (err,latlon) => {
        if (err) return done(err);
        if (!latlon) return done(null,false,'no_coordinates');
        return done(null,latlon);
    })
}