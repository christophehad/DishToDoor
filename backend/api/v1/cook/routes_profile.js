const express = require('express');

const apiConfig = require('../api_config');
const DEBUG = apiConfig.DEBUG;
// to be returned in the HTTP requests
const successJSON = apiConfig.successJSON;
const failureJSON = apiConfig.failureJSON;

const router = express.Router();

const location = require('./profile/location');

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

module.exports = router;