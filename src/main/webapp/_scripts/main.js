require.config({
  //baseUrl: "/another/path",
  urlArgs: "bust=" +  (new Date()).getTime(),
  enforceDefine: true,
  paths: {
    'jquery' : '../_vendors/jquery-1.7.1.min',
    'underscore': '../_vendors/underscore/1.3.3/underscore.min',
    'Stats': '../_vendors/stats/Stats',
    'THREE': '../_vendors/three/r49/Three',
    'dat' : '../_vendors/dat-gui/20111206/dat.gui.min',

    'Box2D' : '../_vendors/box2dweb/Box2D',
    // polyfil
    'webglDetector' : '../_vendors/Detector',
    'console' : '../_vendors/console_log',
    // requirejs plugins
    'domReady' : '../_requirejs/2.0.1/domReady'
  },
  shim: {
    'underscore':     { deps: [], exports: '_' },
    'dat':            { deps: [], exports: 'dat' },
    'THREE' :         { deps: [], exports: 'THREE' },
    'webglDetector' : { deps: [], exports: 'Detector'},
    'Stats' :         { deps: [], exports: 'Stats' },
    'Box2D' :         { deps: [], exports: 'Box2D' }
  },
  waitSeconds: 15,
  locale: "fr-fr"
});

define('console', [], function() {
  return console;
});

define('r7/timer', [], function(){
  return {
    t: function(){
      return new Date().getTime();
    }
  };
});

define('main', ['r7/Ring', 'r7/evt', 'r7/timer', 'r7/Stage4Stats', 'r7/Stage4UserInput', 'r7/Stage4Loaders', 'r7/Stage4Render','r7/Stage4Physics', 'r7/Position','THREE', 'r7/Stage4DatGui'], function(Ring, evt, timer, Stage4Stats, Stage4UserInput, Stage4Loaders, Stage4Render, Stage4Physics, Position, THREE, Stage4DatGui) {

  return function(){
    var container = window.document.body;

    var ring = Ring([
      Stage4UserInput(container).onEvent,
      Stage4Loaders().onEvent,
      Stage4Physics().onEvent,
      Stage4Render(container).onEvent,
      Stage4DatGui().onEvent,
      Stage4Stats(container).onEvent
    ]);
    ring.push(evt.Start());
    var loop = function() {
      // loop on r<F10>equest animation loop
      // - it has to be at the beginning of the function
      // - @see http://my.opera.com/emoller/blog/2011/12/20/requestanimationframe-for-smart-er-animating
      //RequestAnimationFrame.request(loop);
      // note: three.js includes requestAnimationFrame shim
      requestAnimationFrame(loop);
      ring.push(evt.Render(new Date().getTime()));
    };

    loop();
    ring.push(evt.SpawnCube());
    ring.push(evt.SpawnArea("area-1", 'area01', Position(0.0, 0.0, 0.0)));
    ring.push(evt.SpawnShip("ship-1", 'ship01', Position(0.0, 0.0, 0.5)));
    ring.push(evt.SpawnTargetG1("target-g1-1", 'targetg101', Position(0.0, 0.0, 1.0))); //TODO random position near ship
  };
});

require(['main'], function(main){
  main();
});
