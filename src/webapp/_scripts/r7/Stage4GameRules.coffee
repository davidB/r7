define(["r7/Position", "r7/assetsLoader", "underscore", "Q"], (Position, assetsLoader, _, Q) ->

  ###
  @param {Element} container
  ###
  (evt) ->
    _shipId = "!"
    _states = evt.newStates()
    _uid = new Date().getTime()

      # if boost decrease energy
        # if shield decrease energy
        # else increase energy
        # if no energy, stop boost, shield,...

    start = () ->
      _shipId = "ship/" + (_uid + 1)
      evt.SetLocalDroneId.dispatch(_shipId)
      assetsLoader.find('gui'   ).then((x) -> evt.HudSpawn.dispatch('hud', x)).done()
      assetsLoader.find('area01').then((x) -> evt.AreaSpawn.dispatch("area/" + _uid, Position.zero, x.walls)).done()
      assetsLoader.find('ship01').then((x) -> evt.ObjSpawn.dispatch(_shipId, Position(0.0, 0.0, 0.5), x)).done()
      updateState("running", false)
      updateState(_shipId + "/score", 0)
      updateState(_shipId + "/energy", 500)
      updateState(_shipId + "/energyMax", 1000)
      updateState(_shipId + "/boosting", false)
      updateState(_shipId + "/shooting", false)
      updateState(_shipId + "/shielding", false)
      updateState("running", true)
      evt.CountdownStart.dispatch("countdown", 45, evt.GameStop, [])
      evt.Render.dispatch()

    onReqEvent = (signal, args) ->
      switch signal
        when evt.ValUpdateVal
          updateState(args[0], args[1])

        #ignore
        when evt.ValInc
          incState(args[0], args[1])  if args[0].indexOf(_shipId) is 0
        when evt.BoostShipStart
          signal.dispatch.apply(this, args)
          updateState(_shipId + "/boosting", true)  if args[0] is _shipId
        when evt.BoostShipStop
          signal.dispatch.apply(this, args)
          updateState(_shipId + "/boosting", false)  if args[0] is _shipId
        when evt.ShootingStart
          signal.dispatch.apply(this, args)
          evt.PeriodicEvtAdd.dispatch(_shipId + "-fire", 300, evt.EvtReq, [evt.FireBullet, [_shipId]])  if args[0] is _shipId
        when evt.ShootingStop
          signal.dispatch.apply(this, args)
          evt.PeriodicEvtDel.dispatch(_shipId + "-fire")  if args[0] is _shipId
        when evt.FireBullet
          if args[0] isnt _shipId
            signal.dispatch.apply(this, args)
          else
            if _states[_shipId + "/energy"] > 7
              incState(_shipId + "/energy", -7)
              signal.dispatch.apply(this, args)
        else
          signal.dispatch.apply(this, args)

    incState = (k, v) ->
      _states.inc(k, v, onUpdateState)

    updateState = (k, v) ->
      _states.update(k, v, onUpdateState)

    onUpdateState = (k, v) ->
      onReqEvent(evt.BoostShipStop, [_shipId])  if _states[_shipId + "/boosting"]  if k is _shipId + "/energy" and v is 0

    updateEnergy = (delta) ->
      k = _shipId + "/energy"
      v = _states[k]
      unit = 0
      unit -= 5  if _states[_shipId + "/boosting"]

      #if (_states[_shipId + '/shooting']) unit -= 7;
      unit -= 10  if _states[_shipId + "/shielding"]
      unit += 3  if unit is 0
      v = Math.min(_states[k + "Max"], Math.max(0, v + unit))
      updateState(k, v)

    evt.GameInit.add(() ->
      assets = _.map(
        [
          {kind : 'area', id : 'area01'},
          {kind : 'model', id : 'ship01'},
          {kind : 'model', id : 'targetg101'},
          {kind : 'hud',   id : 'gui'}
        ],
        (x) -> assetsLoader.preload(x.id, x.kind)
      )
      Q.all(assets).then((x) ->
        evt.GameInitialized.dispatch()
      )
    )
    evt.GameStart.add(start)
    evt.EvtReq.add(onReqEvent)
    evt.Tick.add((t, delta500) ->
      updateEnergy(delta500)  if _states.running and delta500 >= 1
    )
    evt.GameStop.add(() ->
      updateState("running", false)
    )
    null
)
