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
	$("[class*='show-low']").click(
		function() {
			 var button = $(this).attr('id');
			$('div.monster-container div.low-score.' + button).toggle();
			if($(".btn.show-low." + button).text() == 'Show Hidden') {$(".btn.show-low." + button).html('Hide');} else {$(".btn.show-low." + button).html('Show Hidden');}
		}
	);

   

	//Allow editing tags
	$('#edit-tags').click(
		function() {
			$('#update-tags').show();
			$('select.tags').prop("disabled", false);
			$('div#edit.tags').hide();
			$('div#update.tags').show();
		}
			
	);
	
	//List box select tags
	$('#tag_list').change(function() {
		$("select.tags").append('<option selected="selected" value="'+$('#tag_list').val()+'">'+$('#tag_list').val()+'</option>');
		$("select.tags").trigger("change");
	});
	$('button#reset').click(function() {
		$("select.tags").empty();
		$("select.tags").trigger("change");
	});
}); 