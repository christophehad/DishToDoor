const express = require('express');
const app = express();

const cookComponents = require('./api/cook/cook_main');
const eaterComponents = require('./api/eater/eater_main');
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