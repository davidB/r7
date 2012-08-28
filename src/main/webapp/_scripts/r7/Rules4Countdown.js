define(['r7/evt'], function(evt){
  return function(){
    var self = {};
    var _tasks = {};
    var _states = evt.newStates();

    var onUpdateState = function(out, k, v) {
      if (v === 0) {
        var t = _tasks[k];
        if (t !== null && typeof t !== 'undefined') {
          if (_tasks[k].timeoutEvt !== null) {
            out.push(_tasks[k].timeoutEvt);
          }
          delete _tasks[k];
          delete _states[k];
        }
      }
    };

    var decCountdown = function(out, delta) {
      for(var key in _tasks) {
        var v = _states[key];
        v = Math.max(0, v - delta);
        _states.update(out, key, v, onUpdateState);
      }
    };

    self.onEvent = function(e, out) {
      switch(e.k) {
        case 'StartCountdown' :
          _tasks[e.key] = e;
          _states.update(out, e.key, e.timeout, onUpdateState);
          break;
        case 'Tick' :
          if (e.delta500 > 0){
            //console.debug("t", _lastSeconde, delta);
            decCountdown(out, e.delta500/2);
          }
          break;
        default :
         // pass
      }
    };

    return self;
  };

});

