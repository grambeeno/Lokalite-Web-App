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

  initQtip = ->
    $(".tooltip").qtip
      position:
        my: "bottom middle"
        at: "top middle"
      style:
        classes: "ui-tooltip-youtube"

  initQtip()

  # https://github.com/bigspotteddog/ScrollToFixed
  $('#new-plan-container').scrollToFixed()

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
  planDragOptions =
    revert: 'invalid'
    # ScrollToFixed uses a z-index of 1000, so when the page scrolls
    # the event is obfuscated while dragging
    zindex: 1001
    cursorAt:
      top: 12
      right: 18

  $('li', '.datebook .events').draggable(planDragOptions)

  $('.thumb-container').droppable
    tolerance: 'touch'
    greedy: true
    drop: (event, ui) ->
      # remove positioning set by drag event so the list flows naturally
      ui.draggable.removeAttr('style')
      # ui.draggable.css('position', 'relative')
        # .addClass('without-image')
      $(this).append(ui.draggable)

  $('.remove-from-plan').live 'click', (e) ->
    e.preventDefault()
    li = $(this).closest('.event-preview')
    li.remove()
    $('ul.events').append(li)
    $('li', '.datebook .events').draggable('destroy')
    $('li', '.datebook .events').draggable(planDragOptions)

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

  # '2012-01-27'
  # http://docs.jquery.com/UI/Datepicker/parseDate
  datepickerFormat = 'yy-mm-dd'

  # /my/events/feature
  $('.featured-date').datepicker
    dateFormat: datepickerFormat
    minDate: 0
    # Select a date from the calendar
    onSelect: (dateText, instance) ->
      $('.event-slots').html('<div class="loader" style="margin-left:42px;margin-bottom:8px;"><div>')
      $.get "/my/events/featured_slots/#{dateText}", (data) ->
        $('.event-slots').html(data)
        initQtip()

  # select an organization from dropdown
  $('.feature-events #organization_id').change (event) ->
    $('.event-picker').html("<li class='loader'></li>")
    organization_id = $(this).val()
    $.get "/my/events/events_for_organization/#{organization_id}", (data) ->
      if data == ''
        html = 'No Upcoming Events Found.'
      else
        html = data
      $('.event-picker').html(html)

  # select an event
  $('.event-picker :radio').live 'change', (event) ->
    date = $(this).data('start-date')
    $('.featured-date').datepicker("option", "maxDate", date)

  $('.event-slots .slot').live 'click', (event) ->
    if $(this).hasClass('available')
      $(this).parent().find('.slot').removeClass('selected')
      $(this).addClass('selected')

  $('a.feature-event').live 'click', (event) ->
    event.preventDefault()
    errors = []

    date = $('.featured-date').datepicker('getDate')
    if date
      date = $.datepicker.formatDate(datepickerFormat, date)
    else
      errors.push 'date'

    slot = $('.event-slots .selected')
    if slot.length == 0
      errors.push 'slot'
    else
      slot = extractObjectId(slot)

    event = $('.event-picker :radio:checked')
    if event.length == 0
      errors.push 'event'
    else
      event = extractObjectId(event)

    if errors.length > 0
      alert("Please select: #{errors.reverse().join(', ')}.")
      return false

    path = "/my/events/feature/?event_id=#{event}&slot=#{slot}&date=#{date}"
    window.location = path
  #---------------------------------------------------#


  # https://github.com/aaronrussell/jquery-simply-countable
  # for some reason it doesn't fail silently when the element doesn't exist...
  if $('#organization_description').length
    $('#organization_description').simplyCountable
      maxCount: 500

  if $('#event_description').length
    $('#event_description').simplyCountable
      maxCount: 200

  if $('#plan_description').length
    $('#plan_description').simplyCountable
      maxCount: 140

  # Event date filtering in left sidebar
  # with help from http://medialize.github.com/URI.js/docs.html
  observeEventDateFlitering = ->
    startTimeSelect = $('.event_date_filters #event_start_time')
    startDateSelect = $('.event_date_filters #event_start_date')

    url = new URI(window.location.href)

    startTimeSelect.change ->
      applyFilters()

    startDateSelect.datepicker
      minDate: 0
      dateFormat: 'mm-dd-yy'
      onSelect: (dateText, instance) ->
        applyFilters()

    startTimeString = ->
      selectedDate = startDateSelect.datepicker('getDate')
      date = $.datepicker.formatDate('mm-dd-yy', selectedDate)
      time = startTimeSelect.val()
      "#{date} #{time}"

    applyFilters = ->
      clearFilters()
      $('a.clear_date_filter').show()
      $("#after").val(startTimeString())

    clearFilters = ->
      $("#after").val('')
      $('a.clear_date_filter').hide()

    # use this so we don't have to always normalize
    # also, don't want to reload the page unless we need to

    # now set initial state.
    # if after param is aleady set, select it in the timepicker and calendar

     after = $("#after").val()
     if after 
       [date, time] = after.split(' ')
       startTimeSelect.val(time)
       startDateSelect.datepicker('setDate', date)
     else
       # hide the link to clear the datepicker
       $('a.clear_date_filter').hide()
  
  observeEventDateFlitering()
  #---------------------------------------------------#


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
  unless element == []
    return element.attr('id').split('_').pop()

# id='organization_4-event_5' returns {organization: 4, event: 5}
extractComplexObjectId = (element) ->
  parts = element.attr('id').split('-')
  ids = {}
  for pair in parts
    [key, value] = pair.split('_')
    ids[key] = value
  ids


