// var jQuery  = require("jqueryify");
// var exports = this;
// jQuery(function(){
//   var Page = require("page");
//   exports.page = new Page();
// });

var exports = this;
(function() {

  if (exports.page) return;
  var Page = require('page');
  exports.page = new Page();

})(exports)
