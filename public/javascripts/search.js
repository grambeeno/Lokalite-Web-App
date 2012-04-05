    jQuery(document).ready(function(){
    
    	    		// search panel is open
    			
    	    						
    	jQuery("#search_DD").click(function(){
    		var open = jQuery(this).parent().hasClass('open');
    		var closed = jQuery(this).parent().hasClass('closed');
    		
    	    // toggle advanced search
    	    jQuery("div.search_module").slideToggle();
    		    
    	    if(open == true){
    	    	jQuery("#search_DD").removeClass('open');
    	    	jQuery("#search_DD").addClass('closed');
    	    	jQuery('#search_DD span').text('');
    	    } else if ( closed == true ) {
    	    	jQuery("#search_DD").removeClass('closed');
    	    	jQuery("#search_DD").addClass('open');
    	    	jQuery('#search_DD span').text('');
    	    }
    		    
    	});
    						
    });
    	
