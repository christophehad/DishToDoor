const express = require('express');
const passportJWT = require('./auth/jwt');
const fs = require('fs');
const apiConfig = require('../api_config');

/**
 * Main Module for cook
 * @param {express.Application} app 
 */
module.exports = function(app) {
    // create tmp folder if not present

    if (!fs.existsSync(apiConfig.tmpPath)) {
        fs.mkdirSync(apiConfig.tmpPath);
        console.log('Created tmp Path at ' + apiConfig.tmpPath);
    }

    // Load auth routes
    const routesAuth = require('./routes_auth');
    const some_api_routes = express.Router();

    // Load dish routes
    const routesDish = require('./routes_dish');

    // Load profile routes
    const routesProfile = require('./routes_profile');

    some_api_routes.get('/secret', (req,res) => {
        res.send(`Welcome!\nThis is the secret page for cook ${req.user}`);
    });

    app.use('/cook',routesAuth);
    app.use('/cook/api',passportJWT.authenticate('jwt-cook', { session: false }), some_api_routes);
    app.use('/cook/api',passportJWT.authenticate('jwt-cook', {session: false}),routesDish);
    app.use('/cook/api',passportJWT.authenticate('jwt-cook', {session: false}),routesProfile);

    // Add cook API calls
    app.get('/cook', (req,res) => {
        res.send('Welcome to the Cooks Components');
    })
}