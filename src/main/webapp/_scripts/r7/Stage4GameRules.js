define(['r7/evt', 'r7/Position'], function(evt, Position){
  /**
   * @param {Element} container
   */
  return function(){
    var self = {};
    var _pending = [];
    _pending.push0 = _pending.push;
    _pending.push = function(i) {
      if (i === null || typeof i === 'undefined') {
        throw new Exception("try to push :"  +i);
      }
      _pending.push0(i);
    };
    var _shipId = '!';
    var _states = {
    };
    var _lastSeconde = -1;


    self.onEvent = function(e, out) {
      switch(e.k) {
        case 'Init' :
          var uid = new Date().getTime();
          out.push(evt.SpawnCube());
          out.push(evt.SpawnArea("area/" + uid, 'area01', Position(0.0, 0.0, 0.0)));
          _shipId = 'ship/' + (uid + 1);
          out.push(evt.SpawnShip(_shipId, 'ship01', Position(0.0, 0.0, 0.5), null, true));
          updateState('running', false);
          break;
        case 'Start' :
          updateState(_shipId + '/energy', 500);
          updateState(_shipId + '/energyMax', 1000);
          updateState(_shipId + '/boosting', false);
          updateState(_shipId + '/shooting', false);
          updateState(_shipId + '/shielding', false);
          updateState('countdown', 45);
          updateState('running', true);
          out.push(evt.Render);
          break;
        case 'ReqEvt' :
          onReqEvent(e.e);
          break;
        case 'BeginContact' :
          console.log('contact', e);
          if (e.objId0.indexOf('area/') === 0) {
            if (e.objId1.indexOf('ship/') === 0) {
              // crash if no shield
            } else if (e.objId1.indexOf('ship/1-b') === 0) {
              // despawn bullet
            }
          } 
          //if (e.objId0 === 'ship/1' && e.objId1 === 'target-g1/1') {
            //TODO move some game rule from targetG1 here ?
            //out.push(incState('ship-1.score', 1));
          //}
          break;
        case 'Tick' :
          if (_lastSeconde === -1) {
            _lastSeconde = e.t;
          } else {
            var delta = (e.t - _lastSeconde) / 500;
            if (delta >=  1) {
              _lastSeconde = e.t;
              if (_states.running) {
                console.log("t", _lastSeconde, delta);
                decCountdown(delta/2);
                updateEnergy(delta);
              }
            }
          }
          // if boost decrease energy
          // if shield decrease energy
          // else increase energy
          // if no energy, stop boost, shield,...
          break;
        case 'Stop':
          updateState('running', false);
          break; 
        default :
         // pass
      }
      evt.moveInto(_pending, out);
    };

    var onReqEvent = function(e) {
      switch(e.k) {
        case 'UpdateVal':
          _pending.push(e);
          onUpdateState(e.key, e.value);
          //ignore
          break;
        case 'IncVal':
          if (e.key.indexOf(_shipId) === 0) {   
            incState(e.key, e.inc);
          }
          break;
        case 'BoostShipStart' :
          _pending.push(e);
          if (e.objId === _shipId) updateState(_shipId + '/boosting', true);
          break;
        case 'BoostShipStop':
          _pending.push(e);
          if (e.objId === _shipId) updateState(_shipId + '/boosting', false);
          break;
        case 'ShootingStart' :
          _pending.push(e);
          if (e.emitterId === _shipId) _pending.push(evt.RegisterPeriodicEvt(_shipId + '-fire', 300, evt.ReqEvt(evt.FireBullet(_shipIdi))));
          break; 
        case 'ShootingStop' :
          _pending.push(e);
          if (e.emitterId === _shipId) _pending.push(evt.UnRegisterPeriodicEvt(_shipId + '-fire'));
          break;
        case 'FireBullet' :
          if (e.emitterId !== _shipId) {
            _pending.push(e);
          } else {
            if (_states[_shipId + '/energy'] > 7) {
              incState(_shipId + '/energy', -7);
              _pending.push(e);
            }
          }
        default:
          _pending.push(e);
      }
    };

    var incState = function(k, i) {
      updateState(k, _states[k] + i);
    };

    var updateState = function(k, v) {
      _states[k] = v;
      onReqEvent(evt.UpdateVal(k, v));
    };

    //TODO make testcase
    var decCountdown = function(delta) {
      var k = 'countdown';
      var v = _states[k];
      v = Math.max(0, v - delta);
      updateState(k, v);
    };

    var onUpdateState = function(k, v) {
      if (k === 'countdown' && v === 0 && _states.running) {
        onReqEvent(evt.Stop);
      } else if (k === _shipId + '/energy' && v === 0) {
        if (_states[_shipId + '/boosting']) onReqEvent(evt.BoostShipStop(_shipId));
      }
    };

    var updateEnergy = function(delta) {
      var k = _shipId+ '/energy';
      var v = _states[k];
      var unit = 0;
      if (_states[_shipId + '/boosting']) unit -= 5; 
      //if (_states[_shipId + '/shooting']) unit -= 7;
      if (_states[_shipId + '/shielding']) unit -= 10;
      if (unit === 0) unit += 3;
      v = Math.min(_states[k + 'Max'], Math.max(0, v + unit));
      updateState(k, v);
    };
    return self;
  };


});

  

