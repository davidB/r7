define(["r7/evt", "console", "chipmunk", "r7/Vec3F", "r7/Position", "underscore"], (evt, console, cp, Vec3F, Position, _) ->

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

  ->
    self = {}
    _space = null
    _lastTimestamp = 0
    _pending = []
    self.onEvent = onEvent = (e, out) ->
      switch e.k
        when "Init"
          _space= initSpace()
          _pending = []
        when "SpawnArea"
          spawnArea(e.objId, e.scene3d)  unless not e.scene3d
        when "SpawnShip"

          #trace("create ship in box2d")
          spawnObj(e.objId, "TODO", () -> e.pos) #unless not e.obj3d

        #var debugDraw = new Box2D.Dynamics.b2DebugDraw;
        #debugDraw.SetSprite(document.getElementsByTagName("canvas")[0].getContext("2d"));
        when "BoostShipStart"
          setBoost(e.objId, 0.3)
        when "BoostShipStop"
          setBoost(e.objId, 0)
        when "RotateShipStart"
          setRotation(e.objId, e.angleSpeed)
        when "RotateShipStop"
          setRotation(e.objId, 0)
        when "RequestDirectShip"
          setAngle(e.objId, Math.atan(e.acc.y / e.acc.x)) #TODO case div by zero
          setBoost( e.objId, Math.sqrt(e.acc.y * e.acc.y + e.acc.x * e.acc.x))
        when "FireBullet"
          out.push(spawnBullet(e.emitterId))
        when "ImpulseObj"
          impulseObj(e.objId, e.angle, e.force)
        when "SpawnObj"
          spawnObj(e.objId, "TODO", e.pos)
        when "DespawnObj"
          despawn(e.objId)
        when "Tick"
          update(e.t)
          pushStates(out)

          #          if (out.length > 0) {
          out.push(evt.Render)

        #          }
        else

      #pass
      evt.moveInto(_pending, out)

    initSpace = ()->
      space = new cp.Space()
      space.gravity = cp.vzero
      space.iterations = 10
      space.damping = 0.3

      #_fixDef.density = _scale
      #_fixDef.friction = 0.5
      #_fixDef.restitution = 0.2
      #listener = new Box2D.Dynamics.b2ContactListener()
      #listener.BeginContact = (contact) ->
      #  objId0 = contact.GetFixtureA().GetBody().GetUserData().id
      #  objId1 = contact.GetFixtureB().GetBody().GetUserData().id
      #  if !!objId0 and !!objId1 and objId0 isnt objId1
      #    if objId0 < objId1
      #      _pending.push evt.BeginContact(objId0, objId1)
      #    else
      #      _pending.push evt.BeginContact(objId1, objId0)
      #
      #listener.EndContact = (contact) ->
      #  objId0 = contact.GetFixtureA().GetBody().GetUserData().id
      #  objId1 = contact.GetFixtureB().GetBody().GetUserData().id
      #  if !!objId0 and !!objId1 and objId0 isnt objId1
      #    if objId0 < objId1
      #      _pending.push evt.EndContact(objId0, objId1)
      #    else
      #      _pending.push evt.EndContact(objId1, objId0)
      #
      #listener.PostSolve = (contact, impulse) ->
      #
      #listener.PreSolve = (contact, oldManifold) ->
      #_world.SetContactListener listener
      space

    despawn = (id) ->
      forBody(id, (b, u) ->
        console.log("!!!! DESPAWN ", id, _id2body, b)
        _space.removeShape(shape) for shape in b.shapeList
        _space.removeBody(b)
        delete _id2body[id]
        console.log("in space", _space.containsBody(b), _space.bodies)
        #_id2body[id] = null
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
      #_world.ClearForces()
      _lastTimestamp = t

    pushStates = (out) ->
      #space.eachShape((shape) ->
      _space.lock()
      try
        _space.activeShapes.each((shape) ->
          b = shape.body
          if b? and b.data?
            ud = b.data
            force = ud.boost #0.3;//(0.1 * dt);
            acc = Vec3F(b.rot.x * force, b.rot.y * force, 0)
            out.push(evt.MoveObjTo(ud.id, Position(b.p.x, b.p.y, b.a), acc))
        )
      finally
        _space.unlock(true)

    forBody = (id, f) ->
      back = null
      b = _id2body[id]
      if b?
        ud = b.data
        back = f(b, ud)

      #        } else {
      #          b = b.m_next;
      #        }
      else
        console.warn("body not found : ", id)
      back

    setBoost = (shipId, state) ->
      console.log("setBoost", shipId)
      forBody(shipId, (b, ud) ->
        console.debug(b, b.p)
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



    #console.debug(GetWorldCenter());

    #TODO load from models
    spawnObj = (id, model2d, pos) ->
      body = new cp.Body(100, Infinity)
      p = pos()
      body.setPos(cp.v(p.x, p.y)) # = pos
      body.setAngle(p.a)
      body.data = UserData(id, 0) #{ var id = id; var boost = false; };
      #_bodyDef.linearDamping = 1.0
      #_bodyDef.angularDamping = 0.31
      #TODO read model2d
      shape = new cp.PolyShape(body, [2, 0, -1, -1, -1, 1], cp.vzero)
      shape.sensor = false
      _space.addBody(body)
      _space.addShape(shape)
      _id2body[id] = body

    #TODO load from models
    spawnArea = (id, scene3d) ->
      #_bodyDef.userData = UserData(id, false) #{ var id = id; var boost = false; };
      body = _space.staticBody
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
    findAvailablePos = (newPos) ->
      pos = null
      if typeof newPos is "function"

        #TODO avoid infinite loop
        #        for(pos = newPos() ; isAvailable(pos) ; pos = newPos());
        pos = Position(0, 0, 0)
      else pos = newPos  if isAvailable(newPos)
      throw "Can't find available pos : " + newPos  if pos is null
      pos

    spawnObj = (id, newPos) ->
      pos = findAvailablePos(newPos)
      _bodyDef.type = B2Body.b2_dynamicBody
      _bodyDef.position.x = pos.x / _scale
      _bodyDef.position.y = pos.y / _scale
      _bodyDef.angle = pos.a
      _bodyDef.fixedRotation = true

      #_bodyDef.linearDamping = 1.0;
      #_bodyDef.angularDamping = 0.31;
      _bodyDef.userData = UserData(id, 0)
      s = new B2CircleShape(1 / _scale)
      _fixDef.shape = s
      _fixDef.density = _scale

      #_fixDef.isSensor = true;
      #console.debug("target", _fixDef);

      #return _world.CreateBody(_bodyDef).CreateFixture(_fixDef);
      createBody(id, _bodyDef).CreateFixture _fixDef

    spawnBullet = (emitterId) ->
      forBody emitterId, (b, ud) ->
        id = newId(emitterId + "-b")
        _bodyDef.type = B2Body.b2_dynamicBody
        _bodyDef.position.x = b.GetPosition().x
        _bodyDef.position.y = b.GetPosition().y
        _bodyDef.angle = b.GetAngle()

        #        _bodyDef.linearDamping = 0.0;
        #        _bodyDef.angularDamping = 0.0;
        #        _bodyDef.isSensor = false;
        _bodyDef.bullet = true
        _bodyDef.userData = UserData(id, 0)

        #        _bodyDef.position.x += 5;
        #_bodyDef.linearVelocity.x = 20 * Math.cos(a);
        #_bodyDef.linearVelocity.y = 20 * Math.sin(a);
        s = new B2CircleShape(0.2 / _scale)
        _fixDef.shape = s
        _fixDef.density = _scale
        _fixDef.isSensor = false
        b2 = createBody(id, _bodyDef)
        b2.CreateFixture _fixDef
        p = b2.GetPosition()
        a = b2.GetAngle()
        force = 0.01 #0.3;//(0.1 * dt);
        impulse = Vec3F(Math.cos(a) * force, Math.sin(a) * force, 0)
        b2.ApplyImpulse impulse, b.GetWorldCenter()
        b2.SetAwake true
        evt.SpawnObj id, "bullet-01", Position(p.x * _scale, p.y * _scale, a)

      ###
    newId = (base) ->
      base + new Date().getTime()

    self
)
