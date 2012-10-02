define(['r7/evt'], function(evt) {
  var sut = evt;
  /** @type {Timestamp}*/
  //TODO test creation with inavlid params
  //TODO test creation with missing params
  describe('evt', function() {
    it('should create object with kind "k" set to name of the method', function() {
      for(var p in sut) {
        var p0 = p.toString().charAt(0);
        var e = {};
        if (p0 === p0.toUpperCase()) {
          if (typeof sut[p] === 'function') {
            e = sut[p].apply(sut);
          } else {
            e = sut[p];
          }
          expect(e.k).toEqual(p);
        }
      }
    }); 
  });
});
