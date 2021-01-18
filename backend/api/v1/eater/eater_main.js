const express = require('express');
const passportJWT = require('./auth/jwt');

/**
 * Main Module for eater
 * @param {express.Application} app
 */
module.exports = function (app) {

    // Load auth routes
    const routesAuth = require('./routes_auth');
    const some_api_routes = express.Router();

    some_api_routes.get('/secret', (req, res) => {
        res.send(`Welcome!\nThis is the secret page for eater ${req.user}`);
    });

    app.use('/eater', routesAuth);
    app.use('/eater/api', passportJWT.authenticate('jwt-eater', { session: false }), some_api_routes);

    // Add eater API calls
    app.get('/eater', (req, res) => {
        res.send('Welcome to the Eaters Components');
    })
}