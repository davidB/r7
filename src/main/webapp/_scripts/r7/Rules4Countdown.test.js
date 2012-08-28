define(['r7/evt', 'r7/Rules4Countdown'], function(evt, Rules4Countdown) {
  describe('GameRules:countdown', function() {
    var extractCountdownChanges = function(out, key) {
      return out.filter(function(v) { 
        return (v.k === 'UpdateVal') && (v.key === key);
      });
    };
    var key = 'countdown/00';
    it('should stay unmodified until StartCountdown', function() {
      var sut = Rules4Countdown().onEvent;
      var out = [];
      sut(evt.Tick(0), out);
      sut(evt.Tick(33), out);
      var countdownChanges = extractCountdownChanges(out, key);
      expect(countdownChanges.length).toEqual(0);
      sut(evt.StartCountdown(key, 45, null), out);
      countdownChanges = extractCountdownChanges(out, key);
      expect(countdownChanges.length).toEqual(1);
    }); 
    it('should decrease with delta500 > 0', function() {
      var sut = Rules4Countdown(45).onEvent;
      var out = [];
      sut(evt.Tick(0, 0), out);
      sut(evt.StartCountdown(key, 45, null), out);
      var countdownChanges = extractCountdownChanges(out, key);
      var countdownStart = countdownChanges[0].value;
      expect(countdownStart).toNotEqual(0);
      for(var i = 1; i < countdownStart; i++) {
        out.length = 0;
        sut(evt.Tick(i * 1000, 2), out);
        countdownChanges = extractCountdownChanges(out, key);
        expect(countdownChanges.length).toEqual(1);
        expect(countdownChanges[0].value).toEqual(countdownStart - i);
      }
    }); 
    it('should decrease but stay >= 0', function() {
      var sut = Rules4Countdown().onEvent;
      var out = [];
      sut(evt.Tick(0, 0), out);
      sut(evt.StartCountdown(key, 45, null), out);
      out.length = 0;
      sut(evt.Tick(60 * 1000, 120), out);
      var countdownChanges = extractCountdownChanges(out, key);
      expect(countdownChanges.length).toEqual(1);
      expect(countdownChanges[0].value).toEqual(0);
    });
  });
});
