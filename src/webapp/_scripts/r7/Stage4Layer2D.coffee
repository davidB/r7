define(["r7/evt", "ko"], (evt, ko) ->

  showScreen = (id) ->
    screens = document.getElementsByClassName('screen_info')
    for screen in screens
      #screen.style.opacity = (screen.id === id)?1 : 0;
      screen.style.display = if (screen.id == id) then 'block' else 'none'
    false

  ViewModel = (pending) ->
    @score = ko.observable(0)
    @energy = ko.observable(50)
    @energyMax = ko.observable(100)
    @energyRatio = ko.computed((()-> @energy() / @energyMax()), this)
    @countdown = ko.observable("00:60")
    @shieldActive = ko.observable(false)
    @fireActive = ko.observable(false)
    @initialized =ko.observable(false)
    @start = () ->
      console.log("START")
      pending.push(evt.Start)
      showScreen('none')
    this

  ###
  @param {Element} container
  ###
  (container) ->
    self = {}
    _pending = []
    _shipIdP = "!"
    _viewModel = new ViewModel(_pending)

    self.onEvent = (e, out) ->
      switch e.k
        when "Init"
          showScreen('screenInit')
          ko.applyBindings(_viewModel, container)
          _viewModel.initialized(false)
        when "Initialized"
          _viewModel.initialized(true)
          console.log("dummy")
        when "SpawnHud"
          document.getElementById("hud").appendChild(e.domElem) if e.domElem?
          ko.applyBindings(_viewModel, container)
        when "SetLocalDroneId"
          _shipIdP = e.objId + "/"
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
      evt.moveInto(_pending, out)
    self
)
