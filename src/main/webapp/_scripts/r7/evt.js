define([], function() {
  /**
   * @constructor
   * @return {evt}
   */
  return {
    moveInto : function(src, target) {
      if (src.length > 0) {
        target.push.apply(target,src);
        src.length = 0;
      }
    },
    Start: function() { return {k : 'Start'}; },
    Render: function(t) { return {k : 'Render', t: t}; },
    /**
     * @param {Id} valueId
     * @param {Object} requester
     * @param {=function(T) => T | null} newValue
     */
    AskValueOf: function(valueId, requester, newValue){return {k: 'AskValueOf', valueId : valueId, requester : requester, newValue : newValue};},
    /**
     * @param {*} value
     * @param {AskValueOf} ask
     */
    ReplyValueOf: function(t, value, ask){return {k: 'ReplyValueOf', value : value, ask : ask};},
    SpawnArea:     function(objId, modelId, pos, scene3d){ return {k: 'SpawnArea',     objId : objId, modelId : modelId, pos : pos, scene3d : scene3d};},
    SpawnShip:     function(objId, modelId, pos, obj3d){ return {k: 'SpawnShip',     objId : objId, modelId : modelId, pos : pos, obj3d : obj3d};},
    SpawnTargetG1: function(objId, modelId, pos, obj3d){ return {k: 'SpawnTargetG1', objId : objId, modelId : modelId, pos : pos, obj3d : obj3d};},
    SpawnCube: function(){return {k: 'SpawnCube'};},
    MoveObjTo: function(objId, pos, acc){return {k: 'MoveObjTo', objId : objId, pos : pos, acc : acc};}, 
    SetupDatGui: function(setup){ return {k: 'SetupDatGui', setup : setup};},
    BoostShipStop: function(objId) {return {k: 'BoostShipStop', objId: objId};},
    BoostShipStart: function(objId) {return {k: 'BoostShipStart', objId: objId};},
    RotateShipStart: function(objId, angleSpeed) {return {k: 'RotateShipStart', objId : objId, angleSpeed : angleSpeed};},
    RotateShipStop: function(objId) {return {k: 'RotateShipStop', objId: objId};},
    Stop: function() { return {k : 'Stop'}; },
  };
});

/*
 

enum Event {
  RequestDirectShip(t : Timestamp, shipId : Id, acc : Acceleration);
  SpawnBullet(t : Timestamp, model : BulletModel, fromShipId : Id);
  ScoreG1Add(t: Timestamp, shipId : Id, inc : Int);
  TimeoutTriger(t : Timestamp, triggerId : Id, requester : Dynamic); 
  ImpulseObj(t : Timestamp, objId : Id, angle : Float, force : Float);
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
