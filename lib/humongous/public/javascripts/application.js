$(document).ready(function(){
  $("#loader").bind("ajaxSend", function(){
    $( this ).modal('show');
  }).bind("ajaxComplete", function(){
    $( this ).modal('hide');
  });
  $("#login_dialog a").click( function(e){
    // if(validate("#login_dialog .modal-body form")){
      alert("validated")
      $("#login_dialog .modal-body form").submit();
    // }
    e.preventDefault();
  });
});
var validate = function(anchor){
  alert("validating....")
  var error = false;
  $(anchor).find("input").each(function(index, field){
    if($(field).val() == "" || $(field).val() == null){
      error = true;
      $(field).parent().parent().addClass("error");
    }
  });
  alert("error: " + error)
  return !error;
}