define(['r7/Position', 'r7/assetsLoader'], (Position, assetsLoader) ->

  (evt) ->
    evt.GameInit.add(()->
      assetsLoader.preload('cube0', 'model')
      evt.DevMode.dispatch()
    )
    evt.GameStart.add(() ->
      assetsLoader.find('cube0' ).then((x) -> _pending.push(evt.SpawnObj("cube0", Position.zero, x))).done()
    )
    null
)
