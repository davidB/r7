define(['r7/evt'], function(evt) {
  /**
   * @param {number} min
   * @param {number} max
   */
  var randomFloat = function(min, max) {
    return Math.random() * (max - min) + min;
  };

  /**
   * @param {Timestamp} t
   * @param {Id} objId
   * @param {Number} level
   */
  var newImpule = function(t, objId, level) {
    return evt.ImpuleObj(
      t,
      objId,
      randomFloat(-pi, pi), //radian
      randomFloat(10, 50) //TODO include level in the formula
    );
  };

  return function() {
    var self = {};
    var _value : Int = 1; //getter for display
    var _objId : Id = "g1/obj/1";
    var _timeoutAt : Timestamp = -1;

    self.onEvent = function(e, out) {
      switch(e.k) {
      //TODO case SpawnTargetG1(....) start...
      case 'Collision' :
        if (e.objId === _objId) {
          onHit(t, shipId);
        }
        break;
      case 'Render' :
        if (e.t >= _timeoutAt && _timeoutAt > 0) {
          out.push.apply(out, onTimeout(t));
        }
        break;
      default :
         //pass
      }
    };
    
    var onStart = function() {
      _value = 1;
    };

    var onHit = function(t, shipId) {
      var back = [];
      back.push(evt.ScoreG1Add(t, shipId, _value));
      _value += 1;
      back.push(requestMvt(t));
      return back;
    };

    var onTimeout = function(t) {
      _value = Math.max(1, _value - 10);
      return [requestMvt(t)];
    };

    var requestMvt = function() {
      return newMovement(t, _objId, _value / 10);
    }
    
    return self;
  };
  //TODO time countdown
});
