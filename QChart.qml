/* QChart.qml ---
 *
 * Author: Julien Wintz
 * Created: Thu Feb 13 20:59:40 2014 (+0100)
 * Version:
 * Last-Updated: jeu. mars  6 12:55:14 2014 (+0100)
 *           By: Julien Wintz
 *     Update #: 69
 */

/* Change Log:
 *
 */

import QtQuick 2.0

import "QChart.js" as Charts

Canvas {

  id: canvas;

// ///////////////////////////////////////////////////////////////

  property   var chart;
  property   var chartData;
  property   int chartType: 0;
  property  bool chartAnimated: true;
  property alias chartAnimationEasing: chartAnimator.easing.type;
  property alias chartAnimationDuration: chartAnimator.duration;
  property   int chartAnimationProgress: 0;
  property   var chartOptions: ({});

  property   var events: ({}); /* internal use */

// /////////////////////////////////////////////////////////////////
// Callbacks
// /////////////////////////////////////////////////////////////////

  onPaint: {
      if(!chart) {

          switch(chartType) {
          case Charts.ChartType.BAR:
              chart = new Charts.Chart(canvas.getContext("2d")).Bar(chartData, chartOptions);
              break;
          case Charts.ChartType.DOUGHNUT:
              chart = new Charts.Chart(canvas.getContext("2d")).Doughnut(chartData, chartOptions);
              break;
          case Charts.ChartType.LINE:
                          console.log("here")
              chart = new Charts.Chart(canvas.getContext("2d")).Line(chartData, chartOptions);
              break;
          case Charts.ChartType.PIE:
              chart = new Charts.Chart(canvas.getContext("2d")).Pie(chartData, chartOptions);
              break;
          case Charts.ChartType.POLAR:
              chart = new Charts.Chart(canvas.getContext("2d")).PolarArea(chartData, chartOptions);
              break;
          case Charts.ChartType.RADAR:
              chart = new Charts.Chart(canvas.getContext("2d")).Radar(chartData, chartOptions);
              break;
          default:
              console.log('Chart type should be specified.');
          }

          if (chartAnimated)
              chartAnimator.start();
          else
              chartAnimationProgress = 100;
      }

      if (!chartAnimator.running && events.mouseout) {
          var cb = eventCallback("mouseout")
          if (cb)
              cb(events.mouseout);
          events.mouseout = null;
          events.mousemove = null;
      }
      else if (!chartAnimator.running && events.mousemove) {
          var cb = eventCallback("mousemove")
          if (cb)
              cb(events.mousemove);
          events.mousemove = null;
          chartAnimationProgress = 100;
      }
      else {
          // On some charts 0 draws the full picture, negative values is always buggy
          chart.draw((chartAnimationProgress > 0) ?
                  chartAnimationProgress/100 : 0.0001);
      }
  }

  onHeightChanged: {
    requestPaint();
  }

  onWidthChanged: {
    requestPaint();
  }

  onChartAnimationProgressChanged: {
      requestPaint();
  }

  onChartDataChanged: {
      requestPaint();
  }

// /////////////////////////////////////////////////////////////////
// Functions
// /////////////////////////////////////////////////////////////////

  function repaint() {
      chartAnimationProgress = 0;
      chartAnimator.start();
  }

  function addEventListener(eventType, method) {
      /* empty function that must exist on the canvas (called by Chart.js) */
  }

  function getBoundingClientRect() {
    return {
      left: 0,
       top: 0,
     right: canvasWindow.width,
    bottom: canvasWindow.height
    }
  }

  function eventCallback(name) {
      if (chart && chart.events) {
          return chart.events[name];
      }
      return null;
  }
// /////////////////////////////////////////////////////////////////
// Internals
// /////////////////////////////////////////////////////////////////
  MouseArea {
    id: mouseArea;
    anchors.fill: parent;
    hoverEnabled: true;
    onPositionChanged: {
      if (parent.eventCallback("mousemove")) {
        parent.events.mousemove = {
                type: 'mousemove',
             clientX: mouse.x,
             clientY: mouse.y,
          srcElement: parent
        };
        parent.requestPaint();
      }
    }

    onExited: {
      if (parent.eventCallback("mouseout")) {
        parent.events.mousemove = {
                type: 'mouseout',
          srcElement: parent
        };
        parent.requestPaint();
      }
    }
  }

  PropertyAnimation {
             id: chartAnimator;
         target: canvas;
       property: "chartAnimationProgress";
             to: 100;
       duration: 500;
    easing.type: Easing.InOutElastic;
  }
}
