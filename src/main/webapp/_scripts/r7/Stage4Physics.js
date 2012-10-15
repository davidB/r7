define(['r7/evt', 'console', 'Box2D', 'r7/Vec3F', 'r7/Position', 'underscore'], function(evt, console, Box2D, Vec3F, Position, _) {

  // shortcut, alias
  var B2World = Box2D.Dynamics.b2World;
  var B2FixtureDef = Box2D.Dynamics.b2FixtureDef;
  var B2Body = Box2D.Dynamics.b2Body;
  var B2BodyDef = Box2D.Dynamics.b2BodyDef;
  var B2Vec2 = Box2D.Common.Math.b2Vec2;
  var B2PolygonShape = Box2D.Collision.Shapes.b2PolygonShape;
  var B2EdgeShape = Box2D.Collision.Shapes.b2EdgeShape;
  var B2CircleShape = Box2D.Collision.Shapes.b2CircleShape;
  var B2ContactListener = Box2D.Dynamics.b2ContactListener;
  var B2Contact = Box2D.Dynamics.Contacts.b2Contact;

  var _degToRad = 0.0174532925199432957;
  var _radToDeg = 57.295779513082320876;
  var _scale = 30;
  var _adaptative = false;
  var _intervalRate = 60;
  //Box2D reuse fixture,...
  var _fixDef = new B2FixtureDef();
  var _bodyDef = new B2BodyDef();

  var _id2body = {};

  /**
   * @constructor
   * @param {Id} id
   * @param {Number} boost
   * @return {UserData}
   */
  var UserData = function(id, boost) {return { id : id, boost : boost };};

  return function() {
    var self = {};
    var _world = new B2World(new B2Vec2(0, 0), true);
    var _lastTimestamp = 0;
    var _pending = [];
  
    self.onEvent = function onEvent(e, out) {
      switch(e.k) {
        case 'Init':
          _world = new B2World(new B2Vec2(0, 0), true);
          _pending = [];
          break;
        case 'SpawnArea' :
          if (!!e.scene3d) spawnArea(e.objId, e.scene3d);
          break;
        case 'SpawnShip' :
          //trace("create ship in box2d")
          if (!!e.obj3d) {
            spawnShip(e.objId, e.pos);
            //var debugDraw = new Box2D.Dynamics.b2DebugDraw;
            //debugDraw.SetSprite(document.getElementsByTagName("canvas")[0].getContext("2d")); 
          }
          break;
        case 'BoostShipStart' :
          setBoost(e.objId, 0.3);
          break;
        case 'BoostShipStop' :
          setBoost(e.objId, 0);
          break;
        case 'RotateShipStart' :
          setRotation(e.objId, e.angleSpeed);
          break;
        case 'RotateShipStop' :
          setRotation(e.objId, 0);
          break;
        case 'RequestDirectShip' :
          setAngle(e.objId, Math.atan(e.acc.y/e.acc.x)); //TODO case div by zero
          setBoost(e.objId, Math.sqrt(e.acc.y * e.acc.y + e.acc.x * e.acc.x));
          break;
        case 'FireBullet':
          out.push(spawnBullet(e.emitterId));
          break;
        case 'ImpulseObj':
          impulseObj(e.objId, e.angle, e.force);
          break;
        case 'SpawnTargetG1' :
          spawnTargetG1(e.objId, e.pos);
          break;
        case 'DespawnObj' :
          despawn(e.objId);
          break;
        case 'Tick' :
          update(e.t);
          pushStates(out);
//          if (out.length > 0) {
            out.push(evt.Render);
//          }
          break;
        default :
           //pass
      }
      evt.moveInto(_pending, out);
    };

    var initWorld = function() {
      _fixDef.density = 1.0 * _scale;
      _fixDef.friction = 0.5;
      _fixDef.restitution = 0.2;

      var listener = new Box2D.Dynamics.b2ContactListener();
      listener.BeginContact = function(contact) {
        var objId0 = contact.GetFixtureA().GetBody().GetUserData().id;
        var objId1 = contact.GetFixtureB().GetBody().GetUserData().id;
        if (!!objId0 && !!objId1 && objId0 !== objId1) {
          if (objId0 < objId1) {
            _pending.push(evt.BeginContact(objId0, objId1));
          } else {
            _pending.push(evt.BeginContact(objId1, objId0));
          }
        }
      };
      listener.EndContact = function(contact) {
        var objId0 = contact.GetFixtureA().GetBody().GetUserData().id;
        var objId1 = contact.GetFixtureB().GetBody().GetUserData().id;
        if (!!objId0 && !!objId1 && objId0 !== objId1) {
          if (objId0 < objId1) {
            _pending.push(evt.EndContact(objId0, objId1));
          } else {
            _pending.push(evt.EndContact(objId1, objId0));
          }
        }
      };
      listener.PostSolve = function(contact, impulse) {
      };                   
      listener.PreSolve = function(contact, oldManifold) {
      };
      _world.SetContactListener(listener);
    };

    var despawn = function(id) {
      forBody(id, function(b, u) {
        _world.DestroyBody(b);
      });
    };

    var update = function(t){
      var stepRate = _adaptative ? (t - _lastTimestamp) / 1000 : (1 / _intervalRate);
      var b = _world.GetBodyList();
      while(b !== null) {
        var ud = null;
        if (b.IsActive() && (ud = b.GetUserData()) !== null) {
          updateForce(ud, b, (1 / stepRate));
        }
        b = b.m_next;
      }
     
      _world.Step(
        stepRate
        , 1 //velocity iteration
        , 1 //position iteration
      );
      _world.ClearForces();
      _lastTimestamp = t;
    };

    var pushStates = function(out) {
      var b = _world.GetBodyList();
      while(b !== null) {
        var ud = b.GetUserData();
        if (b.IsActive() && ud !== null && ud.id !== null) {
          var p = b.GetPosition();
          var a = b.GetAngle();
          var force = ud.boost;//0.3;//(0.1 * dt);
          var acc = Vec3F(Math.cos(a) * force, Math.sin(a) * force, 0);
          //Speed or Acceleration ?
          out.push(evt.MoveObjTo(ud.id, Position(p.x * _scale, p.y * _scale, a), acc));
        }
        b = b.m_next;
      }
    };

    var updateForce = function(ud, b, dt) {
      if (ud.boost !== 0) {
        //b.wakeUp();
        // if (myBody->IsAwake() == true)
        var a = b.GetAngle();
        var force = ud.boost;//0.3;//(0.1 * dt);
        var acc = new B2Vec2(Math.cos(a) * force, Math.sin(a) * force);
        b.ApplyForce(acc, b.GetPosition()); //b.GetCenterPosition()
        //trace("velocity");
        //trace(b.GetLinearVelocity());
      } else { //if stabilistor
        //b.setLinearVelocity(new B2Vec2(0.0, 0.0));
      }
    };

    /**
     * @param {Id} id
     * @param {function(B2Body, UserData)} f
     */
    var forBody = function(id, f) {
      var back = null;
      /*
      var b = _world.GetBodyList();
      var done = false;
      while(b !== null && !done) {
      */
      var b = _id2body[id];
      if (b !== null && typeof b !== 'undefined') {
        var ud = b.GetUserData();
        //trace(ud);
        //trace(id);
//        if (!!ud && ud.id == id) { //TODO check if active ?
//          done = true;
          back = f(b, ud);
//        } else {
//          b = b.m_next;
//        }
      } else {
        console.warn('body not found : ' + id);
      }
      return back;
    };

    var setBoost = function(shipId, state) {
      console.log("setBoost", shipId);
      forBody(shipId, function(b, ud) {
        console.debug(b, b.GetPosition());
        b.SetAwake(true);
        ud.boost = state?0.3 : 0.0;
      });
    };

    var setAngle = function(shipId, a) {
      forBody(shipId, function(b, ud) {
        b.SetAwake(true);
        // should take care of dampling (=> * 3)
        b.SetAngularVelocity(0);// 180 * rot * _degToRad * 3); //90 deg per second
        b.SetAngle(a); //TODO rotate until raise the target angle instead of switch
      });
    };

    var setRotation = function(shipId, rot) {
      forBody(shipId, function(b, ud) {
        b.SetAwake(true);
        // should take care of dampling (=> * 3)
        b.SetAngularVelocity( 180 * rot * _degToRad * 3); //90 deg per second
      });
    };
    
    var impulseObj = function(objId, a, force) {
      forBody(objId, function(b, ud) {
        //console.debug('impulse2', objId, force, a);
        var impulse = Vec3F(Math.cos(a) * force, Math.sin(a) * force, 0);
        b.ApplyImpulse( impulse, b.GetWorldCenter() );
        b.SetAwake(true);
        //console.debug(GetWorldCenter());
      });
    };
    //TODO load from models
    var spawnShip = function(id, pos) {
      _bodyDef.type = B2Body.b2_dynamicBody;
      _bodyDef.position.x = pos.x /_scale;
      _bodyDef.position.y = pos.y /_scale;
      _bodyDef.angle = pos.a;
      _bodyDef.linearDamping = 1.0;
      _bodyDef.angularDamping = 0.31;
      _bodyDef.userData = UserData(id, 0);//{ var id = id; var boost = false; };
      var s = B2PolygonShape.AsVector(
        [
          new B2Vec2(2 /_scale, 0),
          new B2Vec2(-1 /_scale, 1 /_scale),
          new B2Vec2(-1 /_scale, -1 /_scale)
        ]
        , 3
      );
      _fixDef.shape = s;
      _fixDef.density = 1.0 * _scale;
      //_world.setContactListener(WorldContactListener());
      _fixDef.isSensor = false;
      return createBody(id, _bodyDef).CreateFixture(_fixDef);
    };

    //TODO load from models
    var spawnArea = function(id, scene3d) {
      _bodyDef.type = B2Body.b2_staticBody;
      _bodyDef.position.x = 0;
      _bodyDef.position.y = 0;
      _bodyDef.angle = 0;
      _bodyDef.userData = UserData(id, false);//{ var id = id; var boost = false; };
      var body = _world.CreateBody(_bodyDef);
      var obj3d = scene3d.objects.wall;
      if (!obj3d) return;

      var faces = obj3d.geometry.faces;
      var vertices = obj3d.geometry.vertices;
      //TODO should apply obj.matrixWorld to vertices
      var scalex = obj3d.scale.x;
      var scaley = obj3d.scale.y;
      //obj3d.materials.push(new THREE.MeshBasicMaterial( { color: 0x000000, shading: THREE.FlatShading, wireframe: true, transparent: true } ));
      //var markColor = obj3d.materials.length -1 ;
      faces.forEach(function(face) {
        var edges = _.reduce([face.a, face.b, face.c, face.d], function(acc, v) {
          //Face3 doesn't have face.d
          if (typeof v !== "undefined" && v !== null) {
            var v2 = new B2Vec2((vertices[v].x * scalex + obj3d.position.x) / _scale, (vertices[v].y * scaley + obj3d.position.y) /_scale);
            // Guard
            //TODO remove guard an do check in exported (v3 distinct, Face3 store as Face4)
            if (acc.length === 0 || ((acc[acc.length - 1].x !== v2.x || acc[acc.length - 1].y !== v2.y) && (acc[0].x !== v2.x || acc[0].y !== v2.y))) {
              acc.push(v2);
            } else {
              console.warn('duplicate vertices in the Face', face, v, v2, acc[acc.length -1 ], acc[0]);
              //face.vertexColors = new THREE.Color(0xff0000);
              //face.color = new THREE.Color(0xff0000);
            }
         }
         return acc;
        }, []);
        
        if (edges.length > 2) {      
          // check if direct oriented       
          /*
          var accum = 0.0;
          for (var i2 = 0; i2 < edges.length; i2++) {
            var j = (i2 + 1) % edges.length;
            accum += edges[j].x * edges[i2].y - edges[i2].x * edges[i2].y;
          }
          if (accum > 0) {
            edges.reverse();
          face.vertexColors = new THREE.Color(0xff0000);
          face.color = new THREE.Color(0xff0000);
          }
          */
          //console.debug(edges);
          var s = B2PolygonShape.AsVector(edges, edges.length);
            
          //var s = new B2EdgeShape(new B2Vec2(p0[0], p0[1]), new B2Vec2(p1[0], p1[1]));
          _fixDef.shape = s;
          _fixDef.isSensor = false;
          body.CreateFixture(_fixDef);
        } else {
          // visual effect for the polygone (eg: change color)
          console.warn('edges.length of area < 3', edges, face);
          //face.vertexColors = new THREE.Color(0xff0000);
          //face.color = new THREE.Color(0xff0000);
        }
        //  face.materialIndex = markColor;
//obj3d.geometry.dynamic = true;
//obj3d.geometry.__dirtyColors = true;
//obj3d.material.vertexColors = THREE.FaceColors;
/*        
        // create a set of polygone (4 side but not right angle as a work around for chainEdge support not available in box2D 2.1
        // or try b2EdgeShape edgeShape;  edgeShape.Set( b2Vec2(-15,0), b2Vec2(15,0) );
        var poly = [];
        var points = fragment.points;
        // if closed start with the edge point[-1] -> point[0]
        var startIndex = (points.length > 2 && fragment.closed) ? 0 : 1;
        for(var i = startIndex; i < points.length; i++) {
          
          var p0 = points[((i < 1)? points.length + i : i) - 1];
          var p1 = points[i];
          console.log(p0);
          console.log(p1);
          
          var dx = fragment.radius * ((p0[0] <= p1[0])? -1 : 1);
          var dy = fragment.radius * ((p0[1] <= p1[1])? -1 : 1);
          var edges = [
            new B2Vec2((p0[0] + dx)/_scale, (p0[1] - dy)/_scale),
            new B2Vec2((p1[0] - dx)/_scale, (p1[1] - dy)/_scale),
            new B2Vec2((p1[0] - dx)/_scale, (p1[1] + dy)/_scale),
            new B2Vec2((p0[0] + dx)/_scale, (p0[1] + dy)/_scale)
          ];
          var accum = 0.0;
          for (var i2 = 0; i2 < edges.length; i2++) {
            var j = (i2 + 1) % edges.length;
            accum += edges[j].x * edges[i2].y - edges[i2].x * edges[i2].y;
          }
          if (accum > 0) {
            edges.reverse();
          }
          console.log(edges);
          var s = B2PolygonShape.AsVector(edges, 4);
          
          //var s = new B2EdgeShape(new B2Vec2(p0[0], p0[1]), new B2Vec2(p1[0], p1[1]));
          _fixDef.shape = s;
          body.CreateFixture(_fixDef);
        }
*/          
      });
      return body;      
    };
    
    var findAvailablePos = function(newPos) {
      var pos = null;
      if  (typeof newPos === 'function') {
        //TODO avoid infinite loop
//        for(pos = newPos() ; isAvailable(pos) ; pos = newPos());       
        pos = Position(0,0,0);
      } else if (isAvailable(newPos)) {
        pos = newPos;
      }
      if (pos === null) {
        throw "Can't find available pos : " + newPos;
      }
      return pos;
    };

    var createBody = function(id, bodyDef) {
      var b = _world.CreateBody(bodyDef);
      _id2body[id] = b;
      return b;
    };

    var spawnTargetG1 = function(id, newPos) {
      var pos = findAvailablePos(newPos);

      _bodyDef.type = B2Body.b2_dynamicBody;
      _bodyDef.position.x = pos.x /_scale;
      _bodyDef.position.y = pos.y /_scale;
      _bodyDef.angle = pos.a;
      _bodyDef.fixedRotation = true;
      //_bodyDef.linearDamping = 1.0;
      //_bodyDef.angularDamping = 0.31;
      _bodyDef.userData = UserData(id, 0);
      var s = new B2CircleShape(1/ _scale);
      _fixDef.shape = s;
      _fixDef.density = 1.0 * _scale;
      //_fixDef.isSensor = true; 
      //console.debug("target", _fixDef);

      //return _world.CreateBody(_bodyDef).CreateFixture(_fixDef);
      return createBody(id, _bodyDef).CreateFixture(_fixDef);
    };

    var spawnBullet = function(emitterId) {
      return forBody(emitterId, function(b, ud) {
        var id = newId(emitterId + "-b");
        _bodyDef.type = B2Body.b2_dynamicBody;
        _bodyDef.position.x = b.GetPosition().x;
        _bodyDef.position.y = b.GetPosition().y;
        _bodyDef.angle = b.GetAngle();
//        _bodyDef.linearDamping = 0.0;
//        _bodyDef.angularDamping = 0.0;
//        _bodyDef.isSensor = false;
        _bodyDef.bullet = true;
        _bodyDef.userData = UserData(id, 0);
//        _bodyDef.position.x += 5;
        //_bodyDef.linearVelocity.x = 20 * Math.cos(a);
        //_bodyDef.linearVelocity.y = 20 * Math.sin(a);

        var s = new B2CircleShape(0.2/ _scale);
        _fixDef.shape = s;
        _fixDef.density = 1 * _scale;
        _fixDef.isSensor = false;
        var b2 = createBody(id, _bodyDef);
        b2.CreateFixture(_fixDef);
        var p = b2.GetPosition();
        var a = b2.GetAngle();
        var force = 0.01;//0.3;//(0.1 * dt);
        var impulse = Vec3F(Math.cos(a) * force, Math.sin(a) * force, 0);
        b2.ApplyImpulse( impulse, b.GetWorldCenter() );
        b2.SetAwake(true);
        return evt.SpawnObj(id, "bullet-01",Position(p.x * _scale, p.y * _scale, a));
      });
    };

    var newId = function(base) {
      return base + new Date().getTime();
    };

    initWorld();
    return self;
  };
});
/*
class WorldContactListener extends B2ContactListener {
  override public function beginContact(contact : B2Contact) {
    trace(contact);
  }
}
*/
/*
                                    void BeginContact(b2Contact* contact) {
                                        
                                            //check if fixture A was a ball
                                            void* bodyUserData = contact->GetFixtureA()->GetBody()->GetUserData();
                                                  if ( bodyUserData )
                                                            static_cast<Ball*>( bodyUserData )->startContact();
                                                    
                                                        //check if fixture B was a ball
                                                        bodyUserData = contact->GetFixtureB()->GetBody()->GetUserData();
                                                              if ( bodyUserData )
                                                                        static_cast<Ball*>( bodyUserData )->startContact();
                                                                
                                                                  }
                                      
                                        void EndContact(b2Contact* contact) {
                                            
                                                //check if fixture A was a ball
                                                void* bodyUserData = contact->GetFixtureA()->GetBody()->GetUserData();
                                                      if ( bodyUserData )
                                                                static_cast<Ball*>( bodyUserData )->endContact();
                                                        
                                                            //check if fixture B was a ball
                                                            bodyUserData = contact->GetFixtureB()->GetBody()->GetUserData();
                                                                  if ( bodyUserData )
                                                                            static_cast<Ball*>( bodyUserData )->endContact();
                                                                    
                                                                      }
                                          };
}
*/
