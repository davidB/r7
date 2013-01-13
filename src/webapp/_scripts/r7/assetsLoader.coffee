define(["console", "THREE", "chipmunk", "underscore", 'preloadjs', 'Q'], (console, THREE, cp, _, PreloadJS, Q) ->

  _preload = new PreloadJS()
  _preload.onFileLoad = (e) ->
    console.log("preload onFileLoad", e)
    e.data.resolve(e)
  _preload.onProgress = (e) -> console.log("preload onProgress", e)
  _preload.onFileProgress = (e) -> console.log("preload onFileProgress", e)
  _preload.onError = (e) ->
    console.error("preload onError", e)
    e.data.reject(e)
  _preload.setMaxConnections(5)
  _preload.initialize(true)
  _preload.load()

  _cache = {}

  _area02 = {
    width : 16 #nbcell
    height : 9 #nbcell
    cellr : 10
    walls : {
      cells : [1,2,0,4] #cellunit [x0,y0,w0,h0, x1,y1,....]
    }
    zones : [
      { k : "targetg1/spawn", cells : [0,0,1,1, 3,4,1,1] }
      { k : "gate/in",    cells : [3,3,1,1] }
    ]
  }


  # Blenders euler order is 'XYZ', but the equivalent euler rotation order in Three.js is 'ZYX'
  fixOrientation = (obj3d) ->
    y2 = obj3d.rotation.z
    z2 = -obj3d.rotation.y

    #m.rotation.x = ob.rot[0];
    #obj3d.rotation.y = y2;
    #obj3d.rotation.z = z2;
    obj3d.eulerOrder = "ZYX"
    obj3d

  makeHud = (d) ->
    window.document.importNode(d.result.documentElement, true)

  makeArea = (d) ->
    area = d.result
    cellr = area.cellr
    cells2boxes3d = (cells, offx, offy) ->
      geometry = new THREE.Geometry()
      for i in [0 .. cells.length-1] by 4
        dx = cells[i+2] * cellr || 1
        dy = cells[i+3] * cellr || 1
        dz = Math.min(2, cellr / 2)
        mesh = new THREE.Mesh(new THREE.CubeGeometry(dx, dy, dz), new THREE.MeshNormalMaterial())
        mesh.position.x = cells[i+0] * cellr + dx / 2 + offx * cellr
        mesh.position.y = cells[i+1] * cellr + dy / 2 + offy * cellr
        THREE.GeometryUtils.merge(geometry, mesh)
      walls = new THREE.Mesh(geometry, new THREE.MeshNormalMaterial())
      obj3d = new THREE.Object3D()
      obj3d.add(walls)
      obj3d
    cells2boxes2d = (cells, offx, offy) ->
      body = new cp.Body(Infinity, Infinity)
      body.nodeIdleTime = Infinity
      body.shapes = []
      for i in [0 .. cells.length-1] by 4
        # TODO optim replace boxes (polyshape) by segment + thick (=> change the display)
        offset = cp.v((cells[i+0] + offx) * cellr, (cells[i+1] + offy) * cellr)
        w = cells[i+2] * cellr || 1
        h = cells[i+3] * cellr || 1
        verts = [ 0,0, 0,h, w,h, w,0 ]
        shape = new cp.PolyShape(body, verts, offset)
        body.shapes.push(shape)
      body
    addBorderAsCells = (w, h, cells) ->
      cells.push(-1, -1, w+2, 1)
      cells.push(-1, -1, 1, h+2)
      cells.push(w, -1, 1, h+2)
      cells.push(-1, h, w+2, 1)
    addBorderAsCells(area.width, area.height, area.walls.cells)
    area.walls.obj3d = () -> cells2boxes3d(area.walls.cells, area.width / -2, area.height/-2)
    area.walls.obj2d = () -> cells2boxes2d(area.walls.cells, area.width / -2, area.height/-2)
    area

  makeShip = (r) ->
    r.obj2d = () ->
      body = new cp.Body(100, Infinity)
      shape = new cp.PolyShape(body, [3, 0, -1, -1, -1, 1], cp.vzero)
      shape.sensor = false
      body.shapes = [shape]
      body
    r

  makeScene = (d) ->
    deferred = Q.defer()
    try
      new THREE.SceneLoader().parse(JSON.parse(d.result), (result) ->
        _.each(result.objects, fixOrientation)
        deferred.resolve(result)
      , d.src)
    catch exc
      deferred.reject(exc)
    deferred.promise

  makeModel = (d) ->
    deferred = Q.defer()
    try
      loader = new THREE.JSONLoader()
      texturePath = loader.extractUrlBase( d.src )
      loader.createModel(JSON.parse(d.result), (geometry, materials) ->

        #var material = new THREE.MeshNormalMaterial();
        #var material = new THREE.MeshNormalMaterial( { shading: THREE.SmoothShading } );
        #geometry.materials[ 0 ].shading = THREE.FlatShading;
        #var material = new THREE.MeshFaceMaterial();
        #material = materials[0]

        #TODO should create a new object or at least change the timestamp
        r = {}
        r.obj3d = () -> fixOrientation(new THREE.Mesh(geometry, new THREE.MeshFaceMaterial(materials)))
        deferred.resolve(r)
      , texturePath)
    catch exc
      deferred.reject(exc)
    deferred.promise

  makeSprite = (d) ->
    deferred = Q.defer()
    try
      texture = new THREE.Texture( d.result )
      texture.needsUpdate = true
      texture.sourceFile = d.src
      material = new THREE.SpriteMaterial( { map: texture, alignment: THREE.SpriteAlignment.topLeft, opacity: 1 } )
      obj3d = new THREE.Sprite(material)
      obj3d.scale.set( t.image.width, t.image.height, 1 )
      obj3d.computeBoundingBox()
      obj2d = { box : [obj3d.boundingBox.max.x, obj3d.boundingBox.max.y] }
      r = {obj3d : obj3d, obj2d : obj2d}
      deferred.resolve(r)
    catch exc
      deferred.reject(exc)

  makeBox = (rx, ry, rz, color) ->
    geometry = new THREE.CubeGeometry(rx, ry, rz || 1)
    material = new THREE.MeshBasicMaterial({
      color: color || 0xff0000
      wireframe: false
    })
    {
      obj3d : new THREE.Mesh(geometry, material)
      obj2d : { box : [rx, ry] }
    }

  preload = (id, kind, src) ->
    defer = Q.defer()
    result = defer.promise
    manifest = switch kind
      when 'scene'
        result = result.then(makeScene)
        { type : PreloadJS.JSON, src: src || '_models/' + id + '.scene.js' }
      when 'model'
        result = result.then(makeModel).then(makeShip)
        { type : PreloadJS.JSON, src : src || '_models/' + id + '.js' }
      when 'hud'
        result = result.then(makeHud)
        { type : PreloadJS.XML, src : src || '_images/' + id + '.svg' }
      when 'sprite'
        # THREE.ImageUtils.loadTexture( "_images/sprites/sprite0.png", undefined, (t) -> makeSprite(defer, t), (err) -> defer.reject(err) )
        result = result.then(makeSprite)
        { type : PreloadJS.IMAGE, src : src || '_images/' + id + '.png'}
      when 'area'
        defer.resolve({ result : _area02 })
        result = result.then(makeArea)
        null
      else
        result = result.then((x) -> x.result)
        { src : src}
    if manifest?
      manifest.id = id
      manifest.data = defer
      _preload.loadFile(manifest, true)
    _cache[id] = result
    result

  {
    find : (id) ->
      r = _cache[id] || Q.reject("id not found " + id )
      r.done()
      r
    clear: () ->
      _cache = {}
      _preload.close()
    preload : preload
  }
)
