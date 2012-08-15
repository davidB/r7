define([
    'r7/Ring',
    'r7/TargetG1',
    'r7/Stage4GameRules',
    'r7/Stage4Physics',
    'r7/Stage4Periodic'
], function(
  Ring,
  TargetG1,
  Stage4GameRules,
  Stage4Physics,
  Stage4Periodic
) {

  return Ring([
    Stage4Periodic().onEvent,
    TargetG1().onEvent,
    Stage4GameRules().onEvent,
    Stage4Physics().onEvent
  ]);

});
