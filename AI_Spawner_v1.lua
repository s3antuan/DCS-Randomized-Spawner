--
-- Randomized Route & Template AI Units Spawner Script (Repeating & Onetime)
-- Requires Moose as dependency
--
-- This is a combined revision code of Randomized_AI_Spawner_v3.1 & Onetime_AI_Spawner_v2
--
-- Version: v1
-- Author: Nyako 2-1 | ginmokusei
-- Date: Oct. 2023
--

do
	local scriptName = "AI_Spawner_v1"


	-- -----------------
	-- Helper Functions:
	-- -----------------

	local function shallowcopy(orig)
		local orig_type = type(orig)
		local copy
		if orig_type == "table" then
			copy = {}
			for orig_key, orig_value in pairs(orig) do
				copy[orig_key] = orig_value
			end
		else -- number, string, boolean, etc
			copy = orig
		end
		return copy
	end


	-- ------------------
	-- Repeating Spawner:
	-- ------------------

	RepeatingSpawner = {}

	function RepeatingSpawner.new(init_name, init_routeTable, init_templateTable)
		local self = {}

		-- Private variables:
		local routeTable = shallowcopy(init_routeTable)
		local templateTable = shallowcopy(init_templateTable)
		local unitCategory
		local isAirUnit
		local subMenuBranchName = nil
		local controlGroupName = nil
		local controlSide = coalition.side.BLUE
		local scheduleTable = {nil, nil, nil, nil, nil, nil, nil, nil}
		local level = 1
		local count = 0
		local limit = 0
		local routeRadiusVariation = 6076
		local routeHeightVariation = 4000
		local hasEscort = false
		local escortRouteTable
		local escortTemplateTable
		local escortLastWaypoint
		local escortEngageDistance
		local escortPointVec = POINT_VEC3:New(-1200, 300, -2000)

		unitCategory = GROUP:FindByName(routeTable[1]):GetCategoryName()
		if unitCategory == "Airplane" or unitCategory == "Helicopter" then
			isAirUnit = true
		else
			isAirUnit = false
		end

		-- Public variables:
		self.name = init_name

		-- Private methods:
		local function spawnAIEscort(escortedGroup, escortRoute)
			local groupName = self.name .. "_Escort_" .. tostring(count)
			local spawn = SPAWN:NewWithAlias(escortRoute, groupName)
				:InitRandomizeTemplate(escortTemplateTable)
				:OnSpawnGroup(function(spawnGroup)
					local escortDCSTask = spawnGroup:TaskEscort(escortedGroup, escortPointVec, escortLastWaypoint, UTILS.NMToMeters(escortEngageDistance))
					spawnGroup:SetTask(escortDCSTask, 1)
					end)
				:Spawn()
		end

		local function spawnAI()
			if limit > 0 and count >= limit then
				return
			end
			count = count + 1
			local groupName = self.name .. "_" .. tostring(count)
			local routeIndex = math.random(#routeTable)
			local route = routeTable[routeIndex]
			local spawn = SPAWN:NewWithAlias(route, groupName)
				:InitRandomizeTemplate(templateTable)
			if isAirUnit then
				spawn:InitRandomizeRoute(0, 1, UTILS.FeetToMeters(routeRadiusVariation), UTILS.FeetToMeters(routeHeightVariation))
					:OnSpawnGroup(function(spawnGroup)
						if hasEscort then
							SCHEDULER:New(spawnGroup, function()
								local escortRoute = escortRouteTable[routeIndex]
								spawnAIEscort(spawnGroup, escortRoute)
								end, {}, 3)
						end
						end)
					:Spawn()
			else
				spawn:InitRandomizeRoute(0, 1, UTILS.FeetToMeters(routeRadiusVariation)):Spawn()
			end
		end

		local function spawnAIScheduled(lvl)
			if level >= lvl then
				spawnAI()
			end
		end

		local function setLevel(lvl)
			MESSAGE:New(self.name .. ": Level set to " .. tostring(lvl), 10):ToAll()
			level = lvl
		end

		-- Public methods:
		function self.setSubMenuBranchName(menuName)
			subMenuBranchName = menuName
		end

		function self.setControlGroupName(groupName)
			controlGroupName = groupName
		end

		function self.setControlSide(side)
			if side == "BLUE" then
				controlSide = coalition.side.BLUE
			elseif side == "RED" then
				controlSide = coalition.side.RED
			else
				-- neutral is not available to play as :P
			end
		end

		function self.setSpawnLimit(lmt)
			limit = lmt
		end

		function self.setRadiusVariation(distance)
			routeRadiusVariation = distance
		end

		function self.setHeightVariation(distance)
			routeHeightVariation = distance
		end

		function self.setEscortPointVec(pointVec3)
			escortPointVec = pointVec3
		end

		function self.setInitialLevel(lvl)
			level = lvl
		end

		function self.setEscort(init_escortRouteTable, init_escortTemplateTable, init_escortLastWaypoint, init_escortEngageDistance)
			hasEscort = true
			escortRouteTable = shallowcopy(init_escortRouteTable)
			escortTemplateTable = shallowcopy(init_escortTemplateTable)
			escortLastWaypoint = init_escortLastWaypoint
			escortEngageDistance = init_escortEngageDistance
		end

		-- Parameter "schedule" is a table looks like below:
		-- { {A, B, C, D, E}, {A, B, C, D, E}, ... }, where:
		--     A: time for the first spawn
		--     B: time variation of the first spawn (0 ~ 1) i.e. actual time for the first spawn = A ± (A * B)
		--     C: time interval between each subsequent spawns
		--     D: time variation of subsequent spawns (0 ~ 1) i.e. actual time for the spawn = A + C * i ± (C * D) where i = 1, 2, 3, ...
		--     E: time for the scheduled spawning to stop
		--     all unit in seconds
		-- Examples:
		--     {A, B, nil, nil, nil} spawn only once
		--     {A, B, C, D, nil}     spawn repeatly on schedule
		--     {A, B, C, D, E}       spawn repeatly on schedule until stop time is reached
		--
		-- Note: directly references the original tables since deepcopy is not needed
		function self.setScheduleTable(level, schedule)
			if level == 1 then
				scheduleTable[1] = schedule
			elseif level == 2 then
				scheduleTable[2] = schedule
			elseif level == 3 then
				scheduleTable[3] = schedule
			elseif level == 4 then
				scheduleTable[4] = schedule
			elseif level == 5 then
				scheduleTable[5] = schedule
			elseif level == 6 then
				scheduleTable[6] = schedule
			elseif level == 7 then
				scheduleTable[7] = schedule
			elseif level == 8 then
				scheduleTable[8] = schedule
			else
				-- invalid level :P
			end
		end

		function self.getSubMenuBranchName()
			return subMenuBranchName
		end

		function self.getLevel()
			return level
		end

		function self.getCount()
			return count
		end

		function self.getLimit()
			return limit
		end

		function self.spawnOneGroup()
			spawnAI()
		end

		function self.run()
			if controlGroupName then
				local menuGroup = GROUP:FindByName(controlGroupName)
				local menu
				if subMenuBranchName then
					local tmp = MENU_GROUP:New(menuGroup, subMenuBranchName)
					menu = MENU_GROUP:New(menuGroup, self.name, tmp)
				else
					menu = MENU_GROUP:New(menuGroup, self.name)
				end

				MENU_GROUP_COMMAND:New(menuGroup, "Spawn One Group Immediately", menu, spawnAI, nil)
				for i = 1, 8 do
					if scheduleTable[i] then
						MENU_GROUP_COMMAND:New(menuGroup, "Set Level to " .. tostring(i), menu, setLevel, i)
					end
				end
			else
				local menuSide = controlSide
				local menu
				if subMenuBranchName then
					local tmp = MENU_COALITION:New(menuSide, subMenuBranchName)
					menu = MENU_COALITION:New(menuSide, self.name, tmp)
				else
					menu = MENU_COALITION:New(menuSide, self.name)
				end

				MENU_COALITION_COMMAND:New(menuSide, "Spawn One Group Immediately", menu, spawnAI, nil)
				for i = 1, 8 do
					if scheduleTable[i] then
						MENU_COALITION_COMMAND:New(menuSide, "Set Level to " .. tostring(i), menu, setLevel, i)
					end
				end
			end

			for level, schedules in pairs(scheduleTable) do
				if not schedules then
					-- continue (schedules is nil)
				else
					for _, schedule in pairs(schedules) do
						local A = schedule[1]
						local B = schedule[2] or 0
						local C = schedule[3]
						local D = schedule[4] or 0
						local E = schedule[5]

						if not A then
							-- continue
						elseif C and E then
							SCHEDULER:New(nil, spawnAIScheduled, {level}, math.random(math.floor(A - A * B), math.floor(A + A * B + 0.5)), C, D, E)
						elseif C then
							SCHEDULER:New(nil, spawnAIScheduled, {level}, math.random(math.floor(A - A * B), math.floor(A + A * B + 0.5)), C, D)
						else
							SCHEDULER:New(nil, spawnAIScheduled, {level}, math.random(math.floor(A - A * B), math.floor(A + A * B + 0.5)))
						end
					end
				end
			end
		end

		return self
	end

	function MenuShowRepeatingSpawnerStatus(repeatingSpawnerTable)
		local function getSpawnerStatus()
			local message = "Mission Repeating Spawner Current Status:\n\n"
			for _, spawner in pairs(repeatingSpawnerTable) do
				if type(spawner) == "table" then
					local name = spawner.name
					local subMenu = spawner.getSubMenuBranchName()
					local level = spawner.getLevel()
					local count = spawner.getCount()
					local limit = spawner.getLimit()
					if subMenu then
						message = message .. subMenu .. "/"
					end
					message = message .. name .. ": Level " .. tostring(level)
					if limit > 0 then
						message = message .. " (" .. tostring(count) .. "/" .. tostring(limit) .. " groups have spawned)" .. "\n"
					else
						message = message .. " (" .. tostring(count) .. " groups have spawned)" .. "\n"
					end
				else -- anything not a "spawner" (table in lua) will give a blank line
					message = message .. "\n"
				end
			end
			return message
		end
		MENU_MISSION_COMMAND:New("Show Repeating Spawner Status", nil, function()
			MESSAGE:New(getSpawnerStatus(), 30):ToAll()
			end, nil)
	end


	-- ----------------
	-- Onetime Spawner:
	-- ----------------

	OnetimeSpawner = {}

	function OnetimeSpawner.new(init_name, init_routeTable, init_templateTable, init_numberOfSpawn)
		local self = {}

		-- Private variables:
		local routeTable = shallowcopy(init_routeTable)
		local routeTableDuplicate = shallowcopy(init_routeTable)
		local templateTable = shallowcopy(init_templateTable)
		local respawn = false
		local respawnProb
		local respawnTime
		local respawnTimeProb

		-- Public variables:
		self.name = init_name
		self.numberOfSpawn = init_numberOfSpawn

		-- Private methods:
		local function spawnAI(route)
			local spawn = SPAWN:New(route):InitRandomizeTemplate(templateTable)
			if respawn then
				local A = respawnTime
				local B = respawnTimeProb
				spawn:OnSpawnGroup(function(spawnGroup)
					spawnGroup:HandleEvent(EVENTS.Dead)
					function spawnGroup:OnEventDead(eventData)
						if math.random() <= respawnProb then
							SCHEDULER:New(nil, spawnAI, {route}, math.random(math.floor(A - A * B), math.floor(A + A * B + 0.5)))
						end
					end
					end)
			end
			spawn:Spawn()
		end

		-- Public methods:
		function self.setRespawn(init_respawnProb, init_respawnTime, init_respawnTimeProb)
			respawn = true
			respawnProb = init_respawnProb
			respawnTime = init_respawnTime
			respawnTimeProb = init_respawnTimeProb
		end

		function self.run()
			for i = 1, self.numberOfSpawn do
				local j = math.random(1, #routeTableDuplicate)
				local route = routeTableDuplicate[j]
				table.remove(routeTableDuplicate, j)
				spawnAI(route)
			end
		end

		return self
	end


	OnetimeSpawnerGroup = {}

	function OnetimeSpawnerGroup.new(init_name, spawnerTable)
		local self = {}

		-- Private variables:
		local subMenuBranchName = nil
		local controlGroupName = nil
		local controlSide = coalition.side.BLUE
		local hasActivated = false

		-- Public variables:
		self.name = init_name

		-- Private methods:
		local function activate()
			if not hasActivated then
				for _, spawner in pairs(spawnerTable) do
					spawner:run()
				end
				hasActivated = true
				MESSAGE:New(self.name .. ": Spawn activated.", 10):ToAll()
			else
				MESSAGE:New(self.name .. ": Spawn has been activated already.", 10):ToAll()
			end
		end

		local function check()
			if hasActivated then
				MESSAGE:New(self.name .. ": Activated.", 10):ToAll()
			else
				MESSAGE:New(self.name .. ": NOT Activated.", 10):ToAll()
			end
		end

		-- Public methods:
		function self.setSubMenuBranchName(menuName)
			subMenuBranchName = menuName
		end

		function self.setControlGroupName(groupName)
			controlGroupName = groupName
		end

		function self.setControlSide(side)
			if side == "BLUE" then
				controlSide = coalition.side.BLUE
			elseif side == "RED" then
				controlSide = coalition.side.RED
			else
				-- neutral
			end
		end

		function self.run()
			if controlGroupName then
				local menuGroup = GROUP:FindByName(controlGroupName)
				local menu
				if subMenuBranchName then
					local tmp = MENU_GROUP:New(menuGroup, subMenuBranchName)
					menu = MENU_GROUP:New(menuGroup, self.name, tmp)
				else
					menu = MENU_GROUP:New(menuGroup, self.name)
				end
				MENU_GROUP_COMMAND:New(menuGroup, "Activate Spawn", menu, activate, nil)
				MENU_GROUP_COMMAND:New(menuGroup, "Check Status", menu, check, nil)
			else
				local menuSide = controlSide
				local menu
				if subMenuBranchName then
					local tmp = MENU_COALITION:New(menuSide, subMenuBranchName)
					menu = MENU_COALITION:New(menuSide, self.name, tmp)
				else
					menu = MENU_COALITION:New(menuSide, self.name)
				end
				MENU_COALITION_COMMAND:New(menuSide, "Activate Spawn", menu, activate, nil)
				MENU_COALITION_COMMAND:New(menuSide, "Check Status", menu, check, nil)
			end
		end

		return self
	end


	MESSAGE:New(scriptName .. " script successfully loaded.", 10):ToAll()
end

