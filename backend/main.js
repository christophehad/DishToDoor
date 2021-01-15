const express = require('express');
const fs = require('fs');
const https = require('https');
const app = express();

// SSL private key and certificate
var privateKey = fs.readFileSync('./cert/dishtodoor.key');
var certificate = fs.readFileSync('./cert/dishtodoor.crt');
var credentials = {key: privateKey, cert: certificate};

const cookComponents = require('./api/v1/cook/cook_main');
const eaterComponents = require('./api/v1/eater/eater_main');
const database = require('./database/database');

// port used by the server
const port = 3000;

app.use(express.json()); // for retrieving json files from POST requests

// dummy response for now
app.get('/', (req,res) => {
    res.send("Welcome to the DishToDoor backend!");
})

// load the cook components into the server
cookComponents(app);

// load the eater components into the server
eaterComponents(app);

app.listen(port, () => {
    console.log(`Listening on port ${port}`);
})

// https server (just uncomment those lines and comment the listen)
/* var httpsServer = https.createServer(credentials, app);

httpsServer.listen(port, () => {
    console.log(`Listening on port ${port}`);
}); */