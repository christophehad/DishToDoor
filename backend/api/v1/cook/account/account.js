const common = require('../../common/account');
const database = require('../../../../database/database');

exports.updateToken = common.updateToken;

exports.deleteToken = common.deleteToken;

exports.kitchenPicUpload = function (cook_id, pic_name, pic_path, done) {
    database.cookUploadKitchenPic(cook_id, pic_name, pic_path, (err, added) => {
        if (err) return done(err);
        if (!added) return done(null, false, 'cloud_problem');
        return done(null, true);
    })
}

exports.kitchenPicGet = function (cook_id, done) {
    database.cookGetKitchenPics(cook_id, (err,pics) => {
        if (err) return done(err);
        if (pics.length == 0) return done(null,false,'no_pics');
        return done(null,pics);
    })
}