var displayOrganizationChart, extractComplexObjectId, extractObjectId, trackImpressions;
var __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; };
$(function() {
  var active_hover_id, planDragOptions;
  trackImpressions();
  displayOrganizationChart();
  $('input, textarea').placeholder();
  $('.truncate').truncate();
  $(".flash a.dismiss").live("click", function(event) {
    event.preventDefault();
    return $(this).closest(".flash").hide(400);
  });
  $(".tooltip").qtip({
    position: {
      my: "bottom middle",
      at: "top middle"
    },
    style: {
      classes: "ui-tooltip-youtube"
    }
  });
  active_hover_id = '';
  $('.events li, .organizations li').live({
    mouseenter: function() {
      $(this).find('.description').show("slide", {
        direction: "down"
      }, 200);
      active_hover_id = $(this).attr('id');
      if ($(this).parent().hasClass('events')) {
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
      }
    },
    mouseleave: function() {
      $(this).find('.description').hide("slide", {
        direction: "down"
      }, 400);
      return active_hover_id = '';
    }
  });
  $(".trend-button").live("click", function(event) {
    var event_id, link;
    event.preventDefault();
    link = $(this);
    event_id = idFromString(link.attr("href"));
    App.ajax({
      url: "/api/1/events/trend?event_id=" + event_id,
      type: "post",
      success: function(response, status, request) {}
    });
    link.removeClass("trend");
    return link.addClass("trended");
  });
  $(".untrend-button").live("click", function(event) {
    var event_id, link;
    event.preventDefault();
    link = $(this);
    event_id = idFromString(link.attr("href"));
    App.ajax({
      url: "/api/1/events/untrend?event_id=" + event_id,
      type: "post",
      success: function(response, status, request) {}
    });
    return link.closest('.event-preview').fadeOut();
  });
  planDragOptions = {
    revert: 'invalid',
    cursorAt: {
      top: 12,
      right: 18
    }
  };
  $('li', '.datebook .events').draggable(planDragOptions);
  $('.thumb-container').droppable({
    tolerance: 'touch',
    greedy: true,
    drop: function(event, ui) {
      ui.draggable.removeAttr('style');
      return $(this).append(ui.draggable);
    }
  });
  $('.remove-from-plan').live('click', function(e) {
    var li;
    e.preventDefault();
    li = $(this).closest('.event-preview');
    li.remove();
    $('ul.events').append(li);
    $('li', '.datebook .events').draggable('destroy');
    return $('li', '.datebook .events').draggable(planDragOptions);
  });
  $('.user-name').click(function(e) {
    e.preventDefault();
    return $('.dropdown-menu').toggle();
  });
  $('#selected-event-list a').live('click', function(event) {
    return event.preventDefault();
  });
  $('.wont_be_there').live('click', function(event) {
    event.preventDefault();
    return $(this).closest('.invitation').slideUp();
  });
  $('.attending-event').live('click', function(event) {
    event.preventDefault();
    $(this).closest('.invitation').slideUp();
    return $('.trend-button').click();
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