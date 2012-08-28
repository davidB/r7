define(['r7/evt', 'r7/Stage4GameRules'], function(evt, Stage4GameRules) {
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
      sut.onEvent(evt.Tick(t * 501, 0), out);
      var shipId = extractLocalShipId(out);
      var energy = extractEnergyChanges(out, shipId)[0].value;
      var energyMax = extractEnergyMaxChanges(out, shipId)[0].value;
      while(energy < energyMax) {
        t++;
        var energyOld = energy;
        out.length = 0;
        sut.onEvent(evt.Tick(t * 501, 1), out);
        energy = extractEnergyChanges(out, shipId)[0].value;
        expect(energy).toBeGreaterThan(energyOld);
      }
      expect(energy).toEqual(energyMax);
      for(var t2 = t + 5; t < t2; t++) {
        out.length = 0;
        sut.onEvent(evt.Tick(t * 500, 1), out);
        expect(extractEnergyChanges(out, shipId).length).toEqual(0);
      }
    }); 
    it('should decrease but stay >= 0 if consumming (eg:boosting) and stop consumming', function() {
      var sut = new Stage4GameRules();
      var out = [];
      var t = 0;
      sut.onEvent(evt.Init, out);
      sut.onEvent(evt.Start, out);
      sut.onEvent(evt.Tick(t * 501, 0), out);
      var shipId = extractLocalShipId(out);
      var energy = extractEnergyChanges(out, shipId)[0].value;
      sut.onEvent(evt.ReqEvt(evt.BoostShipStart(shipId)), out);
      while(energy > 0) {
        t++;
        var energyOld = energy;
        out.length = 0;
        sut.onEvent(evt.Tick(t * 501, 1), out);
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
