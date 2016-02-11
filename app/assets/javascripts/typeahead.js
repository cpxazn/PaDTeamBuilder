
$(document).ready(function(){
	var engine = new Bloodhound({
		datumTokenizer: function (d) {
            return Bloodhound.tokenizers.whitespace(d.name);
		},
		queryTokenizer: Bloodhound.tokenizers.whitespace,
		remote: { url: "/monsters/json/typeahead?name=%QUERY",
			wildcard: '%QUERY'}
	});
	
	engine.initialize();

    $('.typeahead').typeahead(
		{hint: false, highlight: true, minLength: 1}
		,
		{
			limit: 1000,
			name: 'monsters',
			displayKey: 'name',
			source: engine.ttAdapter(),
			templates: {
				suggestion: function(data){
					return '<div>' + data.id + ' - ' + data.name + '</div>';
				}
			}
		}	
	);
	
	$('.typeahead.main').bind('typeahead:selected', function(obj, datum, name) {      
				window.location.href = "/monsters/" + datum.id;  
	});
	
	$('.typeahead.lookup]').bind('typeahead:selected', function(obj, datum, name) {      
				//$("#img.lookup").attr( "src":"http://padherder.com" );
				alert(datum);
	});
}); 
