const express = require('express');
const jwt = require('jsonwebtoken');

const jwtData = require('../../../cert/config').jwtData;
const apiConfig = require('../api_config');
const DEBUG = apiConfig.DEBUG;
// to be returned in the HTTP requests
const successJSON = apiConfig.successJSON;
const failureJSON = apiConfig.failureJSON;
const router = express.Router();

const passportLocal = require('./auth/local');

// register routes
router.post('/register-phone', (req, res, next) => {
    if (DEBUG) console.log(req.body);
    passportLocal.authenticate('eater-register-phone', (err, id, info) => {
        if (err) return next(err);
        if (!id) return res.send(failureJSON("phone_used"));
        res.send(successJSON());
    })(req,res,next);
});

router.post('/register-email', (req, res, next) => {
    if (DEBUG) console.log(req.body);
    passportLocal.authenticate('eater-register-email', (err, id, info) => {
        if (err) return next(err);
        if (!id) return res.send(failureJSON("email_used"));
        res.send(successJSON());
    })(req,res,next);
});

router.post('/register', (req, res, next) => {
    if (DEBUG) console.log(req.body);
    passportLocal.authenticate('eater-register-email-phone', (err, id, info) => {
        if (err) return next(err);
        if (!id) return res.send(failureJSON(info.message));
        res.send(successJSON());
    })(req,res,next);
});

// login routes with tokens
router.post('/login-phone', (req, res, next) => {
    if (DEBUG) console.log(req.body);
    passportLocal.authenticate('eater-login-phone', (err, user, info) => {
        if (err) return next(err);
        if (!user) return res.send(failureJSON(info.message));
        // didn't include req.login since we're not using sessions
        // generate a jwt, containing the signed user_id
        let to_sign = {
            id: user.id
        };
        jwt.sign(to_sign,jwtData.privKey, (err,token) => {
            if (err) return next(err);
            let toSend = successJSON(); toSend.token = token;
            res.json(toSend);
        });
    })(req, res, next);
});
// login routes with tokens
router.post('/login-email', (req, res, next) => {
    if (DEBUG) console.log(req.body);
    passportLocal.authenticate('eater-login-email', (err, user, info) => {
        if (err) return next(err);
        if (!user) return res.send(failureJSON(info.message));
        // didn't include req.login since we're not using sessions
        // generate a jwt, containing the signed user_id
        let to_sign = {
            id: user.id
        };
        jwt.sign(to_sign,jwtData.privKey, (err,token) => {
            if (err) return next(err);
            let toSend = successJSON(); toSend.token = token;
            res.json(toSend);
        });
    })(req, res, next);
});

module.exports = router;