--///////////////////////////////////////////////////////
-- Valkrana / Colors
--///////////////////////////////////////////////////////
INSERT INTO Colors -- Primary is background, secondary foreground. Purple 127,1,254,255; Pink 252,73,178,255
        (Type,									Color)
VALUES  ('COLOR_SAILOR_VALKRANA_PRIMARY',		'127,1,254,255'),
		('COLOR_SAILOR_VALKRANA_SECONDARY',		'14,14,14,255'),
		('COLOR_SAILOR_VALKRANA_PRIMARY2',		'252,73,178,255'),
        ('COLOR_SAILOR_VALKRANA_SECONDARY2',	'14,14,14,255'),
		('COLOR_SAILOR_VALKRANA_PRIMARY3',		'127,1,254,255'),
        ('COLOR_SAILOR_VALKRANA_SECONDARY3',	'146,112,87,255');

INSERT INTO PlayerColors (
		Type,
		Usage, 
		PrimaryColor, 
		SecondaryColor, 
		Alt1PrimaryColor, 
		Alt1SecondaryColor, 
		Alt2PrimaryColor, 
		Alt2SecondaryColor, 
		Alt3PrimaryColor, 
		Alt3SecondaryColor)
SELECT	'LEADER_SAILOR_VALKRANA',
		'Unique',
		'COLOR_SAILOR_VALKRANA_PRIMARY2',
		'COLOR_SAILOR_VALKRANA_SECONDARY2',
		'COLOR_SAILOR_VALKRANA_PRIMARY',
		'COLOR_SAILOR_VALKRANA_SECONDARY',
		'COLOR_SAILOR_VALKRANA_PRIMARY3',
		'COLOR_SAILOR_VALKRANA_SECONDARY3',
		PrimaryColor,
		SecondaryColor
FROM PlayerColors WHERE Type = 'LEADER_PETER_GREAT';