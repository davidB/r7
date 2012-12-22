define(
  [],
  ()->

    #TODO Optimisation memoise (area of valid camera, full result,...) or use a state object
    zmax = (area, tanAngle, aspect) ->
      m = (lg, tanAngle) -> lg / (2 * tanAngle)
      Math.min(m((area.xmax - area.xmin) / aspect, tanAngle), m((area.ymax - area.ymin), tanAngle))


    ###
    @param {{x : {Number}, y : {Number}}} target
    @param {Number} distance
    @param {Camera} camera
    @param {{xmin : {Number}, xmax : {Number}, ymin : {Number}, ymax : {Number}}} area
    ###
    (target, distance, camera, area) ->
      tanAngle = Math.abs(Math.tan(camera.fov * Math.PI / (180 * 2))) # half of the fov
      z = Math.max(0, Math.min(zmax(area, tanAngle, camera.aspect), camera.position.z))
      xmargin = (z * tanAngle) * camera.aspect * camera.scale.x
      ymargin = z * tanAngle * camera.scale.y
      x = Math.max(area.xmin + xmargin, Math.min(area.xmax - xmargin, target.x))
      y = Math.max(area.ymin + ymargin, Math.min(area.ymax - ymargin, target.y))
      camera.position.x = x
      camera.position.y = y
      camera.position.z = z
      camera.lookAt({
        x: x
        y: y
        z: 0
      })
)

