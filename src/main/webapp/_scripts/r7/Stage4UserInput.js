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
    var _keys = [
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
        start : function(){ return evt.RegisterPeriodicEvt(_shipId + '-fire', 300, evt.ReqEvt(evt.FireBullet(_shipId))); },
        stop :  function(){ return evt.UnRegisterPeriodicEvt(_shipId + '-fire'); }
      }
    ];

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

    return self;
  };

});

  

