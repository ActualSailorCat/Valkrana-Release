--///////////////////////////////////////////////////////
-- Valkrana / Config
--///////////////////////////////////////////////////////
-- // Players
INSERT INTO Players	(Domain, PortraitBackground, LeaderType, LeaderName, LeaderIcon, LeaderAbilityName, LeaderAbilityDescription, LeaderAbilityIcon, CivilizationType, CivilizationName, CivilizationIcon, CivilizationAbilityName, CivilizationAbilityDescription, CivilizationAbilityIcon)
SELECT DISTINCT Domain,
		'LEADER_SAILOR_VALKRANA_BACKGROUND', -- PortraitBackground
		'LEADER_SAILOR_VALKRANA', -- LeaderType
		'LOC_LEADER_SAILOR_VALKRANA_NAME', -- LeaderName
		'ICON_LEADER_SAILOR_VALKRANA', -- LeaderIcon
		'LOC_TRAIT_LEADER_SAILOR_VALKRANA_UA_NAME', -- LeaderAbilityName
		'LOC_TRAIT_LEADER_SAILOR_VALKRANA_UA_DESCRIPTION', -- LeaderAbilityDescription
		'ICON_LEADER_SAILOR_VALKRANA', -- LeaderAbilityIcon
		CivilizationType, CivilizationName, CivilizationIcon, CivilizationAbilityName, CivilizationAbilityDescription, CivilizationAbilityIcon
FROM Players WHERE CivilizationType = 'CIVILIZATION_RUSSIA'
AND Domain IN ('Players:Expansion1_Players', 'Players:Expansion2_Players', 'Players:StandardPlayers');

-- // PlayerItems
INSERT INTO PlayerItems	(Domain, LeaderType, CivilizationType, Type, Icon, Name, Description, SortIndex)
SELECT DISTINCT Domain, 'LEADER_SAILOR_VALKRANA', CivilizationType, Type, Icon, Name, Description, SortIndex
FROM PlayerItems WHERE CivilizationType = 'CIVILIZATION_RUSSIA' AND LeaderType = 'LEADER_PETER_GREAT'
AND Domain IN ('Players:Expansion1_Players', 'Players:Expansion2_Players', 'Players:StandardPlayers');

INSERT INTO PlayerItems	(Domain, LeaderType, CivilizationType, Type, Icon, Name, Description, SortIndex)
SELECT DISTINCT Domain,
		'LEADER_SAILOR_VALKRANA',
		'CIVILIZATION_RUSSIA',
		'UNIT_SAILOR_VALKRANA_UU',
		'ICON_UNIT_SAILOR_VALKRANA_UU',
		'LOC_UNIT_SAILOR_VALKRANA_UU_NAME',
		'LOC_UNIT_SAILOR_VALKRANA_UU_DESCRIPTION',
		1
FROM PlayerItems WHERE CivilizationType = 'CIVILIZATION_RUSSIA'
AND Domain IN ('Players:Expansion1_Players', 'Players:Expansion2_Players', 'Players:StandardPlayers');