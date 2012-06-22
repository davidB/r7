define(['Stats'], function(Stats) {
  return function (container) {
    var self = {};
    var _stats = new Stats();
    // Align top-left
    _stats.domElement.style.position = "absolute";
    _stats.domElement.style.left = "0px";
    _stats.domElement.style.top = "0px";

    //parentElement.appendChild( stats.domElement );
 
    container.appendChild( _stats.domElement );
    self.onEvent = function(e, out) {
      if (e.k === 'Render') {
        _stats.update();
      }
    };
    return self;
  };

});


