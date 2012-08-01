define(['r7/Ring'], function(Ring) {

  var EventDemo = function(s, i) {
    return {s : s, i : i};
  };

  /**
   * @constructor
   * @param {string} name
   * @param {Array.<number>} reactInt
   */
  var Stage4Demo = function(name, reactInt){
    var self = {};
    self.received = [];
    self.onEvent = function(e, out) {
      self.received.push(e);
      if (e.s == "A") {
        for(var i = 0; i < reactInt.length; i++){
          if (reactInt[i] == e.i) {
            out.push(EventDemo(name, e.i));
          }
        }
      }
    };
    return self;
  };

  var b = Stage4Demo("B", [1,2]);
  var c = Stage4Demo("C", [1]);
  var d = Stage4Demo("D", [3]);

  var sut = Ring([b.onEvent, c.onEvent, d.onEvent]);
  console.log('sut0', sut);
//TODO push request to hamcrest (add test case before)
//trace(Std.is(EventDemo("A", 1), Enum));
//Assert.isTrue(EventDemo("A", 1) == EventDemo("A", 1));
//Assert.isTrue(Type.enumEq(EventDemo("A", 1), EventDemo("A", 1)));
//Assert.isTrue(Type.enumEq(EventDemo("A", 1), EventDemo("A", 33)));
//    assertThat(EventDemo("A", 1), equalTo(EventDemo("A", 1)));
//    assertThat([EventDemo("A", 1)], arrayContaining(EventDemo("A", 1)));


  describe('Ring', function() {
    beforeEach(function() {
      b.received.length = 0;
      c.received.length = 0;
      d.received.length = 0;
    });

    it('should forward every mesages from outside to every stage', function() {
      sut.push(EventDemo("A", 0));
      expect(b.received).toEqual([EventDemo("A", 0)]);
      expect(c.received).toEqual([EventDemo("A", 0)]);
      expect(d.received).toEqual([EventDemo("A", 0)]);
    });
    it('should forward every mesages from inside to every stage', function() {
      sut.push(EventDemo("A", 1));
      expect(b.received).toEqual([EventDemo("A", 1), EventDemo("C", 1)]);
      expect(c.received).toEqual([EventDemo("A", 1), EventDemo("B", 1)]);
      expect(d.received).toEqual([EventDemo("A", 1), EventDemo("B", 1), EventDemo("C", 1)]);
    

      sut.push(EventDemo("A", 2));
      expect(b.received).toEqual([EventDemo("A", 1), EventDemo("C", 1), EventDemo("A", 2)]);
      expect(c.received).toEqual([EventDemo("A", 1), EventDemo("B", 1), EventDemo("A", 2), EventDemo("B", 2)]);
      expect(d.received).toEqual([EventDemo("A", 1), EventDemo("B", 1), EventDemo("C", 1), EventDemo("A", 2), EventDemo("B", 2)]);
/*
    ring.push(EventDemo("A", 2));
    assertThat(b.received, equalTo([EventDemo("A", 1), EventDemo("C", 1), EventDemo("A", 2), EventDemo("A", 2)]));
    assertThat(c.received, equalTo([EventDemo("A", 1), EventDemo("B", 1), EventDemo("A", 2), EventDemo("B", 2), EventDemo("A", 2), EventDemo("B", 2)]));
    assertThat(d.received, equalTo([EventDemo("A", 1), EventDemo("B", 1), EventDemo("C", 1), EventDemo("A", 2), EventDemo("B", 2), EventDemo("A", 2), EventDemo("B", 2)]));
*/
    });
    it('should not forward null', function() {
      sut.push(null);
      expect(b.received).toEqual([]);
      expect(c.received).toEqual([]);
      expect(d.received).toEqual([]);
    }); 
    it('should not forward undefined', function() {
      sut.push(undefined);
      expect(b.received).toEqual([]);
      expect(c.received).toEqual([]);
      expect(d.received).toEqual([]);
    });
/*    
    it('should state the purpose', function() {
      expect(SampleModule.purpose).toBe("AMD testing");
    });

    it('should have its own dependencies', function() {
      expect(SampleModule.dependency).toBe("Module B");
    });
*/    
  });
  
	return {
		name: "Ring.test"
	};
});

