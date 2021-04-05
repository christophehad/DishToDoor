const mysql = require('mysql');
const async = require ('async'); // for using async loops

// Schemes and templates of database functions/entities
const schemes = require('./schemes');
module.exports.schemes = schemes;

// Cloud Storage
const cloudStorage = require('./cloud_storage');

const dbConfig = {
    host: 'localhost', // insert the database url here
    port: process.env.MYSQL_PORT || process.env.WEBSITE_MYSQL_PORT || 50207, // 3306, for local
    user: 'azure', // 'root',
    password: '6#vWHD_$',// '',
    database: 'dishtodoor',
    supportBigNumbers: true // for the DECIMAL column
};

// in the future, it can become a connection pool (more efficient)
/** @type {mysql.Connection} */
var con; // con

// handling connection errors (after timeout for example)
function handleDisconnect() {
    con = mysql.createConnection(dbConfig);
    con.connect( (err) => {
        if (err) {
            console.log('Error connecting to database: ',err);
            console.log('Retrying in 5s...');
            setTimeout(handleDisconnect,5000);
        }
        else
            console.log('Connected to the MySQL database!');
    })
    con.on('error', (err) => {
        if (err.code == 'PROTOCOL_CONNECTION_LOST' || err.code == 'PROTOCOL_ENQUEUE_AFTER_FATAL_ERROR') {
            console.log('MySQL connection lost. Reconnecting...');
            handleDisconnect();
        }
        else
            throw err;
    });
}
handleDisconnect();

module.exports.tryConnection = function tryConnection(done) {
    con.connect( (err) => {
        if (err) {
            if (err.code == 'PROTOCOL_ENQUEUE_HANDSHAKE_TWICE') {
                console.log('MySQL already connected'); return done(null, 'MySQL already connected');
            }
            else {
                console.log(err); return done(err);
            }
        }
        console.log('Connected to the MySQL database!'); return done(null, 'Connected to the MySQL database!');
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

// returns true if a user has already registered a device
function deviceRegisteredUser(id,done) {
    con.query('SELECT * FROM user_device WHERE id = ?',[id], (err, rows) => {
        if (err) return done(err);
        return done(null, rows.length > 0);
    })
}

// returns token if a user has already registered a device; else false
module.exports.deviceGetToken = function(id,done) {
    con.query('SELECT token FROM user_device WHERE id = ?',[id], (err, rows) => {
        if (err) return done(err);
        if (rows.length == 0) return done(null,false);
        return done(null, rows[0].token);
    })
}

// returns true if device was registered
module.exports.userRegisterDevice = function(id,platform='android',token,done) {
    deviceRegisteredUser(id, (err,hasDevice) => {
        if (err) return done(err);
        if (hasDevice) {
            // update the token
            con.query('UPDATE user_device SET token = ? WHERE id = ?',[token,id], (err,result) => {
                if (err) return done(err);
                return done(null,true);
            })
        }
        else {
            // insert a new row
            con.query('INSERT into user_device (id,token) values (?,?)',[id,token], (err,result) => {
                if (err) return done(err);
                return done(null,true);
            })
        }
    })
}

// delete device(s) associated with user
module.exports.deviceDeleteToken = function(id,done) {
    con.query('DELETE FROM user_device WHERE id = ?',[id], (err,result) => {
        if (err) return done(err);
        return done(null,true);
    })
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
module.exports.cookRegister = function cookRegister(email,phone,pass,fname,lname,isVerified=false,exp,cert,train,inspect,done) {
    // create account
    con.query('INSERT into user_account (email,phone,type,password) values (?,?,?,?)',[email,phone,'COOK',pass], (err,result) => {
        if (err) return done(err);
        const id = result.insertId;
        
        // create common cook profile
        con.query('INSERT into user_profile (id,type,first_name,last_name) values (?,?,?,?)',[id,'COOK',fname,lname], (err,result) => {
            if (err) return done(err);
            // create specific cook profile
            con.query('INSERT into cook (cook_id,is_verified,experience,certified_chef,willing_training,consent_inspection) values (?,?,?,?,?,?)',[id,isVerified,exp,cert,train,inspect],(err,result) => {
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

// returns the admin ID
module.exports.adminRegister = function adminRegister(email, pass, done) {
    // create account
    con.query('INSERT into user_account (email,type,password) values (?,?,?)', [email, 'ADMIN', pass], (err, result) => {
        if (err) return done(err);
        const id = result.insertId;
        return done(null,id);
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

// returns the rows of the query
module.exports.adminLogin = function adminLogin(email,done) {
    con.query('SELECT * FROM user_account WHERE email = ? AND type = ?',[email,'ADMIN'], (err,rows) => {
        if (err) return done(err);
        return done(null,rows);
    })
}

// internal function for checking if account exists; returns 1 if exists
function changeBlockStatus(user_id,blocked,done) {
    con.query('UPDATE user_account SET blocked = ? WHERE id = ?',[blocked,user_id], (err,result) => {
        if (err) return done(err);
        return done(null,true);
    })
}

// returns true
module.exports.blockAccount = function(user_id,done) {
    return changeBlockStatus(user_id,1,done);
}

// returns true
module.exports.unblockAccount = function(user_id,done) {
    return changeBlockStatus(user_id,0,done);
}

// internal function for checking if account exists and allowed to function; returns 1 if exists
function accountExists(id,type,done) {
    con.query('SELECT * FROM user_account WHERE id = ? AND type = ?',[id,type], (err,rows) => {
        if (err) return done(err);
        if (rows.length == 0) return done(null,false);
        return done(null,rows[0].blocked == 0);
    })
}

// returns 1 if cook account exists and allowed to function
module.exports.cookAccountExists = function cookAccountExists(id,done) {
    return accountExists(id,'COOK',done);
}
// returns 1 if eater account exists and allowed to function
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

// returns false if unsuccessful (cloud or database)
module.exports.cookSetPic = function cookSetPic(id,local_pic_name,local_pic_path,done) {
    cloudStorage.uploadCookProfilePic(local_pic_name,local_pic_path).then(cloud_url => {
        con.query('UPDATE cook SET cook_logo = ? WHERE cook_id = ?',[cloud_url,id], (err,result) => {
            if (err) return done(err);
            return done(null,result.affectedRows > 0);
        })
    }).catch(err => {return done(null,false);})
}
// returns the url of the profile pic
module.exports.cookGetPic = function cookGetPic(id, done) {
    con.query('SELECT cook_logo FROM cook WHERE cook_id = ?',[id], (err,rows) => {
        if (err) return done(err);
        if (rows.length == 0) return done(null,false);
        let cook_pic = rows[0].cook_logo;
        return done(null,cook_pic);
    })
}

// returns false if unsuccessful (cloud or database)
module.exports.cookUploadKitchenPic = function (id, local_pic_name, local_pic_path, done) {
    cloudStorage.uploadCookKitchenPic(local_pic_name, local_pic_path).then(cloud_url => {
        con.query('INSERT into cook_kitchen_pics (cook_id,kitchen_pic) values (?,?)', [id,cloud_url], (err, result) => {
            if (err) return done(err);
            return done(null, result.affectedRows > 0);
        })
    }).catch(err => { return done(null, false); })
}
// returns a list of the urls of the kitchen pics
module.exports.cookGetKitchenPics = function (id, done) {
    con.query('SELECT kitchen_pic FROM cook_kitchen_pics WHERE cook_id = ?', [id], (err, rows) => {
        if (err) return done(err);
        let kitchen_pics = [];
        for (const row of rows) {
            kitchen_pics.push(row.kitchen_pic);
        }
        return done(null, kitchen_pics);
    })
}

// return true if successful
module.exports.cookSetOpenCloseTimes = function cookSetOpenCloseTimes(id,opening_time,closing_time,done) {
    con.query('UPDATE cook SET opening_time = ?, closing_time = ? WHERE cook_id = ?',[opening_time,closing_time,id], (err,result) => {
        if (err) return done(err);
        return done(null, result.affectedRows > 0);
    })
}
// returns a list of [opening,closing] times
module.exports.cookGetOpenCloseTimes = function cookGetOpenCloseTimes(id, done) {
    con.query('SELECT opening_time,closing_time FROM cook WHERE cook_id = ?', [id], (err, rows) => {
        if (err) return done(err);
        if (rows.length == 0) return done(null, false);
        let opening=rows[0].opening_time, closing=rows[0].closing_time;
        return done(null, [opening,closing]);
    })
}

// update the user's first name and last name
module.exports.userUpdateNames = function (user_id,f_name,l_name,done) {
    con.query('UPDATE user_profile SET first_name = ?, last_name = ? WHERE id = ?',[f_name,l_name,user_id], (err,result) => {
        if (err) return done(err);
        return done(null,true);
    })
}

function cookUpdateSharePhone(cook_id, shared, done) {
    con.query('UPDATE cook SET share_phone = ? WHERE cook_id = ?',[shared,cook_id], (err, result) => {
        if (err) return done(err);
        return done(null,true);
    })
}

// returns true
module.exports.cookSharePhone = function(cook_id,done) {
    return cookUpdateSharePhone(cook_id,1,done);
}

// returns true
module.exports.cookUnsharePhone = function(cook_id,done) {
    return cookUpdateSharePhone(cook_id,0,done);
}

/**
 * @param {schemes.cookProfileCallback} done 
 */
var cookGetProfile = module.exports.cookGetProfile = function(cook_id,done) {
    con.query('SELECT cook.*,user_profile.*, user_account.phone FROM cook,user_profile,user_account WHERE cook_id = ? AND user_profile.id = cook_id AND user_account.id = cook_id',[cook_id], (err,rows) => {
        if (err) return done(err);
        let row = rows[0];
        let shared = row.share_phone == 1;
        let phone = shared?row.phone : null;
        let cookProfile = schemes.cookProfile(row.cook_id,row.first_name,row.last_name,row.cook_logo,row.lat,row.lon,row.opening_time,row.closing_time,
                                                shared,phone);
        return done(null,cookProfile);
    })
}

/**
 * @param {schemes.cookAccountCallback} done 
 */
module.exports.cookGetAccount = function(cook_id,done) {
    con.query('SELECT user_account.*, cook.is_verified FROM user_account,cook WHERE cook_id = ? AND id = cook_id',[cook_id], (err,rows) => {
        if (err) return done(err);
        let row = rows[0];
        cookGetProfile(cook_id, (err,cookprofile) => {
            if (err) return done(err);
            let cookAccount = schemes.cookAccount(cook_id,row.email,row.phone,row.is_verified,row._added,cookprofile);
            return done(null,cookAccount);
        })
    })
}

/**
 * @param {schemes.eaterProfileCallback} done 
 */
var eaterGetProfile = module.exports.eaterGetProfile = function(eater_id,done) {
    con.query('SELECT eater.*,user_profile.* FROM eater,user_profile WHERE eater_id = ? AND id = eater_id',[eater_id], (err,rows) => {
        if (err) return done(err);
        let row = rows[0];
        let eaterProfile = schemes.eaterProfile(row.eater_id,row.first_name,row.last_name);
        return done(null,eaterProfile);
    })
}

/**
 * @param {schemes.eaterAccountCallback} done 
 */
module.exports.eaterGetAccount = function(eater_id,done) {
    con.query('SELECT user_account.*, eater.pickup_radius FROM user_account, eater WHERE eater_id = ? AND id = eater_id',[eater_id], (err,rows) => {
        if (err) return done(err);
        let row = rows[0];
        eaterGetProfile(eater_id, (err, eaterprofile) => {
            if (err) return done(err);
            let eaterAccount = schemes.eaterAccount(eater_id,row.email,row.phone,row.pickup_radius,row._added,eaterprofile);
            return done(null,eaterAccount);
        })
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

/**
 * get all the generic dishes
 * @param {schemes.genDishSearchCallback} done 
 */
module.exports.genDishGetAll = function genDishGetAll(done) {
    con.query('SELECT * FROM generic_dishes ORDER BY gendish_name',undefined, (err,rows) => {
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

// returns true if cook has dish with id
module.exports.cookDishExists = function cookDishExists(cookdish_id,cook_id,done) {
    con.query('SELECT * FROM dishes WHERE dish_id = ? AND cook_id = ?',[cookdish_id,cook_id],(err,rows) => {
        if (err) return done(err);
        return done(null,rows.length > 0);
    })
}

// returns the cookdish id
module.exports.cookDishAdd = function cookDishAdd(gendish_id,cook_id,custom_name,price,category,label,description,dish_pic,done) {
    con.query('INSERT into dishes (gendish_id,cook_id,custom_name,price,category,label,description,dish_pic) values (?,?,?,?,?,?,?,?)',
        [gendish_id,cook_id,custom_name,price,category,label,description,dish_pic], (err,result) => {
            if (err) return done(err);
            return done(null,result.insertId);
        })
}

// set availability
function cookDishSetAvailability(cookdish_id,availability,done) {
    con.query('UPDATE dishes SET dish_status = ? WHERE dish_id = ?',[availability,cookdish_id], (err,result) => {
        if (err) return done(err);
        return done(null,result.affectedRows > 0);
    })
}
// returns true if successful
module.exports.cookDishMakeAvailable = function cookDishMakeAvailable(cookdish_id,date,done) {
    return cookDishSetAvailability(cookdish_id,date,done);
}
// returns true if successful
module.exports.cookDishMakeUnavailable = function cookDishMakeUnavailable(cookdish_id,done) {
    return cookDishSetAvailability(cookdish_id,null,done);
}

/**
 * returns a list of the dishes for a cook matching the availability
 * @param {Date} availability
 * @param {schemes.cookDishSearchCallback} done
 */
function cookDishGet(cook_id,availability=null,done) {
    con.query('SELECT dish_id FROM dishes WHERE cook_id = ? AND (dish_status = ? OR ? IS NULL)',[cook_id,availability,availability], (err,rows) => {
        if (err) return done(err);
        /** @type {schemes.CookDish[]} */
        let cookdishes = [];
        async.eachOf(rows, (row,index,inner_callback) => {
            let dish_id = row.dish_id;
            cookDishInfo(dish_id, (err,cookdish) => {
                if (err) return inner_callback(err);
                cookdishes.push(cookdish);
                inner_callback();
            })
        }, (err) => {
            if (err) return done(err);
            return done(null,cookdishes);
        })
    })
}

/**
 * returns a list of the dishes for a cook (the name is the gendish_name if custom_name is null or custom_name else)
 * @param {schemes.cookDishSearchCallback} done 
 */
module.exports.cookDishGetAll = function cookDishGetAll(cook_id,done) {
    cookDishGet(cook_id,undefined,done);
}
/**
 * returns a list of the dishes for a cook (the name is the gendish_name if custom_name is null or custom_name else)
 * @param {schemes.cookDishSearchCallback} done 
 */
module.exports.cookDishGetAvailable = function cookDishGetAvailable(cook_id,date,done) {
    cookDishGet(cook_id,date,done);
}

/**
 * returns the cookdish info
 * @param {schemes.cookDishInfoCallback} done
 */
var cookDishInfo = module.exports.cookDishInfo = function (dish_id,done) {
    con.query('SELECT dish_rating.*, dishes.*, generic_dishes.gendish_name FROM (dishes, generic_dishes) '+
            'LEFT JOIN dish_rating ON dish_rating.dish_id = dishes.dish_id ' +
            'WHERE dishes.gendish_id = generic_dishes.gendish_id AND dishes.dish_id = ?',[dish_id],(err,rows) => {
                if (err) return done(err);
                
                let ratings = [], avg_rating = 0;
                async.eachOf(rows, function(row,index,inner_callback) {
                    if (row.rating) {
                        eaterGetProfile(row.eater_id, (err,eater) => {
                            if (err) return inner_callback(err);
                            ratings.push(schemes.dishRating(eater,row.rating,row._added));
                            avg_rating += row.rating;
                            inner_callback();
                        })
                    }
                    else
                        inner_callback();
                }, function (err) {
                    if (err) return done(err);
                    let row = rows[0];
                    let name = row.custom_name ? row.custom_name : row.gendish_name;
                    if (ratings.length == 0) {
                        ratings = null, avg_rating = null;
                    }
                    else
                        avg_rating = avg_rating / ratings.length;
                    let cookdish = schemes.cookDish(
                        row.dish_id, row.gendish_id, row.cook_id, name, row.price,
                        row.category, row.label, row.description, row.dish_pic, avg_rating, ratings
                    );
                    return done(null, cookdish);
                });
            });
}

// returns false if already rated; else true
module.exports.cookDishRate = function (eater_id,dish_id,order_id,rating,done) {
    con.query('SELECT rated FROM eater_dish_order WHERE order_id = ? AND dish_id = ?', [order_id, dish_id],(err,rows) => {
        if (err) return done(err);
        if (rows.length == 0) return done(null,false);
        if (rows[0].rated == 1) return done(null,false);
        con.query('INSERT into dish_rating (eater_id,dish_id,rating) values (?,?,?)', [eater_id, dish_id, rating], (err, result) => {
            if (err) return done(err);
            con.query('UPDATE eater_dish_order SET rated = 1 WHERE order_id = ? AND dish_id = ?', [order_id, dish_id], (err, result) => {
                if (err) return done(err);
                return done(null, true);
            })
        })
    })
}

/* Map Functions */

/**
 * get the cooks and dishes with status provided around an eater's coordinates
 * @param {schemes.cookMapCallback} done 
 */
module.exports.getDishesAround = function getDishesAround(eater_id,lat,lon,dish_status=null,done) {
    con.query('SELECT *,distance FROM ('+
                'SELECT cook.cook_logo,cook.lat,cook.lon,cook.opening_time,cook.closing_time,profile.first_name,profile.last_name,'+
                        'eater.pickup_radius, '+
                        'dishes.*, '+
                        'p.distance_unit '+
                            '* DEGREES(ACOS(LEAST(1.0, COS(RADIANS(p.lat)) '+
                            '* COS(RADIANS(cook.lat)) '+
                            '* COS(RADIANS(p.lon - cook.lon)) '+
                            '+ SIN(RADIANS(p.lat)) '+
                            '* SIN(RADIANS(cook.lat))))) AS distance '+
                'FROM cook, user_profile as profile, dishes, eater '+
                'JOIN (SELECT ? AS lat, ? AS lon, 111.045 AS distance_unit, ? AS status) AS p ON 1=1 '+ // 111.045 km/degree
                'WHERE eater.eater_id = ? '+
                    'AND cook.lat BETWEEN p.lat - (eater.pickup_radius / p.distance_unit) '+
                                    'AND p.lat + (eater.pickup_radius / p.distance_unit) '+
                    'AND cook.lon BETWEEN p.lon - (eater.pickup_radius / (p.distance_unit * COS(RADIANS(p.lat)))) '+
                                    'AND p.lon + (eater.pickup_radius / (p.distance_unit * COS(RADIANS(p.lat)))) '+
                    'AND cook.cook_id = profile.id '+
                    'AND dishes.cook_id = cook.cook_id '+
                    'AND (dishes.dish_status = p.status OR p.status IS NULL) '+
                ') AS d '+
                'WHERE distance <= pickup_radius '  // can add LIMIT x
                ,[lat,lon,dish_status,eater_id], (err,rows) => {
                    if (err) return done(err);
                    if (rows.length == 0) return done(null,false);
                    let cookDetails = {};
                    async.eachOf(rows,function(row,index,inner_callback){
                        let cook_id = row.cook_id;
                        cookDishInfo(row.dish_id,(err,curDish) => {
                            if (err) return inner_callback(err);
                            if (cook_id in cookDetails) { // just add meal
                                cookDetails[cook_id].dishes.push(curDish);
                            }
                            else {
                                cookDetails[cook_id] = schemes.cookMap(
                                    cook_id, row.first_name, row.last_name,
                                    row.cook_logo, row.lat, row.lon, row.distance, row.opening_time, row.closing_time, [curDish]);
                            }
                            inner_callback();
                        })
                    },function(err) {
                        if (err) return done(err);
                        let cookList = Object.values(cookDetails);
                        return done(null, cookList);
                    })
                });
}

/* Cart Functions */

// return the insert id
module.exports.cartAdd = function cartAdd(eater_id,dish_id,cook_id,quantity=1,delivery=false,done) {
    con.query('INSERT into eater_cart (eater_id,dish_id,cook_id,quantity,delivery_availability) values (?,?,?,?,?)',[eater_id,dish_id,cook_id,quantity,delivery],(err,result) => {
        if (err) return done(err);
        return done(null,result.insertId);
    });
}

/**
 * returns the cart dishes and their info
 * @param {schemes.eaterCartCallback} done 
 */
module.exports.cartGetDishes = function cartGetDishes(eater_id,done) {
    con.query('SELECT * FROM eater_cart WHERE eater_id = ?',[eater_id],(err,rows) => {
        if (err) return done(err);
        if (rows.length == 0) return done(null,false);
        /** @type {schemes.EaterCartEntry[]} */
        let cart = [];
        async.eachOf(rows, function(row,index,inner_callback) {
            let dish_id=row.dish_id,quantity=row.quantity,delivery=row.delivery_availability;
            cookDishInfo(dish_id, (err,cookdish) => {
                if (err) return inner_callback(err);
                cart.push(schemes.eaterCartEntry(cookdish,quantity,delivery));
            })
        }, function (err) {
            if (err) return done(err);
            return done(null,cart);
        });
    })
}

// return true if entry deleted
module.exports.cartDelete = function cartDelete(eater_id, dish_id, done) {
    con.query('DELETE FROM eater_cart WHERE eater_id = ? AND dish_id = ?', [eater_id, dish_id], (done, result) => {
        if (err) return done(err);
        return done(null, result.affectedRows > 0);
    });
}

// return true if cart emptied
module.exports.cartEmpty = function cartEmpty(eater_id, done) {
    con.query('DELETE FROM eater_cart WHERE eater_id = ?', [eater_id], (done, result) => {
        if (err) return done(err);
        return done(null, result.affectedRows > 0);
    });
}


/* Orders Functions */

/**
 * adds a dish to an already created order
 * @param {schemes.DishTuple[]} dishes 
 */
function orderAddDishes(order_id,eater_id,dishes,done) {
    let dishlist = [];
    for (const dish of dishes) {
        dishlist.push([order_id,dish.dish_id,eater_id,dish.quantity]);
    }
    con.query('INSERT into eater_dish_order (order_id,dish_id,eater_id,quantity) values ?',[dishlist],(err,result)=>{
        if (err) return done(err);
        return done(null,result.insertId);
    })
}

/**
 * returns true if successful
 * @param {Date} datetime 
 * @param {schemes.DishTuple[]} dishes 
 */
module.exports.orderCreate = function orderCreate(eater_id,cook_id,del_method='takeaway',datetime,total,dishes,done) {
    con.query('INSERT into order_status (cook_id,total_price,delivery_method,date_scheduled_on) values (?,?,?,?)',[cook_id,total,del_method,datetime],(err,result) => {
        if (err) return done(err);
        const order_id = result.insertId;
        // insert the dishes to the order
        orderAddDishes(order_id,eater_id,dishes, (err,resultId) => {
            if (err) return done(err);
            return done(null,true);
        })
    });
}

/**
 * returns a list of orders for a given eater
 * @param {schemes.orderCallback} done 
 */
module.exports.orderGet_Eater = function orderGet_Eater(eater_id,status=null,done) {
    con.query('SELECT eater_dish_order.*,order_status.* FROM eater_dish_order,order_status '+
                'WHERE eater_dish_order.order_id=order_status.order_id AND eater_dish_order.eater_id = ? '+
                    'AND (order_status.general_status = ? OR ? IS NULL)',[eater_id,status,status], (err,rows) => {
                        if (err) return done(err);
                        let orderByID = {};
                        for (const row of rows) {
                            let order_id=row.order_id;
                            /** @type {schemes.DishTuple} */
                            let dish = {dish_id: row.dish_id, quantity: row.quantity, rated:row.rated};
                            if (order_id in orderByID)
                                orderByID[order_id].dishes.push(dish);
                            else {
                                orderByID[order_id] = schemes.order(
                                    order_id, row.eater_id, row.cook_id, row.total_price, row.general_status, row.prepared_status, row.packaged_status,
                                    row.message,row.date_scheduled_on,[dish]);
                            }
                        }
                        let orderList = Object.values(orderByID);
                        return done(null,orderList);
                    })
}

/**
 * returns a list of orders for a given cook
 * @param {schemes.orderCallback} done 
 */
module.exports.orderGet_Cook = function orderGet_Cook(cook_id,status=null,done) {
    con.query('SELECT eater_dish_order.*,order_status.* FROM eater_dish_order,order_status '+
                'WHERE eater_dish_order.order_id=order_status.order_id AND order_status.cook_id = ? '+
                    'AND (order_status.general_status = ? OR ? IS NULL)',[cook_id,status,status], (err,rows) => {
                        if (err) return done(err);
                        let orderByID = {};
                        for (const row of rows) {
                            let order_id=row.order_id;
                            /** @type {schemes.DishTuple} */
                            let dish = { dish_id: row.dish_id, quantity: row.quantity, rated: row.rated};
                            if (order_id in orderByID)
                                orderByID[order_id].dishes.push(dish);
                            else {
                                orderByID[order_id] = schemes.order(
                                    order_id, row.eater_id, row.cook_id, row.total_price, row.general_status, row.prepared_status, row.packaged_status,
                                    row.message,row.date_scheduled_on,[dish]);
                            }
                        }
                        let orderList = Object.values(orderByID);
                        return done(null,orderList);
                    })
}

/**
 * @param {schemes.orderInfoCallback} done 
 */
var orderInfo = module.exports.orderInfo = function(order_id,done) {
    con.query('SELECT eater_dish_order.*,order_status.* FROM eater_dish_order,order_status ' +
        'WHERE eater_dish_order.order_id=order_status.order_id AND order_status.order_id = ?',
        [order_id], (err, rows) => {
            if (err) return done(err);
            let orderByID = {};
            for (const row of rows) {
                /** @type {schemes.DishTuple} */
                let dish = { dish_id: row.dish_id, quantity: row.quantity };
                if (order_id in orderByID)
                    orderByID[order_id].dishes.push(dish);
                else {
                    orderByID[order_id] = schemes.order(
                        order_id, row.eater_id, row.cook_id, row.total_price, row.general_status, row.prepared_status, row.packaged_status,
                        row.message, row.date_scheduled_on, [dish]);
                }
            }
            let order = orderByID[order_id];
            return done(null, order);
        })
}

// returns true
function orderSetStatus(order_id,status,done) {
    con.query('UPDATE order_status SET general_status = ? WHERE order_id = ?',[status,order_id], (err,result) => {
        if (err) return done(err);
        return done(null,true);
    })
}

// approve order
module.exports.orderApprove = function(order_id,done) {
    orderSetStatus(order_id,schemes.OrderStatus.approved,done);
}

// reject order
module.exports.orderReject = function(order_id,done) {
    orderSetStatus(order_id,schemes.OrderStatus.rejected,done);
}

// cancel order
module.exports.orderCancel = function(order_id,done) {
    orderSetStatus(order_id,schemes.OrderStatus.cancelled,done);
}

// ready order
module.exports.orderReady = function(order_id,done) {
    orderSetStatus(order_id,schemes.OrderStatus.ready,done);
}

// complete order
module.exports.orderComplete = function(order_id,done) {
    orderSetStatus(order_id,schemes.OrderStatus.completed,done);
}



module.exports.uploadCookDishPic = cloudStorage.uploadCookDishPic;