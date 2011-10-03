(function() {
  var displayOrganizationChart, extractObjectId, trackImpressions;
  $(function() {
    trackImpressions();
    return displayOrganizationChart();
  });
  displayOrganizationChart = function() {
    return $('.organization_stats').each(function() {
      var id, path, target;
      target = "#" + ($(this).attr('id'));
      id = extractObjectId($(this));
      path = "/organizations/" + id + "/";
      return ReportGrid.barChart(target, {
        path: path,
        event: 'impression',
        property: 'type',
        start: '1 week ago',
        end: 'now',
        options: {
          displayrules: function(type) {
            return type === 'count';
          }
        }
      });
    });
  };
  trackImpressions = function() {
    return $('[data-reportgrid]').each(function() {
      var data, path;
      data = $.parseJSON($(this).attr('data-reportgrid'));
      path = data.path;
      delete data.path;
      return ReportGrid.track(path, data);
    });
  };
  extractObjectId = function(element) {
    return element.attr('id').split('-').pop();
  };
}).call(this);
