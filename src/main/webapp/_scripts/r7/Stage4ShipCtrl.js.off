package r7;

import js.Lib;
import js.Dom;
import js.d3.D3;
import r7.Stage;
import r7.Event;

using Lambda;
using r7.Stage.StageUtils;

class Stage4ShipCtrl implements Stage<Evt> {
  private var _pending : List<Evt>; // concurrent access !!
  private var _shipId : Id;
  private var _container: HtmlDom;

  public function new(container: HtmlDom) {
    _container = container;
    _pending = new List<Evt>();
  }

  public function onEvent(e : Evt, out : Array<Evt>) {
    switch(e) {
      case SpawnArea(t, areaId, model) :
        //trace("create area in renderer");
      case SpawnShip(t, shipId, model, pos) :
        bindShipControl(shipId);
     default :
       // pass
    }
    if (_pending.length > 0) {
      var p = _pending;
      _pending = new List<Evt>();
      out.pushAll(p);
    }
  }

  function bindShipControl(shipId) {
    _shipId = shipId;
    //container.onkeypress= this.onKeyDown;
    //container.onkeyup = this.onKeyUp;
    //Lib.document.onkeypress = onKeyDown;
    displayCtrl();
  }

  function displayCtrl() {

      //d3.ns.prefix['sodipodi'] = 'http://sodipodi.sourceforge.net/DTD/sodipodi-0.dtd';
      //d3.ns.prefix['inkscape'] = 'http://www.inkscape.org/namespaces/inkscape';
      D3.xml("/_images/pointer2.svg", "image/svg+xml", function(xml) {
        if (xml == null) {
          //TODO log, notify user
          return;
        }

        // var importedNode = document.importNode(xml.documentElement, true);
        // d3.select("#viz").node().appendChild(importedNode);
        _container.appendChild(xml.documentElement);

        var _model_dx = 0.0;
        var _model_dy = 0.0;
        var _model_powerMax = 100.0;

        var area = D3.select("#pointer_area");
        var pointer = D3.select("#pointer");
        var _view_dx = 0.0;
        var _view_dy = 0.0;
        var _view_cx = parseFloat(area.attr("cx"));
        var _view_cy = parseFloat(area.attr("cy"));
        var _view_radius = parseFloat(area.attr("r"));


        function d_view2model(v) {
          return v * _model_powerMax / _view_radius;
        }
        function d_model2view(v) {
          return v * _view_radius / _model_powerMax;
        };

        function push(model_dx, model_dy) {
          //TODO notify eventBus about new values
          onUpdate(model_dx, model_dy);
        };

        function onUpdate(model_dx, model_dy) {
          //dx = Math.max(-radius, Math.min(radius, dx));
          //dy = Math.max(-radius, Math.min(radius, dy));
          _view_dx = d_model2view(model_dx);
          _view_dy = d_model2view(model_dy);
          D3.select('#pointer')
            .attr("transform", function(d, i) {return  "translate(" + _view_dx + "," + _view_dy + ")"; })
          //  .data(_view)
          //  .transition()
          ;
        };
        function dragstart(d, i) {
          var pos = D3.mouse(area); //TODO this should bind
          //var area = d3.select(this);
          //var pointerCx = parseFloat(area.attr('cx'));
          //var pointerCy = parseFloat(area.attr('cy'));
          var dx = pos[0] - _view_cx;
          var dy  = pos[1] - _view_cy;
          var c = _view_radius / Math.sqrt(Math.pow(dx,2) + Math.pow(dy, 2));
          if (c < 1) {
            //find the angle = atan(dy/dx)
            //&& Math.abs(dx) > _view.radius){
            //dx = _view.radius * Math.cos(angle);
            //dy = _view.radius * Math.sin(angle);
            
            dx = dx *c;
            dy = dy *c;
          }
          _view_dx = dx;
          _view_dy = dy;
          push(d_view2model(dx), d_view2model(dy));
        };
        var drag = D3.behavior.drag()
          .on("dragstart", dragstart)
          .on("drag", dragstart)
//          .on("dragend", dragend)
          ;
//        console.log("starting", _view, pointer, area);
        pointer
          .style("fill", "#9955FF")
          .attr("cx", function(d) { return _view_cx; })
          .attr("cy", function(d) { return _view_cy; })
          .attr("transform", function(d, i) {return  "translate(" + _view_dx + "," + _view_dy + ")"; })
        ;
        area
          .attr("cx", function(d, i) { return _view_cx; })
          .attr("cy", function(d, i) { return _view_cy; })
          .attr("transform", null)
          .call(drag)
        ;

      });
  }
}
