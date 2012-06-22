define(['THREE'], function(THREE){
  /** @type {models} */
  var exports = {
    /**
     * @param {string} modelId
     * @param {function(THREE.Object3D)} cbOk
     * @param {function(string)} cbKo
     */
    //TODO use Promise vs Callback
    find : function(modelId, cbOk, cbKo){
      new THREE.JSONLoader().load('_models/' + modelId + '.js', cbOk);
    },
    findArea : function(modelId /*: AreaModel*/) /*: Array<Path>*/ {
//  var w = 10.0;
      var x0 = -100.0;
      var y0 = -50.0;
      var x2 = 100.0;
      var y2 = 50.0;
      return [
        {
          points : [[x0, y0], [x2, y0], [x2, y2], [x0, y2]],
          closed : true,
          radius : 1.0
        }
//      new Path([[x2, y0], [x2, y2], [x0, y2], [x0, y0]], true)
//      new Path([[x0, y0], [x2, y0], [x2, y2], [x0, y2]], true)
/*
   new AreaStaticFragment([[x0, y0], [x0, y0 - w], [x2, y0 - w], [x2, y0]]),
      new AreaStaticFragment([[x2, y2], [x2, y0], [x2 + w, y0], [x2 + w, y2]]),
      new AreaStaticFragment([[x0, y2], [x2, y2], [x2, y2 + w], [x0, y2 + w]]),
      new AreaStaticFragment([[x0, y0], [x0, y2], [x0 - w, y2], [x0 - w, y0]])
*/    
      ];
    }
  };
  return exports;
});

// very basic path (sequence of point)
// TODO read from svg (see fabricjs or http://www.kevlindev.com/dom/path_parser/)
// TODO craete an json reader +  svg to json
/*
class  Path {
  public var points(default, null) : Array<Array<Float>>;
  public var closed : Bool;
  public var radius : Float;

  public function new (points, closed : Bool) {
    this.points = points;
    this.closed = closed;
    this.radius = 1.0;
  }
  //var texture : Dynamic;
}
*/
