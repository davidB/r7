define(['r7/evt', 'r7/Position'], function(evt, Position){
  /**
   * @param {Element} container
   */
  return function(){
    var self = {};
    var _pending = [];
    var _states = {
    };


    self.onEvent = function(e, out) {
      switch(e.k) {
        case 'Start' :
          var uid = new Date().getTime();
          out.push(evt.SpawnCube());
          out.push(evt.SpawnArea("area/" + uid, 'area01', Position(0.0, 0.0, 0.0)));
          out.push(evt.SpawnShip("ship/" + (uid + 1), 'ship01', Position(0.0, 0.0, 0.5), null, true));
          break;
        case 'ReqEvt' :
          onReqEvent(e.e, out);
          break;
        case 'BeginContact' :
          console.log('contact', e);
          if (e.objId0.indexOf('area_') === 0) {
            if (e.objId1 === 'ship_') {
              // crash if no shield
            } else if (e.objId1.indexOf('ship-1-b') == 0) {
              // despawn bullet
            }
          } 
          //if (e.objId0 === 'ship/1' && e.objId1 === 'target-g1/1') {
            //TODO move some game rule from targetG1 here ?
            //out.push(incState('ship-1.score', 1));
          //}
          break;
        case 'Render' :
          // if boost decrease energy
          // if shield decrease energy
          // else increase energy
          // if no energy, stop boost, shield,...
          break;
        default :
         // pass
      }
      evt.moveInto(_pending, out);
    };

    var onReqEvent = function(e, out) {
      switch(e.k) {
        case 'UpdateVal':
          //ignore
          break;
        case 'IncVal':
          if (e.key === 'ship1_score') {   
            out.push(incState(e.key, e.inc));
          }
          break;
        default:
          out.push(e);
      }
    };

    var incState = function(k, i) {
      _states[k](_states[k]() += i);
      return evt.UpdateVal(k, _states[k]());
    };

    var updateState = function(k, v) {
      _states[k](v);
      return evt.UpdateVal(k, v);
    };
    return self;
  };

});

  

