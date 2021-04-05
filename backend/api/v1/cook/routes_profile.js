const express = require('express');

const apiConfig = require('../api_config');
const DEBUG = apiConfig.DEBUG;
// to be returned in the HTTP requests
const successJSON = apiConfig.successJSON;
const failureJSON = apiConfig.failureJSON;
const cookAccountAPI = apiConfig.cookAccountAPI;

// module for uploading pics
const multer = require('multer');
const fs = require('fs');
const extension = require('mime-types').extension;
const storage = multer.diskStorage({
    destination: (req, file, cb) => { cb(null, apiConfig.tmpPath) },
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

router.post('/profile/times/set',(req,res,next) => {
    if (DEBUG) console.log(req.body);

    let cook_id = req.user, opening_time=req.body.opening_time, closing_time=req.body.closing_time;
    profile.openCloseTimeSet(cook_id, opening_time, closing_time, (err,added,message) => {
        if (err) return next(err);
        if (!added) return res.json(failureJSON(message));
        res.json(successJSON());
    })
});

router.get('/profile/times/get',(req,res,next) => {
    if (DEBUG) console.log(req.body);

    let cook_id = req.user;
    profile.openCloseTimeGet(cook_id, (err,openclosing,message) => {
        if (err) return next(err);
        if (!openclosing) return res.json(failureJSON(message));
        let toSend = successJSON();
        toSend.opening_time=openclosing[0], toSend.closing_time=openclosing[1];
        res.json(toSend);
    })
})

router.get('/profile/get',(req,res,next) => {
    if (DEBUG) console.log(req.body);

    let cook_id = req.user;
    profile.getAccount(cook_id, (err,cook,message) => {
        if (err) return next(err);
        let cookAccount = cookAccountAPI(cook);
        let toSend = successJSON();
        toSend.cook = cookAccount;
        res.json(toSend);
    })
})

router.post('/profile/name/set',(req,res,next) => {
    if (DEBUG) console.log(req.body);

    let cook_id = req.user, f_name=req.body.first_name, l_name=req.body.last_name;
    profile.updateName(cook_id,f_name,l_name, (err,updated,message) => {
        if (err) return next(err);
        if (!updated) return res.json(failureJSON(message));
        res.json(successJSON());
    })
})

router.post('/profile/phone/share', (req,res,next) => {
    if (DEBUG) console.log(req.body);

    let cook_id = req.user, shared=req.body.shared;
    if (shared === undefined) return res.json(failureJSON('missing_fields'));

    shared = shared == true;
    profile.changePhoneShare(cook_id,shared, (err,success) => {
        if (err) return next(err);
        res.json(successJSON());
    })
})

module.exports = router;