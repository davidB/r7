define([], function() {
  /**
   * @constructor
   * @return {evt}
   */
  var evt = {
    Init: {k : 'Init'},
    Start: {k : 'Start'},
    Tick: function(t, delta500) { return {k : 'Tick', t: t, delta500 : (delta500 === 0) ? 0 : (delta500 || null)}; },
    Render: {k : 'Render'},
    UpdateVal: function(key, value){return {k: 'UpdateVal', key : key, value : value};},
    IncVal: function(key, inc){return {k: 'IncVal', key : key, inc : inc};},
    ReqEvt: function(e) { return {k: 'ReqEvt', e : e};},
    UnRegisterPeriodicEvt: function(id){ return {k: 'UnRegisterPeriodicEvt', id : id};},
    RegisterPeriodicEvt: function(id, interval, evt){ return {k: 'RegisterPeriodicEvt', id : id, interval : interval,  evt : evt};},
    StartCountdown: function(key, timeout, timeoutEvt){ return {k: 'StartCountdown', key : key, timeout : timeout, timeoutEvt : timeoutEvt};},
    StopCountdown: function(key){ return {k: 'StopCountdown', key : key};},
    SpawnArea:     function(objId, modelId, pos, scene3d){ return {k: 'SpawnArea',     objId : objId, modelId : modelId, pos : pos, scene3d : scene3d};},
    SpawnShip:     function(objId, modelId, pos, obj3d, isLocal){ return {k: 'SpawnShip',     objId : objId, modelId : modelId, pos : pos, obj3d : obj3d, isLocal : isLocal};},
    SpawnTargetG1: function(objId, modelId, pos, obj3d){ return {k: 'SpawnTargetG1', objId : objId, modelId : modelId, pos : pos, obj3d : obj3d};},
    SpawnCube: function(){return {k: 'SpawnCube'};},
    ShootingStart: function(emitterId) { return {k: 'ShootingStart', emitterId : emitterId}; },
    ShootingStop: function(emitterId) { return {k: 'ShootingStop', emitterId : emitterId}; },
    FireBullet: function(emitterId) { return {k: 'FireBullet', emitterId : emitterId}; },
    SpawnObj: function(objId, modelId, pos, obj3d) { return {k: 'SpawnObj', objId : objId, modelId : modelId, pos : pos, obj3d : obj3d }; },
    DespawnObj: function(objId) { return { k : 'DespawnObj', objId : objId};},
    MoveObjTo: function(objId, pos, acc){return {k: 'MoveObjTo', objId : objId, pos : pos, acc : acc};}, 
    SetupDatGui: function(setup){ return {k: 'SetupDatGui', setup : setup};},
    BoostShipStop: function(objId) {return {k: 'BoostShipStop', objId: objId};},
    BoostShipStart: function(objId) {return {k: 'BoostShipStart', objId: objId};},
    RotateShipStart: function(objId, angleSpeed) {return {k: 'RotateShipStart', objId : objId, angleSpeed : angleSpeed};},
    RotateShipStop: function(objId) {return {k: 'RotateShipStop', objId: objId};},
    BeginContact: function(objId0, objId1) {return {k: 'BeginContact', objId0 : objId0, objId1 : objId1};},
    EndContact: function(objId0, objId1) {return {k: 'EndContact', objId0 : objId0, objId1 : objId1};},
    ImpulseObj: function(objId, angle, force) {return {k: 'ImpulseObj', objId : objId, angle: angle, force : force};},
    Stop: {k : 'Stop'}
  };

  evt.moveInto = function(src, target) {
    if (src.length > 0) {
      target.push.apply(target, src);
      src.length = 0;
    }
  };
  evt.newListOfEvt = function() {
    var b = [];
    b.push = function(i) {
      if (i === null || typeof i === 'undefined') {
        throw ('try to push invalid value (empty) ['  + i + '] : ') ;
      }
      if (i.k === null || typeof i.k === 'undefined') {
        throw ('try to push invalid value (no kind .k)['  + i + '] : ' + i.k) ;
      }
      return Array.prototype.push.apply(this,arguments);
    };
    return b;
  };
  evt.newStates = function() {
    var s = {};
    s.update = function(out, k, v, onUpdateState) {
      if (s[k] !== v) {
        s[k] = v;
        out.push(evt.UpdateVal(k, v));
        if (onUpdateState !== null) onUpdateState(out, k, v);
      }
    };
    s.inc = function(out, k, i, onUpdateState) {
      s.updateState(out, k, s[k] + i, onUpdateState);
    };
    return s;
  };
  evt.extractK = function(out, k, objIdPart) {
    return out.filter(function(v) { 
      var b = (v.k === k);
      b = b && (typeof objIdPart === 'undefined' || objIdPart === null || (v.objId.indexOf(objIdPart) > -1)) ;
      return b;
    });
  };
  return evt;
});

/*
 

enum Event {
  RequestDirectShip(t : Timestamp, shipId : Id, acc : Acceleration);
  SpawnBullet(t : Timestamp, model : BulletModel, fromShipId : Id);
  ScoreG1Add(t: Timestamp, shipId : Id, inc : Int);
  TimeoutTriger(t : Timestamp, triggerId : Id, requester : Dynamic); 
}

class Timer {
  public function new() {}

  public function t() : Timestamp {
    return Date.now().getTime(); 
  }
}
typedef Id = String;
typedef Timestamp = Float;
typedef AreaModel = String;
typedef ShipModel = Int;
typedef BulletModel = Int;
typedef Evt = Event; //To avoid collision with js.Event
*/
