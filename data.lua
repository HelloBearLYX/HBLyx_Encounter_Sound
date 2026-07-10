local ADDON_NAME, addon = ...
local L = LibStub("AceLocale-3.0"):GetLocale(ADDON_NAME)
addon.data = {}

addon.data.MAP_ENCOUNTER_EVENTS = {
	-- data template
	-- [mapID] = {
		-- seasonMapID	= 0,
		-- name = select(1, EJ_GetInstanceInfo(mapID)) or "instance name",
		-- encounters = {
			-- [encounterID] = {
				-- events = {eventID1, eventID2, eventID3, ...},
				-- journalID = 0,
				-- privateAuras = {spellID1, spellID2, spellID3, ...}
			-- },
			-- ["trash"] = {	
				-- privateAuras = {spellID1, spellID2, ...}
			-- },
	-- }

	-- MARK: current season 12.1
	[1309] = {
		name = select(1, EJ_GetInstanceInfo(1309)) or "The Blinding Vale",
		encounters = {
			[3199] = {
				events = {173, 174, 175, 176, 177},
				journalID = 2769,
				privateAuras = {{1261276, 1235865, 1238076}, 1276586, 1239825, 1239919, 1235574, 1235828, 1234802},
			},
			[3200] = {
				events = {178, 179, 180},
				journalID = 2770,
				privateAuras = {1236747, 1259365, 1237091},
			},
			[3201] = {
				events = {115, 181, 182, 183, 184, 188},
				journalID = 2771,
				privateAuras = {1240222, 1239825, 1241058, 1257094},
			},
			[3202] = {
				events = {189, 190, 191, 192},
				journalID = 2772,
				privateAuras = {1247052, 1247746, 1246751, 1251345, 1246753},
			},
			["trash"] = {
				privateAuras = {1303039, 1238368, 1242135, 1250937, 1238084, 1237858}
			},
		},
	},
	[1304] = {
		name = select(1, EJ_GetInstanceInfo(1304)) or "Murder Row",
		encounters = {
			[3101] = {
				events = {120, 122, 202, 610},
				journalID = 2679,
				privateAuras = {1228198},
			},
			[3102] = {
				events = {123, 124, 125, 127, 193},
				journalID = 2680,
				privateAuras = {474545, 474740, 1214352},
			},
			[3103] = {
				events = {30, 31, 32, 753},
				journalID = 2681,
				privateAuras = {},
			},
			[3105] = {
				events = {37, 38, 207},
				journalID = 2682,
				privateAuras = {1217483},
			},
			["trash"] = {
				privateAuras = {}
			},
		},
	},
	[1311] = {
		name = select(1, EJ_GetInstanceInfo(1311)) or "Den of Nalorakk",
		encounters = {
			[3207] = {
				events = {86, 87, 88},
				journalID = 2776,
				privateAuras = {1234846},
			},
			[3208] = {
				events = {67, 68, 69, 70},
				journalID = 2777,
				privateAuras = {1235549},
			},
			[3209] = {
				events = {90, 92, 89, 91, 598},
				journalID = 2778,
				privateAuras = {1242869, 1261781, 1262253},
			},
			["trash"] = {
				privateAuras = {}
			},

		},
	},
	[1313] = {
		name = select(1, EJ_GetInstanceInfo(1313)) or "Voidscar Arena",
		encounters = {
			[3285] = {
				events = {39, 40, 41, 42, 558, 782},
				journalID = 2791,
				privateAuras = {},
			},
			[3286] = {
				events = {46, 47, 54, 55, 297},
				journalID = 2792,
				privateAuras = {},
			},
			[3287] = {
				events = {56, 57, 58, 171},
				journalID = 2793,
				privateAuras = {},
			},
			["trash"] = {
				privateAuras = {}
			},

		},
	},
	[1322] = {
		name = select(1, EJ_GetInstanceInfo(1322)) or "Altar of Fangs",
		encounters = {
			[3456] = {
				events = {795, 797, 798, 899, 902},
				journalID = 2878,
				privateAuras = {},
			},
			[3457] = {
				events = {813, 814, 815, 816, 817, 818},
				journalID = 2879,
				privateAuras = {},
			},
			[3458] = {
				events = {821, 822, 823, 824},
				journalID = 2880,
				privateAuras = {},
			},
			["trash"] = {
				privateAuras = {1294569, 1294557, 1307571, 1294845, 1308518}
			},
		},
	},
	[1041] = {
		name = select(1, EJ_GetInstanceInfo(1041)) or "King's Rest",
		encounters = {
			[2139] = {
				events = {767, 891, 892, 893},
				journalID = 2165,
				privateAuras = {265773, 265914}, -- damage aura (1306736) for 265773
			},
			[2142] = {
				events = {878, 879, 880},
				journalID = 2171,
				privateAuras = {{271555, 267702}, 267626, 267763, 267618, 267874},
			},
			[2140] = {
				events = {870, 872, 871, 873, 874, 875, 876},
				journalID = 2170,
				privateAuras = {266191, 266231, 266238},
			},
			[2143] = {
				events = {831, 832, 833, 834, 835, 836},
				journalID = 2172,
				privateAuras = {1303267, 1303039, 1302945, 1303399, 1303490},
			},
			["trash"] = {
				privateAuras = {1301851, 1298304, 1297918, 1306763, 1298104, 1294815, 1302028, 1297781, 270499, 270292, 270927, 272021, 272388, 270492, 270931}
			},
		},
	},
	[1030] = {
		name = select(1, EJ_GetInstanceInfo(1030)) or "Temple of Sethraliss",
		encounters = {
			[2124] = {
				events = {689, 690, 691, 692},
				journalID = 2142,
				privateAuras = {1288885, 1308738},
			},
			[2125] = {
				events = {701, 702, 703, 704, 705, 706},
				journalID = 2143,
				privateAuras = {1308838, {1290030, 263958}, {1289109, 1289588}, 1293048, 267027, 1300227},
			},
			[2126] = {
				events = {697, 698},
				journalID = 2144,
				privateAuras = {266923, 1291815},
			},
			[2127] = {
				events = {354, 828},
				journalID = 2145,
				privateAuras = {1300666, 1302158, 1303446, 1302618, 1300877, 1302826, 1300704, 1300714},
			},
			["trash"] = {
				privateAuras = {1225638, 1300684, 1293307, 273274, 1308546, 1296052, 1291468, 1308113, 1308148, 1303596, {1289589, 1293133}, 1303486, 1295635, 264206, 1291399, 1288457, 272655}
			},
		},
	},
	[1202] = {
		name = select(1, EJ_GetInstanceInfo(1202)) or "Ruby Life Pools",
		encounters = {
			[2609] = {
				events = {866, 867, 868, 869},
				journalID = 2488,
				privateAuras = {384024, 385518, 373688, 1305234}, -- 397077 is the global damage and pull aura for 385518
			},
			[2606] = {
				events = {882, 883, 884},
				journalID = 2485,
				privateAuras = {372858, 372860, 372820, 372865, 384823},
			},
			[2623] = {
				events = {885, 887, 888, 889, 890},
				journalID = 2503,
				privateAuras = {381862, 384773, 381526, 381515, 381518},
			},
			["trash"] = {
				privateAuras = {1305225, 1307205, 373693, 1307372, 385536, 1305201, 372047, 1306366, 372963, 1310361, 1310599, 392641, 385536}
			},
		},
	},

    -- -- MARK: Raid
	[1320] = {
		name = select(1, EJ_GetInstanceInfo(1320)) or "The Venomous Abyss",
		encounters = {
			[3470] = {
				events = {675, 676, 693, 731, 804},
				journalID = 2888,
				privateAuras = {},
			},
			[3445] = {
				events = {637, 638, 639, 640, 643, 673, 788},
				journalID = 2874,
				privateAuras = {},
			},
			[3455] = {
				events = {754, 757, 759},
				journalID = 2882,
				privateAuras = {},
			},
			[3497] = {
				events = {721, 722, 725, 727, 729, 768, 776, 783},
				journalID = 2894,
				privateAuras = {},
			},
			[3420] = {
				events = {653, 664, 665, 863},
				journalID = 2871,
				privateAuras = {1297707, 1299899},
			},
			[3421] = {
				events = {711, 740, 742, 743, 744, 751, 753, 896, 897, 900},
				journalID = 2887,
				privateAuras = {},
			},
			[3429] = {
				events = {667, 677, 680, 682, 684, 687, 794, 811, 812, 898},
				journalID = 2883,
				privateAuras = {},
			},
			[3492] = {
				events = {699, 700, 746, 799, 800, 806, 810, 825, 826, 830},
				journalID = 2895,
				privateAuras = {},
			},
			["trash"] = {
				privateAuras = {}
			},
		},
	}
}

-- MARK: Instance Journal
addon.data.INSTANCE_JOURNAL = {
	[2859] = 1309, -- The Blinding Vale
	[2813] = 1304, -- Murder Row
	[2825] = 1311, -- Den of Nalorakk
	[2923] = 1313, -- Voidscar Arena
	[2993] = 1322, -- Altar of Fangs	
	[1762] = 1041, -- King's Rest
	[1877] = 1030, -- Temple of Sethraliss
	[2521] = 1202, -- Ruby Life Pools
	[3004] = 1320, -- The Venomous Abyss
}

-- MARK: Spell Data
addon.data.SPELL_FLAGS = {
	[0] = {flag = "|TInterface\\AddOns\\HBLyx_Encounter_Sound\\Media\\Flags\\Tank.png:16:16|t", text = L["SpellFlagTank"]};
	[1] = {flag = "|TInterface\\AddOns\\HBLyx_Encounter_Sound\\Media\\Flags\\Damager.png:16:16|t", text = L["SpellFlagDamager"]};
	[2] = {flag = "|TInterface\\AddOns\\HBLyx_Encounter_Sound\\Media\\Flags\\Healer.png:16:16|t", text = L["SpellFlagHealer"]};
	[3] = {flag = "|cffec8b27H|r", text = L["SpellFlagHeroic"]};
	[4] = {flag = "|TInterface\\AddOns\\HBLyx_Encounter_Sound\\Media\\Flags\\Deadly.png:16:16|t", text = L["SpellFlagDeadly"]};
	[5] = {flag = "|TInterface\\AddOns\\HBLyx_Encounter_Sound\\Media\\Flags\\Important.png:16:16|t", text = L["SpellFlagImportant"]};
	[6] = {flag = "|TInterface\\AddOns\\HBLyx_Encounter_Sound\\Media\\Flags\\Interrupt.png:16:16|t", text = L["SpellFlagInterrupt"]};
	[7] = {flag = "|TInterface\\AddOns\\HBLyx_Encounter_Sound\\Media\\Flags\\Magic.png:16:16|t", text = L["SpellFlagMagic"]};
	[8] = {flag = "|TInterface\\AddOns\\HBLyx_Encounter_Sound\\Media\\Flags\\Curse.png:16:16|t", text = L["SpellFlagCurse"]};
	[9] = {flag = "|TInterface\\AddOns\\HBLyx_Encounter_Sound\\Media\\Flags\\Poison.png:16:16|t", text = L["SpellFlagPoison"]};
	[10] = {flag = "|TInterface\\AddOns\\HBLyx_Encounter_Sound\\Media\\Flags\\Disease.png:16:16|t", text = L["SpellFlagDisease"]};
	[11] = {flag = "|TInterface\\AddOns\\HBLyx_Encounter_Sound\\Media\\Flags\\Enrage.png:16:16|t", text = L["SpellFlagEnrage"]};
	[12] = {flag = "|cffbf42f5M|r", text = L["SpellFlagMythic"]};
	[13] = {flag = "|TInterface\\AddOns\\HBLyx_Encounter_Sound\\Media\\Flags\\Bleed.png:16:16|t", text = L["SpellFlagBleed"]};
	[14] = {flag = "|cffffffffT|r", text = L["SpellFlagTextWarning"]};
}

-- text warning flag[14] data is originally from: https://wago.tools/db2/EncounterEvent?build=12.0.5.66529&page=1 
addon.data.SPELL_INFO = {
}

-- MARK: Gossips
addon.data.INSTANCE_GOSSIP = {
	-- Den of Nalorakk
	[2825] = {
		[135009] = true,
		[135010] = true,
		[137693] = true,
		[137702] = true,
	},
	-- Murder Row
	[2813] = {
		[131502] = true,
		[131567] = true,
	},
	-- The Blinding Vale
	[2859] = {
		[137222] = true,
	},
}

-- MARK: Data Changes