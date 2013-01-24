define(["Mousetrap"], (Mousetrap) ->

  (evt) ->
    _shipId = null

    _keys = [{
      codes: [ 'up', 'w', 'z' ]
      label: 'Forward'
      active : false
      start: () -> evt.EvtReq.dispatch(evt.BoostShipStart, [_shipId])
      stop: ()-> evt.EvtReq.dispatch(evt.BoostShipStop, [_shipId])
    },
    {
      codes: [ 'left', 'a', 'q']
      label: 'Rotate Left'
      active : false
      start: -> evt.EvtReq.dispatch( evt.RotateShipStart, [_shipId, 0.5])
      stop: -> evt.EvtReq.dispatch( evt.RotateShipStop, [_shipId])
    },
    {
      codes: ['right', 'd']
      label: 'Rotate Right'
      active : false
      start: -> evt.EvtReq.dispatch( evt.RotateShipStart, [_shipId, -0.5])
      stop: -> evt.EvtReq.dispatch( evt.RotateShipStop, [_shipId])
    },
    {
      codes: ['space']
      label: 'Shoot'
      active : false
      start: -> evt.EvtReq.dispatch( evt.ShootingStart[_shipId])
      stop: -> evt.EvtReq.dispatch( evt.ShootingStop[_shipId])
    }]

    bindShipControl = (shipId) ->
      _shipId = shipId

      _keys.forEach((key) ->
        Mousetrap.bind(
          key.codes
          , (e, combo) ->
            key.active = false
            key.stop()
          , 'keyup'
        )
        Mousetrap.bind(
          key.codes
          , (e, combo) ->
            key.active = true
            key.start()
          , 'keydown'
        )
      )

    diseableControl = ->
      _keys.forEach((key) ->
        if key.code < 0
          key.code = -key.code
          key.stop()
      )
      Mousetrap.reset()

    evt.GameInit.add(diseableControl)
    evt.GameStop.add(diseableControl)
    evt.SetLocalDroneId.add(bindShipControl)
    _keys
)
