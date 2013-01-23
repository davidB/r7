define(['r7/evt', 'r7/Position', 'r7/assetsLoader', 'underscore'], (evt, Position, assetsLoader, _) ->

  ###
  @param {Element} container
  ###
  () ->
    self = {}
    _pending = []
    self.onEvent = (e, out) ->
      switch e.k
        when 'Init'
          assets = _.map(
            [
              {kind : 'model', id : 'cube0'},
            ],
            (x) -> assetsLoader.preload(x.id, x.kind)
          )
          out.push(evt.DevMode)
        when 'Start'
          assetsLoader.find('cube0' ).then((x) -> _pending.push(evt.SpawnObj("cube0", Position.zero, x))).done()
      evt.moveInto(_pending, out)

    self
)
