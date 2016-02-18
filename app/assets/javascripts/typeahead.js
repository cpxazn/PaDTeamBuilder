
$(document).ready(function(){
	var monEngine = new Bloodhound({
		datumTokenizer: function (d) {
            return Bloodhound.tokenizers.whitespace(d.name);
		},
		queryTokenizer: Bloodhound.tokenizers.whitespace,
		remote: { url: "/monsters/json/typeahead?name=%QUERY",
			wildcard: '%QUERY'}
	});
	
	monEngine.initialize();

    $('.typeahead.monster').typeahead(
		{hint: false, highlight: true, minLength: 1}
		,
		{
			limit: 1000,
			name: 'monsters',
			displayKey: 'name',
			source: monEngine.ttAdapter(),
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
	
	$('.typeahead.monster.lookup').bind('typeahead:selected', function(obj, datum, name) {    
				$('img#lookup').attr( {"src":"http://padherder.com" + datum.img_url} );
				
	});
	
	
	var tagEngine = new Bloodhound({
		datumTokenizer: function (d) {
            return Bloodhound.tokenizers.whitespace(d.name);
		},
		queryTokenizer: Bloodhound.tokenizers.whitespace,
		remote: { url: "/monsters/json/tags?name=%QUERY",
			wildcard: '%QUERY'}
	});
	
	monEngine.initialize();

    $('.typeahead.tag').typeahead(
		{hint: false, highlight: true, minLength: 1}
		,
		{
			limit: 1000,
			name: 'tags',
			displayKey: 'name',
			source: tagEngine.ttAdapter(),
			templates: {
				suggestion: function(data){
					return '<div>' + data.name + '</div>';
				}
			}
		}	
	);
	
}); 
