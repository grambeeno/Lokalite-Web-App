$ ->
  trackImpressions()
  displayOrganizationChart()

  # store the active_hover_id so we can track hovers that last over 1 second
  active_hover_id = ''
  $('.events li, .organizations li').live
    mouseenter: ->
      $(this).find('.description').show("slide", { direction: "down" }, 200)
      active_hover_id = $(this).attr('id')

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


