const database = require('../../../../database/database');

exports.profilePicSet = function profilePicSet(cook_id,pic_name,pic_path,done) {
    database.cookSetPic(cook_id,pic_name,pic_path, (err,added) => {
        if (err) return done(err);
        if (!added) return done(null,false,'cloud_error');
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