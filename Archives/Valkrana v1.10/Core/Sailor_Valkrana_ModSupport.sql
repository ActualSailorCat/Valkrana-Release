-- 6T
INSERT OR REPLACE INTO AiFavoredItems (ListType, Favored, Item, Value) SELECT 'SAILOR_VALKRANA_Techs', 1, 'TECH_PRINTING', 0
WHERE EXISTS (SELECT CivicType FROM Civics WHERE CivicType = 'CIVIC_6T_CITIZENSHIP');

-- Buddhas of Bamyan
INSERT OR REPLACE INTO AiFavoredItems (ListType, Favored, Item, Value) SELECT 'SAILOR_VALKRANA_Buildings', 1, 'BUILDING_BAMYAN', 50
WHERE EXISTS (SELECT BuildingType FROM Buildings WHERE BuildingType = 'BUILDING_BAMYAN');

INSERT OR REPLACE INTO AiFavoredItems (ListType, Favored, Item, Value) SELECT 'SAILOR_VALKRANA_Civics', 1, PrereqCivic, 50 
FROM Buildings WHERE BuildingType = 'BUILDING_BAMYAN'
AND EXISTS (SELECT BuildingType FROM Buildings WHERE BuildingType = 'BUILDING_BAMYAN');

-- Restore Flirtatious & Curmudgeon
INSERT OR REPLACE INTO ExclusiveAgendas (AgendaOne, AgendaTwo) SELECT 'AGENDA_SAILOR_VALKRANA', AgendaType
FROM Agendas WHERE AgendaType IN ('AGENDA_SAILOR_FLIRTATIOUS', 'AGENDA_SAILOR_CURMUDGEON')
AND EXISTS (SELECT AgendaType FROM Agendas WHERE AgendaType = 'AGENDA_SAILOR_FLIRTATIOUS');

-- Prurient and Frigid
INSERT OR REPLACE INTO ExclusiveAgendas (AgendaOne, AgendaTwo) SELECT 'AGENDA_SAILOR_VALKRANA', AgendaType
FROM Agendas WHERE AgendaType IN ('AGENDA_SAILOR_FRIGID', 'AGENDA_SAILOR_PRURIENT')
AND EXISTS (SELECT AgendaType FROM Agendas WHERE AgendaType = 'AGENDA_SAILOR_FRIGID');