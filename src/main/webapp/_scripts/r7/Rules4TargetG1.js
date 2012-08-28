define(['r7/evt', 'r7/Position'], function(evt, Position) {
  /**
   * @param {number} min
   * @param {number} max
   */
  var randomFloat = function(min, max) {
    return Math.random() * (max - min) + min;
  };

  /**
   * @param {{x: number, y: number}} pos0
   * @param {number} level
   */
  var nextPositionFactory = function(pos0, level) {
    var a0 = randomFloat(-Math.PI, Math.PI); //radian
    var d0 = 0;
    var tryCt = -1;
    var tryLg = 10;
    return function() {
      tryCt++;
      tryCt = tryCt % tryLg;
      if (tryCt === 0) {
        d0 = 0;
        //randomFloat(1, 5)/10 //TODO include level in the formula
      }
      var a = a0 + (tryCt * Math.PI * 2 / tryLg);
      return Position(pos0.x + d0 * Math.cos(a), pos0.y + d0 * Math.sin(a), pos0.a);
    };
  };

  return function() {
    var self = {};
    var _value  = 1; //getter for display
    var _timeoutAt = -1;
    var _targetG1Id = 'target-g1/' + (new Date().getTime());
    var _lastPos0 = null;

    self.onEvent = function(e, out) {
      switch(e.k) {
      case 'SpawnShip' :
//        console.log(e, _lastPos0);
        if (e.isLocal && _lastPos0 === null) {
          _lastPos0 = e.pos;
          onAutoEvent(evt.SpawnTargetG1(_targetG1Id, 'targetg101', nextPositionFactory(_lastPos0, _value)), out);
          //TODO random position near ship
        }
        break;
      case 'SpawnTargetG1':
        if (e.pos !== null) _lastPos0 = e.pos;
        onAutoEvent(evt.StartCountdown(_targetG1Id + '/countdown', 5, {k : 'TargetG1.Timeout'}), out);
        break;
      case 'TargetG1.Timeout' :
        onTimeout(out);
        break;
      case 'BeginContact' :
        if (e.objId0.indexOf('ship/') === 0 && e.objId1.indexOf('target-g1/') === 0) {
          onHit(e.objId0, out);
        }
        break;
      default :
         //pass
      }
    };
    
    var onAutoEvent = function(e, out) {
      if (e !== null) {
        out.push(e);
        self.onEvent(e, out);
      }
    };

    var onHit = function(shipId, out) {
      onAutoEvent(evt.StopCountdown(_targetG1Id + '/countdown'), out);
      onAutoEvent(evt.IncVal(shipId + '/score', _value), out);
      onAutoEvent(evt.DespawnObj(_targetG1Id), out);
      _value += 1;
      onAutoEvent(evt.UpdateVal(_targetG1Id + '/value', _value), out);
      onAutoEvent(evt.SpawnTargetG1(_targetG1Id, 'targetg101', nextPositionFactory(_lastPos0, _value)), out);
    };

    var onTimeout = function(out) {
      console.log("TIMEOUT");
      onAutoEvent(evt.DespawnObj(_targetG1Id), out);
      _value = Math.max(1, _value - 10);
      onAutoEvent(evt.UpdateVal(_targetG1Id + '/value', _value), out);
      onAutoEvent(evt.SpawnTargetG1(_targetG1Id, 'targetg101', nextPositionFactory(_lastPos0, _value)), out);
    };

    return self;
  };
  //TODO time countdown
});
