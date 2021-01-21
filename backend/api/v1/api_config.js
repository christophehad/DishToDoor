module.exports.DEBUG = true;

// Communication with API
module.exports.successJSON = function successJSON() {
    return {
        success: true,
        token: ''
    };
}

/**
 * Failure JSON to be returned
 * @param {String} error 
 */
module.exports.failureJSON = function failureJSON(error) {
    return {
        success: false,
        error: error
    }
}