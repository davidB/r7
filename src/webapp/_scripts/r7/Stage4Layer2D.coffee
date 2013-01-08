define(["r7/evt", "ko"], (evt, ko) ->
  ViewModel = () ->
    @score = ko.observable(0)
    @energy = ko.observable(50)
    @energyMax = ko.observable(100)
    @energyRatio = ko.computed((()-> @energy() / @energyMax()), this)
    @countdown = ko.observable("00:60")
    @shieldActive = ko.observable(false)
    @fireActive = ko.observable(false)
    this

  ###
  @param {Element} container
  ###
  (container) ->
    self = {}
    _shipIdP = "!"
    _viewModel = new ViewModel()
    self.onEvent = (e, out) ->
      switch e.k
        when "Init"
          ko.applyBindings(_viewModel, container)
        when "SpawnHud"
          container.appendChild(e.domElem) if e.domElem?
          ko.applyBindings(_viewModel, container)
        when "SpawnShip"
          _shipIdP = e.objId + "/"  if e.isLocal
        when "UpdateVal"
          if e.key.indexOf(_shipIdP) is 0
            fieldName = e.key.substring(_shipIdP.length)
            field = _viewModel[fieldName]
            field(e.value) if field?
          else if e.key is "countdown"
            totalSec = Math.floor(e.value)
            minutes = parseInt(totalSec / 60, 10)
            seconds = parseInt(totalSec % 60, 10)
            result = (
              (if minutes < 10 then "0" + minutes else minutes)
              + ":"
              + (if seconds < 10 then "0" + seconds else seconds)
            )
            _viewModel.countdown(result)
        else
          # pass
    self
)
