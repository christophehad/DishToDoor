const mysql = require('mysql');

// Schemes and templates of database functions/entities
const schemes = require('./schemes');
module.exports.schemes = schemes;

// Cloud Storage
const cloudStorage = require('./cloud_storage');

const dbConfig = {
    host: 'localhost', // insert the database url here
    port: 3306,
    user: 'root',
    password: '',
    database: 'dishtodoor',
    supportBigNumbers: true // for the DECIMAL column
};

// in the future, it can become a connection pool (more efficient)
/** @type {mysql.Connection} */
var con; // con

// handling connection errors (after timeout for example)
function handleDisconnect() {
    con = mysql.createConnection(dbConfig);
    con.on('error', (err) => {
        if (err.code == 'PROTOCOL_CONNECTION_LOST') {
            console.log('MySQL connection lost. Reconnecting...');
            handleDisconnect();
        }
        else
            throw err;
    });
}
handleDisconnect();

module.exports.tryConnection = function tryConnection() {
    con.connect( (err) => {
        if (err) {
            if (err.code == 'PROTOCOL_ENQUEUE_HANDSHAKE_TWICE')
                return console.log('MySQL already connected');
            else
                return console.log(err);
        }
        console.log('Connected to the MySQL database!');
    })
}

/* Add functions as such to communicate with the MySQL database
   For example, a function can return a list of user ids, a success flag...
   Another way of writing it is to write function name(args) {...} 
   and add module.exports.name = name in the end of the file

   All functions should take an extra argument, the callback (usually named done):
   if there's an error err, return callback(err)
   else, return callback(null,...)

   TODO: Should we use instead connection pools?
*/

/* Login/Register Functions */

// internal functions for phone/email exist
function phoneExists(phone,type,done) {
    con.query('SELECT * FROM user_account WHERE phone = ? AND type = ?', [phone, type], (err, rows) => {
        if (err) return done(err);
        return done(null, rows.length > 0);
    })
}
function emailExists(email,type,done) {
    con.query('SELECT * FROM user_account WHERE email = ? AND type = ?', [email, type], (err, rows) => {
        if (err) return done(err);
        return done(null, rows.length > 0);
    })
}

// returns 1 if cook account with phone exists; else 0
module.exports.cookPhoneExists = function cookPhoneExists(phone,done) {
    return phoneExists(phone,'COOK',done);
}
// returns 1 if cook account with email exists; else 0
module.exports.cookEmailExists = function cookEmailExists(email,done) {
    return emailExists(email,'COOK',done);
}

// returns 1 if eater account with phone exists; else 0
module.exports.eaterPhoneExists = function eaterPhoneExists(phone,done) {
    return phoneExists(phone,'EATER',done);
}
// returns 1 if eater account with email exists; else 0
module.exports.eaterEmailExists = function eaterEmailExists(email,done) {
    return emailExists(email,'EATER',done);
}

// returns the cook ID
module.exports.cookRegisterPhone = function cookRegisterPhone(phone,pass,fname,lname,isVerified=false, done) {
    // create account
    con.query('INSERT into user_account (phone,type,password) values (?,?,?)',[phone,'COOK',pass], (err,result) => {
        if (err) return done(err);
        const id = result.insertId;
        // create common cook profile
        con.query('INSERT into user_profile (id,type,first_name,last_name) values (?,?,?,?)',[id,'COOK',fname,lname], (err,result) => {
            if (err) return done(err);
            // create specific cook profile
            con.query('INSERT into cook (cook_id,is_verified) values (?,?)',[id,isVerified],(err,result) => {
                if (err) return done(err);
                return done(null,id);
            })
        })
    })
}
// returns the cook ID
module.exports.cookRegisterEmail = function cookRegisterEmail(email,pass,fname,lname,isVerified=false, done) {
    // create account
    con.query('INSERT into user_account (email,type,password) values (?,?,?)',[email,'COOK',pass], (err,result) => {
        if (err) return done(err);
        const id = result.insertId;
        
        // create common cook profile
        con.query('INSERT into user_profile (id,type,first_name,last_name) values (?,?,?,?)',[id,'COOK',fname,lname], (err,result) => {
            if (err) return done(err);
            // create specific cook profile
            con.query('INSERT into cook (cook_id,is_verified) values (?,?)',[id,isVerified],(err,result) => {
                if (err) return done(err);
                return done(null,id);
            })
        })
    })
}
// returns the cook ID
module.exports.cookRegister = function cookRegister(email,phone,pass,fname,lname,isVerified=false, done) {
    // create account
    con.query('INSERT into user_account (email,phone,type,password) values (?,?,?,?)',[email,phone,'COOK',pass], (err,result) => {
        if (err) return done(err);
        const id = result.insertId;
        
        // create common cook profile
        con.query('INSERT into user_profile (id,type,first_name,last_name) values (?,?,?,?)',[id,'COOK',fname,lname], (err,result) => {
            if (err) return done(err);
            // create specific cook profile
            con.query('INSERT into cook (cook_id,is_verified) values (?,?)',[id,isVerified],(err,result) => {
                if (err) return done(err);
                return done(null,id);
            })
        })
    })
}

// returns the eater ID
module.exports.eaterRegisterPhone = function eaterRegisterPhone(phone,pass,fname,lname,done) {
    // create account
    con.query('INSERT into user_account (phone,type,password) values (?,?,?)',[phone,'EATER',pass], (err,result) => {
        if (err) return done(err);
        const id = result.insertId;
        // create common eater profile
        con.query('INSERT into user_profile (id,type,first_name,last_name) values (?,?,?,?)',[id,'EATER',fname,lname], (err,result) => {
            if (err) return done(err);
            // create specific eater profile
            con.query('INSERT into eater (eater_id) values (?)',[id],(err,result) => {
                if (err) return done(err);
                return done(null,id);
            })
        })
    })
}
// returns the eater ID
module.exports.eaterRegisterEmail = function eaterRegisterEmail(email,pass,fname,lname,done) {
    // create account
    con.query('INSERT into user_account (email,type,password) values (?,?,?)',[email,'EATER',pass], (err,result) => {
        if (err) return done(err);
        const id = result.insertId;
        
        // create common eater profile
        con.query('INSERT into user_profile (id,type,first_name,last_name) values (?,?,?,?)',[id,'EATER',fname,lname], (err,result) => {
            if (err) return done(err);
            // create specific eater profile
            con.query('INSERT into eater (eater_id) values (?)',[id],(err,result) => {
                if (err) return done(err);
                return done(null,id);
            })
        })
    })
}
// returns the eater ID
module.exports.eaterRegister = function eaterRegister(email,phone,pass,fname,lname,done) {
    // create account
    con.query('INSERT into user_account (email,phone,type,password) values (?,?,?,?)',[email,phone,'EATER',pass], (err,result) => {
        if (err) return done(err);
        const id = result.insertId;
        
        // create common eater profile
        con.query('INSERT into user_profile (id,type,first_name,last_name) values (?,?,?,?)',[id,'EATER',fname,lname], (err,result) => {
            if (err) return done(err);
            // create specific eater profile
            con.query('INSERT into eater (eater_id) values (?)',[id],(err,result) => {
                if (err) return done(err);
                return done(null,id);
            })
        })
    })
}

// returns the rows of the query
module.exports.cookLoginPhone = function cookLoginPhone(phone,done) {
    con.query('SELECT * FROM user_account WHERE phone = ? AND type = ?',[phone,'COOK'], (err,rows) => {
        if (err) return done(err);
        return done(null,rows);
    })
}
// returns the rows of the query
module.exports.cookLoginEmail = function cookLoginEmail(email,done) {
    con.query('SELECT * FROM user_account WHERE email = ? AND type = ?',[email,'COOK'], (err,rows) => {
        if (err) return done(err);
        return done(null,rows);
    })
}

// returns the rows of the query
module.exports.eaterLoginPhone = function eaterLoginPhone(phone,done) {
    con.query('SELECT * FROM user_account WHERE phone = ? AND type = ?',[phone,'EATER'], (err,rows) => {
        if (err) return done(err);
        return done(null,rows);
    })
}
// returns the rows of the query
module.exports.eaterLoginEmail = function eaterLoginEmail(email,done) {
    con.query('SELECT * FROM user_account WHERE email = ? AND type = ?',[email,'EATER'], (err,rows) => {
        if (err) return done(err);
        return done(null,rows);
    })
}

// internal function for checking if account exists; returns 1 if exists
function accountExists(id,type,done) {
    con.query('SELECT * FROM user_account WHERE id = ? AND type = ?',[id,type], (err,rows) => {
        if (err) return done(err);
        return done(null,rows.length > 0);
    })
}

// returns 1 if cook account exists
module.exports.cookAccountExists = function cookAccountExists(id,done) {
    return accountExists(id,'COOK',done);
}
// returns 1 if eater account exists
module.exports.eaterAccountExists = function eaterAccountExists(id,done) {
    return accountExists(id,'EATER',done);
}

// returns 1 if cook is verified
module.exports.cookIsVerified = function cookIsVerified(id,done) {
    con.query('SELECT is_verified FROM cook WHERE cook_id = ?',[id], (err,rows) => {
        if (err) return done(err);
        return done(null,rows[0].is_verified == 1);
    })
}

// returns 1 if successful
module.exports.cookSetLocation = function cookSetLocation(id,lat,lon,done) {
    con.query('UPDATE cook SET lat = ?, lon = ? WHERE cook_id = ?',[lat,lon,id], (err,result) => {
        if (err) return done(err);
        return done(null,result.affectedRows > 0);
    })
}

// returns false if unsuccessful (no lat or lon set); else return [lat,lon] as floats
module.exports.cookGetLocation = function cookGetLocation(id,done) {
    con.query('SELECT lat,lon FROM cook WHERE cook_id = ?',[id], (err,rows) => {
        if (err) return done(err);
        if (rows.length == 0) return done(null,false);
        let lat=rows[0].lat, lon=rows[0].lon;
        if (!lat || !lon) return done(null,false);
        return done(null,[parseFloat(lat),parseFloat(lon)]);
    })
}

/* Generic Dishes Functions */

// returns the gendish id
module.exports.genDishAdd = function genDishAdd(name,category,mean_price=0,done) {
    con.query('INSERT into generic_dishes (gendish_name,category,mean_price) values (?,?,?)',[name,category,mean_price], (err,result) => {
        if (err) return done(err);
        return done(null,result.insertId);
    })
}

/**
 * search for rows having query in name; returns an array of GenDish
 * @param {schemes.genDishSearchCallback} done 
 */
module.exports.genDishSearch = function genDishSearch(query,done) {
    con.query('SELECT * FROM generic_dishes WHERE LOCATE(?,LOWER(gendish_name))>0',[query.toLowerCase()], (err,rows) => {
        if (err) return done(err);

        /** @type {schemes.GenDish[]} */
        let found_gen = [];
        for (const row of rows) {
            found_gen.push(schemes.genDish(row.gendish_id,row.gendish_name,row.category));
        }
        return done(null,found_gen);
    })
}


/* Cook Dishes Functions */

// returns the cookdish id
module.exports.cookDishAdd = function cookDishAdd(gendish_id,cook_id,custom_name,price,category,label,description,dish_pic,done) {
    con.query('INSERT into dishes (gendish_id,cook_id,custom_name,price,category,label,description,dish_pic) values (?,?,?,?,?,?,?,?)',
        [gendish_id,cook_id,custom_name,price,category,label,description,dish_pic], (err,result) => {
            if (err) return done(err);
            return done(null,result.insertId);
        })
}

/**
 * returns a list of the dishes for a cook (the name is the gendish_name if custom_name is null or custom_name else)
 * @param {schemes.cookDishSearchCallback} done 
 */
module.exports.cookDishGetAll = function cookDishGetAll(cook_id,done) {
    con.query('SELECT dishes.*, generic_dishes.gendish_name FROM dishes, generic_dishes '+
                'WHERE dishes.gendish_id = generic_dishes.gendish_id AND dishes.cook_id = ?',[cook_id], (err,rows) => {
                    if (err) return done(err);

                    /** @type {schemes.CookDish[]} */
                    let cookdishes = [];
                    for (const row of rows) {
                        let name = row.custom_name ? row.custom_name : row.gendish_name;
                        cookdishes.push(schemes.cookDish(
                            row.dish_id,row.gendish_id,row.cook_id,name,row.price,
                            row.category,row.label,row.description,row.dish_pic
                        ));
                    }
                    return done(null,cookdishes);
                })
}

module.exports.uploadCookDishPic = cloudStorage.uploadCookDishPic;