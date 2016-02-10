
$(document).ready(function(){
	var engine = new Bloodhound({
		datumTokenizer: function (d) {
            return Bloodhound.tokenizers.whitespace(d.name);
		},
		queryTokenizer: Bloodhound.tokenizers.whitespace,
		remote: { url: "/monsters/json/typeahead/%QUERY",
			wildcard: '%QUERY'}
	});
	
	engine.initialize();

    $('.typeahead').typeahead(
		{hint: false, highlight: true, minLength: 1}
		,
		{
			name: 'monsters',
			displayKey: 'name',
			source: engine.ttAdapter(),
			limit: 30,
			templates: {
				suggestion: function(data){
					return '<div>' + data.id + ' - ' + data.name + '</div>';
				}
			}
		}	
	);
	
	$('.typeahead').bind('typeahead:selected', function(obj, datum, name) {      
				window.location.href = "./" + datum.id;  
	});
}); 
