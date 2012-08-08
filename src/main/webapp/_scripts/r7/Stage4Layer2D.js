define(['r7/evt', 'domReady', 'ko', 'd3'], function(evt, domReady, ko, d3){
  var ViewModel = function() {
    this.score = ko.observable(0);
    this.energy = ko.observable(50);
    this.energyMax = ko.observable(100);
    this.energyRatio = ko.computed(function() {
      return this.energy() / this.energyMax();
    }, this);
    this.countdown = ko.observable('00:60');
    this.shieldActive = ko.observable(false);
    this.fireActive = ko.observable(false);
  };

  /**
   * @param {Element} container
   */
  return function(container){
    var self = {};
    var _shipIdP = '!';
    var _viewModel = new ViewModel();

    self.onEvent = function(e, out) {
      switch(e.k) {
        case 'Init' :
          d3.xml("/_images/gui.svg", "image/svg+xml", function(xml) {
            domReady(function(){
              if (xml === null) {
                //TODO log, notify user
                console.error('failed to load gui.svg');
                console.trace();
                return;
              }

              // var importedNode = document.importNode(xml.documentElement, true);
              // d3.select("#viz").node().appendChild(importedNode);
              container.appendChild(xml.documentElement);

              ko.applyBindings(_viewModel);
            });
          });
          break;
        case 'SpawnShip' :
          if (e.isLocal) _shipIdP = e.objId + '/';
          break;
        case 'UpdateVal' :
          if (e.key.indexOf(_shipIdP) === 0) {
            var fieldName = e.key.substring(_shipIdP.length);
            var field = _viewModel[fieldName];
            if (field !== null && typeof field !== 'undefined') {
              field(e.value);
              console.log('update', fieldName, field());
            }
          } else if (e.key === 'countdown') {
            var totalSec = Math.floor(e.value);
            var minutes = parseInt(totalSec / 60, 10);
            var seconds = parseInt(totalSec % 60, 10);
            var result = (minutes < 10 ? '0' + minutes : minutes) + ':' + (seconds  < 10 ? '0' + seconds : seconds);
            _viewModel.countdown(result);
          }
          break;
        default :
         // pass
      }
    };

    return self;
  };

});

  

