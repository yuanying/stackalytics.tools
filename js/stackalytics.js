var stackalytics = {};

stackalytics.createDrawFunction = function(ctx){
  return function(labels, datasets) {
    var _datasets = [];
    for (var i=0; i<datasets.length; i++) {
      data = datasets[i];
      if (!data.chart_off) {
        _datasets.push(data);
      }
    }
    // _datasets = datasets;
    var lineChartData = {
      labels : labels,
      datasets : _datasets
    }
    if (ctx.myLine) {
      ctx.myLine.destroy();
    }
    ctx.myLine = new Chart(ctx).Line(lineChartData, {
      bezierCurve: false,
      responsive: true
    });
  };
};
