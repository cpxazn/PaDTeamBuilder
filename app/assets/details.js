$(document).ready(function(){
	$('ul.nav-tabs').show();
	$('div#comments.page-tab').hide();
	$('div#history.page-tab').hide();
	
		$('.nav-tabs li#statistics').click(
		function() {
			$('div.page-tab').hide();
			$('.nav-tabs li').removeClass("active");
			$('.nav-tabs li#statistics').addClass("active");
			$('div#statistics.page-tab').show();
		}
	)
	$('.nav-tabs li#comments').click(
		function() {
			$('div.page-tab').hide();
			$('.nav-tabs li').removeClass("active");
			$('.nav-tabs li#comments').addClass("active");
			$('div#comments.page-tab').show();
			
		}
	)

	$('.nav-tabs li#history').click(
		function() {
			$('div.page-tab').hide();
			$('.nav-tabs li').removeClass("active");
			$('.nav-tabs li#history').addClass("active");
			$('div#history.page-tab').show();
		}
	)

}); 

