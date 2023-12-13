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

The F10 menu controlling the spawners during the mission can set to attach to either a coalition (blue or red) or a certain group. 
While the former gives access to everyone in that coalition, the latter limits the access to a group that can be either set or announced as host-only.

## Setup in the Mission Editor

## RepeatingSpawner

## OnetimeSpawner
