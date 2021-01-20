const mysql = require('mysql');

const con = mysql.createConnection({
    host: 'localhost', // insert the database url here
    port: 3306,
    user: 'root',
    password: '',
    database: 'dishtodoor',
});

module.exports.tryConnection = function tryConnection() {
    con.connect( (err) => {
        if (err) return console.log(err);
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