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

sendPlanInviteCallback = (response) ->

  $.post '/facebook/ajax_request_handler', response, (data) ->
    console.log data

$ ->
  # $('.invite-to-plan').qtip
  #   content:
  #     text: "Invite Friends!"
  #   position:
  #     my: 'center'
  #     at: 'center'
  #     target: $(window)
  #   show:
  #     event: 'click'
  #     modal: true
  #   # events:
  #   #   hide: (event, api) ->
  #   #     console.log event, api
  #   #     alert 'bye!'
  #   style: 'ui-tooltip-rounded ui-tooltip-light'

  $('.invite-to-plan').click (e) ->
    e.preventDefault()
    data = $(this).data()
    FB.ui
      method: 'send'
      name: data.name
      link: data.link
      description: data.description
      picture: data.picture

