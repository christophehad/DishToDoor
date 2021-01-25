// Templates of returned database objects

/**
 * @typedef {Object} GenDish
 * @property {Number} id
 * @property {String} name
 * @property {String} category
*/

/**
 * GenDish search callback
 * @callback genDishSearchCallback
 * @param {String} err
 * @param {GenDish[]} gendishes
*/

/**
 * Generate a GenDish
 * @returns {GenDish}
 */
exports.genDish = function (id,name,category) {
    return {
        id: id, name: name, category: category
    }
}