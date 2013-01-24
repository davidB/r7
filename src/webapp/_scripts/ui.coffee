define(
  ['r7/Stage4UserInput', 'r7/Stage4Layer2D', 'r7/Stage4Render', 'r7/Stage4Animation'],
  (Stage4UserInput,      Stage4Layer2D,      Stage4Render,      Stage4Animation) ->
    (evt, container) ->
      Stage4UserInput(evt)
      Stage4Animation(evt)
      Stage4Render(evt, container)
      #Stage4Layer2D(window.document.getElementById('layer2D')).onEvent
      Stage4Layer2D(evt, container)
)
