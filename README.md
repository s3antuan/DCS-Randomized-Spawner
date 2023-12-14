# DCS-Randomized-Spawner

A script to set in advance and control during mission the spawning of AI units with randomized route and template for DCS world. 

This script is written based on [MOOSE](https://github.com/FlightControl-Master/MOOSE).


## Abstract

This script is designed for event mission hosts to easily setup the spawners before the mission and make setting changes on the spawners via F10 menu during the mission.

This script comes with two types of spawner: **RepeatingSpawner** and **OnetimeSpawner**. 

**RepeatingSpawner** is used when you want AI units to repeatedly spawn into the map with a given schedule. 
You can also instantly spawn in one group using the F10 menu.

**OnetimeSpawner** is used as an easy way to automatically spawn a large amount of similar units at the mission start (e.g. setup AAA or SAM). 
You can also group up several OnetimeSpawners and activate these spawners later during the mission via the F10 menu.

The F10 menu controlling the spawners during the mission can be set to attach to either a coalition (blue or red) or a certain group. 
While the former gives access to everyone in that coalition, the latter limits the access to a group that can be either set or announced as host-only at the cost of locking the host in the same slot the whole mission.

## Setup in the Mission Editor (ME)

### Adding the Script

This script requires MOOSE. You can find the latest version of MOOSE [here](https://github.com/FlightControl-Master/MOOSE).

Be aware that this script does *not* work with [MIST](https://github.com/mrSkortch/MissionScriptingTools) loaded.

Inside the mission editor, first go to the trigger tab.
Load MOOSE and [AI_Spawner_v1.lua](AI_Spawner_v1.lua) at mission start.

![image]()

Then, load your mission script 5 seconds after mission start.

![image]()

### Basic Guidelines

- Each spawner includes ONLY ONE unit category (airplane, helicopter, ground unit, or ship).
- Each spawner corresponds to ONLY ONE task (e.g. CAP, CAS, ground attack, etc.)
- **Routes** are refered to units placed on the map representing where the spawned units will go and what they are tasked for.
- **Templates** are refered to units placed on the map representing the vehicle type, number and their payload the spawned units will be.
- Routes and templates can be shared between different spawners as long as they have the same unit category and task.

### Placing Routes

### Placing Templates

## RepeatingSpawner

## OnetimeSpawner
