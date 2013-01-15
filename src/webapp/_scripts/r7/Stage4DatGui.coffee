define(["dat"], (dat) ->

  ###
  @param {Element} container
  ###
  () ->
    self = {}
    _gui = new dat.GUI()
    self.onEvent = (e, out) ->
      e.setup(_gui) if e.k == "SetupDatGui"

    self
)
