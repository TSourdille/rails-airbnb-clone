//= require jquery
//= require jquery_ujs
//= require bootstrap-sprockets
//= require jquery-fileupload/basic
//= require cloudinary/jquery.cloudinary
//= require attachinary
//= require_tree .

// app/assets/javascripts/init_attachinary.js
$(document).ready(function() {
  $('.attachinary-input').attachinary();
});
