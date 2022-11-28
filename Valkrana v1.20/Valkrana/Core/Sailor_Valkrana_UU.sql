--///////////////////////////////////////////////////////
-- Valkrana / UU
--///////////////////////////////////////////////////////

INSERT INTO Tags (Tag, Vocabulary) VALUES ('CLASS_SAILOR_VALKRANA_UU', 'ABILITY_CLASS');
INSERT INTO Types
		(Type,										Kind)
VALUES	('UNIT_SAILOR_VALKRANA_UU',					'KIND_UNIT'),
		('ABILITY_SAILOR_VALKRANA_UU_LIBRARY',		'KIND_ABILITY'),
		('ABILITY_SAILOR_VALKRANA_UU_UNIVERSITY',	'KIND_ABILITY'),
		('ABILITY_SAILOR_VALKRANA_UU_RESEARCHLAB',	'KIND_ABILITY'),
		('MODIFIER_SAILOR_VALKRANA_UU_BASE_STRENGTH', 'KIND_MODIFIER');

-- // TypeTags
INSERT INTO TypeTags
		(Type,										Tag)
VALUES	('UNIT_SAILOR_VALKRANA_UU',					'CLASS_SAILOR_VALKRANA_UU'),
		('ABILITY_SAILOR_VALKRANA_UU_LIBRARY',		'CLASS_SAILOR_VALKRANA_UU'),
		('ABILITY_SAILOR_VALKRANA_UU_UNIVERSITY',	'CLASS_SAILOR_VALKRANA_UU'),
		('ABILITY_SAILOR_VALKRANA_UU_RESEARCHLAB',	'CLASS_SAILOR_VALKRANA_UU');
INSERT INTO TypeTags (Type, Tag) SELECT	'UNIT_SAILOR_VALKRANA_UU', Tag
FROM TypeTags WHERE Type = 'UNIT_WARRIOR';

-- // PseudoYields
INSERT INTO PseudoYields (PseudoYieldType, DefaultValue) VALUES ('PSEUDOYIELD_UNIT_SAILOR_VALKRANA_UU', 1);

-- // Units
INSERT INTO Units	(
		UnitType,
		Name,
		Description,
		TraitType,
		BaseMoves,
		Cost,
		CostProgressionModel,
		CostProgressionParam1,
		StrategicResource,
		PurchaseYield,
		AdvisorType,
		Combat,
		BaseSightRange,
		ZoneOfControl,
		Domain,
		FormationClass,
		PromotionClass,
		Maintenance,
		BuildCharges,
		PrereqTech
		--PseudoYieldType
		)
SELECT	'UNIT_SAILOR_VALKRANA_UU', -- UnitType
		'LOC_UNIT_SAILOR_VALKRANA_UU_NAME', -- Name
		'LOC_UNIT_SAILOR_VALKRANA_UU_DESCRIPTION', -- Description
		'TRAIT_LEADER_UNIT_SAILOR_VALKRANA_UU', -- TraitType
		BaseMoves,
		50,
		'COST_PROGRESSION_GAME_PROGRESS', -- CostProgressionModel
		400, -- CostProgressionParam1,
		StrategicResource,
		PurchaseYield,
		AdvisorType,
		20, -- Combat
		BaseSightRange,
		ZoneOfControl,
		Domain,
		FormationClass,
		PromotionClass,
		Maintenance,
		1, -- BuildCharges
		PrereqTech
		--'PSEUDOYIELD_UNIT_SAILOR_VALKRANA_UU' -- PseudoYieldType
FROM	Units
WHERE	UnitType = 'UNIT_WARRIOR';

-- // UnitReplaces
INSERT INTO UnitReplaces (CivUniqueUnitType, ReplacesUnitType) VALUES ('UNIT_SAILOR_VALKRANA_UU', 'UNIT_WARRIOR');

-- // UnitAiInfos
--INSERT INTO UnitAiInfos (UnitType, AiType) VALUES ('UNIT_SAILOR_VALKRANA_UU', 'UNITAI_BUILD');
INSERT INTO UnitAiInfos	(UnitType, AiType) SELECT 'UNIT_SAILOR_VALKRANA_UU', AiType FROM UnitAiInfos WHERE UnitType = 'UNIT_WARRIOR';

-- // UnitAbilities
INSERT INTO UnitAbilities (UnitAbilityType, Name, Description, Inactive) 
VALUES	('ABILITY_SAILOR_VALKRANA_UU_LIBRARY', NULL, NULL, 1),
		('ABILITY_SAILOR_VALKRANA_UU_UNIVERSITY', NULL, NULL, 1),
		('ABILITY_SAILOR_VALKRANA_UU_RESEARCHLAB', NULL, NULL, 1);

-- // UnitAbilityModifiers
INSERT INTO UnitAbilityModifiers
		(UnitAbilityType,							ModifierId)
VALUES	('ABILITY_SAILOR_VALKRANA_UU_LIBRARY',		'ABILITY_SAILOR_VALKRANA_UU_LIBRARY_MODIFIER'),
		('ABILITY_SAILOR_VALKRANA_UU_UNIVERSITY',	'ABILITY_SAILOR_VALKRANA_UU_UNIVERSITY_MODIFIER'),
		('ABILITY_SAILOR_VALKRANA_UU_RESEARCHLAB',	'ABILITY_SAILOR_VALKRANA_UU_RESEARCHLAB_MODIFIER');

-- // Modifiers
INSERT INTO DynamicModifiers (ModifierType, CollectionType, EffectType)
VALUES	('MODIFIER_SAILOR_VALKRANA_UU_BASE_STRENGTH', 'COLLECTION_OWNER', 'EFFECT_ADJUST_UNIT_COMBAT_STRENGTH');

INSERT INTO	Modifiers
		(ModifierId,										ModifierType)
VALUES	('ABILITY_SAILOR_VALKRANA_UU_LIBRARY_MODIFIER',		'MODIFIER_SAILOR_VALKRANA_UU_BASE_STRENGTH'),
		('ABILITY_SAILOR_VALKRANA_UU_UNIVERSITY_MODIFIER',	'MODIFIER_SAILOR_VALKRANA_UU_BASE_STRENGTH'),
		('ABILITY_SAILOR_VALKRANA_UU_RESEARCHLAB_MODIFIER',	'MODIFIER_SAILOR_VALKRANA_UU_BASE_STRENGTH');

-- // ModifierArguments
INSERT INTO	ModifierArguments
		(ModifierId,										Name,		Value)
VALUES	('ABILITY_SAILOR_VALKRANA_UU_LIBRARY_MODIFIER',		'Amount',	10),
		('ABILITY_SAILOR_VALKRANA_UU_UNIVERSITY_MODIFIER',	'Amount',	20),
		('ABILITY_SAILOR_VALKRANA_UU_RESEARCHLAB_MODIFIER',	'Amount',	20);