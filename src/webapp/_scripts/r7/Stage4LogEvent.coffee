define([], () ->

  (evt, kinds) ->
    for kind in kinds
      evt[kind].add(() -> console.log("LogEvent", kind, arguments))
    null
)
