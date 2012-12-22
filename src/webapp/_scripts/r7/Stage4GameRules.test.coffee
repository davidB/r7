define ["r7/evt", "r7/Stage4GameRules"], (evt, Stage4GameRules) ->
  describe "GameRules:energy", ->
    extractLocalShipId = (out) ->
      shipId = null
      i = out.length - 1

      while i > -1 and shipId is null
        e = out[i]
        shipId = e.objId  if e.k is "SpawnShip" and e.isLocal
        i--
      shipId

    extractEnergyChanges = (out, shipId) ->
      out.filter (v) ->
        (v.k is "UpdateVal") and (v.key is shipId + "/energy")


    extractEnergyMaxChanges = (out, shipId) ->
      out.filter (v) ->
        (v.k is "UpdateVal") and (v.key is shipId + "/energyMax")


    it "should start at 50% energyMax", ->
      sut = new Stage4GameRules()
      out = []
      sut.onEvent evt.Init, out
      sut.onEvent evt.Start, out
      shipId = extractLocalShipId(out)
      energyChanges = extractEnergyChanges(out, shipId)
      expect(energyChanges.length).toEqual 1
      energy = energyChanges[0].value
      energyMax = extractEnergyMaxChanges(out, shipId)[0].value
      expect(energy).toEqual energyMax * 0.5

    it "should increase ev 500ms if nothing running until Max", ->
      sut = new Stage4GameRules()
      out = []
      t = 0
      sut.onEvent evt.Init, out
      sut.onEvent evt.Start, out
      sut.onEvent evt.Tick(t * 501, 0), out
      shipId = extractLocalShipId(out)
      energy = extractEnergyChanges(out, shipId)[0].value
      energyMax = extractEnergyMaxChanges(out, shipId)[0].value
      while energy < energyMax
        t++
        energyOld = energy
        out.length = 0
        sut.onEvent evt.Tick(t * 501, 1), out
        energy = extractEnergyChanges(out, shipId)[0].value
        expect(energy).toBeGreaterThan energyOld
      expect(energy).toEqual energyMax
      t2 = t + 5

      while t < t2
        out.length = 0
        sut.onEvent evt.Tick(t * 500, 1), out
        expect(extractEnergyChanges(out, shipId).length).toEqual 0
        t++

    it "should decrease but stay >= 0 if consumming (eg:boosting) and stop consumming", ->
      sut = new Stage4GameRules()
      out = []
      t = 0
      sut.onEvent evt.Init, out
      sut.onEvent evt.Start, out
      sut.onEvent evt.Tick(t * 501, 0), out
      shipId = extractLocalShipId(out)
      energy = extractEnergyChanges(out, shipId)[0].value
      sut.onEvent evt.ReqEvt(evt.BoostShipStart(shipId)), out
      while energy > 0
        t++
        energyOld = energy
        out.length = 0
        sut.onEvent evt.Tick(t * 501, 1), out
        energy = extractEnergyChanges(out, shipId)[0].value
        expect(energy).toBeLessThan energyOld
      expect(energy).toEqual 0
      booststop = out.filter((v) ->
        v.k is "BoostShipStop" and v.objId is shipId
      )
      expect(booststop.length).toEqual 1



