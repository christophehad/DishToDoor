// local strategies for logging in / registering
const passport = require('passport');
const LocalStrategy = require('passport-local').Strategy;
const database = require('../../../../database/database');
const bcrypt = require('bcrypt');

const BCRYPT_SALT_ROUNDS = 8;

// Eater register with phone number
passport.use('eater-register-phone', new LocalStrategy(
    {
        usernameField: 'phone',
        passwordField: 'password',
        //passReqToCallback: true   // uncomment this to access req in the callback (possibly to get other attributes from req.body)
    },
    (phone,password,done) => {
        database.eaterPhoneExists(phone, (err,phoneUsed) => {
            if (err) return done(err);
            if (phoneUsed)
                return done(null,false, {message: 'Phone number already used!'});
            else {
                // since phone is not used, we can create the Eater account
                // using bcrypt to hash the password
                bcrypt.hash(password,BCRYPT_SALT_ROUNDS).then(async hashedPassword => {
                    database.eaterRegisterPhone(phone,hashedPassword,'Eater',' ', (err,id) => {
                        if (err) return done(err);
                        return done(null,id);
                    });
                }).catch(err => { return done(err); })
            }
        });
    }
));

// Eater register with email
passport.use('eater-register-email', new LocalStrategy(
    {
        usernameField: 'email',
        passwordField: 'password',
        //passReqToCallback: true   // uncomment this to access req in the callback (possibly to get other attributes from req.body)
    },
    (email, password, done) => {
        database.eaterEmailExists(email, (err, emailUsed) => {
            if (err) return done(err);
            if (emailUsed)
                return done(null, false, { message: 'Email address already used!' });
            else {
                // since email is not used, we can create the Eater account
                // using bcrypt to hash the password
                bcrypt.hash(password, BCRYPT_SALT_ROUNDS).then(async hashedPassword => {
                    database.eaterRegisterEmail(email, hashedPassword, 'Eater', ' ', (err, id) => {
                        if (err) return done(err);
                        return done(null, id);
                    });
                }).catch(err => {return done(err);})
            }
        });
    }
));


// Eater login with phone
passport.use('eater-login-phone', new LocalStrategy(
    {
        usernameField: 'phone',
        passwordField: 'password'
    },
    (phone,password,done) => {
        database.eaterLoginPhone(phone, (err,rows) => {
            if (err) return done(err);
            if (!rows.length)
                return done(null, false, {message: 'no_eater_phone'});
            else {
                const user = rows[0];
                // user.password is a buffer; need to convert it to string
                bcrypt.compare(password,user.password.toString()).then(response => {
                    if (!response)
                        return done(null,false, {message: 'wrong_password'});
                    else
                        return done(null,user);
                }).catch(err => {return done(err);})
            }
        });
    }
));
// Eater login with email
passport.use('eater-login-email', new LocalStrategy(
    {
        usernameField: 'email',
        passwordField: 'password'
    },
    (email,password,done) => {
        database.eaterLoginEmail(email, (err, rows) => {
            if (err) return done(err);
            if (!rows.length)
                return done(null, false, { message: 'no_eater_email' });
            else {
                const user = rows[0];
                // user.password is a buffer; need to convert it to string
                bcrypt.compare(password, user.password.toString()).then(response => {
                    if (!response)
                        return done(null, false, { message: 'wrong_password' });
                    else
                        return done(null, user);
                }).catch(err => { return done(err); })
            }
        });
    }
));

// export the Local passport scheme
module.exports = passport;