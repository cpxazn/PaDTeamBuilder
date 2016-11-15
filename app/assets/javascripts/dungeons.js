$(document).ready(function(){
	$('select.dungeon-index').select2();
	$('select.dungeon-index').on("change", function(e) {
		window.location.href = "/dungeons/" + $('select.dungeon-index').val();  
	}); 
	
	$('div#technical.dungeon').hide();
	$('div#special.dungeon').hide();
	$('div#multiplayer.dungeon').hide();
	
	$('ul.dungeon.nav > li').click(
		function() {
			dungeon_type = $(this).attr('id');
			$('div.dungeon').hide();
			$('div#' + dungeon_type).show();
			$('ul.dungeon.nav > li').removeClass("active");
			$('ul.dungeon.nav > li#' + dungeon_type).addClass("active");
		}
	)
});