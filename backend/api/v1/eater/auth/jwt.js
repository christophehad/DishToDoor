// strategy for validating tokens and passing user info
const passport = require('passport');
const JWTStrategy = require('passport-jwt').Strategy;
const ExtractJWT = require('passport-jwt').ExtractJwt;
const database = require('../../../../database/database');
const jwtData = require('../../../../cert/config').jwtData;

passport.use('jwt-eater', new JWTStrategy(
    {
        jwtFromRequest: ExtractJWT.fromAuthHeaderAsBearerToken(),
        secretOrKey: jwtData.privKey
    },
    (jwtPayload,done) => {
        // check if cook account exists
        database.eaterAccountExists(jwtPayload.id, (err,accountExists) => {
            if (err) return done(err);
            if (accountExists) return done(null,jwtPayload.id);
            else return done(null,false,{message: 'User not found!'});
        });
    }
));

module.exports = passport;