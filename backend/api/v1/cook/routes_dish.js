const express = require('express');

const apiConfig = require('../api_config');
const DEBUG = apiConfig.DEBUG;
// to be returned in the HTTP requests
const genDishAPI = apiConfig.genDish;
const successJSON = apiConfig.successJSON;
const failureJSON = apiConfig.failureJSON;

// module for uploading pics
const multer = require('multer');
const fs = require('fs');
const extension = require('mime-types').extension;
const storage = multer.diskStorage({
    destination: (req, file, cb) => { cb(null, apiConfig.tmpPath + 'dish_pics/')},
    filename: (req,file,cb) => {
        const uniquePref = Date.now() + '-' + Math.round(Math.random()*1E9);
        cb(null, uniquePref+'.'+extension(file.mimetype));
    }
});
const upload = multer({ storage: storage });

const router = express.Router();

// Generic dishes functions
const genDish = require('./dish/gen_dish');
const cookDish = require('./dish/cook_dish');

router.post('/gen-dish/add', (req,res,next) => {
    if (DEBUG) console.log(req.body);

    let name=req.body.gendish_name, category=req.body.gendish_category;
    genDish.add(name,category, (err,gendish_id,message) => {
        if (err) return next(err);
        if (!gendish_id) return res.json(failureJSON(message));
        res.json(successJSON());
    })
})

// query should be in a 'query' query parameter
router.get('/gen-dish/search', (req,res,next) => {
    if (DEBUG) console.log(req.body);

    let query=req.query.query;
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

// get the gendish categories
router.get('/gen-dish/categories', (req,res,next) => {
    let genCategories = genDish.getCategories();
    let toSend = successJSON();
    toSend.gen_dish_categories = genCategories;
    res.json(toSend);
})


router.post('/cook-dish/add', upload.single('dish_pic'), (req,res,next) => {
    if (DEBUG) console.log(req.body);

    let cook_id=req.user,
        custom_name = req.body.custom_name ? req.body.custom_name : undefined;
        gendish_id=req.body.gendish_id, price=req.body.price, description=req.body.description, category=req.body.category;
    
    let dishpic_path, dishpic_filename;
    if (req.file) {
        // contains the dish_pic
        if (DEBUG) console.log(`Received file: ${req.file.filename}, orig: ${req.file.originalname}, path: ${req.file.path}`);
        dishpic_path = req.file.path;
        dishpic_filename = req.file.filename;
    }
    else {
        // without the dish_pic
        dishpic_path = undefined, dishpic_filename = undefined;
    }
    cookDish.add(gendish_id, cook_id, custom_name, price, category, description, dishpic_path, dishpic_filename, (err, cookdish_id, message) => {
        if (err) return next(err);
        if (!cookdish_id) return res.json(failureJSON(message));
        res.json(successJSON());
    })
})

// get the cookdishes
router.get('/cook-dish/get', (req, res, next) => {
    if (DEBUG) console.log(req.body);

    let cook_id = req.user;
    if (Object.keys(req.query).length == 0) {
        // get all the cookdishes
        cookDish.getAll(cook_id, (err,cookdishes,message) => {
            if (err) return next(err);
            if (!cookdishes) return res.json(failureJSON(message));

            let toSend = successJSON();
            /** @type {apiConfig.CookDishAPI[]} */
            let cook_dishesAPI = [];
            for (const cookdish of cookdishes) {
                cook_dishesAPI.push({
                    dish_id: cookdish.dish_id, gendish_id: cookdish.gendish_id, name: cookdish.name,
                    price: cookdish.price, category: cookdish.category, description: cookdish.description, dish_pic: cookdish.dish_pic
                });
            }
            toSend.cook_dishes = cook_dishesAPI;
            res.json(toSend);
        })
    }
    else {
        res.sendStatus(400);
    }
})

// make cookdish available
router.get('/cook-dish/available',(req,res,next) => {
    if (DEBUG) console.log(req.body);

    let cook_id = req.user, dish_id = req.query.dish_id;
    cookDish.makeAvailable(cook_id,dish_id, (err,added,message) => {
        if (err) return next(err);
        if (!added) return res.json(failureJSON(message));
        res.json(successJSON());
    })
})
// make cookdish unavailable
router.get('/cook-dish/unavailable',(req,res,next) => {
    if (DEBUG) console.log(req.body);

    let cook_id = req.user, dish_id = req.query.dish_id;
    cookDish.makeUnavailable(cook_id,dish_id, (err,added,message) => {
        if (err) return next(err);
        if (!added) return res.json(failureJSON(message));
        res.json(successJSON());
    })
})



module.exports = router;