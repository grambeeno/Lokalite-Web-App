# Compiling this manually for now with:
# coffee -cw .
# Had trouble upgrading to rails 3.1
# don't want to deal with barista or another external gem right now...
$ ->
  trackImpressions()
  displayOrganizationChart()

  $('.truncate').truncate()

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

  $('.user-link').click (e) ->
    e.preventDefault()
    $('.dropdown-menu').toggle()

  # disable links once they're added to the selected events
  $('#selected-event-list a').live 'click', (event) ->
    event.preventDefault()

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

  # $('.invite-to-plan').live 'click', (event) ->
  #   event.preventDefault()
  $('.invite-to-plan').qtip
    content:
      # text: $('div:hidden'),
      text: ->
        $(this).next('.invite-modal').html()
      title:
        text: 'Invite Friends'
        button: true
    position:
      my: 'center'
      at: 'center'
      target: $(window)
    show:
      event: 'click'
      solo: true
      modal: true
    hide: false
    style:
      classes: 'plan-invite-modal ui-tooltip-light ui-tooltip-rounded'
      width: 440
    # events:
    #   show: (event, api) ->


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


