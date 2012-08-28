define([
    'r7/Ring',
    'r7/Rules4Countdown',
    'r7/Rules4TargetG1',
    'r7/Stage4GameRules',
    'r7/Stage4Periodic',
    'r7/Stage4Physics'
], function(
  Ring,
  Rules4Countdown,
  Rules4TargetG1,
  Stage4GameRules,
  Stage4Periodic,
  Stage4Physics
) {

  return Ring([
    Stage4Periodic().onEvent,
    Rules4Countdown().onEvent,
    Rules4TargetG1().onEvent,
    Stage4GameRules().onEvent,
    Stage4Physics().onEvent
  ]);

});
