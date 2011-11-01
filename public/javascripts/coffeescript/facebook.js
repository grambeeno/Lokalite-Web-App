(function() {
  window.facebookLoaded = function() {
    FB.Event.subscribe("comment.create", function(response) {
      return alert("Comment created");
    });
    return FB.getLoginStatus(function(response) {
      if (response.authResponse) {
        return alert("Logged in");
      } else {
        return alert("Not logged in");
      }
    });
  };
  window.afterFacebookSignIn = function() {
    return window.location = '/users/auth/facebook/';
  };
}).call(this);
