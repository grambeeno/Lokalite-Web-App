var sendPlanInviteCallback;
window.facebookLoaded = function() {};
window.afterFacebookSignIn = function() {
  return window.location = '/users/auth/facebook/';
};
sendPlanInviteCallback = function(response) {
  return $.post('/facebook/ajax_request_handler', response, function(data) {
    return console.log(data);
  });
};
$(function() {
  return $('.invite-to-plan').click(function(e) {
    var data;
    e.preventDefault();
    data = $(this).data();
    return FB.ui({
      method: 'send',
      name: data.name,
      link: data.link,
      description: data.description,
      picture: data.picture
    });
  });
});