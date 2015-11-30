#!/usr/bin/env ruby -wKU
require 'active_support'
require 'active_support/core_ext'
require 'open-uri'
require 'json'
require 'yaml'
require 'optparse'
require 'fileutils'

company = "NEC"
base_uri = "http://stackalytics.com/api/1.0/stats/engineers?release=mitaka&metric=commits&company=#{company}"

colors = [
  ["rgba(75, 178, 197, 1)", "rgba(75, 178, 197, 0.2)"],
  ["rgba(234, 162, 40, 1)", "rgba(234, 162, 40, 0.2)"],
  ["rgba(197, 180, 127, 1)", "rgba(197, 180, 127, 0.2)"],
  ["rgba(87, 149, 117, 1)", "rgba(87, 149, 117, 0.2)"],
  ["rgba(131, 149, 87, 1)", "rgba(131, 149, 87, 0.2)"],
  ["rgba(149, 140, 18, 1)", "rgba(149, 140, 18, 0.2)"],
  ["rgba(149, 53, 121, 1)", "rgba(149, 53, 121, 0.2)"],
  ["rgba(75, 93, 228, 1)", "rgba(75, 93, 228, 0.2)"],
  ["rgba(216, 184, 63, 1)", "rgba(216, 184, 63, 0.2)"],
  ["rgba(255, 88, 0, 1)", "rgba(255, 88, 0, 0.2)"],
]

ROOT = File.dirname(__FILE__)
tmp_dir = File.join(ROOT, '.tmp', company)
FileUtils.mkdir_p(tmp_dir)

opt = OptionParser.new
opt.on('-c', '--company') {|v| company = v }
opt.parse!(ARGV)

raw_data = {}
day = Time.new(2015, 10, 16, 0, 0, 0)

day = day + 7.days
while day < Time.now
  tmp_file = File.join(tmp_dir, day.to_i.to_s)
  if File.file?(tmp_file)
    data_uri = tmp_file
  else
    data_uri = "#{base_uri}&end_date=#{day.to_i}"
  end
  json_data = nil
  open(data_uri) do |io|
    json_data = io.read
    raw_data[day] = JSON.parse( json_data )
  end
  open(tmp_file, 'w') do |file|
    file.write( json_data )
  end
  day = day + 7.days
end

person_labels = []
person_map = {}
empty_data = []

raw_data.each do |k, v|
  person_labels << k.strftime("%y/%m/%d")
  v = v['stats']
  v.each do |person|
    id = person['id'].split('@')[0]
    metric = person['metric'].to_i
    person_map[id] = empty_data.dup unless person_map[id]
    person_map[id] << metric
  end
  empty_data << 0
end

person_map = person_map.sort_by{|_, v| - v.last }.to_h

html_path = File.join(ROOT, 'index.html')
open(html_path, 'w') do |io|
  io.write(ERB.new(DATA.read).result(binding))
end

__END__
<html>
<head>
  <meta name="viewport" content="width=device-width, initial-scale=1, maximum-scale=2" />
  <link href="css/bootstrap.min.css" rel="stylesheet" media="screen">
  <script src="http://code.jquery.com/jquery.js"></script>
  <script src="js/bootstrap.min.js"></script>
  <script src="js/Chart.min.js"></script>
  <title>Stackalytics.Chart</title>
  <style type="text/css">
  .chart_off {
    color: #cccccc;
  }
  </style>
  <script>
  var datasets = [
    <% person_map.each_with_index do |(id, metric), index| %>
      <% color = colors[index] || colors[9] %>
    {
      label: "<%= id %>",
      fillColor : "<%= color[1] %>",
      strokeColor : "<%= color[0] %>",
      pointColor : "<%= color[0] %>",
      pointStrokeColor : "#fff",
      pointHighlightFill : "#fff",
      pointHighlightStroke : "<%= color[0] %>",
      data : [ <%= metric.join(', ') %> ],
      chart_off: false
    },
    <% end %>
  ];
  var filterDatasets = function(id, chart_off) {
    var rtn = [];
    for(var i=0; i<datasets.length; i++) {
      if (datasets[i].label == id ) {
        datasets[i].chart_off = chart_off;
      }
      if (!datasets[i].chart_off) {
        rtn.push(datasets[i]);
      }
    }
    console.log(rtn);
    return rtn;
  };

  $(function() {
    <% person_map.each do |id, metric| %>
    var switcher = function() {
      var name = this.id;
      if (this.chart_off) {
        this.chart_off = false;
        $(this).removeClass("chart_off");
      } else {
        this.chart_off = true;
        $(this).addClass("chart_off");
      }
      draw(filterDatasets(name, this.chart_off));
    };
    $('#<%=id%>').click(switcher);
    <% end %>


    var ctx = document.getElementById("canvas").getContext("2d");
    var draw = function(datasets){
      var lineChartData = {
        labels : [<%= person_labels.map{|l| "\"#{l}\"" }.join(', ') %>],
        datasets : datasets
      }
      if (window.myLine) {
        window.myLine.destroy();
      }
      window.myLine = new Chart(ctx).Line(lineChartData, {
        bezierCurve: false,
        responsive: true
      });
    };
    draw(datasets);
  });
  </script>
</head>
<body>
<div class='container'>
  <div>
    <canvas id="canvas" height="1200" width="1600"></canvas>
  </div>
  <div>
    <table class='table table-hover'>
      <tr>
        <th></th>
        <th></th>
        <% person_labels.each do |label| %>
          <th><%= label %></th>
        <% end %>
      </tr>
      <% person_map.each_with_index do |(id, metric), index| %>
        <% color = colors[index] || colors[9] %>
      <tr id='<%=id%>'>
        <td style="background-color: <%= color[0] %>;">&nbsp;</td>
        <td class='name'><%= id %></td>
        <% metric.each do |m| %>
        <td class='metric'><%= m %></td>
        <% end %>
      </tr>
      <% end %>
    </table>
  </div>
</div>

</body>
</html>
