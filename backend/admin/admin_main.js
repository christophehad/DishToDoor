const AdminBro = require('admin-bro');
const AdminBroExpress = require('@admin-bro/express');
const database = require('../database/database');
const bcrypt = require('bcrypt');
const secretData = require('../cert/config').adminData;

// function to use when wanting to register an admin; returns true if successful
async function registerAdmin(email,password) {
    let created = await new Promise ((resolve,reject) => {
        bcrypt.hash(password, 8, (err, hashed_pass) => {
            if (err) return reject(err);
            database.adminRegister(email, hashed_pass, (err, id) => {
                if (err || !id) return resolve(false);
                return resolve(true);
            });
        });
    });
    return created;
}

// configuration settings
const rootPath = '/admin';
const adminBro = new AdminBro({
    databases: [],
    rootPath: rootPath
});

const router = AdminBroExpress.buildAuthenticatedRouter(adminBro, {
    authenticate:
        /**
         * @returns {AdminBro.CurrentAdmin}
         */
        async (email, password) => {
            return await new Promise((resolve,reject) => {
                database.adminLogin(email, (err, rows) => {
                    if (err) return reject(err);
                    if (rows.length == 0) return resolve(false);
                    let curAdmin = rows[0];
                    // compare password with hashed as string
                    bcrypt.compare(password, curAdmin.password.toString(), (err, match) => {
                        if (err || !match) return resolve(false);
                        /** @type {AdminBro.CurrentAdmin} */
                        let toRet = { email: curAdmin.email };
                        return resolve(toRet);
                    })
                })
            })
    },
    cookiePassword: secretData.cookiePassword        
}, undefined, { resave: false, saveUninitialized: false } // options for express-session
);

// pass router and rootPath to main
exports.router = router;
exports.rootPath = rootPath;

//registerAdmin("admin@dishtodoor.com","122333").then((created) => {console.log(created);});