
pc.script.create("main0", (context) ->
  define('playCanvasContext', [], () -> context)
  require(['main'], (main) -> main())
)
