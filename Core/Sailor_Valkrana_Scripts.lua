-- // Property List
-- Context: Game
-- "Sailor_ValkranaKillTicker" (Player)
-- "Sailor_ValkranaReanimationBoost" (Player)
-- "Sailor_ValkranaDivination_" .. x .. y (Player)
-- "Sailor_ValkranaKudosNum" (Player)
-- "Sailor_ValkranaSpell2" (Unit)
-- "Sailor_ValkranaTimerInit" (Game)
-- "Sailor_BarrierExpirationTurn" (Player)
-- 
-- Context: UI
-- "Sailor_ValkranaObtained" .. greatWork (Player)
-- "Sailor_OtherObtained" .. greatWork (Game)
-- "Sailor_ValkranaSlots" (Player)
-- //
ExposedMembers.GameEvents = GameEvents;
local reanimationChance = 10; -- Percentage chance out of 100.
local valkTypeName      = 'LEADER_SAILOR_VALKRANA';
local valkUnitName      = 'UNIT_SAILOR_VALKRANA_UU';
local libAbility        = 'ABILITY_SAILOR_VALKRANA_UU_LIBRARY';
local uniAbility        = 'ABILITY_SAILOR_VALKRANA_UU_UNIVERSITY';
local labAbility        = 'ABILITY_SAILOR_VALKRANA_UU_RESEARCHLAB';
local valkrana_debug    = false;
--///////////////////////////////////////////////////////
-- Reanimation Functions
--///////////////////////////////////////////////////////
function Sailor_Valkrana_Combat(tCombatResult)
	local tAttackerData		= tCombatResult[CombatResultParameters.ATTACKER];
	local tDefenderData		= tCombatResult[CombatResultParameters.DEFENDER];
	local atkplayerID       = tAttackerData[CombatResultParameters.ID].player;
	local defplayerID       = tDefenderData[CombatResultParameters.ID].player;
    if atkplayerID ~= nil and defplayerID ~= nil then
        local atkplayername     = PlayerConfigurations[atkplayerID]:GetLeaderTypeName();
        local defplayername     = PlayerConfigurations[defplayerID]:GetLeaderTypeName();
        -- Was Valkrana a belligerent?
        if atkplayername and defplayername and (atkplayername == valkTypeName or defplayername == valkTypeName) then
            local unitaFDT		= tAttackerData[CombatResultParameters.FINAL_DAMAGE_TO];
            local unitdFDT		= tDefenderData[CombatResultParameters.FINAL_DAMAGE_TO];
            local atkObject     = tAttackerData[CombatResultParameters.ID].type;
            local defObject     = tDefenderData[CombatResultParameters.ID].type;
            local ownerID       = 0;
            -- Identify which side she was on.
            local valkID    = atkplayerID;
            local yahooID   = defplayerID;
            if defplayername == valkTypeName then
                valkID      = defplayerID;
                yahooID     = atkplayerID;
            end
            -- Did something die, and was it a unit?
            -- Attacker case true.
            if unitaFDT > 99 and atkObject == 1 then 
                if valkID == atkplayerID then
                    ownerID = valkID;
                else ownerID = yahooID;
                end
                Sailor_Valkrana_Reanimation(tAttackerData, ownerID, valkID, yahooID);
            end
            -- Defender case true.
            if unitdFDT > 99 and defObject == 1 then 
                if valkID == defplayerID then
                    ownerID = valkID;
                else ownerID = yahooID;
                end
                Sailor_Valkrana_Reanimation(tDefenderData, ownerID, valkID, yahooID);
            end
            -- Debug Stuff    
            --[[
            local unitaX, unitaY	= tAttackerData[CombatResultParameters.LOCATION].x, tAttackerData[CombatResultParameters.LOCATION].y
            local unitdX, unitdY	= tDefenderData[CombatResultParameters.LOCATION].x, tDefenderData[CombatResultParameters.LOCATION].y
            local unitaID			= tAttackerData[CombatResultParameters.ID].id
            local unitdID			= tDefenderData[CombatResultParameters.ID].id
            --print("Attacker: ", unitaID, unitaX, unitaY, "Defender: ", unitbID, unitdX, unitdY)
            local unitaFDT			= tAttackerData[CombatResultParameters.FINAL_DAMAGE_TO]
            local unitaDT			= tAttackerData[CombatResultParameters.DAMAGE_TO]
            local unitaMDHP			= tAttackerData[CombatResultParameters.MAX_DEFENSE_HIT_POINTS]
            local unitaCST			= tAttackerData[CombatResultParameters.COMBAT_SUB_TYPE]
            local unitaDDT			= tAttackerData[CombatResultParameters.DEFENSE_DAMAGE_TO]
            --print("Attacker Final Damage To:", unitaFDT, " / Damage To: ", unitaDT, " / Max Defense HP: ", unitaMDHP, " / Combat Sub Type: ", unitaCST, " / Defense Damage To: ", unitaDDT)
            ]]--
        end
    end
end

function Sailor_Valkrana_Reanimation(tUnitData, ownerID, valkID, yahooID)
    local pPlayer   = Players[ownerID];
    local vPlayer   = Players[valkID];
    local ObjectID  = tUnitData[CombatResultParameters.ID].id;
    local _Unit     = pPlayer:GetUnits():FindID(ObjectID);
    -- Kill tracker.
    if ownerID ~= valkID then
        local killCount = vPlayer:GetProperty("Sailor_ValkranaKillTicker");
        if killCount == nil then
            vPlayer:SetProperty("Sailor_ValkranaKillTicker", 1);
        else
            vPlayer:SetProperty("Sailor_ValkranaKillTicker", killCount + 1);
        end
    end
    -- Was the unit a land unit?
    -- Can't check barbarians because _Unit becomes nil if killed by barbs. Huh?
    if yahooID ~= 63 then
        if GameInfo.Units[_Unit:GetType()].Domain ~= 'DOMAIN_LAND' then
            return;
        end
    end
    local iskeleRoll = Game.GetRandNum(100, "Skeleton Reanimation, Attacker") + 1;
    local iChance = reanimationChance;
    -- Barb and Free City Nerf
    if yahooID > 61 then
        iChance = math.floor(reanimationChance / 2);
    end
    -- Boosted by kills since last reanimation.
    local boost = vPlayer:GetProperty("Sailor_ValkranaReanimationBoost");
    if boost ~= nil then
        iChance = iChance + boost;
    else 
        boost = 0;
    end
    -- Ai Bonus
    if not vPlayer:IsHuman() then
        iChance = iChance * 2;
    end
    VVLog("Attempting reanimation with "..iChance.."% chance.");
    -- Did the roll result in reanimation?
    if iskeleRoll <= iChance then
        vPlayer:SetProperty("Sailor_ValkranaReanimationBoost", 0);
        local unitX, unitY    = tUnitData[CombatResultParameters.LOCATION].x, tUnitData[CombatResultParameters.LOCATION].y;
        local _UnitPlot       = Map.GetPlot(unitX, unitY);
        -- Will skeleton spawn in tile or adjacent tile?
        if not _UnitPlot:IsCity() and not _UnitPlot:IsImpassable() then
            local bPlotUnits  = Units.GetUnitsInPlotLayerID(unitX, unitY, MapLayers.ANY);
            -- Are there units in plot? A combat unit? Belonging to Valkrana?
            if bPlotUnits ~= nil then
                for i, pUnit in ipairs(bPlotUnits) do
                    if GameInfo.Units[pUnit:GetType()].FormationClass == 'FORMATION_CLASS_LAND_COMBAT' then
                        if pUnit:GetOwner() == valkID then
                            VVLog("Friendly combat unit in plot. Attempting to spawn skeleton.");
                            UnitManager.InitUnit(valkID, valkUnitName, unitX, unitY);
                            if Players[valkID]:IsHuman() then
                                Game.AddWorldViewText(valkID, Locale.Lookup("LOC_SAILOR_VALKRANA_REANIMATED"), unitX, unitY, 0);
                            end
                            return;
                        else
                            VVLog("Unfriendly combat unit in plot. Attempting to spawn skeleton adj.");
                            local adjX, adjY = Sailor_Valkrana_ValidAdjacentHex(unitX, unitY, valkID);
                            UnitManager.InitUnit(valkID, valkUnitName, adjX, adjY);
                            if Players[valkID]:IsHuman() then
                                Game.AddWorldViewText(valkID, Locale.Lookup("LOC_SAILOR_VALKRANA_REANIMATED"), unitX, unitY, 0);
                            end
                            return;
                        end
                    end
                end
                VVLog("No combat units in plot. Attempting to spawn skeleton.");
                UnitManager.InitUnit(valkID, valkUnitName, unitX, unitY);
                if vPlayer:IsHuman() then
                    Game.AddWorldViewText(valkID, Locale.Lookup("LOC_SAILOR_VALKRANA_REANIMATED"), unitX, unitY, 0);
                end
                return;
            else
                VVLog("No units in plot. Attempting to spawn skeleton.");
                UnitManager.InitUnit(valkID, valkUnitName, unitX, unitY);
                if vPlayer:IsHuman() then
                    Game.AddWorldViewText(valkID, Locale.Lookup("LOC_SAILOR_VALKRANA_REANIMATED"), unitX, unitY, 0);
                end
                return;
            end
        else
            VVLog("City or impassable plot. Attempting to spawn skeleton adj.");
            local adjX, adjY = Sailor_Valkrana_ValidAdjacentHex(unitX, unitY, valkID);
            UnitManager.InitUnit(valkID, valkUnitName, adjX, adjY);
            if vPlayer:IsHuman() then
                Game.AddWorldViewText(valkID, Locale.Lookup("LOC_SAILOR_VALKRANA_REANIMATED"), unitX, unitY, 0);
            end
            return;
        end
    else
        vPlayer:SetProperty("Sailor_ValkranaReanimationBoost", boost + 1);
    end
end

function Sailor_Valkrana_ValidAdjacentHex(unitX, unitY, valkID)
    for direction = 0, DirectionTypes.NUM_DIRECTION_TYPES - 1, 1 do
        local adjacentPlot = Map.GetAdjacentPlot(unitX, unitY, direction);
        if adjacentPlot then
            if not adjacentPlot:IsCity() and not adjacentPlot:IsImpassable() and not adjacentPlot:IsWater() then
                iX, iY = adjacentPlot:GetX(), adjacentPlot:GetY();
                local plotUnits = Units.GetUnitsInPlotLayerID(iX, iY, MapLayers.ANY);
                if plotUnits ~= nil then
                    for i, unit in ipairs(plotUnits) do
                        if GameInfo.Units[unit:GetType()].FormationClass == 'FORMATION_CLASS_LAND_COMBAT' then
                            if unit:GetOwner() == valkID then
                                return iX, iY;
                            end
                        end
                    end
                else return iX, iY;
                end
            end
        end
    end
end

--///////////////////////////////////////////////////////
-- Spells
--///////////////////////////////////////////////////////
-- // These support functions get plots for Spells 1 and 4.
function Sailor_ValkranaTargeter(leaderID, valkranaID, spellmode)
    local vPlayer       = Players[valkranaID];
    local pPlayer       = Players[leaderID];
    local pPlayerCities = pPlayer:GetCities();
    local tTargets      = {};
    local cityNum       = pPlayerCities:GetCount();
    -- Grab Cities
    for i, city in pPlayerCities:Members() do
        table.insert(tTargets, city);
    end
    if cityNum > 0 then
        -- First check for fresh city. Only do this for Scry.
        if spellmode == 1 then
            local repeatstop = false;
            repeat
                local iRoll = Game.GetRandNum(cityNum, "Target Roller") + 1
                for i, target in ipairs(tTargets) do
                    if i == iRoll then
                        local targetX, targetY = target:GetX(), target:GetY();
                        local status = vPlayer:GetProperty("SailorValkranaDivination_" .. targetX .. targetY);
                        if status == nil then
                            Sailor_Valkrana_Spell1(valkranaID, targetX, targetY, vPlayer);
                            return;
                        end
                    end
                end
                repeatstop = true;
            until (repeatstop == true)
        end
        -- No fresh cities. Holy Tolstoy stop casting this spell. (Or just casting Skeleport.)
        local iRoll2 = Game.GetRandNum(cityNum, "Target Roller 2") + 1
        for i, _target in ipairs(tTargets) do
            if i == iRoll2 then
                local _targetX, _targetY = _target:GetX(), _target:GetY();
                if spellmode == 1 then
                    Sailor_Valkrana_Spell1(valkranaID, _targetX, _targetY);
                    return;
                end
                if spellmode == 4 then
                    Sailor_Valkrana_Spell4(valkranaID, _targetX, _targetY);
                    return;
                end
            end
        end
    else
        VVLog("No cities for spell targeter? Huh?");
    end
end
GameEvents.Sailor_ValkranaTargeter.Add(Sailor_ValkranaTargeter);

function Sailor_ValkranaTargeterRand(valkranaID, spellmode)
    local tLandPlots = Sailor_GetLandPlots();
    local iRoll = Game.GetRandNum(#tLandPlots, "Plot Roller") + 1
    for i, v in ipairs(tLandPlots) do
        if i == iRoll then
            local randX, randY    = v:GetX(), v:GetY();
            if spellmode == 1 then
                Sailor_Valkrana_Spell1(valkranaID, randX, randY);
                return;
            end
            if spellmode == 4 then
                Sailor_Valkrana_Spell4(valkranaID, randX, randY);
                return;
            end
        end
    end
end
GameEvents.Sailor_ValkranaTargeterRand.Add(Sailor_ValkranaTargeterRand);

-- // Spell 1 Divination
function Sailor_Valkrana_Spell1(valkranaID, iX, iY)
    local vPlayer       = Players[valkranaID];
    local divProp       = vPlayer:GetProperty("SailorValkranaDivination_" .. iX .. iY);
    local divRadius     = 2;
    if divProp ~= nil then
        divRadius       = divProp + 1;
    end
    local pVisibility   = PlayersVisibility[valkranaID];
	for dx = (divRadius * -1), divRadius do
		for dy = (divRadius * -1), divRadius do
			local divPlot = Map.GetPlotXYWithRangeCheck(iX, iY, dx, dy, divRadius);
			if divPlot then
                pVisibility:ChangeVisibilityCount(divPlot:GetIndex(), 2);
            end
        end
    end
    vPlayer:SetProperty("SailorValkranaDivination_" .. iX .. iY, divRadius);
end

-- // Spell 2 Abjuration
local barrierExpirationTurn;
function Sailor_Valkrana_Spell2(valkranaID)
    -- No need to have the timer running before the spell has ever been cast.
    local timerInit = Game:GetProperty("Sailor_ValkranaTimerInit");
    if timerInit == nil then
        GameEvents.OnGameTurnStarted.Add(Sailor_ValkranaBarrierTimer);
        Game:SetProperty("Sailor_ValkranaTimerInit", 1);
    end
    local vPlayerUnits		= Players[valkranaID]:GetUnits();
    local tUnits			= {};
    local buffTurns			= 6; -- Desired turns + 1
    for _, pUnit in vPlayerUnits:Members() do
        table.insert(tUnits, pUnit);
    end
    for _, unit in ipairs(tUnits) do
        local unitAbility		= unit:GetAbility();
        local unitAbilityCount  = unitAbility:GetAbilityCount("ABILITY_SAILOR_VALKRANA_SPELL2");
        local unitProperty		= unit:GetProperty("Sailor_ValkranaSpell2");
        unitAbility:ChangeAbilityCount("ABILITY_SAILOR_VALKRANA_SPELL2", 1);
        -- If unit doesn't have turns remaining, property equals current turn + x.
        if unitProperty == nil or unitProperty == 0 then
            unit:SetProperty("Sailor_ValkranaSpell2", Game.GetCurrentGameTurn() + buffTurns);
        else
        -- If unit has turns remaining, add the difference to current turn + x.
            local unitTimer = ((Game.GetCurrentGameTurn() + buffTurns) + (unitProperty - Game.GetCurrentGameTurn()));
            unit:SetProperty("Sailor_ValkranaSpell2", unitTimer);
            local unitStatus = unit:GetProperty("Sailor_ValkranaSpell2");
        end
    end
    -- Timer expiration property.
    Game:SetProperty("Sailor_BarrierExpirationTurn", Game.GetCurrentGameTurn() + buffTurns);
end
GameEvents.Sailor_Valkrana_Spell2.Add(Sailor_Valkrana_Spell2);

-- Supports Spell 2 function by tracking turns and flipping switches.
function Sailor_ValkranaBarrierTimer()
    local tValkranas = Sailor_GetValkranas();
    if tValkranas then
        -- Each unit has its own timer, attached via property.
        -- Property is the turn on which the ability is removed.
        for _, v in ipairs(tValkranas) do
            local pPlayerUnits	= Players[v]:GetUnits();
            local sUnits		= {};
            for _, pUnit in pPlayerUnits:Members() do
                table.insert(sUnits, pUnit);
            end
            for _, unit in ipairs(sUnits) do
                local unitAbility		= unit:GetAbility();
                local unitAbilityCount  = unitAbility:GetAbilityCount("ABILITY_SAILOR_VALKRANA_SPELL2");
                local unitStatus		= unit:GetProperty("Sailor_ValkranaSpell2");
                if unitStatus ~= nil then
                    if unitStatus == Game.GetCurrentGameTurn() then
                        unitAbility:ChangeAbilityCount("ABILITY_SAILOR_VALKRANA_SPELL2", -unitAbilityCount);
                        unit:SetProperty("Sailor_ValkranaSpell2", 0);
                    end
                end
            end
        end
    end
    -- Deactivate timer if it's not being used.
    local expiry = Game:GetProperty("Sailor_BarrierExpirationTurn");
    if expiry == (Game.GetCurrentGameTurn() - 1) then
        GameEvents.OnGameTurnStarted.Remove(Sailor_ValkranaBarrierTimer);
        Game:SetProperty("Sailor_ValkranaTimerInit", 0);
    end
end

-- Adds barrier timer after loading if barrier is active.
function Sailor_ValkranaTimerInit()
    local timerInit = Game:GetProperty("Sailor_ValkranaTimerInit");
    if timerInit == 1 then
        GameEvents.OnGameTurnStarted.Add(Sailor_ValkranaBarrierTimer);
    end
end

-- // Spell 3 Necromancy
function Sailor_Valkrana_Spell3(valkranaID)
    local vPlayer       = Players[valkranaID];
    local vUnits        = vPlayer:GetUnits();
    local killCount     = vPlayer:GetProperty("Sailor_ValkranaKillTicker");
    if killCount == nil then
        killCount = 0;
    end
    for _, unit in vUnits:Members() do
        -- Skeletons only
        if GameInfo.Units[unit:GetType()].UnitType == "UNIT_SAILOR_VALKRANA_UU" then
            local iDMG = unit:GetDamage();
            unit:SetDamage(iDMG - (20 + (killCount * 2)));
        end
    end
    vPlayer:SetProperty("Sailor_ValkranaKillTicker", 0);
end
GameEvents.Sailor_Valkrana_Spell3.Add(Sailor_Valkrana_Spell3);

-- // Spell 4 Necromancy
function Sailor_Valkrana_Spell4(valkranaID, iX, iY)
    local tPlots        = {};
    local iRadius       = 3;
    -- Grabbing open plots.
    for dx = (iRadius * -1), iRadius do
        for dy = (iRadius * -1), iRadius do
            local skelPlot = Map.GetPlotXYWithRangeCheck(iX, iY, dx, dy, iRadius);
            -- Plot and placement valid?
            if skelPlot then
                if not skelPlot:IsCity() and not skelPlot:IsImpassable() and not skelPlot:IsWater() then
                    local plotX, plotY = skelPlot:GetX(), skelPlot:GetY();
                    table.insert(tPlots, {["pX"] = plotX, ["pY"] = plotY});
                end
            end
        end
    end
    -- Rolling and spawning barbarian skeletons.
    local skeleNum = 3;
    local i = 0;
    while i < skeleNum do
        local plotRoll = Game.GetRandNum(#tPlots, "Skeleport Plot Roller");
        for n, _plot in ipairs(tPlots) do
            if n == plotRoll then
                UnitManager.InitUnit(63, valkUnitName, _plot.pX, _plot.pY);
                -- Skeletons adjusted to Valkrana's current skeleton strength.
                local bLibrary, bUniversity, bLab = Sailor_ValkranaBldgs(valkranaID);
                local bPlotUnits = Units.GetUnitsInPlotLayerID(_plot.pX, _plot.pY, MapLayers.ANY);
                if bPlotUnits ~= nil then
                    for _, unit in ipairs(bPlotUnits) do
                        if GameInfo.Units[unit:GetType()].UnitType == "UNIT_SAILOR_VALKRANA_UU" then
                            local unitAbility = unit:GetAbility();
                            if bLibrary then
                                unitAbility:ChangeAbilityCount(libAbility, 1);
                            end
                            if bUniversity then
                                unitAbility:ChangeAbilityCount(uniAbility, 1);
                            end
                            if bLab then
                                unitAbility:ChangeAbilityCount(labAbility, 1);
                            end
                        end
                    end
                end
                i = i + 1;
                break;
            end
        end
    end
end
GameEvents.Sailor_Valkrana_Spell4.Add(Sailor_Valkrana_Spell4);

-- // Checks for stock campus buildings.
local libindex  = GameInfo.Buildings['BUILDING_LIBRARY'].Index;
local uniindex  = GameInfo.Buildings['BUILDING_UNIVERSITY'].Index;
local labindex  = GameInfo.Buildings['BUILDING_RESEARCH_LAB'].Index;
function Sailor_ValkranaBldgs(valkranaID)
    local vCities       = Players[valkranaID]:GetCities();
    local bLibrary      = false;
    local bUniversity   = false;
    local bLab          = false;
    for _, v in vCities:Members() do
        local vCityBldgs = v:GetBuildings();
        if vCityBldgs:HasBuilding(libindex) then
            bLibrary = true;
        end
        if vCityBldgs:HasBuilding(uniindex) then
            bUniversity = true;
        end
        if vCityBldgs:HasBuilding(labindex) then
            bLab = true;
        end
        if bLibrary and bUniversity and bLab then
            break;
        end
    end
    return bLibrary, bUniversity, bLab;
end
--///////////////////////////////////////////////////////
-- Free-Range Skeletons on Defeat
--///////////////////////////////////////////////////////
function Sailor_ValkranaFreeSkeletons(playerID, defeatType, eventID)
    if not Sailor_IsValkrana(playerID) then
        return;
    end
	local playerConfig = PlayerConfigurations[Game.GetLocalPlayer()];
	local gameDifficultyIndex = GameInfo.Difficulties[playerConfig:GetHandicapTypeID()].Index;
	-- Variable spawn depending on difficulty and era.
	local iEra      = Game.GetEras():GetCurrentEra(); -- 0, 2, 5
    local spawnNum  = 3 + (gameDifficultyIndex * 2) + iEra;
    local i         = 0;
    while i < spawnNum do
        local tLandPlots = Sailor_GetLandPlots();
        local iRoll = Game.GetRandNum(#tLandPlots, "Plot Roller") + 1;
        local plot;
        for n, v in ipairs(tLandPlots) do
            if n == iRoll then
                plot = v;
                break;
            end
        end
		-- Is the plot valid for placement?
        if plot and not plot:IsCity() and not plot:IsImpassable() then
            local pX, pY = plot:GetX(), plot:GetY();
            UnitManager.InitUnit(63, valkUnitName, pX, pY);
            -- Attach skeleton abilities based on current era. Generally a bit ahead, but that's OK. No need to be precise in this.
            local bPlotUnits = Units.GetUnitsInPlotLayerID(pX, pY, MapLayers.ANY);
            if bPlotUnits ~= nil then
                for _, unit in ipairs(bPlotUnits) do
                    if GameInfo.Units[unit:GetType()].UnitType == 'UNIT_SAILOR_VALKRANA_UU' then
                        local unitAbility = unit:GetAbility();
                        unitAbility:ChangeAbilityCount(libAbility, 1);
                        if iEra > 1 then -- Medieval, University
                            unitAbility:ChangeAbilityCount(uniAbility, 1);
                        end
                        if iEra > 4 then -- Modern, Research Lab
                            unitAbility:ChangeAbilityCount(labAbility, 1);
                        end
                    end
                end
            end
            i = i + 1;
        end
    end
end

--///////////////////////////////////////////////////////
-- Utils
--///////////////////////////////////////////////////////
-- Sets Properties. Mainly used for UI side.
function Sailor_Valkrana_SetProp(proptype, propunique, value, playerID)
    if playerID == nil then
        Game:SetProperty(proptype .. propunique, value);
		return;
    else
        Players[playerID]:SetProperty(proptype .. propunique, value);
        return;
    end
end
GameEvents.Sailor_Valkrana_SetProp.Add(Sailor_Valkrana_SetProp);

-- Grabs Valkrana's ID.
function Sailor_GetValkranaID()
	for _, v in ipairs(PlayerManager.GetWasEverAliveIDs()) do
		if PlayerConfigurations[v]:GetLeaderTypeName() == valkTypeName then
			return v;
		end
	end
end

function Sailor_GetValkranas()
    local temp = {};
    for _, v in ipairs(PlayerManager.GetAliveIDs()) do
        if PlayerConfigurations[v]:GetLeaderTypeName() == valkTypeName then
		    table.insert(temp, v);
	    end
    end
    return next(temp) ~= nil and temp or false;
end

-- Returns Valkrana boolean.
function Sailor_IsValkrana(playerID)
	if PlayerConfigurations[playerID]:GetLeaderTypeName() == valkTypeName then
		return true;
	else
		return false;
	end
end

function Sailor_GetLandPlots()
    local temp = {};
    local continents = Map.GetContinentsInUse();
    for _, v in ipairs(continents) do
        local continentPlots = Map.GetContinentPlots(v);
        for _, p in ipairs(continentPlots) do
            local plot = Map.GetPlotByIndex(p);
            if not plot:IsWater() then
                table.insert(temp, plot);
            end
        end
    end
    return temp;
end

-- Grants dummy buildings for agenda tracking.
function Sailor_ValkranaDummy(playerID)
    local pPlayer   = Players[playerID];
    local pCity     = pPlayer:GetCities():GetCapitalCity();
    local plot      = Map.GetPlot(pCity:GetX(), pCity:GetY()):GetIndex();
    local iProp     = pPlayer:GetProperty("Sailor_ValkranaKudosNum");
    if iProp == nil then
        iProp = 1;
    elseif iProp > 5 then
        return;
    end
    local vBuilding = GameInfo.Buildings["BUILDING_SAILOR_VALKRANA_" .. iProp].Index;
	pCity:GetBuildQueue():CreateIncompleteBuilding(vBuilding, plot, 100);
    pCity:GetBuildings():RemoveBuilding(vBuilding);
    pPlayer:SetProperty("Sailor_ValkranaKudosNum", iProp + 1);
end
GameEvents.Sailor_ValkranaDummy.Add(Sailor_ValkranaDummy);

-- Grants GSP.
local scientistIndex = GameInfo.GreatPersonClasses["GREAT_PERSON_CLASS_SCIENTIST"].Index;
function Sailor_GPP(playerID, iGSP)
	local pPlayer	= Players[playerID];
	local pPlayerGP = pPlayer:GetGreatPeoplePoints();
	pPlayerGP:ChangePointsTotal(scientistIndex, iGSP);
	if pPlayer:IsHuman() then
		local pCap	= pPlayer:GetCities():GetCapitalCity();
		Game.AddWorldViewText(playerID, Locale.Lookup("[COLOR_FLOAT_SCIENCE]+{1_Num} [ICON_GreatScientist]", iGSP), pCap:GetX(), pCap:GetY(), 2);
	end
end
GameEvents.Sailor_GPP.Add(Sailor_GPP);

--///////////////////////////////////////////////////////
-- AI Stuff
--///////////////////////////////////////////////////////
-- AI doesn't understand skeletons. When the AI trains a
-- melee unit, we need to manually replace it with a skeleton
-- and transfer any bonuses it may have.
local tAbilities = {} -- Grabbing city-trained abilities for later.
for _, tRow in ipairs(DB.Query("SELECT Value FROM ModifierArguments WHERE Name = 'AbilityType' AND ModifierId IN (SELECT ModifierId FROM BuildingModifiers WHERE BuildingType IN (SELECT BuildingType FROM Buildings WHERE TraitType IS NULL)) AND Value IN (SELECT Type FROM TypeTags WHERE Tag IN (SELECT Tag FROM TypeTags WHERE Type = 'UNIT_WARRIOR') OR Tag IN ('CLASS_ALL_UNITS', 'CLASS_ALL_COMBAT_UNITS'))")) do
	table.insert(tAbilities, tRow);
end
function Sailor_ValkranaAI(playerID, unitID)
    -- Ensure it's both Valkrana and AI.
	if (not Sailor_IsValkrana(playerID)) or Players[playerID]:IsHuman() then
		return;
	end
    local vUnit = Players[playerID]:GetUnits():FindID(unitID);
    if vUnit then
        local vType = vUnit:GetType();
        -- Don't replace skeletons. Only replace melee units with STR of 75 or lower.
        if (GameInfo.Units[vType].UnitType == valkUnitName)
        or (GameInfo.Units[vType].PromotionClass ~= 'PROMOTION_CLASS_MELEE' or GameInfo.Units[vType].Combat > 75) then
            return;
        end
        -- Store unit formation and abilities for xfer.
        local vForm         = vUnit:GetMilitaryFormation(); -- 1 Corps, 2 Army
        local vAbilities    = vUnit:GetAbility();
        local vX, vY        = vUnit:GetX(), vUnit:GetY();
        local tActiveAbil   = {};
        for _, value in ipairs(tAbilities) do
            local abilityCount  = vAbilities:GetAbilityCount(value)
            if abilityCount > 0 then
                table.insert(tActiveAbil, value);
            end
        end
        -- Kill old, spawn new, find new.
        UnitManager.Kill(vUnit);
        UnitManager.InitUnit(playerID, valkUnitName, vX, vY);
        local sUnit;
        local unitList = Units.GetUnitsInPlotLayerID(vX, vY, MapLayers.ANY);
        if unitList ~= nil then
            for _, unit in ipairs(unitList) do
                if GameInfo.Units[unit:GetType()].UnitType == valkUnitName then
                    sUnit = unit;
                    break;
                end
            end
        end
        -- Abilities
        local sAbil = sUnit:GetAbility();
        if next(tActiveAbil) ~= nil then
            for _, ability in ipairs(tActiveAbil) do
                sAbil:ChangeAbilityCount(ability, 1);
            end
        end
        -- Formation
        if vForm > 0 then
            if vForm == 2 then
                sAbil:ChangeAbilityCount("ABILITY_SAILOR_VALKRANA_AI_ARMY", 1);
            elseif vForm == 1 then
                sAbil:ChangeAbilityCount("ABILITY_SAILOR_VALKRANA_AI_CORPS", 1);
            end
        end
    end
end
--///////////////////////////////////////////////////////
-- Roll Initiative
--///////////////////////////////////////////////////////
function VVLog(msg)
	if valkrana_debug == true then
		print(msg);
	end
end

function Initialize()
    local has_processedvalk = false;
    local has_processedvalkAI = false;
    for _, v in ipairs(PlayerManager.GetWasEverAliveIDs()) do
        if PlayerConfigurations[v]:GetLeaderTypeName() == 'LEADER_SAILOR_VALKRANA' then
            -- Event subscriptions.
            if not has_processedvalk then
                print("(u_x)/ Valkrana detected. Preparing spells...");
                Events.Combat.Add(Sailor_Valkrana_Combat);              -- Skeleton spawning
                Events.PlayerDefeat.Add(Sailor_ValkranaFreeSkeletons);  -- Free skeletons on defeat
                Events.LoadScreenClose.Add(Sailor_ValkranaTimerInit);   -- Reactivates barrier timer
                has_processedvalk = true;
            end
            if not has_processedvalkAI and not Players[v]:IsHuman() then
                print("(u_x)/ Valkrana AI detected. Reanimation skeletons...");
                Events.UnitAddedToMap.Add(Sailor_ValkranaAI); -- AI stuff
                has_processedvalkAI = true;
            end
            return;
        end
    end
end
Initialize();