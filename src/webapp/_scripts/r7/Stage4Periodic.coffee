define(["r7/evt"], (evt) ->

  ###
  ###
  ()->
    self = {}
    _pending = []
    _tasks = []
    self.onEvent = (e, out) ->
      switch e.k
        when "RegisterPeriodicEvt"
          registerPeriodic(e)
        when "UnRegisterPeriodicEvt"
          unregisterPeriodic(e.id)
        when "Tick"
          ping(e.t)
        else
          # pass
      evt.moveInto(_pending, out)

    registerPeriodic = (e) ->
      e.runAt = 0
      _tasks.push(e)

    unregisterPeriodic = (id) ->
      _tasks = _tasks.filter((v) -> v.id isnt id)


    # other implementation could be to use an array sort by runAt and only process runAt < t (like a priorityQueue)
    ping = (t) ->
      _tasks.forEach((task) ->
        if task.runAt < t
          _pending.push(task.evt)
          task.runAt = t + task.interval
      )

    self
)
