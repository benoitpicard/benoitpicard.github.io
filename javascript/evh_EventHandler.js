/*Scroll when using #ref */
$(function() {
  $('a[href*=#]:not([href=#])').click(function() {
    if (location.pathname.replace(/^\//,'') == this.pathname.replace(/^\//,'') && location.hostname == this.hostname) {
      var target = $(this.hash);
      target = target.length ? target : $('[name=' + this.hash.slice(1) +']');
      if (target.length) {
        $('html,body').animate({
          scrollTop: target.offset().top
        }, 750);
        return false;
      }
    }
  });
});

/*Menu Show/Hide Action*/
function displayCatDropMenu(){
  $("#CatDropMenu").toggle(600);
  $("#TagsDropMenu").hide(600);
}
function displayTagsDropMenu(){
  $("#CatDropMenu").hide(600);
  $("#TagsDropMenu").toggle(600);
}

/* Initialize Single Pop-up window */
$('.sMagPopup').magnificPopup({ 
	type: 'image',
	// Class that is added to popup wrapper and background
	mainClass: 'mfp-fade',
});

/* Initialize Gallery Pop-up window */
$('.gMagPopup').magnificPopup({
	delegate: 'a', // the selector for gallery item
	type: 'image',
	mainClass: 'mfp-fade',
	gallery:{
		enabled:true,
		preload: [0,2],
	},
	image: {
		titleSrc: function(item) {
		return '<a href="' + item.el.attr('linkref') + '"class="whiteLink">' + item.el.attr('title') + '<\a>';
		}
	},
  
});

