var stackalytics = {};

stackalytics.createDrawFunction = function(ctx){
  return function(labels, datasets) {
    var lineChartData = {
      labels : labels,
      datasets : datasets
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
