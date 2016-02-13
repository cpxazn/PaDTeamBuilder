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
	

	
}); 