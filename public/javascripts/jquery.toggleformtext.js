var toggleformtext = function(){

    jQuery("input:text, textarea, input:password").each(function(){
        var input = jQuery(this);
        var title = input.attr('title');
        var value = input.val();
        if(value == ''){
          if(title != ''){
            input.val(title);
            input.addClass('formtext');
          }
        }
    });

    jQuery("input:text, textarea, input:password").focus(function(){
        var input = jQuery(this);
        var title = input.attr('title');
        var value = input.val();
        if(value == title){
          input.val('');
          input.removeClass('formtext');
        }
    });

    jQuery("input:text, textarea, input:password").blur(function(){
        var input = jQuery(this);
        var title = input.attr('title');
        var value = input.val();
        if(value == ''){
          input.val(title);
          input.addClass('formtext');
        }
    });

    jQuery("input:image, input:button, input:submit").click(function(){
      jQuery(this.form.elements).each(function(){
        if(this.type =='text' || this.type =='textarea' || this.type =='password' ){
          var input = jQuery(this);
          var title = input.attr('title');
          var value = input.val();
          if(value == title && title != ''){
            input.val('');
          }
        }
      });
    });
};

jQuery(document).ready(function(){ toggleformtext() });
