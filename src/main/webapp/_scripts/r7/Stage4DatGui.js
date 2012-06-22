define(['dat', 'r7/evt', 'r7/timer'], function(dat, evt, timer) {
  return function () {
    var self = {};
    var _params = {};
    var _gui = new dat.GUI();
    var _pending = [];

    self.onEvent = function(e, out) {
      switch(e.k){
        case 'SetupDatGui' :
          e.setup(_gui);
          break;
/*        case 'ReplyValueOf' :
          if (e.ask.requester === self) {
            _params[e.ask.valueId] = e.value;
          }
          break;
*/         
        case 'Render' : 
          //manual  update of controlers can be resource consumming
          //see http://workshop.chromeexperiments.com/examples/gui/#10--Updating-the-Display-Manually
          // Iterate over all controllers
          for (var i in _gui.__controllers) {
            _gui.__controllers[i].updateDisplay();
          }
          break;
      }
      evt.moveInto(_pending, out);
    };

    //_params.scale = 0;
    return self;
  };

});


