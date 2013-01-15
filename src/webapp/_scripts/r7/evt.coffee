define([], ()->

  ###
  @constructor
  @return {evt}
  ###
  evt = {
    Init: {
      k: "Init"
    }

    Start: {
      k: "Start"
    }
    Tick: (t, delta500) -> {
      k: "Tick"
      t: t
      delta500: (if (delta500 is 0) then 0 else (delta500 or null))
    }
    Render: {
      k: "Render"
    }
    UpdateVal: (key, value) -> {
      k: "UpdateVal"
      key: key
      value: value
    }
    IncVal: (key, inc) -> {
      k: "IncVal"
      key: key
      inc: inc
    }
    ReqEvt: (e) -> {
      k: "ReqEvt"
      e: e
    }
    UnRegisterPeriodicEvt: (id) -> {
      k: "UnRegisterPeriodicEvt"
      id: id
    }
    RegisterPeriodicEvt: (id, interval, evt) -> {
      k: "RegisterPeriodicEvt"
      id: id
      interval: interval
      evt: evt
    }
    StartCountdown: (key, timeout, timeoutEvt) -> {
      k: "StartCountdown"
      key: key
      timeout: timeout
      timeoutEvt: timeoutEvt
    }
    StopCountdown: (key) -> {
      k: "StopCountdown"
      key: key
    }
    SetLocalDroneId: (objId) -> {
      k : "SetLocalDroneId"
      objId : objId
    }
    SpawnHud: (objId, domElem) -> {
      k: "SpawnHud"
      objId: objId
      domElem : domElem
    }
    DespawnHud: (objId) -> {
      k: "DespawnHud"
      objId: objId
    }
    SpawnArea: (objId, pos, obj3d, obj2d) -> {
      k: "SpawnArea"
      objId: objId
      pos: pos
      #scene3d: scene3d
      obj3d: obj3d
      obj2d: obj2d

    }
    SpawnShip: (objId, pos, obj3d, obj2d) -> {
      k: "SpawnShip"
      objId: objId
      pos: pos
      obj3d: obj3d
      obj2d: obj2d
    }
    SpawnCube: () -> {
      k: "SpawnCube"
    }
    ShootingStart: (emitterId) -> {
      k: "ShootingStart"
      emitterId: emitterId
    }
    ShootingStop: (emitterId) -> {
      k: "ShootingStop"
      emitterId: emitterId
    }
    FireBullet: (emitterId) -> {
      k: "FireBullet"
      emitterId: emitterId
    }
    SpawnObj: (objId, pos, obj3d, obj2d) -> {
      k: "SpawnObj"
      objId: objId
      pos: pos
      obj3d: obj3d
      obj2d: obj2d
    }
    DespawnObj: (objId) -> {
      k: "DespawnObj"
      objId: objId
    }
    MoveObjTo: (objId, pos, acc) -> {
      k: "MoveObjTo"
      objId: objId
      pos: pos
      acc: acc
    }
    SetupDatGui: (setup) -> {
      k: "SetupDatGui"
      setup: setup
    }
    BoostShipStop: (objId) -> {
      k: "BoostShipStop"
      objId: objId
    }
    BoostShipStart: (objId) -> {
      k: "BoostShipStart"
      objId: objId
    }
    RotateShipStart: (objId, angleSpeed) -> {
      k: "RotateShipStart"
      objId: objId
      angleSpeed: angleSpeed
    }
    RotateShipStop: (objId) -> {
      k: "RotateShipStop"
      objId: objId
    }
    BeginContact: (objId0, objId1) -> {
      k: "BeginContact"
      objId0: objId0
      objId1: objId1
    }
    EndContact: (objId0, objId1) -> {
      k: "EndContact"
      objId0: objId0
      objId1: objId1
    }
    ImpulseObj: (objId, angle, force) -> {
      k: "ImpulseObj"
      objId: objId
      angle: angle
      force: force
    }
    Stop: {
      k: "Stop"
    }
  }
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

  evt.newStates = () ->
    s = {}
    smax = {}
    smin = {}
    s.setMaxMin = (k, max, min) ->
      smax[k] = max if max?
      smin[k] = min if min?
    s.update = (out, k, v, onUpdateState) ->
      if s[k] isnt v
        s[k] = v
        out.push(evt.UpdateVal(k, v))
        onUpdateState(out, k, v)  if onUpdateState?

    s.inc = (out, k, i, onUpdateState) ->
      v = s[k] + i
      v = Math.min(smax[k], v) if smax[k]?
      v = Math.max(smin[k], v) if smin[k]?
      s.update(out, k, v, onUpdateState)

    s

  evt.extractK = (out, k, objIdPart) ->
    out.filter((v) ->
      b = (v.k is k)
      b = b and (not objIdPart? or (v.objId.indexOf(objIdPart) > -1))
      b
    )

  evt
)
