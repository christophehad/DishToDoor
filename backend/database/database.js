const mysql = require('mysql');

const con = mysql.createConnection({
    host: 'local', // insert the database url here
    port: 3306,
    user: 'root',
    password: '',
    database: 'dishtodoor',
});

module.exports.tryConnection = function tryConnection() {
    con.connect( (err) => {
        if (err) throw err;
        console.log('Connected to the MySQL database!');
    })
}

/* Add functions as such to communicate with the MySQL database
   For example, a function can return a list of user ids, a success flag...
   Another way of writing it is to write function name(args) {...} 
    and add module.exports.name = name in the end of the file
*/
module.exports.cookLogin = async function cookLogin(id) {
    let ret = 0;
    con.query('SELECT * FROM cooks Where id = ?',[id], (err,result) => {
        if (err)
            // handle error
            ret = 0;
        else
            ret = 1;
    })
}