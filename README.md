# DCS-Randomized-Spawner

A script to set in advance and control during mission the spawning of AI units with randomized route and template for DCS world.  
This script is written based on [MOOSE](https://github.com/FlightControl-Master/MOOSE).

A revised version of this script is [here](https://github.com/s3antuan/DCS-UniversalSpawner).


## Abstract

This script is designed for event mission hosts to easily setup the spawners before the mission and make setting changes on the spawners via F10 menu during the mission.

![image](img/03.png)

![image](img/04.png)

![image](img/05.png)

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

![image](img/01.png)

Then, load your mission script 5 seconds after mission start.  
It is important to NOT load the mission script at mission start, otherwise there is a chance some functions won't work.

![image](img/02.png)

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

### Placing Templates

Templates can be placed anywhere on the map. 
Set the vehicle type, number of vehicles per group, their payloads, and their liveries here. 
Name the group name accordingly and set them as late activation as well.

## RepeatingSpawner

There are total 8 levels. Each level can have its own preset schedule for spawning. The default level is 1. 

Every schedules from levels smaller than and equal to the current level are considered active. E.g. the current level is 3, then schedules from level 1, 2, and 3 will be executed, schedules from level 4 and above won't.

Check the document [below](https://github.com/s3antuan/DCS-Randomized-Spawner/tree/main#schedule-table) for more info on how to set the schedules.

Create a spawner for red CAP and tank.

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

## Documents

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

Enable and set the escorts for spawned units.  
**escortRouteTable** must have the same number of elements as **routeTable** used in the constructor. Each pair of routes should be placed closed together.

**Parameters:**
<table>
  <tr>
    <td>#table <b>escortRouteTable</b></td>
    <td>The table of escort route's group name strings shown in the ME.</td>
  </tr>
  <tr>
    <td>#table <b>escortTemplateTable</b></td>
    <td>The table of escort template's group name strings shown in the ME.</td>
  </tr>
  <tr>
    <td>#number <b>escortLastWaypoint</b></td>
    <td>Number of waypoints (including waypoint 0) to escort.</td>
  </tr>
  <tr>
    <td>#number <b>escortEngageDistance</b></td>
    <td>The engaging distance in nautical mile.</td>
  </tr>
</table>

**Return values:**
<table>
  <tr>
    <td>#nil</td>
  </tr>
</table>

### `RepeatingSpawner.setInitialLevel(level)`

Set the initial level of the spawner (from 1 to 8).  
Default is 1.

**Parameters:**
<table>
  <tr>
    <td>#number <b>level</b></td>
    <td>The initial level of the spawner.</td>
  </tr>
</table>

**Return values:**
<table>
  <tr>
    <td>#nil</td>
  </tr>
</table>

### `RepeatingSpawner.setScheduleTable(level, schedule)`

Set the spawning schedules for each level.  
Only the levels set via this function will be shown in the F10 menu as an option.  
There is always a "spawn one group instantly" option even without calling this function.

**Parameters:**
<table>
  <tr>
    <td>#number <b>level</b></td>
    <td>The level to set (from 1 to 8).</td>
  </tr>
  <tr>
    <td>#table <b>schedule</b></td>
    <td>A table of tables representing the spawning schedule.</td>
  </tr>
</table>

**Return values:**
<table>
  <tr>
    <td>#nil</td>
  </tr>
</table>

#### Schedule table

Parameter **schedule** is a table of tables looks like below:

`{ {A, B, C, D, E}, {A, B, C, D, E}, ... }`, where:

- **A:** time for the first spawn.
- **B:** time variation of the first spawn (0 ~ 1) i.e., actual time for the first spawn = A ± (A * B)
- **C:** time interval between each subsequent spawns.
- **D:** time variation of subsequent spawns (0 ~ 1) i.e., actual time for the spawn = A + C * i ± (C * D) where i = 1, 2, 3, ...
- **E:** time for the scheduled spawning to stop.

All unit in seconds.

Examples:

- Empty `{}` spawns nothing.
- `{A, B, nil, nil, nil}` or `{A, B}` spawns only once.
- `{A, B, C, D, nil}` or `{A, B, C, D}` spawns repeatly on schedule.
- `{A, B, C, D, E}` spawns repeatly on schedule until stop time is reached.

### `RepeatingSpawner.getSubMenuBranchName()`

Return the sub menu branch name.

**Return values:**
<table>
  <tr>
    <td>#string</td>
  </tr>
</table>

### `RepeatingSpawner.getLevel()`

Return the current level.

**Return values:**
<table>
  <tr>
    <td>#number</td>
  </tr>
</table>

### `RepeatingSpawner.getCount()`

Return the current count of already spawned groups.

**Return values:**
<table>
  <tr>
    <td>#number</td>
  </tr>
</table>

### `RepeatingSpawner.getLimit()`

Return the maximum amount of groups the spawner can spawn.

**Return values:**
<table>
  <tr>
    <td>#number</td>
  </tr>
</table>

### `RepeatingSpawner.spawnOneGroup()`

Spawn one group immediately.

**Return values:**
<table>
  <tr>
    <td>#nil</td>
  </tr>
</table>

### `RepeatingSpawner.run()`

Activate the spawner. Run this function only after all the settings are done.

**Return values:**
<table>
  <tr>
    <td>#nil</td>
  </tr>
</table>

### `MenuShowRepeatingSpawnerStatus(repeatingSpawnerTable)`

Create an option in the F10 menu for all coalition sides to check the current spawner status.

**Parameters:**
<table>
  <tr>
    <td>#table <b>repeatingSpawnerTable</b></td>
    <td>A table of RepeatingSpawner objects. Any non-table value (e.g. a string) in this table will result in a blank line for better readability.</td>
  </tr>
</table>

**Return values:**
<table>
  <tr>
    <td>#nil</td>
  </tr>
</table>

### `OnetimeSpawner.new(name, routeTable, templateTable, numberOfSpawn)`

OnetimeSpawner constructor.  
Creates a new OnetimeSpawner object.

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
  <tr>
    <td>#number <b>numberOfSpawn</b></td>
    <td>Number of groups to spawn. Must be smaller than or equal to the length of routeTable.</td>
  </tr>
</table>

**Return values:**
<table>
  <tr>
    <td>#OnetimeSpawner</td>
    <td>self</td>
  </tr>
</table>

### `OnetimeSpawner.setRespawn(respawnProb, respawnTime, respawnTimeProb)`

Set respawn after destroyed on.

**Parameters:**
<table>
  <tr>
    <td>#number <b>respawnProb</b></td>
    <td>The probability for respawn after destroyed (0 ~ 1).</td>
  </tr>
  <tr>
    <td>#number <b>respawnTime</b></td>
    <td>The time for respawn after destroyed in seconds. The timer only starts when the entire group is destroyed.</td>
  </tr>
  <tr>
    <td>#number <b>respawnTimeProb</b></td>
    <td>The time variation of the respawn (0 ~ 1).</td>
  </tr>
</table>

**Return values:**
<table>
  <tr>
    <td>#nil</td>
  </tr>
</table>

### `OnetimeSpawner.run()`

Activate the spawner. Run this function only after all the settings are done. The spawn will happen once the mission script loads.

**Return values:**
<table>
  <tr>
    <td>#nil</td>
  </tr>
</table>

### `OnetimeSpawnerGroup.new(name, spawnerTable)`

OnetimeSpawnerGroup constructor.  
Creates a new OnetimeSpawnerGroup object.

**Parameters:**
<table>
  <tr>
    <td>#string <b>name</b></td>
    <td>The name of the group.</td>
  </tr>
  <tr>
    <td>#table <b>spawnerTable</b></td>
    <td>A table of OnetimeSpawner.</td>
  </tr>
</table>

**Return values:**
<table>
  <tr>
    <td>#OnetimeSpawnerGroup</td>
    <td>self</td>
  </tr>
</table>

### `OnetimeSpawnerGroup.setSubMenuBranchName(menuName)`

Set the name of the sub menu.

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

### `OnetimeSpawnerGroup.setControlGroupName(groupName)`

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

### `OnetimeSpawnerGroup.setControlSide(side)`

Set the F10 menu access to the options to a coalition.

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

### `OnetimeSpawnerGroup.run()`

Activate the spawner group. Run this function only after all the settings are done.

**Return values:**
<table>
  <tr>
    <td>#nil</td>
  </tr>
</table>
