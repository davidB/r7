define([], function(){
  //TODO Optimisation memoise (area of valid camera, full result,...) or use a state object

  var zmax = function(area, tanAngle, aspect) {
    var m = function(lg, tanAngle) {
      return lg / (2 * tanAngle);
    };
    return Math.min(m((area.xmax - area.xmin)/aspect, tanAngle), m((area.ymax - area.ymin), tanAngle));
  };

  /**
   * @param {{x : {Number}, y : {Number}}} target
   * @param {Number} distance
   * @param {Camera} camera
   * @param {{xmin : {Number}, xmax : {Number}, ymin : {Number}, ymax : {Number}}} area
   */
  var follow = function(target, distance, camera, area){
    var tanAngle = Math.abs(Math.tan(camera.fov * Math.PI /(180 * 2 ))); // half of the fov
    var z = Math.max(0, Math.min(zmax(area, tanAngle, camera.aspect), camera.position.z));
    var xmargin = (z * tanAngle) * camera.aspect * camera.scale.x;
    var ymargin = z * tanAngle * camera.scale.y;
    var x = Math.max( area.xmin + xmargin, Math.min(area.xmax - xmargin, target.x));
    var y = Math.max( area.ymin + ymargin, Math.min(area.ymax - ymargin, target.y));
    camera.position.x = x;
    camera.position.y = y;
    camera.position.z = z;
    camera.lookAt({x : x, y :y, z: 0});
  };
  return follow;
});
