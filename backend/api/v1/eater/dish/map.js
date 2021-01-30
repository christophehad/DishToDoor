const database = require('../../../../database/database');

/**
 * Callback for cook and dishes on map
 * @callback cookLocationCallback
 * @param {String} err
 * @param {database.schemes.CookMap[]} [cooks]
 * @param {String} [message]
*/

/**
 * get cooks and dishes on map
 * @param {cookLocationCallback} done 
 */
exports.getCooksAround = function getCooksAround(eater_id,lat,lon,done) {
    if (!lat || !lon) return done(null,false,'missing_fields');
    database.getDishesAround(eater_id,lat,lon,undefined, (err,cooks) => {
        if (err) return done(err);
        if (!cooks) return done(null,false,'no_cooks_around');
        return done(null,cooks);
    })
}