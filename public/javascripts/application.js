var dateTimePickerOptions = {
  minDate: 0,
  ampm: true,
  timeFormat: 'h:mm tt',
  stepMinute: 15
}


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


  $('.flash a.dismiss').live('click', function(event) {
    event.preventDefault();
    $(this).closest('.flash').hide(400);
  });

  $('.datetimepicker').datetimepicker(dateTimePickerOptions);
  $('.datepicker').datepicker({
    minDate: 0
  });

  $('#new_organization #organization_name').keyup(function() {
    $('#organization_locations_attributes_0_name').val($(this).val());
  });

  // $('#search_events').keyup(function(event) {
  //   if (event.keyCode == 13) {
  //     window.location = window.location + '/search/' + $(this).val()
  //   }
  // });

  // repeating events
  $('#toggle_all_events').change(function() {
    var boxes = $('.event-checkbox');
    if ($(this).attr('checked') === 'checked') {
      boxes.attr('checked', 'checked');
    } else {
      boxes.attr('checked', null);
    }
  });

  $('.event-checkbox').change(function() {
    if ($(this).attr('checked') !== 'checked') {
      $('#toggle_all_events').attr('checked', null);
    }
  });
  ////////////////////////////////////////////////////

});

function idFromString(string) {
  return string.match(/\d*$/)[0];
}

function unique_id() {
  return new Date().getTime();
}

function manageRepeatingEvents(templateString) {
  $('#repeat-calendar').datepicker({
    minDate: new Date(),
    numberOfMonths: 3,
    onSelect: function(dateText, instance) {
      var template = $(templateString.replace(/INDEX/g, unique_id()));
      var originalStartTime = $('.master-start-time').val();
      var newTime = originalStartTime.replace(/^\S+/i, dateText);
      template.find('.datetimepicker').val(newTime);

      var duration = $('.master-duration').val();
      template.find('.duration-picker').val(duration);

      $('#event-repeats').append( template );
      $('.datetimepicker').datetimepicker('destroy');
      $('.datetimepicker').datetimepicker(dateTimePickerOptions);
      $('.submit-repeats').show();
      $('.event-copy-title').show();
    }
  });

  $('.remove-repeat').live('click', function(event) {
    $(this).closest('.event-repeat').remove();
  });
}


