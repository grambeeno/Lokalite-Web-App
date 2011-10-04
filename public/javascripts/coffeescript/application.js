(function() {
  var displayOrganizationChart, extractComplexObjectId, extractObjectId, trackImpressions;
  var __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; };
  $(function() {
    var active_hover_id;
    trackImpressions();
    displayOrganizationChart();
    active_hover_id = '';
    return $('.events li, .organizations li').live({
      mouseenter: function() {
        $(this).find('.description').show("slide", {
          direction: "down"
        }, 200);
        active_hover_id = $(this).attr('id');
        return setTimeout((__bind(function() {
          var data, ids, path;
          if (active_hover_id === $(this).attr('id')) {
            ids = extractComplexObjectId($(this));
            path = "/organizations/" + ids.organization;
            data = {
              impression: {
                id: ids.event,
                type: 'Event Description Read'
              }
            };
            return ReportGrid.track(path, data);
          }
        }, this)), 1000);
      },
      mouseleave: function() {
        $(this).find('.description').hide("slide", {
          direction: "down"
        }, 400);
        return active_hover_id = '';
      }
    });
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
    return element.attr('id').split('_').pop();
  };
  extractComplexObjectId = function(element) {
    var ids, key, pair, parts, value, _i, _len, _ref;
    parts = element.attr('id').split('-');
    ids = {};
    for (_i = 0, _len = parts.length; _i < _len; _i++) {
      pair = parts[_i];
      _ref = pair.split('_'), key = _ref[0], value = _ref[1];
      ids[key] = value;
    }
    return ids;
  };
}).call(this);
