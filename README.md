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
Inside the mission editor, first go to the trigger tab. Load MOOSE and [AI_Spawner_v1.lua](AI_Spawner_v1.lua) at mission start.

![image]()

Then, load your mission script 5 seconds after mission start.  
It is important to NOT load the mission script at mission start, otherwise there is a chance some functions won't work.

![image]()

### Basic Guidelines

- Each spawner includes ONLY ONE unit category (airplane, helicopter, ground unit, or ship).
- Each spawner corresponds to ONLY ONE task (e.g. CAP, CAS, ground attack, etc.)
- **Routes** are refered to units placed on the map representing where the spawned units will go and what they are tasked for.
- **Templates** are refered to units placed on the map representing a set of choices the spawned units will be chosen from.
- Routes and templates can be shared between different spawners as long as they have the same unit category and task.

### Placing Routes

Routes are where the spawner will choose to spawn units from.
Set the waypoints, tasks, addvance waypoint options, and AI difficulty here.
Name the group name accordingly. Be sure to set them as late activation.

![image]()

### Placing Templates

Templates can be placed anywhere on the map. 
Set the vehicle type, number of vehicles per group, their payloads, and their liveries here. 
Name the group name accordingly and set them as late activation as well.

![image]()

## RepeatingSpawner

Create a spawner for red CAP and tank.  
Check the document for more info on how to set the schedules.

```lua
do
  -- For airplane or helicopter (air units)

  -- create tables containing routes and templates respectively
  local routeTbl_RED_CAP = {"RED CAP 001", "RED CAP 002", "RED CAP 003"}
  local templateTbl_RED_CAP = {"RED CAP Template 001", "RED CAP Template 002"}

  -- create and setup a spawner
  local spawner_RED_CAP = RepeatingSpawner.new("RED CAP", routeTbl_RED_CAP, templateTbl_RED_CAP)
  spawner_RED_CAP.setSubMenuBranchName("RED AIR")
  spawner_RED_CAP.setRadiusVariation(24000)
  spawner_RED_CAP.setHeightVariation(4000)
  spawner_RED_CAP.setScheduleTable(1, {})
  spawner_RED_CAP.setScheduleTable(2, {{300, 0.3}, {600, 0.3}})
  spawner_RED_CAP.setScheduleTable(3, {{900, 0.3, 600, 0.3}})
  spawner_RED_CAP.setScheduleTable(4, {{150, 0.3, 300, 0.3, 3600}})
  spawner_RED_CAP.setInitialLevel(2)
  spawner_RED_CAP.run()


  -- For ground unit or ship (not air units)

  -- create tables containing routes and templates respectively
  local routeTbl_RED_TANK = {"RED TANK 001", "RED TANK 002", "RED TANK 003", "RED TANK 004"}
  local templateTbl_RED_TANK = {"RED TANK Template 001"}

  -- create and setup a spawner
  local spawner_RED_TANK = RepeatingSpawner.new("RED TANK", routeTbl_RED_TANK, templateTbl_RED_TANK)
  spawner_RED_TANK.setSubMenuBranchName("RED GROUND")
  spawner_RED_TANK.setRadiusVariation(3000)
  spawner_RED_TANK.setScheduleTable(1, {})
  spawner_RED_TANK.setScheduleTable(2, {{600, 0.3, 1200, 0.3}})
  spawner_RED_TANK.setInitialLevel(1)
  spawner_RED_TANK.run()


  -- A helper function to add a F10 menu for checking the current status of the spwaners
  MenuShowRepeatingSpawnerStatus({spawner_RED_CAP, spawner_RED_TANK})
end
```

## OnetimeSpawner

Create 30 AAA randomly from 50 preset locations at mission start with respawn after destroyed enabled.
```lua
do
  -- create the route table with 50 routes
  local routeTbl_RED_AAA = {}
  for i = 1, 50 do
    table.insert(routeTbl_RED_AAA, "RED AAA " .. string.format("%03d", i))
  end

  -- create the template table
  local templateTbl_RED_AAA = {"RED AAA Template 001", "RED AAA Template 002", "RED AAA Template 003"}

  -- create a spawner
  local spawner_RED_AAA = OnetimeSpawner.new("RED AAA", routeTbl_RED_AAA, templateTbl_RED_AAA, 30)

  -- set respawn after destroyed on (default is off without calling this function)
  spawner_RED_AAA.setRespawn(0.25, 1800, 0.1)

  -- activate the spawner
  spawner_RED_AAA.run()
end
```

## OnetimeSpawnerGroup

Create a group of OnetimeSpawners (can only have one) for late activation via F10 menu.

```lua
do
  -- let's say we already have two OnetimeSpawner set and ready
  -- DO NOT call run() function for these two spawners
  local routeTbl_RED_SAM_G1 = {"RED SAM 001", "RED SAM 002", "RED SAM 003"}
  local routeTbl_RED_SAM_G2 = {"RED SAM 004", "RED SAM 005", "RED SAM 006"}
  local templateTbl_RED_SAM = {"RED SAM Template 001", "RED SAM Template 002"}

  local spawner_RED_SAM_G1 = OnetimeSpawner.new("RED SAM G1", routeTbl_RED_SAM_G1, templateTbl_RED_SAM, 2)
  local spawner_RED_SAM_G2 = OnetimeSpawner.new("RED SAM G2", routeTbl_RED_SAM_G2, templateTbl_RED_SAM, 2)

  -- create and setup a OnetimeSpawnerGroup
  local group_RED_SAM = OnetimeSpawnerGroup.new("RED SAM Group", {spawner_RED_SAM_G1, spawner_RED_SAM_G2})
  group_RED_SAM.setSubMenuBranchName("Mission Setup")
  group_RED_SAM.run()
end
```

## Doccuments

### `RepeatingSpawner.new(name, routeTable, templateTable)`

RepeatingSpawner constructor.  
Creates a new RepeatingSpawner object.

**Parameters:**
<table>
  <tr>
    <td>#string <b>name</b></td>
    <td>The name of the spawner. Must be Unique within the mission.</td>
  </tr>
  <tr>
    <td>#table <b>routeTable</b></td>
    <td>The table of route's group name strings shown in the ME.</td>
  </tr>
  <tr>
    <td>#table <b>templateTable</b></td>
    <td>The table of template's group name strings shown in the ME.</td>
  </tr>
</table>

**Return values:**
<table>
  <tr>
    <td>#RepeatingSpawner</td>
    <td>self</td>
  </tr>
</table>

### `RepeatingSpawner.setSubMenuBranchName(menuName)`

Set the name of the sub menu this spawner's menu will be located at.

**Parameters:**
<table>
  <tr>
    <td>#string <b>menuName</b></td>
    <td>The name of the sub menu branch.</td>
  </tr>
</table>

**Return values:**
<table>
  <tr>
    <td>#nil</td>
  </tr>
</table>

### `RepeatingSpawner.setControlGroupName(groupName)`

With this function called, ONLY the set group will have access to the spawner options in the F10 menu.  
The set group must be alive at the moment the mission script loads. In other word, mission host must enter the slot and load into the cockpit before unpause the mission at the start. 

By default, the F10 menu access is set to coalition BLUE.

**Parameters:**
<table>
  <tr>
    <td>#string <b>groupName</b></td>
    <td>The name of the group that will only have F10 menu access to the spawner options.</td>
  </tr>
</table>

**Return values:**
<table>
  <tr>
    <td>#nil</td>
  </tr>
</table>

### `RepeatingSpawner.setControlSide(side)`

Set the F10 menu access to the spawner options to a coalition.

**Parameters:**
<table>
  <tr>
    <td>#string <b>side</b></td>
    <td>Either "BLUE" or "RED". Default is coalition BLUE.</td>
  </tr>
</table>

**Return values:**
<table>
  <tr>
    <td>#nil</td>
  </tr>
</table>

### `RepeatingSpawner.setSpawnLimit(limit)`

Set the maximum amount of groups the spawner can spawn.

**Parameters:**
<table>
  <tr>
    <td>#number <b>limit</b></td>
    <td>The maximum amount of groups the spawner can spawn.</td>
  </tr>
</table>

**Return values:**
<table>
  <tr>
    <td>#nil</td>
  </tr>
</table>

### `RepeatingSpawner.setRadiusVariation(distance)`

Set the radius variation of the waypoints in feet.

**Parameters:**
<table>
  <tr>
    <td>#number <b>distance</b></td>
    <td>The radius variation in feet.</td>
  </tr>
</table>

**Return values:**
<table>
  <tr>
    <td>#nil</td>
  </tr>
</table>

### `RepeatingSpawner.setHeightVariation(distance)`

Set the height variation (between $height$ and $height + distance$) of the waypoints in feet.

**Parameters:**
<table>
  <tr>
    <td>#number <b>distance</b></td>
    <td>The height variation in feet.</td>
  </tr>
</table>

**Return values:**
<table>
  <tr>
    <td>#nil</td>
  </tr>
</table>

### `RepeatingSpawner.setEscortPointVec(pointVec3)`

Set the position of escorts will stay relative to the spawned units.

**Parameters:**
<table>
  <tr>
    <td>Core.Point#POINT_VEC3 <b>pointVec3</b></td>
    <td>The position of escorts will stay relative to the spawned units. Defined in MOOSE.</td>
  </tr>
</table>

**Return values:**
<table>
  <tr>
    <td>#nil</td>
  </tr>
</table>

### `RepeatingSpawner.setEscort(escortRouteTable, escortTemplateTable, escortLastWaypoint, escortEngageDistance)`

### `RepeatingSpawner.setScheduleTable(level, schedule)`

### `RepeatingSpawner.getSubMenuBranchName()`

### `RepeatingSpawner.getLevel()`

### `RepeatingSpawner.getCount()`

### `RepeatingSpawner.getLimit()`

### `RepeatingSpawner.spawnOneGroup()`

### `RepeatingSpawner.run()`

### `MenuShowRepeatingSpawnerStatus(repeatingSpawnerTable)`

