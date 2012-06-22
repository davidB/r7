define(['r7/evt', 'r7/Position'], function(evt, Position) {
  var sut = evt;
  /** @type {Timestamp}*/
  var t = 0;
  var id = "any-0";
  var model = "any_00";
  var requester = 'jasmine';
  var pos = Position(1, -1.0, 0.0);
  var acc = 9.8;
  //TODO test creation with inavlid params
  //TODO test creation with missing params
  describe('evt', function() {

    it('should allow creation of Render', function() {
      var e = sut.Render(t);
      expect(e.k).toEqual('Render');
    });
    it('should allow creation of AskValueOf', function() {
      var e = sut.AskValueOf(t, 'x', requester, undefined);
      expect(e.k).toEqual('AskValueOf');
    });
    it('should allow creation of ReplyValueOf', function() {
      var ask = sut.AskValueOf(t, 'x', requester, undefined)
      var e = sut.ReplyValueOf(t, 33, ask);
      expect(e.k).toEqual('ReplyValueOf');
    });
    it('should allow creation of SpawnArea', function() {
      var e = sut.SpawnArea(t, id, model);
      expect(e.k).toEqual('SpawnArea');
    });
    it('should allow creation of SpawnShip', function() {
      var e = sut.SpawnShip(t, id, model, pos);
      expect(e.k).toEqual('SpawnShip');
    });
    it('should allow creation of Render', function() {
      var e = sut.MoveObjTo(t, id, pos, acc);
      expect(e.k).toEqual('MoveObjTo');
      expect(e.t).toEqual(t);
    });
  });
});

/*
 

enum Event {
  SpawnTargetG1(t : Timestamp, objId : Id, pos : Position);
  RotateShipStart(t : Timestamp, shipId : Id, angleSpeed : Float);
  RotateShipStop(t : Timestamp, shipId : Id);
  BoostShipStart(t : Timestamp, shipId : Id);
  BoostShipStop(t : Timestamp, shipId : Id);
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
