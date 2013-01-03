define ["r7/evt", "console", "Box2D", "r7/Vec3F", "r7/Position", "underscore"], (evt, console, Box2D, Vec3F, Position, _) ->

  # shortcut, alias
  B2World = Box2D.Dynamics.b2World
  B2FixtureDef = Box2D.Dynamics.b2FixtureDef
  B2Body = Box2D.Dynamics.b2Body
  B2BodyDef = Box2D.Dynamics.b2BodyDef
  B2Vec2 = Box2D.Common.Math.b2Vec2
  B2PolygonShape = Box2D.Collision.Shapes.b2PolygonShape
  B2EdgeShape = Box2D.Collision.Shapes.b2EdgeShape
  B2CircleShape = Box2D.Collision.Shapes.b2CircleShape
  B2ContactListener = Box2D.Dynamics.b2ContactListener
  B2Contact = Box2D.Dynamics.Contacts.b2Contact
  _degToRad = 0.0174532925199432957
  _radToDeg = 57.295779513082320876
  _scale = 30
  _adaptative = false
  _intervalRate = 60

  #Box2D reuse fixture,...
  _fixDef = new B2FixtureDef()
  _bodyDef = new B2BodyDef()
  _id2body = {}

  ###
  @constructor
  @param {Id} id
  @param {Number} boost
  @return {UserData}
  ###
  UserData = (id, boost) ->
    id: id
    boost: boost

  ->
    self = {}
    _world = new B2World(new B2Vec2(0, 0), true)
    _lastTimestamp = 0
    _pending = []
    self.onEvent = onEvent = (e, out) ->
      switch e.k
        when "Init"
          _world = new B2World(new B2Vec2(0, 0), true)
          _pending = []
        when "SpawnArea"
          spawnArea e.objId, e.scene3d  unless not e.scene3d
        when "SpawnShip"

          #trace("create ship in box2d")
          spawnShip e.objId, e.pos  unless not e.obj3d

        #var debugDraw = new Box2D.Dynamics.b2DebugDraw;
        #debugDraw.SetSprite(document.getElementsByTagName("canvas")[0].getContext("2d"));
        when "BoostShipStart"
          setBoost e.objId, 0.3
        when "BoostShipStop"
          setBoost e.objId, 0
        when "RotateShipStart"
          setRotation e.objId, e.angleSpeed
        when "RotateShipStop"
          setRotation e.objId, 0
        when "RequestDirectShip"
          setAngle e.objId, Math.atan(e.acc.y / e.acc.x) #TODO case div by zero
          setBoost e.objId, Math.sqrt(e.acc.y * e.acc.y + e.acc.x * e.acc.x)
        when "FireBullet"
          out.push spawnBullet(e.emitterId)
        when "ImpulseObj"
          impulseObj e.objId, e.angle, e.force
        when "SpawnObj"
          spawnObj(e.objId, e.pos)
        when "DespawnObj"
          despawn(e.objId)
        when "Tick"
          update e.t
          pushStates out

          #          if (out.length > 0) {
          out.push evt.Render

        #          }
        else

      #pass
      evt.moveInto _pending, out

    initWorld = ->
      _fixDef.density = _scale
      _fixDef.friction = 0.5
      _fixDef.restitution = 0.2
      listener = new Box2D.Dynamics.b2ContactListener()
      listener.BeginContact = (contact) ->
        objId0 = contact.GetFixtureA().GetBody().GetUserData().id
        objId1 = contact.GetFixtureB().GetBody().GetUserData().id
        if !!objId0 and !!objId1 and objId0 isnt objId1
          if objId0 < objId1
            _pending.push evt.BeginContact(objId0, objId1)
          else
            _pending.push evt.BeginContact(objId1, objId0)

      listener.EndContact = (contact) ->
        objId0 = contact.GetFixtureA().GetBody().GetUserData().id
        objId1 = contact.GetFixtureB().GetBody().GetUserData().id
        if !!objId0 and !!objId1 and objId0 isnt objId1
          if objId0 < objId1
            _pending.push evt.EndContact(objId0, objId1)
          else
            _pending.push evt.EndContact(objId1, objId0)

      listener.PostSolve = (contact, impulse) ->

      listener.PreSolve = (contact, oldManifold) ->

      _world.SetContactListener listener

    despawn = (id) ->
      forBody id, (b, u) ->
        console.log("!!!! DESPAWN ", id, _id2body, b)
        _world.DestroyBody(b)
        delete _id2body[id]
        delete _world[id]
        #_id2body[id] = null


    update = (t) ->
      stepRate = (if _adaptative then (t - _lastTimestamp) / 1000 else (1 / _intervalRate))
      b = _world.GetBodyList()
      while b isnt null
        ud = null
        updateForce ud, b, (1 / stepRate)  if b.IsActive() and (ud = b.GetUserData()) isnt null
        b = b.m_next
      #velocity iteration
      _world.Step stepRate, 1, 1 #position iteration
      _world.ClearForces()
      _lastTimestamp = t

    pushStates = (out) ->
      b = _world.GetBodyList()
      while b isnt null
        ud = b.GetUserData()
        if b.IsActive() and ud isnt null and ud.id isnt null
          p = b.GetPosition()
          a = b.GetAngle()
          force = ud.boost #0.3;//(0.1 * dt);
          acc = Vec3F(Math.cos(a) * force, Math.sin(a) * force, 0)

          #Speed or Acceleration ?
          out.push evt.MoveObjTo(ud.id, Position(p.x * _scale, p.y * _scale, a), acc)
        b = b.m_next

    updateForce = (ud, b, dt) ->
      if ud.boost isnt 0

        #b.wakeUp();
        # if (myBody->IsAwake() == true)
        a = b.GetAngle()
        force = ud.boost #0.3;//(0.1 * dt);
        acc = new B2Vec2(Math.cos(a) * force, Math.sin(a) * force)
        b.ApplyForce acc, b.GetPosition() #b.GetCenterPosition()
      #trace("velocity");
      #trace(b.GetLinearVelocity());
      else #if stabilistor

    #b.setLinearVelocity(new B2Vec2(0.0, 0.0));

    ###
    @param {Id} id
    @param {function(B2Body, UserData)} f
    ###
    forBody = (id, f) ->
      back = null

      #
      #      var b = _world.GetBodyList();
      #      var done = false;
      #      while(b !== null && !done) {
      #
      b = _id2body[id]
      if b isnt null and typeof b isnt "undefined"
        ud = b.GetUserData()

        #trace(ud);
        #trace(id);
        #        if (!!ud && ud.id == id) { //TODO check if active ?
        #          done = true;
        back = f(b, ud)

      #        } else {
      #          b = b.m_next;
      #        }
      else
        console.warn "body not found : " + id
      back

    setBoost = (shipId, state) ->
      console.log "setBoost", shipId
      forBody shipId, (b, ud) ->
        console.debug b, b.GetPosition()
        b.SetAwake true
        ud.boost = (if state then 0.3 else 0.0)


    setAngle = (shipId, a) ->
      forBody shipId, (b, ud) ->
        b.SetAwake true

        # should take care of dampling (=> * 3)
        b.SetAngularVelocity 0 # 180 * rot * _degToRad * 3); //90 deg per second
        b.SetAngle a #TODO rotate until raise the target angle instead of switch


    setRotation = (shipId, rot) ->
      forBody shipId, (b, ud) ->
        b.SetAwake true

        # should take care of dampling (=> * 3)
        b.SetAngularVelocity 180 * rot * _degToRad * 3 #90 deg per second


    impulseObj = (objId, a, force) ->
      forBody objId, (b, ud) ->

        #console.debug('impulse2', objId, force, a);
        impulse = Vec3F(Math.cos(a) * force, Math.sin(a) * force, 0)
        b.ApplyImpulse impulse, b.GetWorldCenter()
        b.SetAwake true



    #console.debug(GetWorldCenter());

    #TODO load from models
    spawnShip = (id, pos) ->
      _bodyDef.type = B2Body.b2_dynamicBody
      _bodyDef.position.x = pos.x / _scale
      _bodyDef.position.y = pos.y / _scale
      _bodyDef.angle = pos.a
      _bodyDef.linearDamping = 1.0
      _bodyDef.angularDamping = 0.31
      _bodyDef.userData = UserData(id, 0) #{ var id = id; var boost = false; };
      s = B2PolygonShape.AsVector([new B2Vec2(2 / _scale, 0), new B2Vec2(-1 / _scale, 1 / _scale), new B2Vec2(-1 / _scale, -1 / _scale)], 3)
      _fixDef.shape = s
      _fixDef.density = _scale

      #_world.setContactListener(WorldContactListener());
      _fixDef.isSensor = false
      createBody(id, _bodyDef).CreateFixture _fixDef


    #TODO load from models
    spawnArea = (id, scene3d) ->
      _bodyDef.type = B2Body.b2_staticBody
      _bodyDef.position.x = 0
      _bodyDef.position.y = 0
      _bodyDef.angle = 0
      _bodyDef.userData = UserData(id, false) #{ var id = id; var boost = false; };
      body = _world.CreateBody(_bodyDef)
      obj3d = scene3d.objects.wall
      return  unless obj3d
      faces = obj3d.geometry.faces
      vertices = obj3d.geometry.vertices

      #TODO should apply obj.matrixWorld to vertices
      scalex = obj3d.scale.x
      scaley = obj3d.scale.y

      #obj3d.materials.push(new THREE.MeshBasicMaterial( { color: 0x000000, shading: THREE.FlatShading, wireframe: true, transparent: true } ));
      #var markColor = obj3d.materials.length -1 ;
      faces.forEach (face) ->
        edges = _.reduce([face.a, face.b, face.c, face.d], (acc, v) ->

          #Face3 doesn't have face.d
          if typeof v isnt "undefined" and v isnt null
            v2 = new B2Vec2((vertices[v].x * scalex + obj3d.position.x) / _scale, (vertices[v].y * scaley + obj3d.position.y) / _scale)

            # Guard
            #TODO remove guard an do check in exported (v3 distinct, Face3 store as Face4)
            if acc.length is 0 or ((acc[acc.length - 1].x isnt v2.x or acc[acc.length - 1].y isnt v2.y) and (acc[0].x isnt v2.x or acc[0].y isnt v2.y))
              acc.push v2
            else
              console.warn "duplicate vertices in the Face", face, v, v2, acc[acc.length - 1], acc[0]

          #face.vertexColors = new THREE.Color(0xff0000);
          #face.color = new THREE.Color(0xff0000);
          acc
        , [])
        if edges.length > 2

          # check if direct oriented
          #
          #          var accum = 0.0;
          #          for (var i2 = 0; i2 < edges.length; i2++) {
          #            var j = (i2 + 1) % edges.length;
          #            accum += edges[j].x * edges[i2].y - edges[i2].x * edges[i2].y;
          #          }
          #          if (accum > 0) {
          #            edges.reverse();
          #          face.vertexColors = new THREE.Color(0xff0000);
          #          face.color = new THREE.Color(0xff0000);
          #          }
          #

          #console.debug(edges);
          s = B2PolygonShape.AsVector(edges, edges.length)

          #var s = new B2EdgeShape(new B2Vec2(p0[0], p0[1]), new B2Vec2(p1[0], p1[1]));
          _fixDef.shape = s
          _fixDef.isSensor = false
          body.CreateFixture _fixDef
        else

          # visual effect for the polygone (eg: change color)
          console.warn "edges.length of area < 3", edges, face


      #face.vertexColors = new THREE.Color(0xff0000);
      #face.color = new THREE.Color(0xff0000);

      #  face.materialIndex = markColor;
      #obj3d.geometry.dynamic = true;
      #obj3d.geometry.__dirtyColors = true;
      #obj3d.material.vertexColors = THREE.FaceColors;
      #
      #        // create a set of polygone (4 side but not right angle as a work around for chainEdge support not available in box2D 2.1
      #        // or try b2EdgeShape edgeShape;  edgeShape.Set( b2Vec2(-15,0), b2Vec2(15,0) );
      #        var poly = [];
      #        var points = fragment.points;
      #        // if closed start with the edge point[-1] -> point[0]
      #        var startIndex = (points.length > 2 && fragment.closed) ? 0 : 1;
      #        for(var i = startIndex; i < points.length; i++) {
      #
      #          var p0 = points[((i < 1)? points.length + i : i) - 1];
      #          var p1 = points[i];
      #          console.log(p0);
      #          console.log(p1);
      #
      #          var dx = fragment.radius * ((p0[0] <= p1[0])? -1 : 1);
      #          var dy = fragment.radius * ((p0[1] <= p1[1])? -1 : 1);
      #          var edges = [
      #            new B2Vec2((p0[0] + dx)/_scale, (p0[1] - dy)/_scale),
      #            new B2Vec2((p1[0] - dx)/_scale, (p1[1] - dy)/_scale),
      #            new B2Vec2((p1[0] - dx)/_scale, (p1[1] + dy)/_scale),
      #            new B2Vec2((p0[0] + dx)/_scale, (p0[1] + dy)/_scale)
      #          ];
      #          var accum = 0.0;
      #          for (var i2 = 0; i2 < edges.length; i2++) {
      #            var j = (i2 + 1) % edges.length;
      #            accum += edges[j].x * edges[i2].y - edges[i2].x * edges[i2].y;
      #          }
      #          if (accum > 0) {
      #            edges.reverse();
      #          }
      #          console.log(edges);
      #          var s = B2PolygonShape.AsVector(edges, 4);
      #
      #          //var s = new B2EdgeShape(new B2Vec2(p0[0], p0[1]), new B2Vec2(p1[0], p1[1]));
      #          _fixDef.shape = s;
      #          body.CreateFixture(_fixDef);
      #        }
      #
      body

    findAvailablePos = (newPos) ->
      pos = null
      if typeof newPos is "function"

        #TODO avoid infinite loop
        #        for(pos = newPos() ; isAvailable(pos) ; pos = newPos());
        pos = Position(0, 0, 0)
      else pos = newPos  if isAvailable(newPos)
      throw "Can't find available pos : " + newPos  if pos is null
      pos

    createBody = (id, bodyDef) ->
      b = _world.CreateBody(bodyDef)
      _id2body[id] = b
      b

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


    newId = (base) ->
      base + new Date().getTime()

    initWorld()
    self


#
#class WorldContactListener extends B2ContactListener {
#  override public function beginContact(contact : B2Contact) {
#    trace(contact);
#  }
#}
#

#
#                                    void BeginContact(b2Contact* contact) {
#
#                                            //check if fixture A was a ball
#                                            void* bodyUserData = contact->GetFixtureA()->GetBody()->GetUserData();
#                                                  if ( bodyUserData )
#                                                            static_cast<Ball*>( bodyUserData )->startContact();
#
#                                                        //check if fixture B was a ball
#                                                        bodyUserData = contact->GetFixtureB()->GetBody()->GetUserData();
#                                                              if ( bodyUserData )
#                                                                        static_cast<Ball*>( bodyUserData )->startContact();
#
#                                                                  }
#
#                                        void EndContact(b2Contact* contact) {
#
#                                                //check if fixture A was a ball
#                                                void* bodyUserData = contact->GetFixtureA()->GetBody()->GetUserData();
#                                                      if ( bodyUserData )
#                                                                static_cast<Ball*>( bodyUserData )->endContact();
#
#                                                            //check if fixture B was a ball
#                                                            bodyUserData = contact->GetFixtureB()->GetBody()->GetUserData();
#                                                                  if ( bodyUserData )
#                                                                            static_cast<Ball*>( bodyUserData )->endContact();
#
#                                                                      }
#                                          };
#}
#
