define([], () ->

  ###
  ###
  (evt)->
    _tasks = []

    registerPeriodic = (id, interval, signal, args) ->
      e = {id: id, interval: interval, runAt: 0, signal: signal, args: args}
      _tasks.push(e)

    unregisterPeriodic = (id) ->
      _tasks = _tasks.filter((v) -> v.id isnt id)


    # other implementation could be to use an array sort by runAt and only process runAt < t (like a priorityQueue)
    ping = (t) ->
      _tasks.forEach((task) ->
        if task.runAt < t
          task.signal.dispatch.apply(this, task.args)
          task.runAt = t + task.interval
      )

    evt.PeriodicEvtAdd.add(registerPeriodic)
    evt.PeriodicEvtDel.add(unregisterPeriodic)
    evt.Tick.add(ping)
    null
)
