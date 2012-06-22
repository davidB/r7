define(['r7/evt'], function(evt){
  /**
   * @param {Element} container
   */
  return function(container){
    var self = {};
    var _container = container;
    var _shipId = null;
    var _pending = [];

    // use http://www.quirksmode.org/js/keys.html to test
    var _keys = {
      'boost' : 38, // up arrow
      'rotLeft' : 37, // left arrow
      'rotRight' : 39, //right arrow
      'fire' :  32//space
    };

    self.onEvent = function(e, out) {
      switch(e.k) {
        case 'SpawnShip' :
          bindShipControl(e.objId);
          break;
        default :
         // pass
      }
      evt.moveInto(_pending, out);
    };

    var onKeyDown = function(e) {
      switch(e.keyCode) {
        case _keys.boost : 
          _keys.boost = - _keys.boost;
          _pending.push(evt.BoostShipStart(_shipId));
          break;
        case _keys.rotLeft:
          _keys.rotLeft = - _keys.rotLeft;
          _pending.push(evt.RotateShipStart(_shipId, 1));
          break;
        case  _keys.rotRight:
          _keys.rotRight = - _keys.rotRight;
          _pending.push(evt.RotateShipStart(_shipId, -1));
          break;
      }
    };

    var onKeyUp = function(e) {
      var code = - e.keyCode;
      if (code === _keys.boost) {
        _keys.boost = - _keys.boost;
        _pending.push(evt.BoostShipStop(_shipId));
      } else if (code === _keys.rotLeft) {
        _keys.rotLeft = - _keys.rotLeft;
        _pending.push(evt.RotateShipStop(_shipId));
      } else if (code === _keys.rotRight) {
        _keys.rotRight = - _keys.rotRight;
        _pending.push(evt.RotateShipStop(_shipId));
      }
    };

    var bindShipControl = function(shipId) {
      _shipId = shipId;
      //container.onkeypress= this.onKeyDown;
      //container.onkeyup = this.onKeyUp;
      //Lib.document.onkeypress = onKeyDown;
      //var t : Dynamic = Lib.document; //_container;
      _container.addEventListener("keydown", onKeyDown, false);    
      _container.addEventListener("keyup", onKeyUp, false);    
    };

    return self;
  };

});

  

