define(['r7/evt', 'r7/Position', 'r7/Rules4TargetG1'], function(evt, Position, Rules4TargetG1) {
  var shipId = 'ship/00';

  describe('GameRules:TargetG1', function() {
    it('should spawn target once at first ship spawn', function() {
      var sut = Rules4TargetG1().onEvent;
      var out = [];
      sut(evt.Tick(0), out);
      sut(evt.Tick(33), out);
      var r = evt.extractK(out, 'SpawnTargetG1');
      expect(r.length).toEqual(0);
      sut(evt.SpawnShip(shipId, null, Position(3, 5, 0), null, true), out);
console.log(out);
      r = evt.extractK(out, 'SpawnTargetG1');
      console.log(r);
      expect(r.length).toEqual(1);
      for(var i = 0; i < 3; i++) {
        sut(evt.SpawnShip(shipId, null, Position(3 + 1, 5 - i, 0), null, true), out);
        r = evt.extractK(out, 'SpawnTargetG1');
        expect(r.length).toEqual(1);
      }
    });
    describe('on hit', function() {
      var sut = null;
      var out = [];
      var tid = null;

      beforeEach(function() {
        out.length= 0;
        sut = Rules4TargetG1();
        sut.onEvent(evt.Tick(0), out);
        sut.onEvent(evt.SpawnShip(shipId, null, Position(3, 5, 0), null, true), out);
        var r = evt.extractK(out, 'SpawnTargetG1');
        expect(r.length).toEqual(1);
        tid = r[0].objId;
        out.length= 0;
        sut.onEvent(evt.BeginContact(shipId, tid), out);
      });
      

      it('should despawn/spawn', function() {
        var r = evt.extractK(out, 'DespawnObj', tid);
        expect(r.length).toEqual(1);

        r = evt.extractK(out, 'SpawnTargetG1', tid);
        expect(r.length).toEqual(1);
      });
      it('should increase score', function() {
        for (var i = 1; i < 10; i++) {
          var r = evt.extractK(out, 'IncVal');
          expect(r.length).toEqual(1);
          var e0 = r[0];
          expect(e0.key).toEqual(shipId + '/score');
          expect(e0.inc).toEqual(i);
          out.length = 0;
          sut.onEvent(evt.BeginContact(shipId, tid), out);
        }
      });
      it('should increase target value', function() {
        for (var i = 2; i < 10; i++) {
          var r = evt.extractK(out, 'UpdateVal');
          expect(r.length).toEqual(1);
          var e0 = r[0];
          expect(e0.key).toEqual(tid + '/value');
          expect(e0.value).toEqual(i);
          out.length = 0;
          sut.onEvent(evt.BeginContact(shipId, tid), out);
        }
      });
    });
    describe('on timeout', function() {
      var sut = null;
      var out = [];
      var tid = null;

      beforeEach(function() {
        out.length= 0;
        sut = Rules4TargetG1();
        sut.onEvent(evt.Tick(0), out);
        sut.onEvent(evt.SpawnShip(shipId, null, Position(3, 5, 0), null, true), out);
        var r = evt.extractK(out, 'SpawnTargetG1');
        expect(r.length).toEqual(1);
        tid = r[0].objId;
        out.length= 0;
        sut.onEvent(evt.BeginContact(shipId, tid), out);
      });
      it('should despawn/spawn', function() {
        expect('TODO').toEqual('DONE');
      });
      it('should keep score unchanged', function() {
        expect('TODO').toEqual('DONE');
      });
      it('should decrease level', function() {
        expect('TODO').toEqual('DONE');
      });
    });
  });
});
