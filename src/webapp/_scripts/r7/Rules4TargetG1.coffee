define(["signals", "r7/Position", "r7/assetsLoader", "r7/Stage4Animation"], (signals, Position, assetsLoader, animations) ->

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

  (evt) ->
    _value = 1 #getter for display
    _targetG1IdPrefix = "target-g1/"
    _pos0 = Position.zero



    newTargetG1Id = () -> _targetG1IdPrefix + (newTargetG1Id.n++)#(new Date().getTime())
    newTargetG1Id.n = 0

    onHit = (objId0, objId1) ->
      return if objId0.indexOf("ship/") != 0 and objId1.indexOf(_targetG1IdPrefix) != 0
      shipId = objId0
      targetG1Id = objId1
      evt.CountdownStop.dispatch(targetG1Id + "/countdown")
      evt.EvtReq.dispatch(evt.ValInc, [shipId + "/score", _value])
      evt.ObjDespawn.dispatch(targetG1Id, {animName : "none"})
      _value += 1
      console.log("value", _value)
      #onAutoEvent(evt.UpdateVal(targetG1Id + "/value", _value))
      spawnNewTargetG1(1)

    onTimeout = (objId) ->
      evt.ObjDespawn.dispatch(objId)
      _value = Math.max(1, _value - 10)
      #onAutoEvent(evt.UpdateVal(objId + "/value", _value))
      spawnNewTargetG1(1)

    spawnNewTargetG1 = (toffset) ->
      nextPos = nextPosition(Position.zero, 10)
      objId = newTargetG1Id()
      assetsLoader.find('targetg101').then((x) ->
        evt.CountdownStart.dispatch(objId + "/spawn", toffset, evt.ObjSpawn, [objId, nextPos, x])
        evt.CountdownStart.dispatch(objId + "/countdown", 10 + toffset, TimeOut, [objId])
      ).done()

    TimeOut = new signals.Signal()
    TimeOut.add(onTimeout)
    evt.GameStart.add(() -> spawnNewTargetG1(1))
    evt.GameStop.add(() -> console.log("TODO"))
    evt.ContactBegin.add(onHit)

)
#TODO time countdown
