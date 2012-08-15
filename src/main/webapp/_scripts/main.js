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

define('main', [
    'r7/Ring',
    'r7/evt',
    'r7/timer',
    'r7/TargetG1',
    'r7/Stage4GameRules',
    'r7/Stage4UserInput',
    'r7/Stage4Layer2D',
    'r7/Stage4Loaders',
    'r7/Stage4Render',
    'r7/Stage4Physics',
    'THREE',
    'r7/Stage4DatGui',
    'r7/Stage4Periodic'
], function(
  Ring,
  evt,
  timer,
  TargetG1,
  Stage4GameRules,
  Stage4UserInput,
  Stage4Layer2D,
  Stage4Loaders,
  Stage4Render,
  Stage4Physics,
  THREE,
  Stage4DatGui,
  Stage4Periodic
) {

  return function(){
    var container = window.document.getElementById('layers');

    var ring = Ring([
      Stage4UserInput(window.document.body).onEvent,
      Stage4Periodic().onEvent,
      TargetG1().onEvent,
      Stage4GameRules().onEvent,
      Stage4Loaders().onEvent,
      Stage4Physics().onEvent,
      Stage4Render(container).onEvent,
      Stage4Layer2D(window.document.getElementById('layer2D')).onEvent
  //    Stage4DatGui().onEvent
    ]);
    ring.push(evt.Init);
    ring.push(evt.Start); //TODO push Start when ready and user hit star button
    var loop = function() {
      // loop on r<F10>equest animation loop
      // - it has to be at the beginning of the function
      // - @see http://my.opera.com/emoller/blog/2011/12/20/requestanimationframe-for-smart-er-animating
      //RequestAnimationFrame.request(loop);
      // note: three.js includes requestAnimationFrame shim
      requestAnimationFrame(loop);
      ring.push(evt.Tick(new Date().getTime()));
    };

    loop();
  };
});
