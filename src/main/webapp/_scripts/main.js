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
    'ui',
    'rules'
], function(
  Ring,
  evt,
  timer,
  ui,
  rules
) {

  return function(){
    var container = window.document.getElementById('layers');

    var ring = Ring([
      ui(container).onEvent,
      rules.onEvent
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
