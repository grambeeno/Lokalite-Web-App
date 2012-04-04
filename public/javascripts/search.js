    jQuery(document).ready(function(){
    
    	    		// search panel is open
    			
    	    						
    	jQuery("#panbut").click(function(){
    		var open = jQuery(this).parent().hasClass('open');
    		var closed = jQuery(this).parent().hasClass('closed');
    		
    	    // toggle advanced search
    	    jQuery("div.search_module").slideToggle();
    		    
    	    if(open == true){
    	    	jQuery("#panbut").removeClass('open');
    	    	jQuery("#panbut").addClass('closed');
    	    	jQuery('#panbut span').text('');
    	    } else if ( closed == true ) {
    	    	jQuery("#panbut").removeClass('closed');
    	    	jQuery("#panbut").addClass('open');
    	    	jQuery('#panbut span').text('');
    	    }
    		    
    	});
    						
    });
    	
