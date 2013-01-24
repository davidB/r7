define(["r7/evt", "Mousetrap"], (evt, Mousetrap) ->

  _shipId = null
  _pending = []

  _keys = [{
    codes: [ 'up', 'w', 'z' ]
    label: 'Forward'
    active : false
    start: () -> evt.ReqEvt(evt.BoostShipStart(_shipId))
    stop: ()-> evt.ReqEvt(evt.BoostShipStop(_shipId))
  },
  {
    codes: [ 'left', 'a', 'q']
    label: 'Rotate Left'
    active : false
    start: -> evt.ReqEvt( evt.RotateShipStart(_shipId, 0.5))
    stop: -> evt.ReqEvt( evt.RotateShipStop(_shipId))
  },
  {
    codes: ['right', 'd']
    label: 'Rotate Right'
    active : false
    start: -> evt.ReqEvt( evt.RotateShipStart(_shipId, -0.5))
    stop: -> evt.ReqEvt( evt.RotateShipStop(_shipId))
  },
  {
    codes: ['space']
    label: 'Shoot'
    active : false
    start: -> evt.ReqEvt( evt.ShootingStart(_shipId))
    stop: -> evt.ReqEvt( evt.ShootingStop(_shipId))
  }]
  _onEvent = (e, out) ->
    switch e.k
      when "Stop", "Init"
        diseableControl()
      when "SetLocalDroneId"
        bindShipControl(e.objId)
      else

    # pass
    evt.moveInto(_pending, out)

  bindShipControl = (shipId) ->
    _shipId = shipId

    _keys.forEach((key) ->
      Mousetrap.bind(
        key.codes
        , (e, combo) ->
          key.active = false
          _pending.push(key.stop())
        , 'keyup'
      )
      Mousetrap.bind(
        key.codes
        , (e, combo) ->
          key.active = true
          _pending.push(key.start())
        , 'keydown'
      )
    )

  diseableControl = ->
    _keys.forEach((key) ->
      if key.code < 0
        key.code = -key.code
        _pending.push(key.stop())
    )
    Mousetrap.reset()

  self = {
    controls: _keys
    onEvent: _onEvent
  }
  () -> self
)
