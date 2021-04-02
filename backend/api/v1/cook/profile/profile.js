const database = require('../../../../database/database');
const account = require('../../common/account');

exports.profilePicSet = function profilePicSet(cook_id,pic_name,pic_path,done) {
    database.cookSetPic(cook_id,pic_name,pic_path, (err,added) => {
        if (err) return done(err);
        if (!added) return done(null,false,'cloud_problem');
        return done(null,true);
    })
}

exports.profilePicGet = function profilePicGet(cook_id,done) {
    database.cookGetPic(cook_id, (err,pic_url) => {
        if (err) return done(err);
        if (!pic_url) return done(null,false,'no_pic');
        return done(null,pic_url);
    })
}

exports.openCloseTimeSet = function openCloseTimeSet(cook_id,opening,closing,done) {
    if (!opening || !closing) return done(null,false,'missing_fields');

    // check if correct time format and opening < closing
    let opening_parse = Date.parse('01/01/2020 ' + opening), closing_parse = Date.parse('01/01/2020 ' + closing);
    if (isNaN(opening_parse) || isNaN(closing_parse)) return done(null,false,'wrong_time_format');
    let openBeforeClose = opening_parse < closing_parse;
    if (!openBeforeClose) return done(null,false,'opening_after_closing');

    database.cookSetOpenCloseTimes(cook_id,opening,closing, (err,added) => {
        if (err) return done(err);
        if (!added) return done(null,false,'database_problem');
        return done(null,true);
    })
}

exports.openCloseTimeGet = function openCloseTimeGet(cook_id,done) {
    database.cookGetOpenCloseTimes(cook_id, (err,openclosing) => {
        if (err) return done(err);
        if (!openclosing) return done(null,false,'no_times');
        return done(null,openclosing);
    })
}

/**
 * Callback for passing cook account
 * @callback cookAccountCallback
 * @param {String} err
 * @param {database.schemes.CookAccount} [cook]
 * @param {String} [message]
*/

/**
 * @param {cookAccountCallback} done 
 */
exports.getAccount = function(cook_id,done) {
    database.cookGetAccount(cook_id, (err,cookaccount) => {
        if (err) return done(err);
        return done(null,cookaccount);
    })
}

exports.updateName = account.updateName;