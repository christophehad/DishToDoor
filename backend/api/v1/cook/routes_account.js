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
    destination: (req, file, cb) => { cb(null, apiConfig.tmpPath) },
    filename: (req, file, cb) => {
        const uniquePref = Date.now() + '-' + Math.round(Math.random() * 1E9);
        cb(null, uniquePref + '.' + extension(file.mimetype));
    }
});
const upload = multer({ storage: storage });

const router = express.Router();

const account = require('./account/account');

router.post('/device/register', (req,res,next) => {
    if (DEBUG) console.log(req.body);

    let cook_id=req.user, token=req.body.token;
    account.updateToken(cook_id,token, (err,updated,message) => {
        if (err) return next(err);
        if (!updated) return res.json(failureJSON(message));
        res.json(successJSON());
    })
});

router.get('/device/delete', (req,res,next) => {
    if (DEBUG) console.log(req.query);

    let cook_id=req.user;
    account.deleteToken(cook_id, (err,deleted) => {
        if (err) return next(err);
        res.json(successJSON());
    })
});

router.post('/kitchen/pic/upload', upload.single('kitchen_pic'), (req, res, next) => {
    if (DEBUG) console.log(req.body);

    let cook_id = req.user;
    if (req.file) {
        // contains the kitchen pic
        if (DEBUG) console.log(`Received file: ${req.file.filename}, orig: ${req.file.originalname}, path: ${req.file.path}`);
        pic_path = req.file.path;
        pic_filename = req.file.filename;

        account.kitchenPicUpload(cook_id, pic_filename, pic_path, (err, added, message) => {
            if (err) return next(err);
            if (!added) return res.json(failureJSON(message));
            res.json(successJSON());
        })
    }
    else {
        res.json(failureJSON('missing_fields'));
    }
});

router.get('/kitchen/pic/get', (req,res,next) => {
    if (DEBUG) console.log(req.query);

    let cook_id=req.user;
    account.kitchenPicGet(cook_id, (err,pics,message) => {
        if (err) return next(err);
        if (pics.length == 0) return res.json(failureJSON(message));
        let toSend = successJSON();
        toSend.kitchen_pics = pics;
        res.json(toSend);
    })
})

module.exports = router;