function initChart(token) {
	var chartData = null;
	function redrawChart(rawChartData)
	{
		if (rawChartData && google.visualization)
		{
			chartData = new google.visualization.DataTable();
	
			chartData.addColumn('string', 'Timestamp');
			chartData.addColumn('number', 'Policy Down');
			chartData.addColumn('number', 'Policy Up');
	
			var idx, len = rawChartData.devices.length;
			for (idx = 0; idx < len; idx++) {
				chartData.addColumn('number', rawChartData.devices[idx].display_name);
			}
			chartData.addRows(rawChartData.rows);
		}
	
		if (!chartData) {
			return;
		}
	
		var chart = new google.visualization.AreaChart(document.getElementById('chart_div'));
		if (!chart) {
			return;
		}
	
		chart.draw(chartData, {
			legend: 'bottom', 
			backgroundColor: '#FCFCFC',
			areaOpacity: 1 / chartData.getNumberOfColumns(),
			hAxis: { textPosition: 'none', direction: -1 }, 
			vAxis: { minValue: 0, format: "#,### MB", textPosition: 'in' }, 
			chartArea: { top: 0, left: 0, height: "85%", width: "100%" }
		});
	}
	
	// jQuery function, called when page load is complete
	google.load('visualization', '1', {packages:["corechart"]});
	google.setOnLoadCallback(function() {
		$.ajax('/_api/' + token + '/report', {
			success: function(data) {
				redrawChart(JSON.parse(data));
			},
			error: function() {
				$('#chart_div .spinner').remove();
	
				var msgNode = $('#chart_div .loading')
				if (msgNode) {
					msgNode.text('Error Loading Chart Data');
				}
			}
		});
	});
	
	$(document).ready(function() {
		// when the window is resized, redraw the graph to the new size
		$(window).resize(function(event) {
			if ($('#chart_div').width() != $('#chart_div').children()[0].width)
				redrawChart();
		});	
	
		var scrapeButton = $('#force_scrape');
		scrapeButton.bind('click', function(event) {
			scrapeButton.attr('disabled', true);
			scrapeButton.attr('value', 'Hold on...');
			$.ajax({
				url: '/_api/' + token + '/report?scrape_first',
				success: function(data) {
					redrawChart(JSON.parse(data));
					scrapeButton.attr('disabled', false);
					scrapeButton.attr('value', '#{scrape_button_value}');
				},
				error: function() {
					scrapeButton.attr('disabled', false);
					scrapeButton.attr('value', 'Error: Scrape Failed');
				}
			});
		});
	});
}