const { query } = require('express');
const express = require('express');
const { schemes } = require('../../../database/database');

const apiConfig = require('../api_config');
const DEBUG = apiConfig.DEBUG;
// to be returned in the HTTP requests
const cookDishAPI = apiConfig.cookDish;
const cookMapAPI = apiConfig.cookMap;
const cookProfileAPI = apiConfig.cookProfileAPI;
const eaterOrderAPI = apiConfig.eaterOrderAPI;
const successJSON = apiConfig.successJSON;
const failureJSON = apiConfig.failureJSON;
const addDate = apiConfig.addDateISO;

const router = express.Router();

const map = require('./dish/map');
const order = require('./dish/order');

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
});

router.post('/dish/checkout',(req,res,next) => {
    if (DEBUG) console.log(req.body);

    let eater_id=req.user, datetime=req.body.scheduled_time, dishes=req.body.dishes, total=req.body.total;
    order.checkout(eater_id,datetime,dishes,total, (err,ordered,message) => {
        if (err) return next(err);
        if (!ordered) return res.json(failureJSON(message));
        res.json(successJSON());
    })
})

router.get('/orders/get',(req,res,next) => {
    if (DEBUG) console.log(req.query);

    let eater_id=req.user;
    if (Object.keys(req.query).length == 0) {
        // get all the orders
        order.getOrdersAll(eater_id, (err,orderwrappers,message) => {
            if (err) return next(err);
            if (!orderwrappers) return res.json(failureJSON(message));
            let toSend = successJSON();
            /** @type {apiConfig.EaterOrderAPI[]} */
            let orders = [];
            for (const orderwrapper of orderwrappers) {
                let cookProfile = cookProfileAPI(
                    orderwrapper.cook.first_name, orderwrapper.cook.last_name, orderwrapper.cook.logo,
                    orderwrapper.cook.lat, orderwrapper.cook.lon, orderwrapper.cook.opening_time, orderwrapper.cook.closing_time
                );
                let curOrder = eaterOrderAPI(
                    orderwrapper.order.order_id, cookProfile, orderwrapper.order.total_price,
                    orderwrapper.order.general_status, orderwrapper.order.scheduled_time, orderwrapper.dishes
                );
                orders.push(curOrder);
            }
            toSend.orders = orders;
            res.json(toSend);
        })
    }
    else {
        res.sendStatus(400);
    }
})

module.exports = router;