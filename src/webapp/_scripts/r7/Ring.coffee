#
#interface Stage<T> {
#  public function onEvent(e : T, out : Array<T>) :Void;
#}
#
#class StageUtils {
#
#  public static function pushAll<T>(out : Array<T>, it : Iterable<T>) : Void {
#    for (i in it) {
#      out.push(i);
#    }
#  }
#}
#
define(['console'], (console)->
  pushNonEmpty = ->
    i = 0

    while i < arguments.length
      a = arguments[i]
      throw new Error("try to push invalid value [" + i + "] : " + a)  if not a?
      i++
    Array::push.apply(this, arguments)


  ###
  @param {Array.<function(*, Array)>} stages
  @return {onEvent: function(*, Array<*>), push: function(*)}
  //return {!Ring}
  ###
  Ring = (stages) ->
    self = {}

    #var noop = function(e, out) {};
    forward = (e, out) ->
      forward.dest.push(e)  if forward.dest isnt null

    forward.dest = []

    #pre-include noop/forward as entry point for pushed event from outside
    _ring = [forward].concat(stages).map((v) ->
      v.lastOut = []
      v.lastOut.push = pushNonEmpty
      v
    )
    self.push = (e) ->
      self.onEvent(e, null)

    self.onEvent = (e, out) ->
      _ring[0].dest = out # for forward.method
      _ring[0].lastOut.push(e)
      nbEvents = 1
      i = 1
      lg = _ring.length
      return  if i >= lg

      # process output of other stage until there is no event
      #TODO documentation : vs pipeline, vs bus, vs queue
      guard_loopMax = 3 * lg
      while nbEvents > 0 and guard_loopMax > 0
        guard_loopMax--
        entryI = _ring[i]
        nbEvents -= entryI.lastOut.length
        entryI.lastOut.length = 0 #inJS reset length to zero is better fot GC
        j = (i + 1) % lg

        while j isnt i
          entryJ = _ring[j]
          lg2 = entryJ.lastOut.length
          ei = 0

          while ei < lg2
            evt = entryJ.lastOut[ei]
            if not evt?
              console.warn("invalid evt", evt, ei, lg2, entryJ, entryJ.lastOut)
              continue
            try
              entryI.call(entryI, evt, entryI.lastOut)
            catch exc
              console.error("failed to apply event", evt)
              console.exception(exc)
            ei++
          j = (j + 1) % lg
        nbEvents += entryI.lastOut.length
        i = (i + 1) % lg

    self

  Ring
)
