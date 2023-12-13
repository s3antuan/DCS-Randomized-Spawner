--
--

do
	local routeTable_G = {"RG-1", "RG-2", "RG-3", "RG-4"}
	local templateTable_G = {"TG-1", "TG-2"}
	local spawner_G = RepeatingSpawner.new("Ground Vehicles Running Around", routeTable_G, templateTable_G)
	spawner_G.setRadiusVariation(6067)
	spawner_G.setSubMenuBranchName("XXX")
	spawner_G.setControlGroupName("Controller")
	spawner_G.setSpawnLimit(5)
	spawner_G.setScheduleTable(2, {{120, 0.1}})
	spawner_G.setScheduleTable(3, {{300, 0.1, 300, 0.3}})
	spawner_G.setScheduleTable(4, {{600, 0.3, 600, 0.3, 3000}})
	spawner_G.setScheduleTable(5, {{600, 0.3, 600, 0.3, 3000}})
	spawner_G.run()

	local routeTable_A = {"RA-1", "RA-2", "RA-3", "RA-4", "RA-5"}
	local templateTable_A = {"TA-1", "TA-2", "TA-3"}
	local routeTable_E = {"RE-1", "RE-2", "RE-3", "RE-4", "RE-5"}
	local templateTable_E = {"TE-1"}
	local spawner_A = RepeatingSpawner.new("Aircrafts Flying to Nowhere", routeTable_A, templateTable_A)
	spawner_A.setRadiusVariation(6067)
	spawner_A.setHeightVariation(4000)
	spawner_A.setSubMenuBranchName("XXX")
	spawner_A.setControlGroupName("Controller")
	spawner_A.setEscort(routeTable_E, templateTable_E, 3, 20)
	spawner_A.setScheduleTable(2, {{240, 0.2}})
	spawner_A.setScheduleTable(3, {{300, 0.2, 300, 0.4}})
	spawner_A.setScheduleTable(4, {{600, 0.4, 1200, 0.4, 6000}})
	spawner_A.run()


	MenuShowRepeatingSpawnerStatus({spawner_G, "-----", spawner_A})

	MESSAGE:New("Demo script successfully loaded.", 10):ToAll()
end
