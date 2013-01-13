define(["r7/evt"], (evt) ->

  ###
  @param {Element} container
  ###
  (container) ->
    self = {}
    _container = container
    _shipId = null
    _pending = []

    # use http://www.quirksmode.org/js/keys.html to test
    _keysNone = []
    _keysUser = [{
      codes: [38, 90, 65] # up arrow, Z, A
      active : false
      start: () -> evt.ReqEvt(evt.BoostShipStart(_shipId))
      stop: ()-> evt.ReqEvt(evt.BoostShipStop(_shipId))
    },
    {
      codes: [37, 81] # left arrow, Q
      active : false
      start: -> evt.ReqEvt( evt.RotateShipStart(_shipId, 0.5))
      stop: -> evt.ReqEvt( evt.RotateShipStop(_shipId))
    },
    {
      codes: [39, 68] #right arrow, D
      active : false
      start: -> evt.ReqEvt( evt.RotateShipStart(_shipId, -0.5))
      stop: -> evt.ReqEvt( evt.RotateShipStop(_shipId))
    },
    {
      codes: [32] #space
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
        when "SpawnShip"
          bindShipControl(e.objId)  if e.isLocal
        else

      # pass
      evt.moveInto(_pending, out)

    onKeyDown = (e) ->
      _keys.forEach((key) ->
        if e.keyCode in key.codes
          key.active = true
          _pending.push(key.start())
      )


    onKeyUp = (e) ->
      _keys.forEach((key) ->
        if e.keyCode in key.codes
          key.active = false
          _pending.push(key.stop())
      )


    bindShipControl = (shipId) ->
      _shipId = shipId

      #container.onkeypress= this.onKeyDown;
      #container.onkeyup = this.onKeyUp;
      #Lib.document.onkeypress = onKeyDown;
      #var t : Dynamic = Lib.document; //_container;
      _container.addEventListener("keydown", onKeyDown, false)
      _container.addEventListener("keyup", onKeyUp, false)

    diseableControl = ->
      _keys.forEach((key) ->
        if key.code < 0
          key.code = -key.code
          _pending.push(key.stop())
      )

      _keys = _keysNone

    self
)
