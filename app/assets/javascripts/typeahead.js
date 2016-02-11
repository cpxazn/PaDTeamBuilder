
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

    $('#monster_field.typeahead').typeahead(
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
	
	$('#monster_field.typeahead.main').bind('typeahead:selected', function(obj, datum, name) {      
				window.location.href = "/monsters/" + datum.id;  
	});
}); 
