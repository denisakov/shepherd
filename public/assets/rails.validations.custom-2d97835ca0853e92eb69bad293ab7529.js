// The validator variable is a JSON Object
// The selector variable is a jQuery Object
window.Rails4ClientSideValidations.validators.local["imo_format"] = function(element, options) {
  // Your validator code goes in here
  if (!/^[0-9]{7}*$/.test(element.val())) {
    // When the value fails to pass validation you need to return the error message.
    // It can be derived from validator.message
    return options.message;
  }
}
;
