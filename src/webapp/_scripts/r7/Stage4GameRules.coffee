{
  "type": "block",
  "src": "{",
  "value": "{",
  "lineno": 39,
  "children": [],
  "varDecls": [],
  "labels": {
    "table": {},
    "size": 0
  },
  "functions": [],
  "nonfunctions": [],
  "transformed": true
}
{
  "type": "block",
  "src": "{",
  "value": "{",
  "lineno": 39,
  "children": [],
  "varDecls": [],
  "labels": {
    "table": {},
    "size": 0
  },
  "functions": [],
  "nonfunctions": [],
  "transformed": true
}
{
  "type": "block",
  "src": "{",
  "value": "{",
  "lineno": 39,
  "children": [],
  "varDecls": [],
  "labels": {
    "table": {},
    "size": 0
  },
  "functions": [],
  "nonfunctions": [],
  "transformed": true
}
{
  "type": "block",
  "src": "{",
  "value": "{",
  "lineno": 39,
  "children": [],
  "varDecls": [],
  "labels": {
    "table": {},
    "size": 0
  },
  "functions": [],
  "nonfunctions": [],
  "transformed": true
}
define ["r7/evt", "r7/Position"], (evt, Position) ->
  
  ###
  @param {Element} container
  ###
  ->
    self = {}
    _pending = evt.newListOfEvt()
    _shipId = "!"
    _states = evt.newStates()
    self.onEvent = (e, out) ->
      switch e.k
        when "Init"
          uid = new Date().getTime()
          out.push evt.SpawnCube()
          out.push evt.SpawnArea("area/" + uid, "area01", Position(0.0, 0.0, 0.0))
          _shipId = "ship/" + (uid + 1)
          out.push evt.SpawnShip(_shipId, "ship01", Position(0.0, 0.0, 0.5), null, true)
          updateState "running", false
        when "Start"
          updateState _shipId + "/energy", 500
          updateState _shipId + "/energyMax", 1000
          updateState _shipId + "/boosting", false
          updateState _shipId + "/shooting", false
          updateState _shipId + "/shielding", false
          updateState "running", true
          out.push evt.StartCountdown("countdown", 45, evt.Stop)
          out.push evt.Render
        when "ReqEvt"
          onReqEvent e.e
        when "BeginContact"
          
          #console.debug('contact', e);
          if e.objId0.indexOf("area/") is 0
            if e.objId1.indexOf("ship/") is 0

            
            # crash if no shield
            else e.objId1.indexOf("ship/1-b") is 0
        
        # despawn bullet
        
        #if (e.objId0 === 'ship/1' && e.objId1 === 'target-g1/1') {
        #TODO move some game rule from targetG1 here ?
        #out.push(incState('ship-1.score', 1));
        #}
        when "Tick"
          
          #console.debug("t", _lastSeconde, delta);
          updateEnergy(e.delta500)  if _states.running and e.delta500 >= 1
        
        # if boost decrease energy
        # if shield decrease energy
        # else increase energy
        # if no energy, stop boost, shield,...
        when "Stop"
          updateState "running", false
        else
      
      # pass
      evt.moveInto _pending, out

    onReqEvent = (e) ->
      switch e.k
        when "UpdateVal"
          updateState e.key, e.value
        
        #ignore
        when "IncVal"
          incState e.key, e.inc  if e.key.indexOf(_shipId) is 0
        when "BoostShipStart"
          _pending.push e
          updateState _shipId + "/boosting", true  if e.objId is _shipId
        when "BoostShipStop"
          _pending.push e
          updateState _shipId + "/boosting", false  if e.objId is _shipId
        when "ShootingStart"
          _pending.push e
          _pending.push evt.RegisterPeriodicEvt(_shipId + "-fire", 300, evt.ReqEvt(evt.FireBullet(_shipId)))  if e.emitterId is _shipId
        when "ShootingStop"
          _pending.push e
          _pending.push evt.UnRegisterPeriodicEvt(_shipId + "-fire")  if e.emitterId is _shipId
        when "FireBullet"
          if e.emitterId isnt _shipId
            _pending.push e
          else
            if _states[_shipId + "/energy"] > 7
              incState _shipId + "/energy", -7
              _pending.push e
        else
          _pending.push e

    incState = (k, v) ->
      _states.inc _pending, k, v, onUpdateState

    updateState = (k, v) ->
      _states.update _pending, k, v, onUpdateState

    onUpdateState = (out, k, v) ->
      onReqEvent evt.BoostShipStop(_shipId)  if _states[_shipId + "/boosting"]  if k is _shipId + "/energy" and v is 0

    updateEnergy = (delta) ->
      k = _shipId + "/energy"
      v = _states[k]
      unit = 0
      unit -= 5  if _states[_shipId + "/boosting"]
      
      #if (_states[_shipId + '/shooting']) unit -= 7;
      unit -= 10  if _states[_shipId + "/shielding"]
      unit += 3  if unit is 0
      v = Math.min(_states[k + "Max"], Math.max(0, v + unit))
      updateState k, v

    self

