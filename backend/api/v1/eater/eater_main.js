const express = require('express');
/**
 * Main Module for eater
 * @param {express.Application} app
 */
module.exports = function (app) {
    // Add eater API calls
    app.get('/eater', (req, res) => {
        res.send('Welcome to the Eaters Components');
    })
}