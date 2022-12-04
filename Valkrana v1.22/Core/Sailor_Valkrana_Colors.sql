--///////////////////////////////////////////////////////
-- Valkrana / Colors
--///////////////////////////////////////////////////////
INSERT INTO Colors -- Primary is background, secondary foreground. Purple 127,1,254,255; Pink 252,73,178,255
        (Type,									Color)
VALUES  ('COLOR_SAILOR_VALKRANA_PRIMARY',		'127,1,254,255'),
		('COLOR_SAILOR_VALKRANA_SECONDARY',		'14,14,14,255'),
		('COLOR_SAILOR_VALKRANA_PRIMARY2',		'252,73,178,255'),
        ('COLOR_SAILOR_VALKRANA_SECONDARY2',	'14,14,14,255'),
		('COLOR_SAILOR_VALKRANA_PRIMARY3',		'59,45,34,255'),
        ('COLOR_SAILOR_VALKRANA_SECONDARY3',	'151,48,255,255'),
		('COLOR_SAILOR_VALKRANA_PRIMARY4',		'213,161,7,255'),
		('COLOR_SAILOR_VALKRANA_SECONDARY4',	'117,32,32,255');

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
VALUES	('LEADER_SAILOR_VALKRANA',
		'Unique',
		'COLOR_SAILOR_VALKRANA_PRIMARY2',
		'COLOR_SAILOR_VALKRANA_SECONDARY2',
		'COLOR_SAILOR_VALKRANA_PRIMARY',
		'COLOR_SAILOR_VALKRANA_SECONDARY',
		'COLOR_STANDARD_WHITE_DK',
		'COLOR_SAILOR_VALKRANA_SECONDARY3',
		'COLOR_SAILOR_VALKRANA_PRIMARY4',
		'COLOR_SAILOR_VALKRANA_SECONDARY4');