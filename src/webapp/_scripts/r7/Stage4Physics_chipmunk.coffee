define(["console", "chipmunk", "r7/Vec3F", "r7/Position", "underscore", "THREE", "r7/assetsLoader"], (console, cp, Vec3F, Position, _, THREE, assetsLoader) ->

  # shortcut, alias
  _degToRad = 0.0174532925199432957
  _radToDeg = 57.295779513082320876
  _adaptative = false
  _intervalRate = 60

  _id2body = {}

  ###
  @constructor
  @param {Id} id
  @param {Number} boost
  @return {UserData}
  ###
  UserData = (id, boost) -> {
    id: id
    boost: boost
  }

  (evt) ->
    _space = null
    _lastTimestamp = 0
    _running = false


    initSpace = ()->
      space = new cp.Space()
      space.gravity = cp.vzero
      space.iterations = 10
      space.damping = 0.3

      begin = (arb, space) ->
        shapes = arb.getShapes()
        evt.ContactBegin.dispatch(shapes[0].body.data.id, shapes[1].body.data.id)
        false

      space.addCollisionHandler(assetsLoader.types.drone, assetsLoader.types.item, begin, undefined, undefined, undefined)
      space

    despawn = (id) ->
      forBody(id, (b, u) ->
        f = () ->
          _space.removeShape(shape) for shape in b.shapeList when shape?
          _space.removeBody(b)
          delete _id2body[id]
        if _space.isLocked
          _space.addPostStepCallback(f)
        else
          f()
      )

    update = (t) ->
      stepRate = (if _adaptative then (t - _lastTimestamp) / 1000 else (1 / _intervalRate))

      updateForce = (ud, b, dt) ->
        b.f = cp.vzero #resetForces() but keep torque
        if ud.boost isnt 0
          force = ud.boost * dt
          acc = cp.v(b.rot.x * force, b.rot.y * force)
          b.applyForce(acc, cp.vzero)

      _space.lock()
      try
        _space.activeShapes.each((shape) ->
          b = shape.body
          if b? and b.data?
            updateForce(b.data, b, (1 / stepRate))
        )
      finally
        _space.unlock(true)

      _space.step(stepRate)
      _lastTimestamp = t

    pushStates = () ->
      #space.eachShape((shape) ->
      ct = 0
      _space.lock()
      try
        _space.activeShapes.each((shape) ->
          b = shape.body
          if b? and b.data?
            ud = b.data
            force = ud.boost #0.3;//(0.1 * dt);
            acc = Vec3F(b.rot.x * force, b.rot.y * force, 0)
            evt.ObjMoveTo.dispatch(ud.id, Position(b.p.x, b.p.y, b.a), acc)
            ct++
        )
      finally
        _space.unlock(true)
      ct

    forBody = (id, f) ->
      back = null
      b = _id2body[id]
      if b?
        ud = b.data
        back = f(b, ud)
      else
        console.warn("body not found : ", id)
      back

    setBoost = (shipId, state) ->
      forBody(shipId, (b, ud) ->
        #_space.activateBody(b) # or b.active() ?
        ud.boost = (if state then 100.0 else 0.0)
      )


    setAngle = (objId, a) ->
      forBody(objId, (b, ud) ->
        b.setAngVel(0)
        b.setAngle(a) #TODO rotate until raise the target angle instead of switch
      )

    setRotation = (objId, angVel) ->
      forBody(objId, (b, ud) ->
        # should take care of dampling (=> * 3)
        b.setAngVel(180 * angVel * _degToRad * 3) #90 deg per second
      )

    impulseObj = (objId, a, force) ->
      forBody(objId, (b, ud) ->
        impulse = cp.v(Math.cos(a) * force, Math.sin(a) * force)
        b.applyImpulse(impulse, cp.vzero)
      )

    spawnObj = (id, pos, gpof) ->
      return if !gpof.obj2dF?
      body = gpof.obj2dF()
      body.setPos(cp.v(pos.x, pos.y)) # = pos
      body.setAngle(pos.a)
      body.data = UserData(id, 0) #{ var id = id; var boost = false; };
      _space.addBody(body)
      _space.addShape(shape) for shape in body.shapes when shape?
      _id2body[id] = body
      drawBody(body)
      body

    spawnArea = (id, pos, gpof) ->
      obj2d = gpof.obj2dF()
      obj2d.setPos(cp.v(pos.x, pos.y))
      obj2d.setAngle(pos.a)
      _space.staticBody = obj2d
      body = _space.staticBody
      body.data = UserData(id, false) #{ var id = id; var boost = false; };
      _space.addStaticShape(shape) for shape in body.shapes when shape?
      _id2body[id] = body
      drawBody(body)
      body

    drawBody = (body) ->
      obj3dF = () ->
        obj3d = new THREE.Object3D()
        obj3d.position.z = 0.1 #for Z != 0 une an ortho camera
        for shape2d in body.shapes
          geometry = switch (typeof shape2d)
            when cp.PolyShape
              path = new THREE.Path()
              verts = shape2d.verts
              path.moveTo( verts[0], verts[1])
              for i in [2 .. verts.length + 1] by 2
                i2 = i % verts.length
                path.lineTo( verts[i2], verts[i2+1])
              path.toShapes()[0].makeGeometry()
            when cp.CircleShape
              new THREE.CircleGeometry(shape2d.r)
            else
              null
        #      rectShape.multilineTo( rectLength/2, -rectLength/2 )
        #rectShape.lineTo( -rectLength/2,      -rectLength/2 )
          if geometry?
            mesh = THREE.SceneUtils.createMultiMaterialObject( geometry, [ new THREE.MeshLambertMaterial( { color: 0xff0000, opacity: 0.2, transparent: true } ), new THREE.MeshBasicMaterial( { color: 0x000000, wireframe: true,  opacity: 0.3 } ) ] )
            obj3d.add(mesh)
        obj3d
      #_pending.push(evt.SpawnObj(body.data.id+ '/debug/chipmun/boundingbox', (() -> Position(body.p.x, body.p.y, body.p.a)), obj3d))
      evt.ObjSpawn.dispatch(body.data.id+ '>debug-physics', Position.zero, obj3dF)

    #TODO load from models
    ###
    spawnArea = (id, scene3d) ->
      body = _space.staticBody
      body.data = UserData(id, false) #{ var id = id; var boost = false; };
      obj3d = scene3d.objects.wall
      return  unless obj3d
      faces = obj3d.geometry.faces
      vertices = obj3d.geometry.vertices

      #TODO should apply obj.matrixWorld to vertices
      scalex = obj3d.scale.x
      scaley = obj3d.scale.y

      #var markColor = obj3d.materials.length -1 ;
      faces.forEach((face) ->
        vertsflat = _.reduce([face.a, face.b, face.c, face.d], (acc, v) ->

          #Face3 doesn't have face.d
          if v?
            x = vertices[v].x * scalex + obj3d.position.x
            y = vertices[v].y * scaley + obj3d.position.y

            # Guard
            #TODO remove guard an do check in exported (v3 distinct, Face3 store as Face4)
            if acc.length is 0 or ((acc[acc.length - 2] != x or acc[acc.length - 1] != y) and (acc[0] != x or acc[1] != y))
              acc.push(x)
              acc.push(y)
            else
              console.warn("duplicate vertices in the Face", face, v, x, y, acc[acc.length - 1], acc[0])

          #face.vertexColors = new THREE.Color(0xff0000);
          #face.color = new THREE.Color(0xff0000);
          acc
        , [])
        if vertsflat.length > 2
          shape = new cp.PolyShape(body, vertsflat, cp.vzero)
          shape.sensor = false
          _space.addShape(shape)
        else

          # visual effect for the polygone (eg: change color)
          console.warn("edges.length of area < 3", edges, face)
      )
      body
    ###

    newId = (base) ->
      base + new Date().getTime()

    evt.GameInit.add(()->
      _space = initSpace()
    )
    evt.GameStart.add(() ->
      _running = true
    )
    evt.GameStop.add(() ->
      _running = false
    )
    evt.AreaSpawn.add(spawnArea)
    evt.BoostShipStart.add((objId) ->
      setBoost(objId, 0.3)
    )
    evt.BoostShipStop.add((objId) ->
      setBoost(objId, 0)
    )
    evt.RotateShipStart.add(setRotation)
    evt.RotateShipStop.add((objId) -> setRotation(objId, 0))
    #evt.RequestDirectShip.
    #      setAngle(e.objId, Math.atan(e.acc.y / e.acc.x)) #TODO case div by zero
    #      setBoost( e.objId, Math.sqrt(e.acc.y * e.acc.y + e.acc.x * e.acc.x))
    #"ImpulseObj"
    #      impulseObj(e.objId, e.angle, e.force)
    evt.ObjSpawn.add(spawnObj)
    evt.ObjDespawn.add(despawn)
    evt.Tick.add((t, delta500) ->
      if _running
        update(t)
        pushStates()
        evt.Render.dispatch() # if hasChanges > 0
    )
    null
)
