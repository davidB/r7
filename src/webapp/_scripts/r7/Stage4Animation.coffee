define(
  ['TWEEN', 'console', 'r7/evt'],
  (TWEEN, console, evt) ->
    back = () ->
      self = {}
      self.onEvent = (e, out) ->
        switch e.k

          #TODO initialize/reset
          when "Start", "Stop"
            TWEEN.removeAll()
          when "Tick"
            TWEEN.update(e.t)
          else
            # pass
      self
    back.scaleIn = (obj3d, onComplete) ->
      tween = (
        new TWEEN.Tween({x : 0, y : 0, z : 0})
        .to({x: obj3d.scale.x, y : obj3d.scale.y, z : obj3d.scale.z}, 300)
        .delay(0)
        .easing(TWEEN.Easing.Quadratic.In)
        .onUpdate(() ->
          obj3d.scale.set(this.x, this.y, this.z)
        )
      )
      tween.onComplete(() -> onComplete(obj3d)) if onComplete?
      obj3d.scale.set(0, 0, 0)
      tween.start()
      tween
    back.scaleOut = (obj3d, onComplete) ->
      tween = (
        new TWEEN.Tween({x : obj3d.scale.x, y : obj3d.scale.y, z : obj3d.scale.z})
        .to({x: 0, y : 0, z : 0}, 300)
        .delay(0)
        .easing(TWEEN.Easing.Quadratic.In)
        .onUpdate(() ->
          obj3d.scale.x = this.x
          obj3d.scale.y = this.y
          obj3d.scale.z = this.z
        )
      )
      tween.onComplete(() -> onComplete(obj3d)) if onComplete?
      tween.start()
      tween
    back.fadeOut1 = (obj3d, onComplete) ->
      tween = (
        new TWEEN.Tween({x : obj3d.material.opacity || 1})
        .to({x: 0}, 300)
        .delay(0)
        .easing(TWEEN.Easing.Linear.None)
        .onUpdate(() ->
          m = obj3d.material
          m.opacity = this.x
          m.needsUpdate = true
        )
      )
      tween.onComplete(() -> onComplete(obj3d)) if onComplete?
      tween.start()
      m = obj3d.material.clone()
      m.transparent = true
      m.needsUpdate = true
      obj3d.material = m
      tween
    back
)
