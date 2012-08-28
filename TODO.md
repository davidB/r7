# 0.1.0

1. --fix gameplay bug (energy management)--
1. --split big actual Ring into dedicated Ring for UI, GamePlay--
1. replace string 'ship' by 'drone' (code, doc)
1. fire bullet with '2' and not 'spacebar'

# 0.2.0

1. despawn/spawn targetG1 when hit (instead of impulse)
1. collision with wall crash the ship => management of respawn
1. tuning : adjust energy up/down (ex boost 20s should consumme all energy)

# 0.3.0

1. display value on targetG1
1. display shadow of ship
1. animations for spawn, despawn and other case (ex : ship rotate)
1. manage animations blending ?
1. "billboard", display information (2d) around 3d object
1. display via billboard gain of points (+1) with an animation

# 0.4.0

1. sound on events (blending ?, multi event in parallele ?)
1. control ship with mouse ?
1. ui/api from console to customize ships behavior (for dev)
1. remove ?bust on resources on GAE

# 0.5.0

1. add shield + implusion 
1. activate shield with '1'
1. add armor to shield (shield should consume armor on hit, or more energy ?)

# 0.6.0

1. background music
1. preload assets

# 0.7.0

1. loading screen (also display controls ?)
1. display title + instructions 

# 0.8.0

1. replay screen
1. polish visual assets items
1. make a box2dbebug visual layer ?

# 0.9.0

1. drone spawn area define in 3d model (blender : use property, name, material name ??)
1. use particules to display boost
1. use particules for explosions and some animations

# 0.10.0

1. provide a leaderboard (login, best score per game/ship)

# 1.0.0

1. first announce 1.0.0

# 1.1.0

1. control ship with joypad
1. display ads (where ?)
1. full screen (on/off)

# 1.2.0

1. ui to customize keys @settings
1. manage user/ship settings (store, autoreload, notify) @settings
1. ui to customize ships behavior @settings

# 1.3.0

1. control ship with touch @tablet
1. reactive resolution @tablet
1. display mini-radar

# 2.0.0

1. display name of pilot @multi
1. use a server + run 2 ships (try PuNub) @mutli

# Backlog
1. use Periodic Event to manage Energy, consommable ?, need for non-discret event (timeline, periodic sub-event)
1. move ring gamerules (include physics) in a WebWorker
