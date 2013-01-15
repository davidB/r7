define(
  ['r7/Ring', 'r7/Stage4UserInput', 'r7/Stage4Layer2D', 'r7/Stage4Render', 'r7/Stage4DatGui'],
  (Ring,      Stage4UserInput,      Stage4Layer2D,      Stage4Render,      Stage4DatGui) ->
    (container) -> Ring([
      Stage4UserInput(window.document.body).onEvent,
      Stage4Render(container).onEvent,
      Stage4Layer2D(window.document.getElementById('layer2D')).onEvent,
      Stage4DatGui().onEvent
    ])
)
