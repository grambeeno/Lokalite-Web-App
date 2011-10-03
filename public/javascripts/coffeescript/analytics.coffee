$ ->
  trackImpressions()
  displayOrganizationChart()


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

# id='organization-4' returns 4
extractObjectId = (element) ->
  element.attr('id').split('-').pop()

