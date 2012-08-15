define([
    'r7/Ring',
    'r7/Stage4UserInput',
    'r7/Stage4Layer2D',
    'r7/Stage4Loaders',
    'r7/Stage4Render',
    'THREE'
], function(
  Ring,
  Stage4UserInput,
  Stage4Layer2D,
  Stage4Loaders,
  Stage4Render,
  THREE
) {

  return function(container){
    return Ring([
      Stage4UserInput(window.document.body).onEvent,
      Stage4Loaders().onEvent,
      Stage4Render(container).onEvent,
      Stage4Layer2D(window.document.getElementById('layer2D')).onEvent
    ]);
  };
});
