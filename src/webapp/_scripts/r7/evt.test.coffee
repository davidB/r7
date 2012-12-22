define(["r7/evt"], (evt) ->
  sut = evt

  ###
  @type {Timestamp}
  ###

  #TODO test creation with inavlid params
  #TODO test creation with missing params
  describe( "evt", () ->
    it( "should create object with kind \"k\" set to name of the method", () ->
      for p of sut
        p0 = p.toString().charAt(0)
        e = {}
        if p0 is p0.toUpperCase()
          e = if typeof sut[p] is "function" then sut[p].apply(sut) else sut[p]
          expect(e.k).toEqual(p)
    )
  )
)
