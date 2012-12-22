define ["r7/evt", "r7/Position"], (evt, Position) ->

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
    ->
      tryCt++
      tryCt = tryCt % tryLg
      d0 = 0  if tryCt is 0

      #randomFloat(1, 5)/10 //TODO include level in the formula
      a = a0 + (tryCt * Math.PI * 2 / tryLg)
      Position pos0.x + d0 * Math.cos(a), pos0.y + d0 * Math.sin(a), pos0.a

  ->
    self = {}
    _value = 1 #getter for display
    _timeoutAt = -1
    _targetG1Id = "target-g1/" + (new Date().getTime())
    _lastPos0 = null
    self.onEvent = (e, out) ->
      switch e.k
        when "SpawnShip"

          #        console.log(e, _lastPos0);
          if e.isLocal and _lastPos0 is null
            _lastPos0 = e.pos
            onAutoEvent evt.SpawnTargetG1(_targetG1Id, "targetg101", nextPositionFactory(_lastPos0, _value)), out

        #TODO random position near ship
        when "SpawnTargetG1"
          _lastPos0 = e.pos  if e.pos isnt null
          onAutoEvent evt.StartCountdown(_targetG1Id + "/countdown", 5,
            k: "TargetG1.Timeout"
          ), out
        when "TargetG1.Timeout"
          onTimeout out
        when "BeginContact"
          onHit e.objId0, out  if e.objId0.indexOf("ship/") is 0 and e.objId1.indexOf("target-g1/") is 0
        else


    #pass
    onAutoEvent = (e, out) ->
      if e isnt null
        out.push e
        self.onEvent e, out

    onHit = (shipId, out) ->
      onAutoEvent evt.StopCountdown(_targetG1Id + "/countdown"), out
      onAutoEvent evt.IncVal(shipId + "/score", _value), out
      onAutoEvent evt.DespawnObj(_targetG1Id), out
      _value += 1
      onAutoEvent evt.UpdateVal(_targetG1Id + "/value", _value), out
      onAutoEvent evt.SpawnTargetG1(_targetG1Id, "targetg101", nextPositionFactory(_lastPos0, _value)), out

    onTimeout = (out) ->
      console.log "TIMEOUT"
      onAutoEvent evt.DespawnObj(_targetG1Id), out
      _value = Math.max(1, _value - 10)
      onAutoEvent evt.UpdateVal(_targetG1Id + "/value", _value), out
      onAutoEvent evt.SpawnTargetG1(_targetG1Id, "targetg101", nextPositionFactory(_lastPos0, _value)), out

    self


#TODO time countdown