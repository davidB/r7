define([], () ->
  (evt) ->
    _tasks = {}

    decCountdown = (t, delta500) ->
      return if delta500 <= 0
      delta = (delta500 / 2)
      for key of _tasks
        t = _tasks[key]
        v = t.timeout
        v = Math.max(0, v - delta)
        if v == 0
          delete _tasks[key]
          t.signal.dispatch.apply(this, t.args)
        else
          t.timeout = v
          evt.ValUpdate.dispatch(key, v)

    evt.CountdownStart.add((key, timeout, signal, args) ->
      _tasks[key] = {timeout: timeout, signal: signal, args: args}
    )
    evt.CountdownStop.add((key) ->
      delete _tasks[key]
    )
    evt.Tick.add(decCountdown)
    null
)
