define(["r7/evt", "r7/Rules4Countdown"], (evt, Rules4Countdown) ->
  describe("GameRules:countdown", ->
    extractCountdownChanges = (out, key) ->
      out.filter (v) ->
        (v.k is "UpdateVal") and (v.key is key)


    key = "countdown/00"
    it("should stay unmodified until StartCountdown", ->
      sut = Rules4Countdown().onEvent
      out = []
      sut evt.Tick(0), out
      sut evt.Tick(33), out
      countdownChanges = extractCountdownChanges(out, key)
      expect(countdownChanges.length).toEqual 0
      sut evt.StartCountdown(key, 45, null), out
      countdownChanges = extractCountdownChanges(out, key)
      expect(countdownChanges.length).toEqual 1
    )
    it("should decrease with delta500 > 0", ->
      sut = Rules4Countdown(45).onEvent
      out = []
      sut evt.Tick(0, 0), out
      sut evt.StartCountdown(key, 45, null), out
      countdownChanges = extractCountdownChanges(out, key)
      countdownStart = countdownChanges[0].value
      expect(countdownStart).toNotEqual 0
      i = 1

      while i < countdownStart
        out.length = 0
        sut evt.Tick(i * 1000, 2), out
        countdownChanges = extractCountdownChanges(out, key)
        expect(countdownChanges.length).toEqual 1
        expect(countdownChanges[0].value).toEqual countdownStart - i
        i++
    )
    it("should decrease but stay >= 0", ->
      sut = Rules4Countdown().onEvent
      out = []
      sut evt.Tick(0, 0), out
      sut evt.StartCountdown(key, 45, null), out
      out.length = 0
      sut evt.Tick(60 * 1000, 120), out
      countdownChanges = extractCountdownChanges(out, key)
      expect(countdownChanges.length).toEqual 1
      expect(countdownChanges[0].value).toEqual 0
    )
  )
)
