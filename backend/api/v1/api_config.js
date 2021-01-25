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

module.exports.genDish = function genDish(id,name,category) {
    return {
        id: id, name: name, category: category
    }
}

// Allowed categories (for now, on long run we get them from database)
module.exports.gendishCategories = ['appetizer','main dish', 'dessert', 'salad'];