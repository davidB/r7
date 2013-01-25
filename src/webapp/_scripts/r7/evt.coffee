define(['signals'], (signals)->

  ###
  @constructor
  @return {evt}
  ###
  evt = {
    GameInit: new signals.Signal()
    GameInitialized :new signals.Signal()
    GameStart: new signals.Signal()
    GameStop: new signals.Signal()#{
    DevMode : new signals.Signal()
    Tick: new signals.Signal()#(t, delta500) ->
    Render: new signals.Signal()
    ValUpdate: new signals.Signal()#(key, value) -> {
    ValInc: new signals.Signal()#(key, inc) -> {
    EvtReq: new signals.Signal()#(signal, arguments) -> {
    PeriodicEvtDel: new signals.Signal()#(id) -> {
    PeriodicEvtAdd: new signals.Signal()#(id, interval, signal, arguments) -> {
    CountdownStart: new signals.Signal()#(key, timeout, signal, arguments) -> {
    CountdownStop: new signals.Signal()#(key) -> {
    SetLocalDroneId: new signals.Signal()#(objId) -> {
    HudSpawn: new signals.Signal()#(objId, domElem) -> {
    HudDespawn: new signals.Signal()#(objId) -> {
    AreaSpawn: new signals.Signal()#(objId, pos, gpof) -> {
    ShootingStart: new signals.Signal()#(emitterId) -> {
    ShootingStop: new signals.Signal()#(emitterId) -> {
    FireBullet: new signals.Signal()#(emitterId) -> {
    ObjSpawn: new signals.Signal()#(objId, pos, gpof, options) -> {
    ObjDespawn: new signals.Signal()#(objId, options) -> {
    ObjMoveTo: new signals.Signal()#(objId, pos, acc) -> {
    SetupDatGui: new signals.Signal()#(setup) -> {
    BoostShipStop: new signals.Signal()#(objId) -> {
    BoostShipStart: new signals.Signal()#(objId) -> {
    RotateShipStart: new signals.Signal()#(objId, angleSpeed) -> {
    RotateShipStop: new signals.Signal()#(objId) -> {
    ContactBegin: new signals.Signal()#(objId0, objId1) -> {
    ContactEnd: new signals.Signal()#(objId0, objId1) -> {
    LoadProgress: new signals.Signal()
  }
  ###
  evt.moveInto = (src, target) ->
    if src.length > 0 && src != target
      target.push.apply(target, src)
      src.length = 0

  evt.newListOfEvt = ->
    b = []
    b.push = (i) ->
      throw new Error("try to push invalid value (empty) [" + i + "] : ")  if not i?
      throw new Error("try to push invalid value (no kind .k)[" + i + "] : " + i.k)  if not i.k?
      Array::push.apply(this, arguments)

    b
  ###
  evt.newStates = () ->
    s = {}
    smax = {}
    smin = {}
    s.setMaxMin = (k, max, min) ->
      smax[k] = max if max?
      smin[k] = min if min?
    s.update = (k, v, onUpdateState) ->
      if s[k] isnt v
        s[k] = v
        evt.ValUpdate.dispatch(k, v)
        onUpdateState(k, v)  if onUpdateState?

    s.inc = (k, i, onUpdateState) ->
      v = s[k] + i
      v = Math.min(smax[k], v) if smax[k]?
      v = Math.max(smin[k], v) if smin[k]?
      s.update(k, v, onUpdateState)

    s
  ###
  evt.extractK = (out, k, objIdPart) ->
    out.filter((v) ->
      b = (v.k is k)
      b = b and (not objIdPart? or (v.objId.indexOf(objIdPart) > -1))
      b
    )
  ###
  evt
)
