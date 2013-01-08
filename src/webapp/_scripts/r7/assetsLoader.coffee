define(["console", "THREE", "underscore", 'preloadjs', 'Q'], (console, THREE, _, PreloadJS, Q) ->

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
        deferred.resolve(fixOrientation(new THREE.Mesh(geometry, new THREE.MeshFaceMaterial(materials))))
      , texturePath)
    catch exc
      deferred.reject(exc)
    deferred.promise

  makeSphere = (r) ->
    geometry = new THREE.CubeGeometry(r, r, r)
    material = new THREE.MeshBasicMaterial({
      color: 0xff0000
      wireframe: false
    })
    new THREE.Mesh(geometry, material)

  preload = (id, kind, src) ->
    defer = Q.defer()
    result = defer.promise
    manifest = switch kind
      when 'scene'
        result = result.then(makeScene)
        { type : PreloadJS.JSON, src: src || '_models/' + id + '.scene.js' }
      when 'model'
        result = result.then(makeModel)
        { type : PreloadJS.JSON, src : src || '_models/' + id + '.js' }
      when 'hud'
        result = result.then(makeHud)
        { type : PreloadJS.XML, src : src || '_images/' + id + '.svg' }
      else
        result = result.then((x) -> x.result)
        { src : src}
    manifest.id = id
    manifest.data = defer
    _preload.loadFile(manifest, true)
    _cache[id] = result
    result

  {
    find : (id) -> _cache[id] || Q.reject("id not found " + id )
    clear: () ->
      _cache = {}
      _preload.close()
    preload : preload
  }
)
