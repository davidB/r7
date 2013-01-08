define(["r7/evt", "r7/Position", "r7/assetsLoader"], (evt, Position, assetsLoader) ->

  ###
  @param {number} min
  @param {number} max
  ###
  randomFloat = (min, max) ->
    Math.random() * (max - min) + min


  ###
  @param {{x: number, y: number}} pos0
  @param {number} level
  ###
  nextPositionFactory = (pos0, level) ->
    a0 = randomFloat(-Math.PI, Math.PI) #radian
    d0 = 0
    tryCt = -1
    tryLg = 10
    nextPos = () ->
      tryCt++
      tryCt = tryCt % tryLg
      d0 = randomFloat(1, level * 3)

      #randomFloat(1, 5)/10 //TODO include level in the formula
      a = a0 + (tryCt * Math.PI * 2 / tryLg)
      nextPos.last = Position(pos0.x + d0 * Math.cos(a), pos0.y + d0 * Math.sin(a), pos0.a)
      nextPos.last
    nextPos.last = pos0
    nextPos

  ->
    self = {}
    _value = 1 #getter for display
    _targetG1IdPrefix = "target-g1/"
    _lastPos0 = null
    _pending = []
    self.onEvent = (e, out) ->
      switch e.k
        when "SpawnShip"
          if e.isLocal and _lastPos0 is null
            _lastPos0 = e.pos
            spawnNewTargetG1()
          #TODO random position near ship
        when "SpawnObj"
          if e.objId.indexOf(_targetG1IdPrefix) == 0
            _lastPos0 = e.pos?.last
            onAutoEvent(evt.StartCountdown(e.objId + "/countdown", 3, {k: "TargetG1.Timeout", objId : e.objId}))
        when "TargetG1.Timeout"
          onTimeout(e.objId)
        when "BeginContact"
          onHit(e.objId0, e.objId1) if e.objId0.indexOf("ship/") is 0 and e.objId1.indexOf(_targetG1iIdPrefix) is 0
        else
          #pass
      evt.moveInto(_pending, out)

    newTargetG1Id = () -> _targetG1IdPrefix + (new Date().getTime())

    onAutoEvent = (e) ->
      if e isnt null
        _pending.push(e)
        self.onEvent(e, _pending)

    onHit = (shipId, targetG1Id) ->
      onAutoEvent(evt.StopCountdown(targetG1Id + "/countdown"))
      onAutoEvent(evt.IncVal(shipId + "/score", _value))
      onAutoEvent(evt.DespawnObj(targetG1Id))
      _value += 1
      onAutoEvent(evt.UpdateVal(targetG1Id + "/value", _value))
      spawnNewTargetG1()

    onTimeout = (objId) ->
      onAutoEvent(evt.DespawnObj(objId))
      _value = Math.max(1, _value - 10)
      onAutoEvent(evt.UpdateVal(objId + "/value", _value))
      spawnNewTargetG1()

    spawnNewTargetG1 = () ->
      nextPos = nextPositionFactory(_lastPos0, _value)
      objId = newTargetG1Id()
      assetsLoader.find('targetg101').then((x) -> onAutoEvent(evt.SpawnObj(objId, nextPos, x))).done()

    self

)
#TODO time countdown
