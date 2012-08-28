/*
interface Stage<T> {
  public function onEvent(e : T, out : Array<T>) :Void;
}

class StageUtils {

  public static function pushAll<T>(out : Array<T>, it : Iterable<T>) : Void {
    for (i in it) {
      out.push(i);
    }
  }
}
*/
define([], function() {
  var pushNonEmpty = function() {
    for (var i = 0; i < arguments.length; i++) {
      var a = arguments[i];
      if (a === null || typeof a === 'undefined') {
        throw ('try to push invalid value ['  + i + '] : ' + a) ;
      }
    }
    return Array.prototype.push.apply(this,arguments);
  };
  
  /**
   * @param {Array.<function(*, Array)>} stages
   * @return {onEvent: function(*, Array<*>), push: function(*)}
   * //return {!Ring}
   */
  var Ring = function(stages){
    var self = {};
    //var noop = function(e, out) {};
    var forward = function(e, out) {
      if(forward.dest !== null) forward.dest.push(e);
    };
    forward.dest = [];
    //pre-include noop/forward as entry point for pushed event from outside
    var _ring = [forward].concat(stages).map(function(v){
      v.lastOut = [];
      v.lastOut.push = pushNonEmpty;
      return v;
    });    
    self.push = function(e) {
      self.onEvent(e, null);
    };
    self.onEvent = function(e, out) {
      _ring[0].dest = out; // for forward.method
      _ring[0].lastOut.push(e);
      var nbEvents = 1;
      var i = 1;
      var lg = _ring.length;

      if ( i >= lg) return;

      // process output of other stage until there is no event
      //TODO documentation : vs pipeline, vs bus, vs queue
      var guard_loopMax = 3 * lg;
      while(nbEvents > 0 && guard_loopMax > 0) {
        guard_loopMax--;

        var entryI = _ring[i];
        nbEvents -= entryI.lastOut.length;
        entryI.lastOut.length = 0; //inJS reset length to zero is better fot GC
        for(var j = (i+1) % lg; j !== i; j = (j + 1) % lg) {
          var entryJ = _ring[j];
          var lg2 = entryJ.lastOut.length;
          for (var ei = 0;  ei < lg2; ei++) {
            var evt = entryJ.lastOut[ei];
            if (evt === null || typeof evt === 'undefined') {
              console.warn("invalid evt", evt, ei, lg2, entryJ, entryJ.lastOut);
              continue;
            }
            try {
              entryI.call(entryI, evt, entryI.lastOut);
            } catch (exc) {
              console.error("failed to apply event", evt);
              if (console.exception) {
                console.exception(exc);
              } else {
                console.error(exc.message, exc.stack);
              }
            }
          }
        }
        nbEvents += entryI.lastOut.length;
        i = (i + 1) % lg;
      }
    };
    return self;
  };
  return Ring;
});

