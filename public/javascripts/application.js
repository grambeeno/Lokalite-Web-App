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
// _.templateSettings = { start : '{{', end : '}}', interpolate : /{{(.+?)}}/g };
//

// customize date_input formats
//
  jq.extend(DateInput.DEFAULT_OPTS, {
    stringToDate: function(string) {
      var matches;
      if (matches = string.match(/^(\d{4,4})-(\d{2,2})-(\d{2,2})$/)) {
        return new Date(matches[1], matches[2] - 1, matches[3]);
      } else {
        return null;
      }
    },
    dateToString: function(date) {
      var month = (date.getMonth() + 1).toString();
      var dom = date.getDate().toString();
      if (month.length == 1) month = "0" + month;
      if (dom.length == 1) dom = "0" + dom;
      return date.getFullYear() + "-" + month + "-" + dom;
    }
  });

// find and pre-compile all jquery templates on the page. cache them by name.
//
  var templates = {};
  App.templates = templates;
  jq('script.template').each(function(){
    var j = jq(this);
    var name = j.attr('name');
    var html = j.html();
    templates[name] = jq.template(name, html);
  });


// flash message support
//
  App.flash = function(msg, options){
    options = options || {};
    var flash = jq('.flash');

    var template = App.templates['flash-list-item'];
    var data = {'message' : msg};
    var message = jq.tmpl(template, data);

    var dismiss = message.find('.dismiss');

    dismiss.click(function(){ message.remove(); });

    message.addClass(options['class'] || 'info');
    flash.append(message);
    App.blink(message);
    return(message);
  };

// new skool <blink>
//
  App.blink = function(){
    var element = arguments[0];
    var options = arguments[1] || {};
    var n = options.n || App.blink.n;
    var speed = options.speed || App.blink.speed;
    element = jq(element);
    element.fadeout = function(){ element.fadeTo(speed, 0.50, element.fadein); };
    element.fadein = function(){ element.fadeTo(speed, 1.00); --n > 0 && element.fadeout(); };
    var id = setTimeout( element.fadeout, speed );
    return(id);
  };
  App.blink.n = 2;
  App.blink.speed = 2000;

// initializers
//
  App.initialize = function(){
    var scope = arguments[0];
    scope = scope ? jq(scope) : jq('html');

    App.initialize_type_classes(scope);
    //App.initialize_traditional_box_model(scope);
    App.initialize_form_hints(scope); 
    App.initialize_date_inputs(scope);
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

// make tds clickable in the "you might like" table
//
  jq('.recommended-events td').click(function() {
    window.location.href = $('a', this).first().attr('href');
  });


  App.initialize_traditional_box_model = function(){
    var args = Array.prototype.slice.call(arguments);
    var scope = args.shift();
    scope = scope ? jq(scope) : jq('html');

    var selectors;

    if(args.length==0){
      selectors = [
        'textarea',
        'input[type=text]',
        'input[type=password]',
        'input'
      ];
    } else {
      selectors = args;
    }

    var list = []; 

    jq.each(selectors, function(index, selector){
      scope.find(selector).each(function(){
        var element = jq(this);

        var traditional_box_model_width =
          element.data('traditional_box_model_width');

        if(!traditional_box_model_width){
          var width =
            element.data('width');
          if(!width){
            width = element.width();
            element.data('width', width);
          }

          var padding =
            element.data('padding');
          if(!padding){
            padding = element.padding();
            element.data('padding', padding);
          }

          traditional_box_model_width = Math.floor(width - padding.left - padding.right - 1);
          //var delta = (element.outerWidth() - element.width()) / 2;
          //traditional_box_model_width = element.width() - delta;
//console.log('---');
//console.log(element);
//console.log(element.outerWidth());
//console.log(element.width());
//console.log(delta);
//console.log(traditional_box_model_width);
          element.data('traditional_box_model_width', traditional_box_model_width);
        }

        list.push([element, traditional_box_model_width]);
        //element.width(traditional_box_model_width);
      });
    });

    for(var i = 0; i < list.length; i++){
      var pair = list[i];
      var element = pair[0];
      var width = pair[1];
      element.width(width);
    }
  };

  App.initialize_form_hints = function(){
    var scope = arguments[0];
    scope = scope ? jq(scope) : jq('html');
    toggleformtext();
  };

  App.initialize_focus = function(){
    var scope = arguments[0];
    scope = scope ? jq(scope) : jq('html');
    scope.find('.focus:first').focus().click();
    scope.find('#focus:first').focus().click();
  };

  App.initialize_date_inputs = function(){
    var scope = arguments[0];
    scope = scope ? jq(scope) : jq('html');
    scope.find('.date').date_input();
  };

  App.initialize_submits = function(){
    var scope = arguments[0];
    scope = scope ? jq(scope) : jq('html');
    scope.find('.date').date_input();

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


  $('.trend').live('click', function(event) {
    event.preventDefault();
    var link = $(this);
    var event_id = idFromString(link.attr('href'));
    App.ajax({
      url: '/api/events/trend?event_id=' + event_id,
      type: 'post',
      success: function(response, status, request) {
        var counter = link.find('.trend-count');
        counter.text( parseInt(counter.text(), 10) + 1 )
      
        link.removeClass('trend');
        link.addClass('trended');
        link.attr('href', link.attr('href').replace('trend', 'untrend'));
      }
    });
  });

  $('.trended').live('click', function(event) {
    event.preventDefault();
    console.log('untrend');
    var link = $(this);
    var event_id = idFromString(link.attr('href'));
    App.ajax({
      url: '/api/events/untrend?event_id=' + event_id,
      type: 'post',
      success: function(response, status, request) {
        var counter = link.find('.trend-count');
        counter.text( parseInt(counter.text(), 10) - 1 )

        link.removeClass('trended');
        link.addClass('trend');
        link.attr('href', link.attr('href').replace('untrend', 'trend'));
      }
    });
  });


  $('.events li').live({
    mouseenter: function() {
      $(this).find('.description').show("slide", { direction: "down" }, 200);
    },
    mouseleave: function() {
      $(this).find('.description').hide("slide", { direction: "down" }, 400);
    }
  });

  // $('#category-tabs').tabs();

});

function idFromString(string) {
  return string.match(/\d*$/)[0];
}

