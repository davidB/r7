"use strict"

define('console', [], function() {
  if (!console.exception) {
    console.exception = function(exc){
      console.error(exc.message)
      console.error(exc.stack);
    }
  }
  return console;
});

define('r7/timer', [], function(){
  return {
    t: function(){
      return new Date().getTime();
    }
  };
});

define('main', [
    'r7/evt',
    'r7/timer',
    'r7/Stage4DevMode',
    'r7/Stage4LogEvent',
    'r7/Stage4DatGui',
    'ui',
    'rules',
    'console'
], function(
  evt,
  timer,
  Stage4DevMode,
  Stage4LogEvent,
  Stage4DatGui,
  ui,
  rules,
  console
) {

  return function(){
    var devMode = document.location.href.indexOf('dev=true') > -1;

    var container = window.document.getElementById('layers');

    rules(evt);
    ui(evt, container);
    if (devMode) {
      Stage4DevMode(evt);
      Stage4LogEvent(evt, ['Init', 'SpawnObj', 'DespawnObj', 'BeginContact', 'Start', 'Stop', 'Initialized']);
      Stage4DatGui(evt);
    }


    evt.GameInit.dispatch();
    //ring.push(evt.Start); //TODO push Start when ready and user hit star button
    var lastDelta500 = -1;
    var loop = function() {
      // loop on request animation loop
      // - it has to be at the beginning of the function
      // - @see http://my.opera.com/emoller/blog/2011/12/20/requestanimationframe-for-smart-er-animating
      //RequestAnimationFrame.request(loop);
      // note: three.js includes requestAnimationFrame shim
      //setTimeout(function() { requestAnimationFrame(loop); }, 1000/30);
      requestAnimationFrame(loop);
      var t = new Date().getTime();
      var delta500 = null;
      if (lastDelta500 === -1) {
        lastDelta500 = t;
        delta500 = 0;
      }
      var d = (t - lastDelta500) / 500;
      if (d >=  1) {
        lastDelta500 = t;
        delta500 = d;
      }
      evt.Tick.dispatch(t, delta500);
    };

    loop();
  };
});
