// Place your application-specific JavaScript functions and classes here
// This file is automatically included by javascript_include_tag :defaults
//

if(!window.jq && window.jQuery){
  var jq = jQuery;
}

if(!window.App){
  window.App = {};
}

App.log = function(){
  try {
    if(window.console){
      if(window.console.log){
        window.console.log.apply(window.console, arguments);
      }
    }
  } catch(e) {}
};


jq(function($){

// initializers
//
  App.initialize = function(){
    var scope = arguments[0];
    scope = scope ? jq(scope) : jq('html');

    App.initialize_type_classes(scope);
    //App.initialize_traditional_box_model(scope);
    App.initialize_submits(scope);
    App.initialize_focus(scope);
  };

// apply a type class to each input to get around shitty IE css selectors.
// fuck you IE.
//
  App.initialize_type_classes = function(){
    var scope = arguments[0];
    scope = scope ? jq(scope) : jq('html');
    scope.find('input').each(function(){
      var input = jq(this);
      var type = input.attr('type');
      input.addClass(type);
    });
  };

// facebox shit yo!
//
  jq('a[rel*=facebox]').facebox();
  jq(document).bind(
    'afterReveal.facebox',
    function(){
      var facebox = jq('#facebox');
      App.initialize(facebox);
    }
  );

  App.initialize_focus = function(){
    var scope = arguments[0];
    scope = scope ? jq(scope) : jq('html');
    scope.find('.focus:first').focus().click();
    scope.find('#focus:first').focus().click();
  };

  App.initialize_submits = function(){
    var scope = arguments[0];
    scope = scope ? jq(scope) : jq('html');

    scope.find('input[type=submit]').click(function(){
      if(jQuery.data(this, 'clicked')){
        return(confirm('Are you sure you want to submit this form again?'));
      }
      else{
        jQuery.data(this, 'clicked', true);
        return true;
      }
      return true;
    });
  };


  App.initialize();


// ajax shortcuts
//
  App.ajax = function(){
    var options = {};

    if(arguments.length == 1){
      var arg = arguments[0];

      if(typeof(arg)=='string'){
        options.url = arg;
      } else {
        options = arg;
      }
    }

    if(arguments.length > 1){
      options.url = arguments[0];

      if(typeof(arguments[1])=='function'){
        options.success = arguments[1];
        options.data = arguments[2];
      } else {
        options.data = arguments[1];
        options.success = arguments[2];
      }
    }

    var ajax = {};
    ajax.type = options.type || App.ajax.defaults.type;
    ajax.url = options.url || App.ajax.defaults.url;
    ajax.dataType = 'json';
    ajax.cache = false;

    if(ajax.type == 'POST' || ajax.type == 'PUT' || ajax.type == 'DELETE'){
      ajax.data = jQuery.toJSON(options.data || {});
    } else {
      ajax.data = (options.data || {});
    }

    ajax.contentType = (options.contentType || 'application/json; charset=utf-8');

    var result = App;

    if(options.success){
      ajax.success = options.success;
    } else {
      if(typeof(ajax.async) == 'undefined'){
        ajax.async = false;
        ajax.success = function(){
          var args = Array.prototype.slice.call(arguments);
          result = args[0];
          App.ajax.results.push(result);
          App.ajax.result = result;
        };
      }
    }

    jQuery.ajax(ajax);
    return(result);
  };

  App.ajax.modes = ["options", "get", "head", "post", "put", "delete", "trace", "connect"];
  App.ajax.result = null;
  App.ajax.results = [];
  App.ajax.defaults = {};
  App.ajax.defaults.type = 'get';
  App.ajax.defaults.url = '/';

// meta-program App.ajax.get(...), App.ajax.post(...)
//

  for(var i = 0; i < App.ajax.modes.length; i++){
    (function(){
      var mode = App.ajax.modes[i];
      App.ajax[mode] = function(options){
        if(typeof(options) == 'string'){
          var opts = {'url' : options};
          options = opts;
        }
        options.type = mode.toUpperCase();
        App.ajax(options);
      };
    })();
  }


  $('input, textarea').placeholder();

  $('.trend').live('click', function(event) {
    event.preventDefault();
    var link = $(this);
    var event_id = idFromString(link.attr('href'));
    App.ajax({
      url: '/api/1/events/trend?event_id=' + event_id,
      type: 'post',
      success: function(response, status, request) {
        // nothing anymore, we'll just ignore if the request was
        // successful and give the user immediate feedback instead
      }
    });
    link.removeClass('trend');
    link.addClass('trended');
    link.attr('href', link.attr('href').replace('trend', 'untrend'));
  });

  $('.trended').live('click', function(event) {
    event.preventDefault();
    var link = $(this);
    var event_id = idFromString(link.attr('href'));
    App.ajax({
      url: '/api/1/events/untrend?event_id=' + event_id,
      type: 'post',
      success: function(response, status, request) {
        // nothing anymore, we'll just ignore if the request was
        // successful and give the user immediate feedback instead
      }
    });
    link.removeClass('trended');
    link.addClass('trend');
    link.attr('href', link.attr('href').replace('untrend', 'trend'));
  });


  $('.flash a.dismiss').live('click', function(event) {
    event.preventDefault();
    $(this).closest('.flash').hide(400);
  });


  $('.events li, .organizations li').live({
    mouseenter: function() {
      $(this).find('.description').show("slide", { direction: "down" }, 200);
    },
    mouseleave: function() {
      $(this).find('.description').hide("slide", { direction: "down" }, 400);
    }
  });

  // rolling our own simple tabs here because it's
  // easier than un-styling the jQueryUI tabs
  //
  // alert(window.location.match(/places/g));

  if (window.location.pathname.match(/\/places\//g)) {
    $("#event-categories").hide();
    $('a[href="#places-categories"]').addClass('active');
  } else {
    $("#places-categories").hide();
    $('a[href="#event-categories"]').addClass('active');
  }

  $('a[href="#event-categories"]').click(function(event) {
    event.preventDefault();
    $(this).closest('ul').find('.active').removeClass('active');
    $(this).addClass('active');
    $("#places-categories").hide();
    $("#event-categories").show();
  });
  $('a[href="#places-categories"]').click(function(event) {
    event.preventDefault();
    $(this).closest('ul').find('.active').removeClass('active');
    $(this).addClass('active');
    $("#event-categories").hide();
    $("#places-categories").show();
  });


  $('.datetimepicker').datetimepicker({
    ampm: true,
    stepMinute: 15
  });

  $('#new_organization #organization_name').keyup(function() {
    $('#organization_locations_attributes_0_name').val($(this).val());
  });

  $('.tooltip').qtip({
    position: {
      my: 'bottom middle',
      at: 'top middle'
    },
    style: {
      classes: 'ui-tooltip-youtube'
    }
  });

  // $('#search_events').keyup(function(event) {
  //   if (event.keyCode == 13) {
  //     window.location = window.location + '/search/' + $(this).val()
  //   }
  // });

  // https://github.com/aaronrussell/jquery-simply-countable
  // for some reason it doesn't fail silently when the element doesn't exist...
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

  // repeating events
  $('#repeat-calendar').datepicker({
    minDate: new Date(),
    numberOfMonths: 3,
    onSelect: function(dateText, instance) {
      var template = $('<li><div class="event-repeat"><input class="date" id="event_dates_" name="event_dates[]" type="text" /><a href="#remove" class="remove-repeat">Remove</a></div></li>');
      template.find('.date').val(dateText);
      $('#event-repeats').append( template );
      // $('#event-repeats').append( new Date(dateText) );
      $('.submit-repeats').show();

    }
  });

  $('.remove-repeat').live('click', function(event) {
    $(this).closest('.event-repeat').remove();
  });

  ////////////////////////////////////////////////////

  $('.truncate').truncate();

});

function idFromString(string) {
  return string.match(/\d*$/)[0];
}

