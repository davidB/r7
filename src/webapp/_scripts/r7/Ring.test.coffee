define ["r7/Ring"], (Ring) ->
  EventDemo = (s, i) ->
    s: s
    i: i

  
  ###
  @param {string} name
  @param {Array.<number>} reactInt
  @return {{received: Array.<*>, onEvent : function(*, Array.<*>)}}
  ###
  Stage4Demo = (name, reactInt) ->
    self = {}
    self.received = []
    self.onEvent = (e, out) ->
      self.received.push e
      if e.s is "A"
        i = 0

        while i < reactInt.length
          out.push EventDemo(name, e.i)  if reactInt[i] is e.i
          i++

    self

  b = Stage4Demo("B", [1, 2])
  c = Stage4Demo("C", [1])
  d = Stage4Demo("D", [3])
  sut = Ring([b.onEvent, c.onEvent, d.onEvent])
  
  #TODO push request to hamcrest (add test case before)
  #trace(Std.is(EventDemo("A", 1), Enum));
  #Assert.isTrue(EventDemo("A", 1) == EventDemo("A", 1));
  #Assert.isTrue(Type.enumEq(EventDemo("A", 1), EventDemo("A", 1)));
  #Assert.isTrue(Type.enumEq(EventDemo("A", 1), EventDemo("A", 33)));
  #    assertThat(EventDemo("A", 1), equalTo(EventDemo("A", 1)));
  #    assertThat([EventDemo("A", 1)], arrayContaining(EventDemo("A", 1)));
  describe "Ring", ->
    beforeEach ->
      b.received.length = 0
      c.received.length = 0
      d.received.length = 0

    it "should not failed for emptyRing", ->
      emptyRing = Ring([])
      emptyRing.push EventDemo("A", 0)
      out = []
      emptyRing.onEvent EventDemo("A", 1)
      expect(out).toEqual []

    it "should forward every mesages from outside to every stage", ->
      sut.push EventDemo("A", 0)
      expect(b.received).toEqual [EventDemo("A", 0)]
      expect(c.received).toEqual [EventDemo("A", 0)]
      expect(d.received).toEqual [EventDemo("A", 0)]

    it "should forward every mesages from inside to every stage", ->
      sut.push EventDemo("A", 1)
      expect(b.received).toEqual [EventDemo("A", 1), EventDemo("C", 1)]
      expect(c.received).toEqual [EventDemo("A", 1), EventDemo("B", 1)]
      expect(d.received).toEqual [EventDemo("A", 1), EventDemo("B", 1), EventDemo("C", 1)]
      sut.push EventDemo("A", 2)
      expect(b.received).toEqual [EventDemo("A", 1), EventDemo("C", 1), EventDemo("A", 2)]
      expect(c.received).toEqual [EventDemo("A", 1), EventDemo("B", 1), EventDemo("A", 2), EventDemo("B", 2)]
      expect(d.received).toEqual [EventDemo("A", 1), EventDemo("B", 1), EventDemo("C", 1), EventDemo("A", 2), EventDemo("B", 2)]

    
    #
    #    ring.push(EventDemo("A", 2));
    #    assertThat(b.received, equalTo([EventDemo("A", 1), EventDemo("C", 1), EventDemo("A", 2), EventDemo("A", 2)]));
    #    assertThat(c.received, equalTo([EventDemo("A", 1), EventDemo("B", 1), EventDemo("A", 2), EventDemo("B", 2), EventDemo("A", 2), EventDemo("B", 2)]));
    #    assertThat(d.received, equalTo([EventDemo("A", 1), EventDemo("B", 1), EventDemo("C", 1), EventDemo("A", 2), EventDemo("B", 2), EventDemo("A", 2), EventDemo("B", 2)]));
    #
    it "should not forward null", ->
      f = ->
        sut.push null

      expect(f).toThrow "try to push invalid value [0] : null"
      expect(b.received).toEqual []
      expect(c.received).toEqual []
      expect(d.received).toEqual []

    it "should not forward undefined", ->
      f = ->
        sut.push `undefined`

      expect(f).toThrow "try to push invalid value [0] : undefined"
      expect(b.received).toEqual []
      expect(c.received).toEqual []
      expect(d.received).toEqual []

    it "could act as a Stage", ->
      out = []
      sut.onEvent EventDemo("A", 1), out
      expect(out).toEqual [EventDemo("B", 1), EventDemo("C", 1)]
      out.length = 0
      sut.onEvent EventDemo("A", 2), out
      expect(out).toEqual [EventDemo("B", 2)]

    describe "Composable Ring", ->
      beforeEach ->
        b.received.length = 0
        c.received.length = 0
        d.received.length = 0

      ringBCD = Ring([b.onEvent, c.onEvent, d.onEvent])
      ringBC = Ring([b.onEvent, c.onEvent])
      ring0D = Ring([d.onEvent])
      ringBC_0D = Ring([ringBC.onEvent, ring0D.onEvent])
      ringBC_D = Ring([ringBC.onEvent, d.onEvent])
      ring0_BCD = Ring([Ring([]).onEvent, ringBCD.onEvent])
      ring_BCD = Ring([ringBCD.onEvent])
      ring_BC_D = Ring([ringBC_D.onEvent])
      empty = []
      ringBCD.push EventDemo("A", 1)
      expect(b.received.length).toBeGreaterThan 0
      expect_b_received_A1 = empty.concat(b.received)
      expect(c.received.length).toBeGreaterThan 0
      expect_c_received_A1 = empty.concat(c.received)
      expect(d.received.length).toBeGreaterThan 0
      expect_d_received_A1 = empty.concat(d.received)
      ringBCD.push EventDemo("A", 2)
      expect_b_received_A1A2 = empty.concat(b.received)
      expect_c_received_A1A2 = empty.concat(c.received)
      expect_d_received_A1A2 = empty.concat(d.received)
      testEquivBCD = (x) ->
        x.push EventDemo("A", 1)
        expect(b.received).toEqual expect_b_received_A1
        expect(c.received).toEqual expect_c_received_A1
        expect(d.received).toEqual expect_d_received_A1
        x.push EventDemo("A", 2)
        expect(b.received).toEqual expect_b_received_A1A2
        expect(c.received).toEqual expect_c_received_A1A2
        expect(d.received).toEqual expect_d_received_A1A2

      
      #[ringBC_D, ringBC_0D, ring0_BCD, ring_BC_D].forEach(testEquivBCD);
      it "behave BC_D like BCD", ->
        testEquivBCD ringBC_D

      it "behave BC_0D like BCD", ->
        testEquivBCD ringBC_0D

      it "behave _BCD like BCD", ->
        testEquivBCD ring_BCD

      it "behave 0_BCD like BCD", ->
        testEquivBCD ring0_BCD

      it "behave _BC_D like BCD", ->
        testEquivBCD ring_BC_D




