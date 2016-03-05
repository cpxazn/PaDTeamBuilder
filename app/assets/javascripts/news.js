$(document).ready(function(){
	$("[class*='toggle']").click(
		function() {
			var id = $(this).attr('id');
			$('div.' + id + '-content').toggle();
			if($('a#' + id).html() == 'Hide') {$('a#' + id).html('Show');} else {$('a#' + id).html('Hide');}
		}
	);
	
}); 