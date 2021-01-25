const express = require('express'); 

const apiConfig = require('../api_config');
const DEBUG = apiConfig.DEBUG;
// to be returned in the HTTP requests
const genDishAPI = apiConfig.genDish;
const successJSON = apiConfig.successJSON;
const failureJSON = apiConfig.failureJSON;

const router = express.Router();

// Generic dishes functions
const genDish = require('./dish/gen_dish');

router.post('/gen-dish/add', (req,res,next) => {
    if (DEBUG) console.log(req.body);

    let name=req.body.gendish_name, category=req.body.gendish_category;
    genDish.add(name,category, (err,gendish_id,message) => {
        if (err) return next(err);
        if (!gendish_id) return res.json(failureJSON(message));
        res.json(successJSON());
    })
})

router.post('/gen-dish/search', (req,res,next) => {
    if (DEBUG) console.log(req.body);

    let query=req.body.query;
    genDish.search(query, (err,gendishes,message) => {
        if (err) return next(err);
        if (!gendishes) return res.json(failureJSON(message));

        let toSend = successJSON();
        toSend.gen_dishes = [];
        for (const gendish of gendishes) {
            toSend.gen_dishes.push(
                genDishAPI(gendish.id,gendish.name,gendish.category)
            );
        }
        res.json(toSend);
    })
})


module.exports = router;