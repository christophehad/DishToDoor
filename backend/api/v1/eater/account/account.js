const common = require('../../common/account');
const database = require('../../../../database/database');

exports.updateToken = common.updateToken;

exports.deleteToken = common.deleteToken;

/**
 * Callback for passing eater account
 * @callback eaterAccountCallback
 * @param {String} err
 * @param {database.schemes.EaterAccount} [eater]
 * @param {String} [message]
*/

/**
 * @param {eaterAccountCallback} done
 */
exports.getAccount = function(eater_id,done) {
    database.eaterGetAccount(eater_id, (err,eater) => {
        if (err) return done(err);
        return done(null,eater);
    })
}

exports.updateName = common.updateName;