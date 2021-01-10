const express = require('express');
/**
 * Main Module for cook
 * @param {express.Application} app 
 */
module.exports = function(app) {
    // Add cook API calls
    app.get('/cook', (req,res) => {
        res.send('Welcome to the Cooks Components');
    })
}