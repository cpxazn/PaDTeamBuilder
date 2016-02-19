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
	//Show/Hide Low Scores
	$('div.monster-container div.low-score').hide();
	$('.btn.show-low').show();
	$('.btn.show-low.subs').click(
		function() {
			$('div.monster-container div.low-score.subs').toggle();
			if($(".btn.show-low.subs").text() == 'Show Hidden') {$(".btn.show-low.subs").html('Hide');} else {$(".btn.show-low.subs").html('Show Hidden');}
		}
	);
	$('.btn.show-low.leaders').click(
		function() {
			$('div.monster-container div.low-score.leaders').toggle();
			if($(".btn.show-low.leaders").text() == 'Show Hidden') {$(".btn.show-low.leaders").html('Hide');} else {$(".btn.show-low.leaders").html('Show Hidden');}
		}
	);
	
	$('#edit-tags').click(
		function() {
			$('#update-tags').show();
			$('select.tags').prop("disabled", false);
			$('div#edit.tags').hide();
			$('div#update.tags').show();
		}
			
	);
}); 