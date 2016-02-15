$(document).ready(function(){
	//Form validation
	$('#Sub.btn, #Leader.btn').click(
		function() {
			
			if($('input.vote').val() == '') {
				alert('Select a monster');
				return false;
			}
			if($('select.vote').val() == 'Rating') {
				alert('Select a rating');
				return false;
			}
			
		}
	)
	
	//Show/Hide Monster Details
	$('.jumbotron > .header-details').hide();
	$(".btn.monster-hide").html('Details');
	$('.btn.monster-hide').show();
	$('.btn.monster-hide').click(
		function() {
			$('.jumbotron > .header-details').toggle();
			if($(".btn.monster-hide").text() == 'Details') {$(".btn.monster-hide").html('Hide');} else {$(".btn.monster-hide").html('Details');}
		}
	)
}); 