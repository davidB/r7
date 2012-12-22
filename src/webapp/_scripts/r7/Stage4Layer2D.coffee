define(["r7/evt", "domReady", "ko", "module"], (evt, domReady, ko, module) ->
  ViewModel = () ->
    @score = ko.observable(0)
    @energy = ko.observable(50)
    @energyMax = ko.observable(100)
    @energyRatio = ko.computed((()-> @energy() / @energyMax()), this)
    @countdown = ko.observable("00:60")
    @shieldActive = ko.observable(false)
    @fireActive = ko.observable(false)
    this


  #TODO move xhr methods into a network/resource utils lib
  xhr = (url, mime, callback) ->
    req = new XMLHttpRequest
    req.overrideMimeType(mime) if mime and req.overrideMimeType
    req.open("GET", url, true)
    req.setRequestHeader("Accept", mime)  if mime
    req.onreadystatechange = ->
      if req.readyState is 4
        s = req.status
        callback(if not s and req.response or s >= 200 and s < 300 or s is 304 then req else null)

    req.send(null)


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
          #d3.xml("/_images/gui.svg", "image/svg+xml", function(xml) {
          console.log(module, module.config())
          xhr(module.config().baseUrl + "_images/gui.svg", "image/svg+xml", (req) ->
            (domReady) ->
              xml = req and req.responseXML
              if xml is null

                #TODO log, notify user
                console.error("failed to load gui.svg")
                return
              console.log("LOAD >>>>> SVG")
              # var importedNode = document.importNode(xml.documentElement, true);
              # d3.select("#viz").node().appendChild(importedNode);
              container.appendChild(xml.documentElement)
              ko.applyBindings(_viewModel)
          )

        when "SpawnShip"
          _shipIdP = e.objId + "/"  if e.isLocal
        when "UpdateVal"
          if e.key.indexOf(_shipIdP) is 0
            fieldName = e.key.substring(_shipIdP.length)
            field = _viewModel[fieldName]
            field(e.value) if field?

          #console.debug('update', fieldName, field());
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
