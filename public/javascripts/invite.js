$(function() {
  
  $('.invite-to-plan').click(function(e) {
    e.preventDefault()
    var data;
    data = $(this).data();
    sendRequestToManyRecipients(data);
  });
});
