const express = require('express');

const apiConfig = require('../api_config');
const DEBUG = apiConfig.DEBUG;
// to be returned in the HTTP requests
const successJSON = apiConfig.successJSON;
const failureJSON = apiConfig.failureJSON;

const router = express.Router();

const account = require('./account/account');

router.post('/device/register', (req,res,next) => {
    if (DEBUG) console.log(req.body);

    let eater_id=req.user, token=req.body.token;
    account.updateToken(eater_id,token, (err,updated,message) => {
        if (err) return next(err);
        if (!updated) return res.json(failureJSON(message));
        res.json(successJSON());
    })
});

router.get('/device/delete', (req,res,next) => {
    if (DEBUG) console.log(req.query);

    let eater_id=req.user;
    account.deleteToken(eater_id, (err,deleted) => {
        if (err) return next(err);
        res.json(successJSON());
    })
})

module.exports = router;