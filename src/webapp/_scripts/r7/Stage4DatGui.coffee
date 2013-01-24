define(["dat"], (dat) ->

  (evt) ->
    _gui = new dat.GUI()
    evt.SetupDatGui.add((setup) -> setup(_gui))
    null
)
