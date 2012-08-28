define(['r7/Ring'], function(Ring) {

  var EventDemo = function(s, i) {
    return {s : s, i : i};
  };

  /**
   * @param {string} name
   * @param {Array.<number>} reactInt
   * @return {{received: Array.<*>, onEvent : function(*, Array.<*>)}}
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

    it('should not failed for emptyRing', function() {
      var emptyRing = Ring([]);
      emptyRing.push(EventDemo("A", 0));

      var out = [];
      emptyRing.onEvent(EventDemo('A',1));
      expect(out).toEqual([]);
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
      var f = function(){sut.push(null);};
      expect(f).toThrow('try to push invalid value [0] : null');
      expect(b.received).toEqual([]);
      expect(c.received).toEqual([]);
      expect(d.received).toEqual([]);
    }); 
    it('should not forward undefined', function() {
      var f = function(){sut.push(undefined);};
      expect(f).toThrow('try to push invalid value [0] : undefined');
      expect(b.received).toEqual([]);
      expect(c.received).toEqual([]);
      expect(d.received).toEqual([]);
    });
    it('could act as a Stage', function() {
      var out = [];
      sut.onEvent(EventDemo("A", 1), out);
      expect(out).toEqual([EventDemo("B", 1), EventDemo("C", 1)]);
    
      out.length = 0;
      sut.onEvent(EventDemo("A", 2), out);
      expect(out).toEqual([EventDemo("B", 2)]);
    });

    describe('Composable Ring', function() {
      beforeEach(function() {
        b.received.length = 0;
        c.received.length = 0;
        d.received.length = 0;
      });

      var ringBCD = Ring([b.onEvent, c.onEvent, d.onEvent]);
      var ringBC = Ring([b.onEvent, c.onEvent]);
      var ring0D = Ring([d.onEvent]);

      var ringBC_0D = Ring([ringBC.onEvent, ring0D.onEvent]);
      var ringBC_D = Ring([ringBC.onEvent, d.onEvent]);
      var ring0_BCD = Ring([Ring([]).onEvent, ringBCD.onEvent]);
      var ring_BCD = Ring([ringBCD.onEvent]);
      var ring_BC_D = Ring([ringBC_D.onEvent]);

      var empty = [];

      ringBCD.push(EventDemo("A", 1));
      expect(b.received.length).toBeGreaterThan(0);
      var expect_b_received_A1 = empty.concat(b.received);
      expect(c.received.length).toBeGreaterThan(0);
      var expect_c_received_A1 = empty.concat(c.received);
      expect(d.received.length).toBeGreaterThan(0);
      var expect_d_received_A1 = empty.concat(d.received);
     

      ringBCD.push(EventDemo("A", 2));
      var expect_b_received_A1A2 = empty.concat(b.received);
      var expect_c_received_A1A2 = empty.concat(c.received);
      var expect_d_received_A1A2 = empty.concat(d.received);
    
      var testEquivBCD = function(x) {
        x.push(EventDemo("A", 1));
        expect(b.received).toEqual(expect_b_received_A1);
        expect(c.received).toEqual(expect_c_received_A1);
        expect(d.received).toEqual(expect_d_received_A1);
      

        x.push(EventDemo("A", 2));
        expect(b.received).toEqual(expect_b_received_A1A2);
        expect(c.received).toEqual(expect_c_received_A1A2);
        expect(d.received).toEqual(expect_d_received_A1A2);
      };
      //[ringBC_D, ringBC_0D, ring0_BCD, ring_BC_D].forEach(testEquivBCD);
      it('behave BC_D like BCD', function() { testEquivBCD(ringBC_D); });
      it('behave BC_0D like BCD', function() { testEquivBCD(ringBC_0D); });
      it('behave _BCD like BCD', function() { testEquivBCD(ring_BCD); });
      it('behave 0_BCD like BCD', function() { testEquivBCD(ring0_BCD); });
      it('behave _BC_D like BCD', function() { testEquivBCD(ring_BC_D); });
    });
  });
});

