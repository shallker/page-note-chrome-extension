// var jQuery  = require("jqueryify");
// var exports = this;
// jQuery(function(){
//   var Page = require("page");
//   exports.page = new Page();
// });

var exports = this;
(function() {

  if (exports._PageNoteApp) return;
  var Page = require('page');
  exports._PageNoteApp = new Page();

})(exports)
