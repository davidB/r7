define(["r7/evt", "r7/Position", "r7/assetsLoader", "r7/Stage4Animation"], (evt, Position, assetsLoader, animations) ->

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
  nextPosition = (pos0, level) ->
    a = randomFloat(-Math.PI, Math.PI) #radian
    d0 = randomFloat(1, level * 3)

    Position(pos0.x + d0 * Math.cos(a), pos0.y + d0 * Math.sin(a), pos0.a)

  ->
    self = {}
    _value = 1 #getter for display
    _targetG1IdPrefix = "target-g1/"
    _pending = []
    _pos0 = Position.zero
    _onEventWaiting = (e, out) ->
      switch e.k
        when "Start"
          self._onEvent = _onEventRunning
          spawnNewTargetG1(1)
      evt.moveInto(_pending, out)

    _onEventRunning = (e, out) ->
      switch e.k
        when "Stop"
          self._onEvent = _onEventWaiting
        when "TargetG1.Timeout"
          onTimeout(e.objId)
        when "BeginContact"
          onHit(e.objId0, e.objId1) if e.objId0.indexOf("ship/") is 0 and e.objId1.indexOf(_targetG1IdPrefix) is 0
        else
          #pass
      evt.moveInto(_pending, out)

    self._onEvent = _onEventWaiting
    self.onEvent = (e, out) -> self._onEvent(e, out)

    n = 0
    newTargetG1Id = () -> _targetG1IdPrefix + (n++)#(new Date().getTime())

    onAutoEvent = (e) ->
      if e isnt null
        _pending.push(e)
        self.onEvent(e, _pending)

    onHit = (shipId, targetG1Id) ->
      onAutoEvent(evt.StopCountdown(targetG1Id + "/countdown"))
      onAutoEvent(evt.ReqEvt(evt.IncVal(shipId + "/score", _value)))
      onAutoEvent(evt.DespawnObj(targetG1Id))
      _value += 1
      console.log("value", _value)
      #onAutoEvent(evt.UpdateVal(targetG1Id + "/value", _value))
      spawnNewTargetG1(1)

    onTimeout = (objId) ->
      onAutoEvent(evt.DespawnObj(objId, animations.scaleOut))
      _value = Math.max(1, _value - 10)
      #onAutoEvent(evt.UpdateVal(objId + "/value", _value))
      spawnNewTargetG1(1)

    spawnNewTargetG1 = (toffset) ->
      nextPos = nextPosition(Position.zero, 10)
      objId = newTargetG1Id()
      assetsLoader.find('targetg101').then((x) ->
        onAutoEvent(evt.StartCountdown(objId + "/spawn", toffset, evt.SpawnObj(objId, nextPos, x)))
        onAutoEvent(evt.StartCountdown(objId + "/countdown", 10 + toffset, {k: "TargetG1.Timeout", objId : objId}))
      ).done()

    self

)
#TODO time countdown
