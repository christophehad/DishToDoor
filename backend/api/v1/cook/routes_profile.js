const express = require('express');

const apiConfig = require('../api_config');
const DEBUG = apiConfig.DEBUG;
// to be returned in the HTTP requests
const successJSON = apiConfig.successJSON;
const failureJSON = apiConfig.failureJSON;

// module for uploading pics
const multer = require('multer');
const fs = require('fs');
const extension = require('mime-types').extension;
const storage = multer.diskStorage({
    destination: (req, file, cb) => { cb(null, apiConfig.tmpPath + 'dish_pics/') },
    filename: (req, file, cb) => {
        const uniquePref = Date.now() + '-' + Math.round(Math.random() * 1E9);
        cb(null, uniquePref + '.' + extension(file.mimetype));
    }
});
const upload = multer({ storage: storage });

const router = express.Router();

const location = require('./profile/location');
const profile = require('./profile/profile');
const { add } = require('./dish/gen_dish');

router.post('/location/set',(req,res,next) => {
    if (DEBUG) console.log(req.body);

    let cook_id=req.user, lat=req.body.lat, lon=req.body.lon;
    location.set(cook_id,lat,lon, (err,added,message) => {
        if (err) return next(err);
        if (!added) return res.json(failureJSON(message));
        res.json(successJSON());
    })
});

router.get('/location/get',(req,res,next) => {
    if (DEBUG) console.log(req.body);

    let cook_id=req.user;
    location.get(cook_id, (err,latlon,message) => {
        if (err) return next(err);
        if (!latlon) return res.json(failureJSON(message));
        let toSend = successJSON();
        toSend.lat = latlon[0]; toSend.lon = latlon[1];
        res.json(toSend);
    })
});

router.post('/profile/pic/set',upload.single('profile_pic'), (req,res,next) => {
    if (DEBUG) console.log(req.body);

    let cook_id=req.user;
    if (req.file) {
        // contains the profile pic
        if (DEBUG) console.log(`Received file: ${req.file.filename}, orig: ${req.file.originalname}, path: ${req.file.path}`);
        pic_path = req.file.path;
        pic_filename = req.file.filename;

        profile.profilePicSet(cook_id,pic_filename,pic_path,(err,added,message) => {
            if (err) return next(err);
            if (!added) return res.json(failureJSON(message));
            res.json(successJSON());
        })
    }
    else {
        res.json(failureJSON('missing_fields'));
    }
});

router.get('/profile/pic/get',(req,res,next) => {
    if (DEBUG) console.log(req.body);

    let cook_id = req.user;
    profile.profilePicGet(cook_id, (err,pic_url,message) => {
        if (err) return next(err);
        if (!pic_url) return res.json(failureJSON(message));
        let toSend = successJSON(); toSend.profile_pic = pic_url;
        res.json(toSend);
    })
});

module.exports = router;