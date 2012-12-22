define ["r7/evt"], (evt) ->
  
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
    _keysUser = [
      code: 38 # up arrow
      start: ->
        evt.ReqEvt evt.BoostShipStart(_shipId)

      stop: ->
        evt.ReqEvt evt.BoostShipStop(_shipId)
    ,
      code: 37 # left arrow
      start: ->
        evt.ReqEvt evt.RotateShipStart(_shipId, 1)

      stop: ->
        evt.ReqEvt evt.RotateShipStop(_shipId)
    ,
      code: 39 #right arrow
      start: ->
        evt.ReqEvt evt.RotateShipStart(_shipId, -1)

      stop: ->
        evt.ReqEvt evt.RotateShipStop(_shipId)
    ,
      code: 32 #space
      start: ->
        evt.ReqEvt evt.ShootingStart(_shipId)

      stop: ->
        evt.ReqEvt evt.ShootingStop(_shipId)
    ]
    _keys = _keysNone
    self.onEvent = (e, out) ->
      switch e.k
        when "Stop", "Init"
          diseableControl()
        when "Start"
          _keys = _keysUser
        when "SpawnShip"
          bindShipControl e.objId  if e.isLocal
        else
      
      # pass
      evt.moveInto _pending, out

    onKeyDown = (e) ->
      _keys.forEach (key) ->
        if key.code is e.keyCode
          key.code = -key.code
          _pending.push key.start()


    onKeyUp = (e) ->
      _keys.forEach (key) ->
        if key.code is -e.keyCode
          key.code = -key.code
          _pending.push key.stop()


    bindShipControl = (shipId) ->
      _shipId = shipId
      
      #container.onkeypress= this.onKeyDown;
      #container.onkeyup = this.onKeyUp;
      #Lib.document.onkeypress = onKeyDown;
      #var t : Dynamic = Lib.document; //_container;
      _container.addEventListener "keydown", onKeyDown, false
      _container.addEventListener "keyup", onKeyUp, false

    diseableControl = ->
      _keys.forEach (key) ->
        if key.code < 0
          key.code = -key.code
          _pending.push key.stop()

      _keys = _keysNone

    self

