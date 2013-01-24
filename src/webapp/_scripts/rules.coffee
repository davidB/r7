define(
  ['r7/Rules4Countdown', 'r7/Rules4TargetG1', 'r7/Stage4GameRules', 'r7/Stage4Periodic', 'r7/Stage4Physics_chipmunk'],
  (Rules4Countdown,      Rules4TargetG1,      Stage4GameRules,      Stage4Periodic,      Stage4Physics) ->
    (evt) ->
      Stage4Periodic(evt)
      Rules4Countdown(evt)
      Rules4TargetG1(evt)
      Stage4GameRules(evt)
      Stage4Physics(evt)

)
