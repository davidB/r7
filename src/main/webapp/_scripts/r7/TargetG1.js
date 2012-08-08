define(['r7/evt', 'r7/Position'], function(evt, Position) {
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
  var newImpulse = function(objId, level) {
    return evt.ImpulseObj(
      objId,
      randomFloat(-Math.PI, Math.PI), //radian
      randomFloat(1, 5)/10 //TODO include level in the formula
    );
  };

  return function() {
    var self = {};
    var _value  = 1; //getter for display
    var _timeoutAt = -1;
    var _shipId = '!';
    var _targetG1Id = 'target-g1/' + (new Date().getTime());

    self.onEvent = function(e, out) {
      switch(e.k) {
      case 'SpawnShip' :
        if (e.isLocal && _shipId === '!') {
          _shipId = e.objId;
          out.push(evt.SpawnTargetG1(_targetG1Id, 'targetg101', Position(0.0, 0.0, 1.0))); //TODO random position near ship
        }
        break;
      case 'BeginContact' :
        if (e.objId0 === _shipId && e.objId1.indexOf('target-g1/') === 0) {
          evt.moveInto(onHit(e.objId0), out);
        }
        break;
      case 'Tick' :
        if (e.t >= _timeoutAt && _timeoutAt > 0) {
          evt.moveInto(onTimeout(), out);
        }
        break;
      default :
         //pass
      }
    };
    
    var onStart = function() {
      _value = 1;
    };

    var onHit = function(shipId) {
      var back = [];
      back.push(evt.ReqEvt(evt.IncVal(shipId + '/score', _value)));
      //_value += 1;
      back.push(requestMvt());
      return back;
    };

    var onTimeout = function() {
      console.log("TIMEOUT");
      _value = Math.max(1, _value - 10);
      return [requestMvt()];
    };

    var requestMvt = function() {
      return newImpulse(_targetG1Id, _value / 10);
    };
    
    return self;
  };
  //TODO time countdown
});
