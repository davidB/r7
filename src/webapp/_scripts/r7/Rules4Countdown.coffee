define(["r7/evt"], (evt) ->
  () ->
    self = {}
    _tasks = {}
    _states = evt.newStates()
    onUpdateState = (out, k, v) ->
      if v is 0
        t = _tasks[k]
        if t?
          out.push(_tasks[k].timeoutEvt)  if _tasks[k].timeoutEvt isnt null
          delete _tasks[k]

          delete _states[k]

    decCountdown = (out, delta) ->
      for key of _tasks
        v = _states[key]
        v = Math.max(0, v - delta)
        _states.update(out, key, v, onUpdateState)

    self.onEvent = (e, out) ->
      switch e.k
        when "StartCountdown"
          _tasks[e.key] = e
          _states.update(out, e.key, e.timeout, onUpdateState)
        when "Tick"
          decCountdown(out, e.delta500 / 2)  if e.delta500 > 0
        else
          # pass
    self
)
