(function() {
  var displayOrganizationChart, extractComplexObjectId, extractObjectId, trackEvent, trackImpressions;
  var __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; };
  $(function() {
    var active_hover_id;
    trackImpressions();
    displayOrganizationChart();
    $('.truncate').truncate();
    active_hover_id = '';
    $('.events li, .organizations li').live({
      mouseenter: function() {
        $(this).find('.description').show("slide", {
          direction: "down"
        }, 200);
        active_hover_id = $(this).attr('id');
        if ($(this).parent().hasClass('events') || $(this).parent().hasClass('organizations')) {
          return setTimeout((__bind(function() {
            var data;
            if (active_hover_id === $(this).attr('id')) {
              data = $.parseJSON($(this).attr('data-reportgrid'));
              return trackEvent(data, "_engage");
            }
          }, this)), 1000);
        }
      },
      mouseleave: function() {
        $(this).find('.description').hide("slide", {
          direction: "down"
        }, 400);
        return active_hover_id = '';
      },
      click: function() {
        var data;
        data = $.parseJSON($(this).attr('data-reportgrid'));
        return trackEvent(data, "_click");
      }
    });
    $('a.trend').live({
      click: function(event) {
        var data, event_li;
        event.stopPropagation();
        event_li = $(this).parent().parent();
        data = $.parseJSON(event_li.attr('data-reportgrid'));
        return trackEvent(data, "_trend_click");
      }
    });
    $('a.trended').live({
      click: function(event) {
        var data, event_li;
        event.stopPropagation();
        event_li = $(this).parent().parent();
        data = $.parseJSON(event_li.attr('data-reportgrid'));
        return trackEvent(data, "_untrend_click");
      }
    });
    $('.featured_sidebar li, .trending_sidebar li').live({
      click: function() {
        var data;
        data = $.parseJSON($(this).attr('data-reportgrid'));
        return trackEvent(data, "_click");
      }
    });
    $('section.event .text a').live({
      click: function() {
        var data;
        data = $.parseJSON($('section.event').attr('data-reportgrid'));
        return trackEvent(data, "_org_click");
      }
    });
    $('section.event .map a').live({
      mouseenter: function() {
        active_hover_id = $(this).attr('href');
        if ($(this).parent().hasClass('map')) {
          return setTimeout((__bind(function() {
            var data;
            if (active_hover_id === $(this).attr('href')) {
              data = $.parseJSON($('section.event').attr('data-reportgrid'));
              return trackEvent(data, "_map_engage");
            }
          }, this)), 1000);
        }
      },
      mouseleave: function() {
        return active_hover_id = '';
      },
      click: function() {
        var data;
        data = $.parseJSON($('section.event').attr('data-reportgrid'));
        return trackEvent(data, "_map_click");
      }
    });
    $('section.organization .map a').live({
      mouseenter: function() {
        active_hover_id = $(this).attr('href');
        if ($(this).parent().hasClass('map')) {
          return setTimeout((__bind(function() {
            var data;
            if (active_hover_id === $(this).attr('href')) {
              data = $.parseJSON($('section.organization').attr('data-reportgrid'));
              return trackEvent(data, "_map_engage");
            }
          }, this)), 1000);
        }
      },
      mouseleave: function() {
        return active_hover_id = '';
      },
      click: function() {
        var data;
        data = $.parseJSON($('section.organization').attr('data-reportgrid'));
        return trackEvent(data, "_map_click");
      }
    });
    $('section.organization dd.website a').live({
      click: function() {
        var data;
        data = $.parseJSON($('section.organization').attr('data-reportgrid'));
        return trackEvent(data, "_website_click");
      }
    });
    $('section.organization dd.phone').live({
      click: function() {
        var data;
        data = $.parseJSON($('section.organization').attr('data-reportgrid'));
        return trackEvent(data, "_phone_click");
      }
    });
    $('li', '.datebook .events').draggable({
      revert: 'invalid',
      cursorAt: {
        top: 12,
        right: 18
      }
    });
    $('.thumb-container').droppable({
      tolerance: 'touch',
      greedy: true,
      drop: function(event, ui) {
        ui.draggable.removeAttr('style');
        return $(this).append(ui.draggable);
      }
    });
    $('.close').click(function(e) {
      var li;
      e.preventDefault();
      li = $(this).closest('li');
      li.remove();
      return $('ul.events').append(li);
    });
    $('.user-name').click(function(e) {
      e.preventDefault();
      return $('.dropdown-menu').toggle();
    });
    $('#selected-event-list a').live('click', function(event) {
      return event.preventDefault();
    });
    $('#plan-form').submit(function(event) {
      var event_ids, event_string;
      event_ids = [];
      $('#selected-event-list li[id]').each(function(index) {
        return event_ids.push(extractObjectId($(this)));
      });
      event_string = event_ids.join(', ');
      if (event_string !== '') {
        $('#plan_event_ids').val(event_string);
        return true;
      } else {
        alert('Please add an event to your plan!');
        $(this).find('input[type=submit]').data('clicked', false);
        return false;
      }
    });
    if ($('#organization_description').length) {
      $('#organization_description').simplyCountable({
        maxCount: 500
      });
    }
    if ($('#event_description').length) {
      $('#event_description').simplyCountable({
        maxCount: 140
      });
    }
    if ($('#plan_description').length) {
      return $('#plan_description').simplyCountable({
        maxCount: 140
      });
    }
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
  trackEvent = function(data, type_suffix) {
    var event_type, path, tracking_data;
    event_type = data.base_type + type_suffix;
    path = data.path;
    delete data.base_type;
    delete data.path;
    tracking_data = {};
    tracking_data[event_type] = data;
    console.log(JSON.stringify(tracking_data));
    return ReportGrid.track(path, tracking_data);
  };
  trackImpressions = function() {
    return $('[data-reportgrid]').each(function() {
      var data;
      data = $.parseJSON($(this).attr('data-reportgrid'));
      return trackEvent(data, " impression");
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
