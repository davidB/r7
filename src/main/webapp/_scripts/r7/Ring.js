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
  /**
   * @contructor
   * @param {Array.<function(*, Array}>} stages
   * @return {!Ring}
   */
  var Ring = function(stages){
    var self = {};
    /** @type {Array.<RingEntry>} */
    var noop = function(e, out) {};
    //pre-include noop as entry point for pushed event from outside
    var _ring = [noop].concat(stages).map(function(v){
      v.lastOut = [];
      return v;
    });    
    self.push = function(e) {
      _ring[0].lastOut.push(e);
      var nbEvents = 1;
      var i = 1;
      var lg = _ring.length;

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

