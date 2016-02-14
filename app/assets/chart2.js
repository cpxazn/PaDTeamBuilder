function chart1(l,s,u) {		
	parameters = '?leader_id=' + l + '&sub_id=' + s;
	urls = ['/monsters/json/graph/since' + parameters,
			'/monsters/json/graph/monthly' + parameters];
	
	var jxhr = [];
	var result = [];
	$.each(urls, function (i, url) {
		jxhr.push(
			$.getJSON(url, function (json) {
				result.push(json);
				console.log(json);
			})
		);

	});

	$.when.apply($, jxhr).done(function() {
		for (i = 0; i < result.length; i++) { 
			for (j = 0; j < result[i].length; j++) {
				var strDate = result[i][j][0] + '';
				var arrDate = strDate.split("-");
				console.log(arrDate[0] + "-" + arrDate[1] + "-" + arrDate[2]);
				result[i][j][0] = Date.UTC(arrDate[0],arrDate[1],arrDate[2]);
			}
		}
		
        $('#container').highcharts({
            chart: {
                zoomType: 'x'
            },
            title: {
                text: 'Ratings'
            },
            subtitle: {
                text: document.ontouchstart === undefined ?
                        'Click and drag in the plot area to zoom in' : 'Pinch the chart to zoom in'
            },
            xAxis: {
                type: 'datetime'
            },
            yAxis: {
                title: {
                    text: 'Rating'
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

            series: [
			{
                type: 'line',
                name: 'Avg Since',
                data: result[0]
            }
			,
			{
                type: 'line',
                name: 'Avg Per Month',
                data: result[1]
            }
			]
        });
	});
}