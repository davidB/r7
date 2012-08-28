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
    var _keysNone = [];
    var _keysUser = [
      {
        code : 38, // up arrow
        start : function(){ return evt.ReqEvt(evt.BoostShipStart(_shipId)); },
        stop : function(){ return evt.ReqEvt(evt.BoostShipStop(_shipId)); }
      },
      {
        code : 37, // left arrow
        start : function(){ return evt.ReqEvt(evt.RotateShipStart(_shipId, 1)); },
        stop : function() { return evt.ReqEvt(evt.RotateShipStop(_shipId)); }
      },
      {
        code : 39, //right arrow
        start : function(){ return evt.ReqEvt(evt.RotateShipStart(_shipId, -1)); },
        stop : function() { return evt.ReqEvt(evt.RotateShipStop(_shipId)); }
      },
      {
        code :  32,//space
        start : function(){ return evt.ReqEvt(evt.ShootingStart(_shipId)); },
        stop :  function(){ return evt.ReqEvt(evt.ShootingStop(_shipId)); }
      }
    ];
    var _keys = _keysNone;

    self.onEvent = function(e, out) {
      switch(e.k) {
        case 'Stop' :
        case 'Init' :
          diseableControl();
          break;
        case 'Start' :
          _keys = _keysUser;
          break;
        case 'SpawnShip' :
          if (e.isLocal) bindShipControl(e.objId);
          break; 
        default :
         // pass
      }
      evt.moveInto(_pending, out);
    };

    var onKeyDown = function(e) {
      _keys.forEach(function(key){
        if (key.code === e.keyCode) {
          key.code = -key.code;
          _pending.push(key.start());
        }
      });
    };

    var onKeyUp = function(e) {
      _keys.forEach(function(key){
        if (key.code === - e.keyCode) {
          key.code = -key.code;
          _pending.push(key.stop());
        }
      });
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

    var diseableControl = function() {
      _keys.forEach(function(key){
        if (key.code < 0) {
          key.code = -key.code;
          _pending.push(key.stop());
        }
      });
      _keys = _keysNone;
    };
    return self;
  };

});

  

