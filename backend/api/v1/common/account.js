const database = require('../../../database/database');

exports.updateToken = function(user_id,token,done) {
    if (!token) return done(null,false,'missing_fields');
    database.userRegisterDevice(user_id,undefined,token, (err,registered) => {
        if (err) return done(err);
        return done(null,true);
    })
}

exports.deleteToken = function(user_id,done) {
    database.deviceDeleteToken(user_id, (err, deleted) => {
        if (err) return done(err);
        return done(null,true);
    })
}

exports.updateName = function(user_id,f_name,l_name,done) {
    if (!f_name || !l_name) return done(null, false, 'missing_fields');
    database.userUpdateNames(user_id,f_name,l_name, (err,updated) => {
        if (err) return done(err);
        return done(null,true);
    })
}