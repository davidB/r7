define(["r7/evt", "Mousetrap"], (evt, Mousetrap) ->

  ###
  @param {Element} container
  ###
  (container) ->
    self = {}
    _container = container
    _shipId = null
    _pending = []

    # use http://www.quirksmode.org/js/keys.html to test
    # or use [mousetrap](http://craig.is/killing/mice)
    _keysNone = []
    _keysUser = [{
      codes: [ 'up', 'w' ]
      active : false
      start: () -> evt.ReqEvt(evt.BoostShipStart(_shipId))
      stop: ()-> evt.ReqEvt(evt.BoostShipStop(_shipId))
    },
    {
      codes: [ 'left', 'a']
      active : false
      start: -> evt.ReqEvt( evt.RotateShipStart(_shipId, 0.5))
      stop: -> evt.ReqEvt( evt.RotateShipStop(_shipId))
    },
    {
      codes: ['right', 'd']
      active : false
      start: -> evt.ReqEvt( evt.RotateShipStart(_shipId, -0.5))
      stop: -> evt.ReqEvt( evt.RotateShipStop(_shipId))
    },
    {
      codes: ['space']
      active : false
      start: -> evt.ReqEvt( evt.ShootingStart(_shipId))
      stop: -> evt.ReqEvt( evt.ShootingStop(_shipId))
    }]
    _keys = _keysNone
    self.onEvent = (e, out) ->
      switch e.k
        when "Stop", "Init"
          diseableControl()
        when "Start"
          _keys = _keysUser
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
      _keys = _keysNone

    self
)
