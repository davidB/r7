define(["console", "THREE", "r7/evt", "underscore"], (console, THREE, evt, _) ->
  ->
    self = {}
    _pending = []
    self.onEvent = onEvent = (e, out) ->
      switch e.k
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
      new THREE.SceneLoader().load("_models/" + e.modelId + ".scene.js?" + new Date().getTime(), (result) ->
        _.each(result.objects, fixOrientation)
        e.scene3d = result
        console.debug("spawn scene3d ", e.modelId)
        _pending.push(e)
      )

    loadObj3d = (e) ->
      new THREE.JSONLoader().load("_models/" + e.modelId + ".js?" + new Date().getTime(), (geometry, materials) ->

        #var material = new THREE.MeshNormalMaterial();
        #var material = new THREE.MeshNormalMaterial( { shading: THREE.SmoothShading } );
        #geometry.materials[ 0 ].shading = THREE.FlatShading;
        #var material = new THREE.MeshFaceMaterial();
        #material = materials[0]

        #TODO should create a new object or at least change the timestamp
        e.obj3d = fixOrientation(new THREE.Mesh(geometry, new THREE.MeshFaceMaterial(materials)))
        console.debug("spawn obj3d ", e.modelId)
        _pending.push(e)
      )

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
