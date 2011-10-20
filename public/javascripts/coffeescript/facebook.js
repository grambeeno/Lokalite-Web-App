(function() {
  window.facebookLoaded = function() {
    return console.log('loaded facebook');
  };
  window.afterFacebookSignIn = function() {
    return window.location = '/users/auth/facebook/';
  };
}).call(this);
