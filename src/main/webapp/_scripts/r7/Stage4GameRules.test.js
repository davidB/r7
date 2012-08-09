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
      var t = 0;
      sut.onEvent(evt.Init, out);
      sut.onEvent(evt.Start, out);
      sut.onEvent(evt.Tick(t * 501), out);
      var shipId = extractLocalShipId(out);
      var energy = extractEnergyChanges(out, shipId)[0].value;
      var energyMax = extractEnergyMaxChanges(out, shipId)[0].value;
      while(energy < energyMax) {
        t++;
        var energyOld = energy;
        out.length = 0;
        sut.onEvent(evt.Tick(t * 501), out);
        energy = extractEnergyChanges(out, shipId)[0].value;
        expect(energy).toBeGreaterThan(energyOld);
      }
      expect(energy).toEqual(energyMax);
      for(var t2 = t + 5; t < t2; t++) {
        out.length = 0;
        sut.onEvent(evt.Tick(t * 500), out);
        expect(extractEnergyChanges(out, shipId).length).toEqual(0);
      }
    }); 
    it('should decrease but stay >= 0 if consumming (eg:boosting) and stop consumming', function() {
      var sut = new Stage4GameRules();
      var out = [];
      var t = 0;
      sut.onEvent(evt.Init, out);
      sut.onEvent(evt.Start, out);
      sut.onEvent(evt.Tick(t * 501), out);
      var shipId = extractLocalShipId(out);
      var energy = extractEnergyChanges(out, shipId)[0].value;
      sut.onEvent(evt.ReqEvt(evt.BoostShipStart(shipId)), out);
      while(energy > 0) {
        t++;
        var energyOld = energy;
        out.length = 0;
        sut.onEvent(evt.Tick(t * 501), out);
        energy = extractEnergyChanges(out, shipId)[0].value;
        expect(energy).toBeLessThan(energyOld);
      }
      expect(energy).toEqual(0);
      var booststop = out.filter(function(v){
        return v.k === 'BoostShipStop' && v.objId === shipId;
      });
      expect(booststop.length).toEqual(1);
    }); 
  });
});
