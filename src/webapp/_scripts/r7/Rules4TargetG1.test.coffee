define ["r7/evt", "r7/Position", "r7/Rules4TargetG1"], (evt, Position, Rules4TargetG1) ->
  shipId = "ship/00"
  describe "GameRules:TargetG1", ->
    it "should spawn target once at first ship spawn", ->
      sut = Rules4TargetG1().onEvent
      out = []
      sut evt.Tick(0), out
      sut evt.Tick(33), out
      r = evt.extractK(out, "SpawnTargetG1")
      expect(r.length).toEqual 0
      sut evt.SpawnShip(shipId, null, Position(3, 5, 0), null, true), out
      console.log out
      r = evt.extractK(out, "SpawnTargetG1")
      console.log r
      expect(r.length).toEqual 1
      i = 0

      while i < 3
        sut evt.SpawnShip(shipId, null, Position(3 + 1, 5 - i, 0), null, true), out
        r = evt.extractK(out, "SpawnTargetG1")
        expect(r.length).toEqual 1
        i++

    describe "on hit", ->
      sut = null
      out = []
      tid = null
      beforeEach ->
        out.length = 0
        sut = Rules4TargetG1()
        sut.onEvent evt.Tick(0), out
        sut.onEvent evt.SpawnShip(shipId, null, Position(3, 5, 0), null, true), out
        r = evt.extractK(out, "SpawnTargetG1")
        expect(r.length).toEqual 1
        tid = r[0].objId
        out.length = 0
        sut.onEvent evt.BeginContact(shipId, tid), out

      it "should despawn/spawn", ->
        r = evt.extractK(out, "DespawnObj", tid)
        expect(r.length).toEqual 1
        r = evt.extractK(out, "SpawnTargetG1", tid)
        expect(r.length).toEqual 1

      it "should increase score", ->
        i = 1

        while i < 10
          r = evt.extractK(out, "IncVal")
          expect(r.length).toEqual 1
          e0 = r[0]
          expect(e0.key).toEqual shipId + "/score"
          expect(e0.inc).toEqual i
          out.length = 0
          sut.onEvent evt.BeginContact(shipId, tid), out
          i++

      it "should increase target value", ->
        i = 2

        while i < 10
          r = evt.extractK(out, "UpdateVal")
          expect(r.length).toEqual 1
          e0 = r[0]
          expect(e0.key).toEqual tid + "/value"
          expect(e0.value).toEqual i
          out.length = 0
          sut.onEvent evt.BeginContact(shipId, tid), out
          i++


    describe "on timeout", ->
      sut = null
      out = []
      tid = null
      beforeEach ->
        out.length = 0
        sut = Rules4TargetG1()
        sut.onEvent evt.Tick(0), out
        sut.onEvent evt.SpawnShip(shipId, null, Position(3, 5, 0), null, true), out
        r = evt.extractK(out, "SpawnTargetG1")
        expect(r.length).toEqual 1
        tid = r[0].objId
        out.length = 0
        sut.onEvent evt.BeginContact(shipId, tid), out

      it "should despawn/spawn", ->
        expect("TODO").toEqual "DONE"

      it "should keep score unchanged", ->
        expect("TODO").toEqual "DONE"

      it "should decrease level", ->
        expect("TODO").toEqual "DONE"




