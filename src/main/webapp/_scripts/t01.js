      //d3.ns.prefix['sodipodi'] = 'http://sodipodi.sourceforge.net/DTD/sodipodi-0.dtd';
      //d3.ns.prefix['inkscape'] = 'http://www.inkscape.org/namespaces/inkscape';
      d3.xml("pointer2.svg", "image/svg+xml", function(xml) {
        // var importedNode = document.importNode(xml.documentElement, true);
        // d3.select("#viz").node().appendChild(importedNode);
        document.body.appendChild(xml.documentElement);
        d3.selectAll("#pointer").style("fill", "#9955FF").attr('transform', '');
        d3.selectAll("#pointer").attr("cx", "80");
        //var dx = 0;
        //var dy = 0;
        var _model = {};
        _model.dx = 0;
        _model.dy = 0;
        _model.powerMax = 100;

        var area = d3.select('#pointer_area');
        var pointer = d3.select('#pointer');
        var _view = {};
        _view.dx = 0;
        _view.dy = 0;
        _view.cy = parseFloat(area.attr('cx'));
        _view.cx = parseFloat(area.attr('cy'));
        _view.radius = parseFloat(area.attr('r'));
        
        var view2model = function(view, model) {
          model.dx = view.dx * model.powerMax / view.radius;
          model.dy = view.dy * model.powerMax / view.radius;
        };
        var model2view = function(model, view) {
          view.dx = model.dx * view.radius / model.powerMax;
          view.dy = model.dy * view.radius / model.powerMax;
        };

        var push = function(model) {
          //TODO notify eventBus about new values
          onUpdate(model);
        };

        var onUpdate= function(model) {
          //dx = Math.max(-radius, Math.min(radius, dx));
          //dy = Math.max(-radius, Math.min(radius, dy));
          model2view(model, _view);
          d3.select('#pointer')
            .attr("transform", function(d, i) {return  "translate(" + _view.dx + "," + _view.dy + ")"; })
          //  .data(_view)
          //  .transition()
          ;
        };
/*
        d3.select("#pointer_area").on('mousedown', function(d, i) {
          console.log(arguments);
          console.log(d3.mouse(this));
          var pos = d3.mouse(this);
          var area = d3.select(this);
          var pointerCx = parseFloat(area.attr('cx'));
          var pointerCy = parseFloat(area.attr('cy'));
          dx = pos[0] - pointerCx;
          dy = pos[1] - pointerCy;
          update();
        });
  */
        var dragstart = function(d, i) {
          var pos = d3.mouse(this);
          //var area = d3.select(this);
          //var pointerCx = parseFloat(area.attr('cx'));
          //var pointerCy = parseFloat(area.attr('cy'));
          var dx = pos[0] - _view.cx;
          var dy  = pos[1] - _view.cy;
          var c = _view.radius / Math.sqrt(Math.pow(dx,2) + Math.pow(dy, 2));
          if (c < 1) {
            //find the angle = atan(dy/dx)
            //&& Math.abs(dx) > _view.radius){
            //dx = _view.radius * Math.cos(angle);
            //dy = _view.radius * Math.sin(angle);
            
            dx = dx *c;
            dy = dy *c;
          }
          _view.dx = dx;
          _view.dy = dy;
          view2model(_view, _model);
          push(_model);
        };
        /*
        function dragmove(d, i) {
            dx += d3.event.dx;
            dy += d3.event.dy;
            update();
            //d3.select(this).attr("transform", "translate(" + d.x + "," + d.y + ")");
        }
        */
        var drag = d3.behavior.drag()
          .on("dragstart", dragstart)
          .on("drag", dragstart)
//          .on("dragend", dragend)
          ;
        console.log("starting", _view, pointer, area);
        pointer
        //  .transition()
//          .data(_view)
//          .enter()
          .attr("cx", function(d) { return _view.cx; })
          .attr("cy", function(d) { return _view.cy; })
          .attr("transform", function(d, i) {return  "translate(" + _view.dx + "," + _view.dy + ")"; })
        ;
        area
//          .data(_view)
        //  .transition()
          .attr("cx", function(d, i) { return _view.cx; })
          .attr("cy", function(d, i) { return _view.cy; })
          .attr("transform", null)
          .call(drag)
        ;
        /*
d3.select("#button_panel")
        .on("mousedown", function(d, i){
            data = generateData(5);
            d3.selectAll("rect.bar")
                .data(data)
                .transition()
                .call(setBarHeight);

        });
*/
      });
