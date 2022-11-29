include("InstanceManager");
include("SupportFunctions");
include("Civ6Common");
GameEvents = ExposedMembers.GameEvents;
local RELOAD_CACHE_ID:string = "Sailor_Valkrana_ScriptsUI"; -- Must be unique (usually the same as the file name)
local i_MaxSpells 		= 4; -- Maximum number of spells shown on screen.
local m_SelectedSpellTypes:table = {};
local m_SpellbookInstanceManager:table = InstanceManager:new("ValkranaSpellbook", "SelectCheck", Controls.SpellbookStack);
local spellbookOpen		= false;
local m_spellmode:number;
local defaultID			= 0;
local valkTypeName		= 'LEADER_SAILOR_VALKRANA';
local sailorSlotsProp 	= "Sailor_ValkranaSlots";
--///////////////////////////////////////////////////////
-- Relics
--///////////////////////////////////////////////////////
local tSlotBuildings = {} -- Relic-Friendly Buildings (Used in sniffer and GSP per turn.)
for i, tRow in ipairs(DB.Query("SELECT * FROM Buildings WHERE TraitType IS NULL AND BuildingType IN (SELECT DISTINCT BuildingType FROM Building_GreatWorks WHERE GreatWorkSlotType IN ('GREATWORKSLOT_PALACE', 'GREATWORKSLOT_RELIC'))")) do
	local rowIndex = GameInfo.Buildings[tRow.BuildingType].Index
	table.insert(tSlotBuildings, rowIndex);
end

-- // Relic via creation.
function Sailor_ValkranaRelicCreated(playerID, unitID, cityX, cityY, buildingID, greatWorkNum)
	--print("(UI) Player:", playerID, "Unit:", unitID, "CityXY:", cityX, cityY, "Building:", buildingID, "GreatWorkNum:", greatWorkNum);
	if Sailor_GetValkranaID() == nil then
		return;
	end
	-- Determine creator.
	local isValkrana = false;
	if Sailor_IsValkrana(playerID) then
		isValkrana = true;
	end
	local pCities = Players[playerID]:GetCities();
	for i, pCity in pCities:Members() do
		local iX, iY = pCity:GetX(), pCity:GetY();
		if iX == cityX and iY == cityY then
			local pCityBuildings 	= pCity:GetBuildings();
			local numSlots 			= pCityBuildings:GetNumGreatWorkSlots(buildingID);
			local index 			= 0;
			for i=0, numSlots - 1 do
				local greatWorkSlotID 	= pCityBuildings:GetGreatWorkSlotType(buildingID, i);
				local greatWorkSlotType = GameInfo.GreatWorkSlotTypes[greatWorkSlotID].GreatWorkSlotType;
				if greatWorkSlotType == 'GREATWORKSLOT_RELIC' or greatWorkSlotType == 'GREATWORKSLOT_PALACE' then
					local greatWorkID 		= pCityBuildings:GetGreatWorkInSlot(buildingID, i);
					if greatWorkID > -1 then
						local greatWork 	= pCityBuildings:GetGreatWorkTypeFromIndex(greatWorkID);
						local greatWorkObj 	= GameInfo.GreatWorks[greatWork].GreatWorkObjectType;
						-- If item is relic, has it been addressed?
						if greatWorkObj == 'GREATWORKOBJECT_RELIC' then
							if isValkrana == true then
								-- Open spellbook if Valkrana.
								local greatWorkStatus = Game:GetProperty("Sailor_ValkranaObtained" .. greatWork);
								if greatWorkStatus ~= 1 or greatWorkStatus == nil then
									local proptype = "Sailor_ValkranaObtained";
									GameEvents.Sailor_Valkrana_SetProp.Call(proptype, greatWork, 1);
									Sailor_SpellbookBuffer(playerID);
								end
							else
								-- Exit if no Valkrana AI.
								local vAIPresent = false;
								for k, v in ipairs(tValkranas) do
									if not Players[v]:IsHuman() then
										vAIPresent = true;
										break;
									end
								end
								if vAIPresent == false then
									return;
								end
								-- Otherwise, bonus to owner.
								local greatWorkStatus = Game:GetProperty("Sailor_OtherObtained" .. greatWork);
								if greatWorkStatus ~= 1 or greatWorkStatus == nil then
									GameEvents.Sailor_ValkranaDummy.Call(playerID);
								end
							end
						end
					end
				end
			end
		end
	end
end

-- // Relic via deal.
function Sailor_ValkranaRelicDeal()
	local valkranaID = Sailor_GetValkranaID();
	if valkranaID == nil then
		return;
	end
	Sailor_GreatWorkSniffer(valkranaID);
end

-- // Relic via city capture.
function Sailor_ValkranaRelicCapture(playerID, cityID)
	if not Sailor_IsValkrana(playerID) then
		return;
	end
	Sailor_GreatWorkSniffer(playerID);
end

-- // Relic GSP
local iGSP_MODE		= 2; -- Points per relic.
local sTraitDesc	= DB.Query("SELECT Description FROM Traits WHERE TraitType = 'TRAIT_LEADER_SAILOR_VALKRANA_UA'")[1].Description;
-- Lower relic points during certain modes due to overabundance of relics.
if sTraitDesc == 'LOC_TRAIT_LEADER_SAILOR_VALKRANA_UA_DESCRIPTION_MODE' then
	iGSP_MODE = 1;
end
-- Grants +iGSP_MODE Great Scientist points per relic per turn.
function Sailor_RelicGSP()
    for _, playerID in ipairs(PlayerManager.GetAliveMajorIDs()) do
        local sLeaderType = PlayerConfigurations[playerID]:GetLeaderTypeName();
        if sLeaderType == 'LEADER_SAILOR_VALKRANA' then
			local pPlayer = Players[playerID];
			local pCities = pPlayer:GetCities();
			local iRelics = 0;
			for i, pCity in pCities:Members() do
				local pCityBuildings = pCity:GetBuildings();
				for k, buildingIndex in ipairs(tSlotBuildings) do
					if pCityBuildings:HasBuilding(buildingIndex) then
					local numSlots = pCityBuildings:GetNumGreatWorkSlots(buildingIndex);
						for slot = 0, numSlots - 1 do
						-- Cycle through slots.
							local greatWorkID 	= pCityBuildings:GetGreatWorkInSlot(buildingIndex, slot);
							if greatWorkID > -1 then
								local greatWork 	= pCityBuildings:GetGreatWorkTypeFromIndex(greatWorkID);
								local greatWorkObj 	= GameInfo.GreatWorks[greatWork].GreatWorkObjectType;
								-- If relic, iterate bonus count.
								if greatWorkObj == 'GREATWORKOBJECT_RELIC' then
									iRelics = iRelics + 1;
								end
							end
						end			
					end			
				end
			end
			if iRelics > 0 then
				local iGSP = iRelics * iGSP_MODE;
				GameEvents.Sailor_GPP.Call(playerID, iGSP);
			end
		end
	end
end

--///////////////////////////////////////////////////////
-- Kudos Randomizer
--///////////////////////////////////////////////////////
local tKudos = {
	"LOC_DIPLO_KUDO_EXIT_LEADER_SAILOR_VALKRANA_1",
	"LOC_DIPLO_KUDO_EXIT_LEADER_SAILOR_VALKRANA_2",
	"LOC_DIPLO_KUDO_EXIT_LEADER_SAILOR_VALKRANA_3",
	"LOC_DIPLO_KUDO_EXIT_LEADER_SAILOR_VALKRANA_4",
	"LOC_DIPLO_KUDO_EXIT_LEADER_SAILOR_VALKRANA_5",
	"LOC_DIPLO_KUDO_EXIT_LEADER_SAILOR_VALKRANA_6",
	"LOC_DIPLO_KUDO_EXIT_LEADER_SAILOR_VALKRANA_7",
	"LOC_DIPLO_KUDO_EXIT_LEADER_SAILOR_VALKRANA_8",
	"LOC_DIPLO_KUDO_EXIT_LEADER_SAILOR_VALKRANA_9",
	"LOC_DIPLO_KUDO_EXIT_LEADER_SAILOR_VALKRANA_0",
}

function Sailor_ValkranaKudo(fromID, toID, kVariants)
    --print("Diplo from:", fromID, "Statement:", kVariants.StatementType, "StatementSubType:", kVariants.StatementSubType, DiplomacyManager.GetKeyName(kVariants.StatementType), DiplomacyManager.GetKeyName(kVariants.StatementSubType));
	-- Check if Valkrana and Kudo.
    if not Sailor_IsValkrana(fromID) then
		return;
	end
	local statementType = DiplomacyManager.GetKeyName(kVariants.StatementType);
	if statementType ~= 'DIPLOMATIC_KUDO' then
		return;
	end
	-- Determine dialogue based on turn. No need for random with so few options.
	local turnmod10 = math.fmod(Game.GetCurrentGameTurn(), 10);
	--local roll 		= math.ceil(turnmod10 / 2);
	local responseText;
	for i, loc in ipairs(tKudos) do
		if turnmod10 == i then
			responseText = Locale.Lookup(loc);
			break;
		end
	end
	ContextPtr:LookUpControl("/InGame/DiplomacyActionView/LeaderResponseText"):SetText(responseText);
end

--///////////////////////////////////////////////////////
--///////////////////////////////////////////////////////
--///////////////////////////////////////////////////////
--///////////////////////////////////////////////////////
--///////////////////////////////////////////////////////
--///////////////////////////////////////////////////////
--///////////////////////////////////////////////////////
--///////////////////////////////////////////////////////
--///////////////////////////////////////////////////////
--///////////////////////////////////////////////////////
--///////////////////////////////////////////////////////
--///////////////////////////////////////////////////////
-- Spellbook Instance
-- This buffer accrues stored spells, since ValkranaSpellbook() is invoked in multiple contexts.
function Sailor_SpellbookBuffer(valkranaID)
	if Players[valkranaID]:IsHuman() then
		local slots = Players[valkranaID]:GetProperty(sailorSlotsProp);
		if slots == nil then
			slots = 1;
			GameEvents.Sailor_Valkrana_SetProp.Call(sailorSlotsProp, "", 1, valkranaID);
		else
			slots = slots + 1;
			GameEvents.Sailor_Valkrana_SetProp.Call(sailorSlotsProp, "", slots, valkranaID);
		end
		Controls.OpenButtonText:SetText(slots);
		Controls.OpenButton:SetDisabled(false);
		Controls.OpenButton:SetToolTipString(Locale.Lookup("LOC_SAILOR_VALKRANA_BUTTON_NOT_NIL"));
	end
	ValkranaSpellbook(valkranaID);
end

-- Spells for later.
local tSpellList = {}
for i, tRow in ipairs(DB.Query("SELECT * FROM Sailor_Valkrana_Spells")) do
	table.insert(tSpellList, tRow)
end

function ValkranaSpellbook(valkranaID)
	if not Sailor_IsValkrana(valkranaID) then
		return;
	end
	-- Ai don't need no interface.
	if not Players[valkranaID]:IsHuman() then
		local turn = Game.GetCurrentGameTurn();
		if math.fmod(turn, 2) == 0 then
			if math.fmod(turn, 10) <= 4 then
				m_spellmode = 1;
				GameEvents.Sailor_ValkranaTargeterRand.Call(valkranaID, m_spellmode);
				return;
			else
				GameEvents.Sailor_Valkrana_Spell2.Call(valkranaID);
				return;		
			end
		else
			if math.fmod(turn, 10) <= 4 then
				GameEvents.Sailor_Valkrana_Spell3.Call(valkranaID);
				return;
			else
				m_spellmode = 4;
				GameEvents.Sailor_ValkranaTargeterRand.Call(valkranaID, m_spellmode);
				return;
			end
		end
	end
	local localPlayerID = Game.GetLocalPlayer();
	-- Local player is Valkrana?
	if localPlayerID ~= valkranaID then
		return;
	end
	-- Observor?
	if localPlayerID == PlayerTypes.NONE then
		return;
	end
	-- Populating spells.
	Controls.Title:SetText(Locale.ToUpper(Locale.Lookup("LOC_SAILOR_VALKRANA_POPUP_TITLE", 0)));
	m_SpellbookInstanceManager:ResetInstances();
	-- Create option for each spell in spell table.
	for i, spell in ipairs(tSpellList) do
		CreateSpellbook(spell, valkranaID);
	end
	-- How many spells can be cast at once?
	local selectionsAllowed = 1
	if m_SpellbookInstanceManager.m_iAllocatedInstances > 0 then
		ShowPopup();
		m_SelectedSpellTypes = {}
		Controls.Confirm:SetDisabled(true);
		Controls.SpellbookStack:CalculateSize();
		Controls.SpellbookScroller:CalculateSize();
	else
		Controls.Spellbook:SetHide(true);
	end

	Controls.SpellbookScroller:SetScrollValue(0);
	-- Update control styles
	Controls.SubHeader:SetText(Locale.ToUpper(Locale.Lookup("LOC_SAILOR_VALKRANA_POPUP_SUBHEADER")));
	Controls.PopupBackground:SetTexture("Ages_ParchmentDark");
	Controls.PopupFrame:SetTexture("Ages_FrameDark");
	UpdateConfirmButton(0);
end

-- // Scribing spells.
function CreateSpellbook(spellInfo:table, valkranaID)
	local instance = m_SpellbookInstanceManager:GetInstance();
	-- Spell Icons
	local iconName = "ICON_" .. spellInfo.SpellType;
	instance.SpellbookIcon:SetIcon(iconName);
	-- Spell Text
	local categoryText:string = "";
	if (spellInfo ~= nil and spellInfo.Description ~= nil) then
		categoryText = Locale.Lookup(spellInfo.Name);
	end
	instance.SpellbookName:SetText(Locale.ToUpper(categoryText));
	local bonusText:string = "";
	local localPlayerID:number = Game.GetLocalPlayer();
	if (localPlayerID ~= PlayerTypes.NONE) then
		-- Display current healing potential for Spell 3.
		if (spellInfo ~= nil and spellInfo.Description ~= nil) then
			if spellInfo.SpellType == 'SPELL_3' then
				local killCount = Players[localPlayerID]:GetProperty("Sailor_ValkranaKillTicker");
				if killCount == nil then
					killCount = 0;
				end
				bonusText = Locale.Lookup(spellInfo.Description) .. " " .. (20 + (killCount * 2));
			else
				bonusText = Locale.Lookup(spellInfo.Description);
			end
		end
	end

	instance.SelectCheck:SetTexture("Ages_ButtonComNormal");
	instance.SpellbookBonuses:SetText(bonusText);
	instance.SelectCheck:SetSelected(false);
	instance.SelectCheck:RegisterCallback(Mouse.eLClick, function() OnSpellSelected(instance, spellInfo.SpellType, valkranaID) end);
end

-- // Controls
function OnSpellSelected(selectedInstance:table, spellType, valkranaID)
	-- How many are we allowed to select?
	local selectionsAllowed = 1
	local selectionsMade:number = 0;
	for _,instance in ipairs(m_SpellbookInstanceManager.m_AllocatedInstances) do
		if (instance.SelectCheck:IsSelected()) then
			selectionsMade = selectionsMade + 1;
		end
	end

	-- Have we already selected this one?
	local alreadySelected:boolean = false;
	for i,selectedSpellType in ipairs(m_SelectedSpellTypes) do
		if (selectedSpellType == spellType) then
			alreadySelected = true;
			selectedInstance.SelectCheck:SetSelected(false);
			table.remove(m_SelectedSpellTypes, i);
			selectionsMade = selectionsMade - 1;
		end
	end

	if (not alreadySelected) then
		if (selectionsMade >= selectionsAllowed) then
			-- At capacity, so first clear previous selections
			for _,instance in ipairs(m_SpellbookInstanceManager.m_AllocatedInstances) do
				instance.SelectCheck:SetSelected(false);
			end
			m_SelectedSpellTypes = {}
			selectionsMade = 0;
		end

		-- Make new selection
		selectedInstance.SelectCheck:SetSelected(true);	
		table.insert(m_SelectedSpellTypes, spellType);
		selectionsMade = selectionsMade + 1;
	end

	UpdateConfirmButton(selectionsMade);
end
--------------------------------------------------------------------
function UpdateConfirmButton(currentlySelected:number)
	local selectionsAllowed = 1
	Controls.Confirm:SetDisabled(currentlySelected ~= selectionsAllowed);
end
--------------------------------------------------------------------
function OnConfirm()
	local valkranaID = Game.GetLocalPlayer();
    UI.PlaySound("Confirm_Dedication");
	Controls.Spellbook:SetHide(true);
	spellbookOpen = false;
	-- Adjust slots remaining on confirm.
	local confirmslots = Players[valkranaID]:GetProperty(sailorSlotsProp);
	if confirmslots == nil or confirmslots < 2 then
		confirmslots = 0;
		GameEvents.Sailor_Valkrana_SetProp.Call(sailorSlotsProp, "", confirmslots, valkranaID);
		Controls.OpenButton:SetDisabled(true);
		Controls.OpenButton:SetToolTipString(Locale.Lookup("LOC_SAILOR_VALKRANA_BUTTON_NIL"));
	else
		confirmslots = confirmslots - 1;
		GameEvents.Sailor_Valkrana_SetProp.Call(sailorSlotsProp, "", confirmslots, valkranaID);
	end
	Controls.OpenButtonText:SetText(confirmslots);
	-- Casting selected spell.
	for i, selectedSpellType in ipairs(m_SelectedSpellTypes) do
		if selectedSpellType == 'SPELL_1' then
			m_spellmode = 1;
			PickerInstance(valkranaID, m_spellmode);
			break;
		elseif selectedSpellType == 'SPELL_2' then
			GameEvents.Sailor_Valkrana_Spell2.Call(valkranaID)
			break;
		elseif selectedSpellType == 'SPELL_3' then
			GameEvents.Sailor_Valkrana_Spell3.Call(valkranaID)
			break;
		elseif selectedSpellType == 'SPELL_4' then
			m_spellmode = 4;
			PickerInstance(valkranaID, m_spellmode);
			break;
		end
	end
end

--------------------------------------------------------------------
function ShowPopup(playerID)
	Controls.Spellbook:SetHide(false);
	spellbookOpen = true;
end
--------------------------------------------------------------------
function OnOpen()
	if not Controls.Spellbook:IsHidden() then
		Controls.Spellbook:SetHide(true);
		return;
	end
	local localID = Game.GetLocalPlayer();
	ValkranaSpellbook(localID);
end

function OnClose()
	Controls.Spellbook:SetHide(true);
	spellbookOpen = false;
end

function InputHandler( pInputStruct:table )
	-- Intercept all input while on this screen (is modal).
	if spellbookOpen then
		if ( pInputStruct:GetMessageType() == KeyEvents.KeyUp ) then
			local key:number = pInputStruct:GetKey();
			if ( key == Keys.VK_ESCAPE ) then
				OnClose();
				return true;
			end
		end
	end
end
ContextPtr:SetInputHandler(InputHandler, true);
-- End Spellbook Instance
--///////////////////////////////////////////////////////
--///////////////////////////////////////////////////////
--///////////////////////////////////////////////////////
--///////////////////////////////////////////////////////
--///////////////////////////////////////////////////////
--///////////////////////////////////////////////////////
--///////////////////////////////////////////////////////
--///////////////////////////////////////////////////////
--///////////////////////////////////////////////////////
--///////////////////////////////////////////////////////
--///////////////////////////////////////////////////////
--///////////////////////////////////////////////////////
-- Canadian Pickers Instance
local m_SelectedLeaders:table = {};
local m_PickerInstanceManager:table = InstanceManager:new("PickerInstance", "PickerSelect", Controls.PickerStack);
function PickerInstance(valkranaID, m_spellmode)
	-- Populate applicable leaders table.
	local pDiplomacy = Players[valkranaID]:GetDiplomacy();
	local m_Leaders = {};
	for i, leaderID in ipairs(PlayerManager.GetAliveMajorIDs()) do
		if leaderID ~= valkranaID and pDiplomacy:HasMet(leaderID) then
			table.insert(m_Leaders, leaderID);
		end
	end

	if #m_Leaders > 0 then
		-- Populating leaders.
		m_PickerInstanceManager:ResetInstances();
		-- Create button for each leader in table.
		for i, leader in ipairs(m_Leaders) do
			CreatePicker(leader, valkranaID);
		end
		-- How many leaders can be picked at once?
		local selectionsAllowed = 1;
		if m_PickerInstanceManager.m_iAllocatedInstances > 0 then
			ShowPickerPopup();
			m_SelectedLeaders = {};
			Controls.PickerConfirm:SetDisabled(true);
			Controls.PickerStack:CalculateSize();
			Controls.PickerScroller:CalculateSize();
		else
			Controls.PlayerPicker:SetHide(true);
		end

		Controls.PickerScroller:SetScrollValue(0);
		-- Update control styles
		Controls.PickerSubHeader:SetText(Locale.ToUpper(Locale.Lookup("LOC_SAILOR_VALKRANA_TARGETS_SUBHEADER")));
		UpdatePickerConfirmButton(0);
	else
		GameEvents.Sailor_ValkranaTargeterRand.Call(valkranaID, m_spellmode);
	end
end

-- // Creating leaders.
function CreatePicker(leader, valkranaID)
	local instance = m_PickerInstanceManager:GetInstance();
	-- Leader Text
	local leaderText:string = "";
	if leader ~= nil then
		local leaderTypeName = PlayerConfigurations[leader]:GetLeaderName();
		leaderText = Locale.Lookup(leaderTypeName);
	end
	instance.PickerName:SetText(leaderText);

	instance.PickerSelect:SetSelected(false);
	instance.PickerSelect:RegisterCallback(Mouse.eLClick, function() OnLeaderSelected(instance, leader, valkranaID) end);
end

-- // Controls
function OnLeaderSelected(selectedInstance:table, leader, valkranaID)
	-- How many are we allowed to select?
	local selectionsAllowed = 1
	local selectionsMade:number = 0;
	for _,instance in ipairs(m_PickerInstanceManager.m_AllocatedInstances) do
		if (instance.PickerSelect:IsSelected()) then
			selectionsMade = selectionsMade + 1;
		end
	end

	-- Have we already selected this one?
	local alreadySelected:boolean = false;
	for i,selectedLeaderType in ipairs(m_SelectedLeaders) do
		if (selectedLeaderType == leader) then
			alreadySelected = true;
			selectedInstance.PickerSelect:SetSelected(false);
			table.remove(m_SelectedLeaders, i);
			selectionsMade = selectionsMade - 1;
		end
	end

	if (not alreadySelected) then
		if (selectionsMade >= selectionsAllowed) then
			-- At capacity, so first clear previous selections
			for _,instance in ipairs(m_PickerInstanceManager.m_AllocatedInstances) do
				instance.PickerSelect:SetSelected(false);
			end
			m_SelectedLeaders = {}
			selectionsMade = 0;
		end

		-- Make new selection
		selectedInstance.PickerSelect:SetSelected(true);	
		table.insert(m_SelectedLeaders, leader);
		selectionsMade = selectionsMade + 1;
	end

	UpdatePickerConfirmButton(selectionsMade);
end

function UpdatePickerConfirmButton(currentlySelected:number)
	local selectionsAllowed = 1
	Controls.PickerConfirm:SetDisabled(currentlySelected ~= selectionsAllowed);
end

function OnPickerConfirm(valkranaID)
    UI.PlaySound("Confirm_Dedication");
	Controls.PlayerPicker:SetHide(true);
	-- Moving spell casting to target designation.
	for i, selectedLeaderType in ipairs(m_SelectedLeaders) do
		GameEvents.Sailor_ValkranaTargeter.Call(selectedLeaderType, valkranaID, m_spellmode);
	end
	m_SelectedLeaders = {}
end

function ShowPickerPopup(playerID)
	Controls.PlayerPicker:SetHide(false);
end
-- End Canadian Pickers Instance
--///////////////////////////////////////////////////////
--///////////////////////////////////////////////////////
--///////////////////////////////////////////////////////
--///////////////////////////////////////////////////////
--///////////////////////////////////////////////////////
--///////////////////////////////////////////////////////
--///////////////////////////////////////////////////////
--///////////////////////////////////////////////////////
--///////////////////////////////////////////////////////
--///////////////////////////////////////////////////////
--///////////////////////////////////////////////////////
--///////////////////////////////////////////////////////
--///////////////////////////////////////////////////////
-- Tools
--///////////////////////////////////////////////////////
-- Grabs Valkrana's ID.
-- Avoid using over IsValkrana() to account for duplicate leaders.
function Sailor_GetValkranaID()
	for k, v in ipairs(PlayerManager.GetAliveIDs()) do
		local sLeaderType = PlayerConfigurations[v]:GetLeaderTypeName()
		if sLeaderType == valkTypeName then
			return v;
		end
	end
end
local defaultID = Sailor_GetValkranaID();

-- Returns Valkrana boolean.
-- This seems faster than GetLeaderTypeName()
local tValkranas = {}
for k, v in ipairs(PlayerManager.GetWasEverAliveIDs()) do
	local leadertype = PlayerConfigurations[v]:GetLeaderTypeName();
    if leadertype == valkTypeName then
		table.insert(tValkranas, v);
	end
end
function Sailor_IsValkrana(playerID)
	for k, v in ipairs(tValkranas) do
		if playerID == v then
			return true;
		end
	end
	return false;
end

-- GreatWorkSniffer
function Sailor_GreatWorkSniffer(playerID)
	local pCities = Players[playerID]:GetCities();
	for i, pCity in pCities:Members() do
		local pCityBuildings = pCity:GetBuildings();
		for k, buildingIndex in ipairs(tSlotBuildings) do
			if pCityBuildings:HasBuilding(buildingIndex) then
				local numSlots = pCityBuildings:GetNumGreatWorkSlots(buildingIndex);
				for slot = 0, numSlots - 1 do
				-- Cycle through slots.
					local greatWorkID 	= pCityBuildings:GetGreatWorkInSlot(buildingIndex, slot);
					if greatWorkID > -1 then
						local greatWork 	= pCityBuildings:GetGreatWorkTypeFromIndex(greatWorkID);
						local greatWorkObj 	= GameInfo.GreatWorks[greatWork].GreatWorkObjectType;
						-- If item is relic, has it been addressed?
						if greatWorkObj == 'GREATWORKOBJECT_RELIC' then
							-- Spellbook block.
							local greatWorkStatus = Game:GetProperty("Sailor_ValkranaObtained" .. greatWork);
							--print("Valkrana's GreatWorkType: ", GameInfo.GreatWorks[greatWork].GreatWorkType, "GreatWorkStatus: ", greatWorkStatus);
							if greatWorkStatus ~= 1 or greatWorkStatus == nil then
								local proptype = "Sailor_ValkranaObtained";
								GameEvents.Sailor_Valkrana_SetProp.Call(proptype, greatWork, 1);
								Sailor_SpellbookBuffer(playerID);
							end
						end			
					end			
				end
			end
		end
	end
end

-- // Enables or disables open button for local player.
function Sailor_ValkranaLocalPlayer(localPlayerID, prevLocalPlayerID)
	Controls.OpenButton:SetHide(true);
	if Sailor_IsValkrana(localPlayerID) then
		Controls.OpenButton:SetHide(false);
		local localSlots = Players[localPlayerID]:GetProperty(sailorSlotsProp);
		if localSlots == nil then
			GameEvents.Sailor_Valkrana_SetProp.Call(sailorSlotsProp, "", 0, localPlayerID);
			localSlots = 0;
			Controls.OpenButton:SetDisabled(true);
			Controls.OpenButton:SetToolTipString(Locale.Lookup("LOC_SAILOR_VALKRANA_BUTTON_NIL"));
		else
			Controls.OpenButton:SetDisabled(false);
		end
		Controls.OpenButtonText:SetText(localSlots);
	end
end
--///////////////////////////////////////////////////////
-- Init
--///////////////////////////////////////////////////////
function Initialize() 
    for k, v in ipairs(PlayerManager.GetWasEverAliveIDs()) do
        local sLeaderType = PlayerConfigurations[v]:GetLeaderTypeName();
        if sLeaderType == 'LEADER_SAILOR_VALKRANA' then
            print("///// Valkrana detected. Loading UI functions...");
			-- Initializes slot properties for any Valkrana leaders.
			if Players[v]:IsAlive() then
				local slotNum = Players[v]:GetProperty(sailorSlotsProp);
				if slotNum == nil then
					GameEvents.Sailor_Valkrana_SetProp.Call(sailorSlotsProp, "", 0, v);
				end
			end			
			-- Valkrana Functions
			Events.CityOccupationChanged.Add(Sailor_ValkranaRelicCapture);	-- Relic via City Capture
			Events.DiplomacyDealEnacted.Add(Sailor_ValkranaRelicDeal);		-- Relic via Trade
			Events.GreatWorkCreated.Add(Sailor_ValkranaRelicCreated);		-- Relic via Creation
			GameEvents.OnGameTurnStarted.Add(Sailor_RelicGSP);				-- Relic GSP
			Events.DiplomacyStatement.Add(Sailor_ValkranaKudo);				-- Kudo Injector
			-- UI Stuff
			--Events.TurnBegin.Add(Sailor_SpellbookBuffer);					-- Testing Only
			Events.LocalPlayerChanged.Add(Sailor_ValkranaLocalPlayer);		-- Local UI Handler
			Sailor_ValkranaLocalPlayer(Game.GetLocalPlayer(), -1);
			-- ChangeParent is crucial to lowering button priority.
			Controls.OpenButton:ChangeParent(ContextPtr:LookUpControl("/InGame/NotificationPanel"));
			Controls.Spellbook:ChangeParent(ContextPtr:LookUpControl("/InGame/NotificationPanel"));
			Controls.PlayerPicker:ChangeParent(ContextPtr:LookUpControl("/InGame/NotificationPanel"));
			ContextPtr:SetHide(false);
			Controls.OpenButton:RegisterCallback(Mouse.eLClick, OnOpen);
			Controls.CloseButton:RegisterCallback(Mouse.eLClick, OnClose);
			Controls.Confirm:RegisterCallback(Mouse.eLClick, OnConfirm);
			Controls.PickerConfirm:RegisterCallback(Mouse.eLClick, OnPickerConfirm);
			Controls.Spellbook:SetHide(true);
			Controls.PlayerPicker:SetHide(true);
			return;
		end
	end
end
Events.LoadScreenClose.Add(Initialize);