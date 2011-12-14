# Compiling this manually for now with:
# coffee -cwb .
# Had trouble upgrading to rails 3.1
# don't want to deal with barista or another external gem right now...
$ ->
  trackImpressions()
  displayOrganizationChart()

  $('input, textarea').placeholder()

  $('.truncate').truncate()

  $(".flash a.dismiss").live "click", (event) ->
    event.preventDefault()
    $(this).closest(".flash").hide 400

  $(".tooltip").qtip
    position:
      my: "bottom middle"
      at: "top middle"
    style:
      classes: "ui-tooltip-youtube"

  # Tell ReportGrid when the mouse hovers over an event tile for over 1 second
  # store active_hover_id so we can determine the length of the event
  #
  # TODO - We should be tracking organizations too
  active_hover_id = ''
  $('.events li, .organizations li').live
    mouseenter: ->
      $(this).find('.description').show("slide", { direction: "down" }, 200)
      active_hover_id = $(this).attr('id')

      if $(this).parent().hasClass('events')
        setTimeout ( =>
          if active_hover_id == $(this).attr('id')
            ids  = extractComplexObjectId($(this))
            path = "/organizations/#{ids.organization}"
            data =
              impression:
                  id  : ids.event
                  type: 'Event Description Read'

            ReportGrid.track(path, data)
          ),
          1000

    mouseleave: ->
      $(this).find('.description').hide("slide", { direction: "down" }, 400)
      active_hover_id = ''

  $(".trend-button").live "click", (event) ->
    event.preventDefault()
    link = $(this)
    event_id = idFromString(link.attr("href"))
    App.ajax
      url: "/api/1/events/trend?event_id=" + event_id
      type: "post"
      success: (response, status, request) ->
        # Prefer immediate response
    link.removeClass "trend"
    link.addClass "trended"

  $(".untrend-button").live "click", (event) ->
    event.preventDefault()
    link = $(this)
    event_id = idFromString(link.attr("href"))
    App.ajax
      url: "/api/1/events/untrend?event_id=" + event_id
      type: "post"
      success: (response, status, request) ->
        # Prefer immediate response
    link.closest('.event-preview').fadeOut()

  # event plans
  $('li', '.datebook .events').draggable
    revert: 'invalid'
    cursorAt:
      top: 12
      right: 18

  $('.thumb-container').droppable
    tolerance: 'touch'
    greedy: true
    drop: (event, ui) ->
      # remove positioning set by drag event so the list flows naturally
      ui.draggable.removeAttr('style')
        # .addClass('without-image')
      $(this).append(ui.draggable)

  $('.close').click (e) ->
    e.preventDefault()
    li = $(this).closest('li')
    li.remove()
    $('ul.events').append(li)

  $('.user-name').click (e) ->
    e.preventDefault()
    $('.dropdown-menu').toggle()

  # disable links once they're added to the selected events
  $('#selected-event-list a').live 'click', (event) ->
    event.preventDefault()

  # on plan invitation page
  $('.wont_be_there').live 'click', (event) ->
    event.preventDefault()
    $(this).closest('.invitation').slideUp()

  # on event invitation page
  $('.attending-event').live 'click', (event) ->
    event.preventDefault()
    $(this).closest('.invitation').slideUp()
    # instead of re-implementing the trend event we'll just
    # click the button that already exists on the event page
    $('.trend-button').click()


  # serialize event ids before submitting form
  $('#plan-form').submit (event) ->
    event_ids = []

    $('#selected-event-list li[id]').each (index) ->
      event_ids.push extractObjectId($(this))

    event_string = event_ids.join(', ')

    if event_string != ''
      $('#plan_event_ids').val(event_string)
      return true
    else
      alert 'Please add an event to your plan!'
      # unset clicked data on button so user doesn't get asked if they want to submit again
      $(this).find('input[type=submit]').data('clicked', false)
      return false
  #---------------------------------------------------#

  # https://github.com/aaronrussell/jquery-simply-countable
  # for some reason it doesn't fail silently when the element doesn't exist...
  if $('#organization_description').length
    $('#organization_description').simplyCountable
      maxCount: 500

  if $('#event_description').length
    $('#event_description').simplyCountable
      maxCount: 140

  if $('#plan_description').length
    $('#plan_description').simplyCountable
      maxCount: 140


displayOrganizationChart = ->
  $('.organization_stats').each ->
    target = "##{$(this).attr('id')}"
    id = extractObjectId($(this))
    path = "/organizations/#{id}/"

    ReportGrid.barChart target,
      path     : path
      event    : 'impression'
      property : 'type'
      start    : '1 week ago'
      end      : 'now'
      options:
        displayrules: (type) ->
          type == 'count'
        # label:
        #   datapoint     : label.sourceTypePercent
        #   datapointover : label.sourceType
        # }

trackImpressions = ->
  $('[data-reportgrid]').each ->
    data = $.parseJSON $(this).attr('data-reportgrid')

    path = data.path
    delete data.path

    ReportGrid.track path, data

# id='organization_4' returns 4
extractObjectId = (element) ->
  element.attr('id').split('_').pop()

# id='organization_4-event_5' returns {organization: 4, event: 5}
extractComplexObjectId = (element) ->
  parts = element.attr('id').split('-')
  ids = {}
  for pair in parts
    [key, value] = pair.split('_')
    ids[key] = value
  ids


