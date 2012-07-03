define([], function(){
  //TODO Optimisation memoise (area of valid camera, full result,...) or use a state object

  var zmax = function(area, tanAngle) {
    var m = function(min, max, tanAngle) {
      return (max - min) / (2 * tanAngle);
    };
    return Math.min(m(area.xmin, area.xmax, tanAngle), m(area.ymin, area.ymax, tanAngle));
  };

  /**
   * @param {{x : {Number}, y : {Number}} target
   * @param {Number} distance
   * @param {Camera} camera
   * @param {{xmin : {Number}, xmax : {Number}, ymin : {Number}, ymax : {Number}}} area
   */
  var follow = function(target, distance, camera, area){
    var tanAngle = Math.abs(Math.tan(camera.fov * Math.PI /(180 * 2 ))); // half of the fov
    var z = Math.max(0, Math.min(zmax(area, tanAngle), camera.position.z));
    var margin = z * tanAngle;
    var x = Math.max( area.xmin + margin, Math.min(area.xmax - margin, target.x));
    var y = Math.max( area.ymin + margin, Math.min(area.ymax - margin, target.y));
    camera.position.x = x;
    camera.position.y = y;
    camera.position.z = z;
    camera.lookAt({x : x, y :y, z: 0});
  };
  return follow;
});
