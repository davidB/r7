define([], () ->
  #TODO may be in future use a json objet (with uniform representation in physics and render) ??
  P = (x, y, a) -> {
    x : x
    y : y
    a : a
  }
  P.zero = P(0,0,0)
  P
)
