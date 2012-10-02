define([], function(){
  //TODO may be in future use a json objet (with uniform representation in physics and render) ??
  return function(x, y, a) {
    return {
      x : x,
      y : y,
      a : a
    };
  };
});
/*
class Vec3F {
  public var x(default, null) : Float;
  public var y(default, null) : Float;
  public var z(default, null) : Float;

  public function new(x, y, z) {
    this.x = x;
    this.y = y;
    this.z = z;
  }
}

type Speed = Vec3F
type Acceleration = Vec3F
*/
