window.facebookLoaded = ->
  # getFacebookUser()
  # console.log 'loaded facebook'
  # FB.ui
  #   method: 'send'
  #   name: 'Just a test'
  #   link: 'http://lokalite.com/'

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

postToFeedCallback = (response) ->

$ ->
  $('.facebook-invite').click (e) ->
    e.preventDefault()
    data = $(this).data()
    FB.ui
      method: 'send'
      name: data.name
      link: data.link
      description: data.description
      picture: data.picture

  $('.facebook-icon').click (e) ->
    e.preventDefault()
    data = $(this).data()
    console.log 'data', data
    FB.ui {
      method: 'feed'
      link: data.link
      picture: data.picture
      name: data.name
      description: data.description
    }, postToFeedCallback

