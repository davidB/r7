define(['r7/evt'], function(evt){
  /**
   */
  return function(){
    var self = {};
    var _pending = [];
    var _tasks = [];   

    self.onEvent = function(e, out) {
      switch(e.k) {
        case 'RegisterPeriodicEvt':
          registerPeriodic(e);
          break;
        case 'UnRegisterPeriodicEvt' :
          unregisterPeriodic(e.id);
          break;
        case 'Render' :
          ping(e.t);
          break;
        default :
         // pass
      }
      evt.moveInto(_pending, out);
    };

    var registerPeriodic = function(e) {
      e.runAt = 0;
      _tasks.push(e);
    };

    var unregisterPeriodic = function(id) {
      //console.debug("unregister", id);
      _tasks = _tasks.filter(function(v) { return v.id !== id;});
    };

    // other implementation could be to use an array sort by runAt and only process runAt < t (like a priorityQueue)
    var ping = function(t) {
      _tasks.forEach( function(task) {
        if (task.runAt < t) {
          _pending.push(task.evt);
          task.runAt = t + task.interval;
        }
      });
    };
    return self;
  };

});

  

