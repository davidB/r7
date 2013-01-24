define(["ko"], (ko) ->

  showScreen = (id) ->
    screens = document.getElementsByClassName('screen_info')
    for screen in screens
      #screen.style.opacity = (screen.id === id)?1 : 0;
      screen.style.display = if (screen.id == id) then 'block' else 'none'
    false

  ViewModel = (evt) ->
    @score = ko.observable(0)
    @energy = ko.observable(50)
    @energyMax = ko.observable(100)
    @energyRatio = ko.computed((()-> @energy() / @energyMax()), this)
    @countdown = ko.observable("00:60")
    @shieldActive = ko.observable(false)
    @fireActive = ko.observable(false)
    @initialized =ko.observable(false)
    @start = () ->
      evt.GameStart.dispatch()
      showScreen('none')
    this

  ###
  @param {Element} container
  ###
  (evt, container) ->
    _shipIdP = "!"
    _viewModel = new ViewModel(evt)

    evt.GameInit.add(()->
      showScreen('screenInit')
      ko.applyBindings(_viewModel, container)
      _viewModel.initialized(false)
    )
    evt.GameInitialized.add(()->
      _viewModel.initialized(true)
    )
    evt.HudSpawn.add((objId, domElem)->
      document.getElementById("hud").appendChild(domElem) if domElem?
      ko.applyBindings(_viewModel, container)
    )
    evt.SetLocalDroneId.add((objId)->
      _shipIdP = objId + "/"
    )
    evt.ValUpdate.add((key, value) ->
      if key.indexOf(_shipIdP) is 0
        fieldName = key.substring(_shipIdP.length)
        field = _viewModel[fieldName]
        field(value) if field?
      else if key is "countdown"
        totalSec = Math.floor(value)
        minutes = parseInt(totalSec / 60, 10)
        seconds = parseInt(totalSec % 60, 10)
        result = (
          (if minutes < 10 then "0" + minutes else minutes)
          + ":"
          + (if seconds < 10 then "0" + seconds else seconds)
        )
        _viewModel.countdown(result)
    )
    null
)
