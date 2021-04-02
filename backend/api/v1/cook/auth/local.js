// local strategies for logging in / registering
const passport = require('passport');
const LocalStrategy = require('passport-local').Strategy;
const database = require('../../../../database/database');
const bcrypt = require('bcrypt');

const BCRYPT_SALT_ROUNDS = 8;

// Cook register with phone number
passport.use('cook-register-phone', new LocalStrategy(
    {
        usernameField: 'phone',
        passwordField: 'password',
        //passReqToCallback: true   // uncomment this to access req in the callback (possibly to get other attributes from req.body)
    },
    (phone,password,done) => {
        database.cookPhoneExists(phone, (err,phoneUsed) => {
            if (err) return done(err);
            if (phoneUsed)
                return done(null,false, {message: 'Phone number already used!'});
            else {
                // since phone is not used, we can create the Cook account
                // using bcrypt to hash the password
                bcrypt.hash(password,BCRYPT_SALT_ROUNDS).then(async hashedPassword => {
                    database.cookRegisterPhone(phone,hashedPassword,'Cook',' ',false, (err,id) => {
                        if (err) return done(err);
                        return done(null,id);
                    });
                }).catch(err => { return done(err); })
            }
        });
    }
));

// Cook register with email
passport.use('cook-register-email', new LocalStrategy(
    {
        usernameField: 'email',
        passwordField: 'password',
        //passReqToCallback: true   // uncomment this to access req in the callback (possibly to get other attributes from req.body)
    },
    (email, password, done) => {
        database.cookEmailExists(email, (err, emailUsed) => {
            if (err) return done(err);
            if (emailUsed)
                return done(null, false, { message: 'Email address already used!' });
            else {
                // since email is not used, we can create the Cook account
                // using bcrypt to hash the password
                bcrypt.hash(password, BCRYPT_SALT_ROUNDS).then(async hashedPassword => {
                    database.cookRegisterEmail(email, hashedPassword, 'Cook', ' ', false, (err, id) => {
                        if (err) return done(err);
                        return done(null, id);
                    });
                }).catch(err => {return done(err);})
            }
        });
    }
));

// Cook register with email and phone
passport.use('cook-register-email-phone', new LocalStrategy(
    {
        usernameField: 'email',
        passwordField: 'password',
        passReqToCallback: true,   // uncomment this to access req in the callback (possibly to get other attributes from req.body)
    },
    (req, email, password, done) => {
        database.cookEmailExists(email, (err, emailUsed) => {
            if (err) return done(err);
            if (emailUsed)
                return done(null, false, { message: 'email_used' });
            else {
                let f_name = req.body.first_name, l_name = req.body.last_name, phone = req.body.phone;
                let exp=req.body.experience, cert=req.body.certified, train=req.body.training, inspection=req.body.inspection;
                if (!f_name || !l_name || !phone || !exp || (cert === undefined) || (train === undefined) || (inspection === undefined))
                    return done(null, false, {message: 'missing_credentials'});
                database.cookPhoneExists(phone, (err, phoneUsed) => {
                    if (err) return done(err);
                    if (phoneUsed)
                        return done(null, false, {message: 'phone_used'});
                    else {
                        // since email and phone are not used, we can create the Cook account
                        // using bcrypt to hash the password
                        bcrypt.hash(password, BCRYPT_SALT_ROUNDS).then(async hashedPassword => {
                            cert=cert==true; train=train==true; inspection=inspection==true;
                            database.cookRegister(email, phone, hashedPassword, f_name, l_name, false, exp, cert, train, inspection, (err, id) => {
                                if (err) return done(err);
                                return done(null, id);
                            });
                        }).catch(err => { return done(err); })
                    }
                });
            }
        });
    }
));


// Cook login with phone
passport.use('cook-login-phone', new LocalStrategy(
    {
        usernameField: 'phone',
        passwordField: 'password'
    },
    (phone,password,done) => {
        database.cookLoginPhone(phone, (err,rows) => {
            if (err) return done(err);
            if (!rows.length)
                return done(null, false, {message: 'no_cook_phone'});
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
// Cook login with email
passport.use('cook-login-email', new LocalStrategy(
    {
        usernameField: 'email',
        passwordField: 'password'
    },
    (email,password,done) => {
        database.cookLoginEmail(email, (err, rows) => {
            if (err) return done(err);
            if (!rows.length)
                return done(null, false, { message: 'no_cook_email' });
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