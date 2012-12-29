define(["console", "THREE", "r7/evt", "underscore", 'preloadjs'], (console, THREE, evt, _, PreloadJS) ->
  ->
    self = {}
    _pending = []

    _waitingStart = false
    preload = new PreloadJS()
    preload.onFileLoad = (e) -> console.log("preload onFileLoad", e)
    preload.onProgress = (e) ->
      console.log("preload onProgress", e)
      if (e.loaded == e.total) and _waitingStart
        console.log(">>>>>>>>>>>>>>>>>> push start")
        _pending.push(evt.Start)
        _waitingStart = false
    preload.onFileProgress = (e) -> console.log("preload onFileProgress", e)
    preload.onError = (e) -> console.error("preload onError", e)
    preload.setMaxConnections(5)
    preload.initialize(true)
    preload.load()

    self.onEvent = onEvent = (e, out) ->
      switch e.k
        when 'Init'
          preload.close()
        when 'Preload'
          manifest = e.assets.map((a) -> switch a.kind
            when 'scene'
              { id : a.id, type : PreloadJS.JSON, src: a.src || '_models/' + a.id + '.scene.js' }
            when 'model'
              { id : a.id, type : PreloadJS.JSON, src : a.src || '_models/' + a.id + '.js' }
            when 'hud'
              { id : a.id, type : PreloadJS.SVG, src : a.src || '_images/' + a.id + '.svg' }
            else
              { id : a.id, src : a.src}
          )
          _waitingStart = true if (e.startOnComplete)
          preload.loadManifest(manifest, true)
        when "SpawnTargetG1", "SpawnShip"
          loadObj3d(e)  if !!e.modelId and (not e.obj3d?)
        when "SpawnArea"
          loadScene(e)  if !!e.modelId and (not e.scene3d?)
        when "SpawnObj"
          makeSphere(e, 1.0) if e.modelId is "bullet-01"  if !!e.modelId and (not e.scene3d?)
        else
          #pass
      evt.moveInto(_pending, out)


    # Blenders euler order is 'XYZ', but the equivalent euler rotation order in Three.js is 'ZYX'
    fixOrientation = (obj3d) ->
      y2 = obj3d.rotation.z
      z2 = -obj3d.rotation.y

      #m.rotation.x = ob.rot[0];
      #obj3d.rotation.y = y2;
      #obj3d.rotation.z = z2;
      obj3d.eulerOrder = "ZYX"
      obj3d

    loadScene = (e) ->
      d = preload.getResult(e.modelId)
      console.log("loadScene", d)
      new THREE.SceneLoader().parse(JSON.parse(d.result), (result) ->
        _.each(result.objects, fixOrientation)
        e.scene3d = result
        console.debug("spawn scene3d ", e.modelId)
        _pending.push(e)
      , d.src)

    loadObj3d = (e) ->
      loader = new THREE.JSONLoader()
      d = preload.getResult(e.modelId)
      texturePath = loader.extractUrlBase( d.src )
      loader.createModel(JSON.parse(d.result), (geometry, materials) ->

        #var material = new THREE.MeshNormalMaterial();
        #var material = new THREE.MeshNormalMaterial( { shading: THREE.SmoothShading } );
        #geometry.materials[ 0 ].shading = THREE.FlatShading;
        #var material = new THREE.MeshFaceMaterial();
        #material = materials[0]

        #TODO should create a new object or at least change the timestamp
        e.obj3d = fixOrientation(new THREE.Mesh(geometry, new THREE.MeshFaceMaterial(materials)))
        console.debug("spawn obj3d ", e.modelId)
        _pending.push(e)
      , texturePath)

    makeSphere = (e, r) ->
      geometry = new THREE.CubeGeometry(r, r, r)
      material = new THREE.MeshBasicMaterial({
        color: 0xff0000
        wireframe: false
      })
      e.obj3d = new THREE.Mesh(geometry, material)
      _pending.push(e)

    self
)
