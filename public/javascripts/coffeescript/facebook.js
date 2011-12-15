var postToFeedCallback;
window.facebookLoaded = function() {};
window.afterFacebookSignIn = function() {
  return window.location = '/users/auth/facebook/';
};
postToFeedCallback = function(response) {};
$(function() {
  $('.facebook-invite').click(function(e) {
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
  return $('.facebook-icon').click(function(e) {
    var data;
    e.preventDefault();
    data = $(this).data();
    console.log('data', data);
    return FB.ui({
      method: 'feed',
      link: data.link,
      picture: data.picture,
      name: data.name,
      description: data.description
    }, postToFeedCallback);
  });
});