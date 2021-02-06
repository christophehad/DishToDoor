const { query } = require('express');
const express = require('express');
const { schemes } = require('../../../database/database');

const apiConfig = require('../api_config');
const DEBUG = apiConfig.DEBUG;
// to be returned in the HTTP requests
const cookDishAPI = apiConfig.cookDish;
const cookMapAPI = apiConfig.cookMap;
const successJSON = apiConfig.successJSON;
const failureJSON = apiConfig.failureJSON;
const addDate = apiConfig.addDateISO;

const router = express.Router();

const map = require('./dish/map');

router.get('/dish/around',(req,res,next) => {
    if (DEBUG) console.log(req.query);

    let eater_id=req.user, lat=req.query.lat, lon=req.query.lon;
    map.getCooksAround(eater_id,lat,lon, (err,cooks,message) => {
        if (err) return next(err);
        if (!cooks) return res.json(failureJSON(message));
        
        let toSend = successJSON();
        /** @type {apiConfig.CookMapAPI[]} */
        let cooks_with_dishesAPI = [];
        for (const cook of cooks) {
            /** @type {apiConfig.CookDishAPI[]} */
            let dishes = [];
            for (const dish of cook.dishes) {
                dishes.push(cookDishAPI(dish.dish_id,dish.gendish_id,dish.name,dish.price,dish.category,
                                        dish.category,dish.dish_pic));
            }
            cooks_with_dishesAPI.push(cookMapAPI(cook.first_name,cook.last_name,cook.logo,
                                                cook.lat,cook.lon,cook.distance,
                                                addDate(cook.opening_time),addDate(cook.closing_time),
                                                dishes));
        }
        toSend.cooks = cooks_with_dishesAPI;
        res.json(toSend);
    })
})

module.exports = router;