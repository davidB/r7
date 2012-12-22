define("main.test",
 [
   "jasmine", "jasmine-html",
   #include all specs to be run
   "r7/evt.test", "r7/Ring.test", "r7/Rules4Countdown.test", "r7/Rules4TargetG1.test", "r7/Stage4GameRules.test"
 ],
 (jasmine) ->

   #run tests
   jasmine.getEnv().addReporter(new jasmine.TrivialReporter())
   jasmine.getEnv().execute()
)
