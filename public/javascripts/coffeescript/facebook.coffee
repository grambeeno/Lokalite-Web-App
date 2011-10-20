window.facebookLoaded = ->
  # getFacebookUser()
  console.log 'loaded facebook'
  # FB.ui
  #   method: 'send'
  #   name: 'People Argue Just to Win'
  #   link: 'http://www.nytimes.com/2011/06/15/arts/people-argue-just-to-win-scholars-assert.html'

# getFacebookUser = ->
#   FB.getLoginStatus (response) ->
#     console.log response
#     FB.api '/me', (response) ->
#       console.log 'Your name is ', response.name
#     if response.authResponse
#       console.log 'logged in!'
#     else
#       console.log 'need to log in!'

# We sign in via the JS api, then redirect to the Rails app
# to execute the devise sign in. For details, see:
# https://github.com/intridea/omniauth/issues/120
window.afterFacebookSignIn = ->
  window.location = '/users/auth/facebook/'

