define(['r7/evt', 'r7/Stage4GameRules'], function(evt, Stage4GameRules) {
  describe('GameRules:countdown', function() {
    var extractCountdownChanges = function(out) {
      return out.filter(function(v) { 
        return (v.k === 'UpdateVal') && (v.key === 'countdown');
      });
    };
    it('should stay unmodified until start', function() {
      var sut = new Stage4GameRules().onEvent;
      var out = [];
      sut(evt.Tick(0), out);
      sut(evt.Tick(33), out);
      var countdownChanges = extractCountdownChanges(out);
      expect(countdownChanges.length).toEqual(0);
    }); 
    it('should decrease after every second elapsed from start', function() {
      var sut = new Stage4GameRules().onEvent;
      var out = [];
      sut(evt.Start, out);
      var countdownChanges = extractCountdownChanges(out);
      var countdownStart = countdownChanges[0].value;
      expect(countdownStart).toNotEqual(0);
      sut(evt.Tick(0), out);
      for(var i = 0; i < countdownStart; i++) {
        console.log(i);
        sut(evt.Tick(i * 1000), out);
        var countdownChanges = extractCountdownChanges(out);
        expect(countdownChanges.length).toEqual(1);
        expect(countdownChanges[0].value).toEqual(countdownStart - i);
        out.length = 0;
      }
    }); 
    it('should decrease but stay >= 0', function() {
      var sut = new Stage4GameRules().onEvent;
      var out = [];
      sut(evt.Start, out);
      sut(evt.Tick(0), out);
      out.length = 0;
      sut(evt.Tick(60 * 1000), out);
      var countdownChanges = extractCountdownChanges(out);
      expect(countdownChanges.length).toEqual(1);
      expect(countdownChanges[0].value).toEqual(0);
    });
  });

  describe('GameRules:energy', function() {
    var extractLocalShipId = function(out) {
      var shipId = null;
      for(var i = out.length -1; i > -1 && shipId === null; i--) {
        var e = out[i];
        if (e.k === 'SpawnShip' && e.isLocal) {
          shipId = e.objId;
        }
      }
      return shipId;
    };
    var extractEnergyChanges = function(out, shipId) {
      return out.filter(function(v) {
        console.log(v);
        return (v.k === 'UpdateVal') && (v.key === shipId + '/energy');
      });
    };
    var extractEnergyMaxChanges = function(out, shipId) {
      return out.filter(function(v) { 
        return (v.k === 'UpdateVal') && (v.key === shipId + '/energyMax');
      });
    };
    it('should start at 50% energyMax', function() {
      var sut = new Stage4GameRules();
      var out = [];
      sut.onEvent(evt.Init, out);
      sut.onEvent(evt.Start, out);
      var shipId = extractLocalShipId(out);
      var energyChanges = extractEnergyChanges(out, shipId);
      expect(energyChanges.length).toEqual(1);
      var energy = energyChanges[0].value;
      var energyMax = extractEnergyMaxChanges(out, shipId)[0].value 
      expect(energy).toEqual(energyMax * 0.5);
    }); 
    it('should increase ev 500ms if nothing running until Max', function() {
      var sut = new Stage4GameRules();
      var out = [];
      sut.onEvent(evt.Init, out);
      sut.onEvent(evt.Start, out);
      var shipId = extractLocalShipId(out);
      var energy = extractEnergyChanges(out, shipId)[0].value;
      var energyMax = extractEnergyMaxChanges(out, shipId)[0].value;
      var t = 0;
      while(energy < energyMax) {
        t++;
        var energyOld = energy;
        out.length = 0;
        sut.onEvent(evt.Tick(t * 500), out);
        energy = extractEnergyChanges(out, shipId)[0].value;
        expect(energy > energyOld).toEqual(true);
      }
      for(var t2 = t + 5; t < t2; t++) {
        out.length = 0;
        sut.onEvent(evt.Tick(t * 500), out);
        energy = extractEnergyChanges(out, shipId)[0].value;
        expect(energy).toEqual(energyMax);
      }
    }); 
    it('should decrease after every second elapsed from start', function() {
      var sut = new Stage4GameRules().onEvent;
      var out = [];
      sut(evt.Start, out);
      sut(evt.Tick(0), out);
      for(var i = 0; i < 60; i++) {
        console.log(i);
        sut(evt.Tick(i * 1000), out);
        var countdownChanges = extractCountdownChanges(out);
        expect(countdownChanges.length).toEqual(1);
        expect(countdownChanges[0].value).toEqual(60 - i);
        out.length = 0;
      }
    }); 
    it('should decrease but stay >= 0', function() {
      var sut = new Stage4GameRules().onEvent;
      var out = [];
      sut(evt.Start, out);
      sut(evt.Tick(0), out);
      out.length = 0;
      sut(evt.Tick(60 * 1000), out);
      var countdownChanges = extractCountdownChanges(out);
      expect(countdownChanges.length).toEqual(1);
      expect(countdownChanges[0].value).toEqual(0);
    }); 
    /*
    it('should allow creation of Render', function() {
      var e = sut.Render(1000);
      expect(e.k).toEqual('Render');
    });
    it('should allow creation of SpawnArea', function() {
      var e = sut.SpawnArea(id, model);
      expect(e.k).toEqual('SpawnArea');
    });
    it('should allow creation of SpawnShip', function() {
      var e = sut.SpawnShip(id, model, pos);
      expect(e.k).toEqual('SpawnShip');
    });
    it('should allow creation of MoveObjTo', function() {
      var e = sut.MoveObjTo(id, pos, acc);
      expect(e.k).toEqual('MoveObjTo');
    });
    */
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
