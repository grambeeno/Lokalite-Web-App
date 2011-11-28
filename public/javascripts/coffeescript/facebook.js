(function() {
  window.facebookLoaded = function() {};
  window.afterFacebookSignIn = function() {
    return window.location = '/users/auth/facebook/';
  };
}).call(this);
