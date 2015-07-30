//= require jquery
//= require jquery_ujs
//= require bootstrap-sprockets
//= require bootstrap-editable

$(function() {
  $.fn.editable.defaults.ajaxOptions = {type: "PUT"};
  $.fn.editable.defaults.mode = 'inline';
  $('.js-editable').editable();
});
