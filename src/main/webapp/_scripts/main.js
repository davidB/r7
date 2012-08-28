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
    var lastDelta500 = -1;
    var loop = function() {
      // loop on r<F10>equest animation loop
      // - it has to be at the beginning of the function
      // - @see http://my.opera.com/emoller/blog/2011/12/20/requestanimationframe-for-smart-er-animating
      //RequestAnimationFrame.request(loop);
      // note: three.js includes requestAnimationFrame shim
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
      ring.push(evt.Tick(t, delta500));
    };

    loop();
  };
});
