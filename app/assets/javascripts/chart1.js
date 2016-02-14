function chart1(l,s,urls,id,title,tick,maxy) {		
	parameters = '?leader_id=' + l + '&sub_id=' + s;
	//urls = ['/monsters/json/graph/since' + parameters,'/monsters/json/graph/monthly' + parameters];
	
	var jxhr = [];
	var result = [];
	var arrSeries = [];

	//console.log(urls);
	$.each(urls, function (i, url) {
		
		url[0] = '/monsters/json/graph/' + url[0] + parameters
		//console.log(url[0]);
		jxhr.push(
			$.getJSON(url[0], function (json) {
				result.push(json);
				//console.log(result);
			})
		);

	});

	$.when.apply($, jxhr).done(function() {
		
		for (i = 0; i < result.length; i++) { 
			for (j = 0; j < result[i].length; j++) {
				var strDate = result[i][j][0] + '';
				var arrDate = strDate.split("-");
				//console.log(arrDate[0] + "-" + arrDate[1] + "-" + arrDate[2]);
				result[i][j][0] = Date.UTC(arrDate[0],arrDate[1],arrDate[2]);
			}
		}
		
		//console.log(urls);
		$.each(urls, function( index, value ) { 
			arrSeries.push({type: 'line', name: value[1], data: result[index]})
		});
		
		//console.log(arrSeries);
		
        $(id).highcharts({
            chart: {
                zoomType: 'x'
            },
            title: {
                text: title
            },
            subtitle: {
                text: document.ontouchstart === undefined ?
                        'Click and drag in the plot area to zoom in' : 'Pinch the chart to zoom in'
            },
            xAxis: {
                type: 'datetime'
            },
            yAxis: {
				max: maxy,
				tickInterval: tick,
                title: {
                    text: title
                }
            },
            legend: {
                enabled: true
            },
            plotOptions: {
                area: {
                    fillColor: {
                        linearGradient: {
                            x1: 0,
                            y1: 0,
                            x2: 0,
                            y2: 1
                        },
                        stops: [
                            [0, Highcharts.getOptions().colors[0]],
                            [1, Highcharts.Color(Highcharts.getOptions().colors[0]).setOpacity(0).get('rgba')]
                        ]
                    },
                    marker: {
                        radius: 2
                    },
                    lineWidth: 1,
                    states: {
                        hover: {
                            lineWidth: 1
                        }
                    },
                    threshold: null
                }
            },
            series: arrSeries
        });
	});
}