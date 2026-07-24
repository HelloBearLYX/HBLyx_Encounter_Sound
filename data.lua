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
	-- MARK: TBV
	[1309] = {
		name = select(1, EJ_GetInstanceInfo(1309)) or "The Blinding Vale",
		encounters = {
			[3199] = {
				events = {173, 174, 175, 176, 177},
				journalID = 2769,
				privateAuras = {{1261276, 1235865}, 1276586, 1239825, 1235574, 1235828, 1234802},
			},
			[3200] = {
				events = {178, 179, 180},
				journalID = 2770,
				privateAuras = {1236747, 1259365, 1237091, 1237267},
			},
			[3201] = {
				events = {115, 181, 182, 183, 184, 188},
				journalID = 2771,
				privateAuras = {1239919, 1240222, 1239825, 1241058, 1257094},
			},
			[3202] = {
				events = {189, 190, 191, 192},
				journalID = 2772,
				privateAuras = {1247052, 1247746, 1246751, 1246753},
			},
			["trash"] = {
				privateAuras = {1238084, 1238076, 1237858, 1303039, 1238294, 1242135, 1251345, 1238368, 1250937}
			},
		},
	},
	-- MARK: MR
	[1304] = {
		name = select(1, EJ_GetInstanceInfo(1304)) or "Murder Row",
		encounters = {
			[3101] = {
				events = {120, 122, 202, 610},
				journalID = 2679,
				privateAuras = {1228198, 1217633, 1223613, 1253813},
			},
			[3102] = {
				events = {123, 124, 125, 127, 193},
				journalID = 2680,
				privateAuras = {1219631, 474545, 474740, 1214352, 474515},
			},
			[3103] = {
				events = {30, 31, 32, 752, 753},
				journalID = 2681,
				privateAuras = {473898, 1214637, 1295455, 474234, 1214650},
			},
			[3105] = {
				events = {37, 38, 207},
				journalID = 2682,
				privateAuras = {113942},
			},
			["trash"] = {
				privateAuras = {1216571, 1216300, 1295035, 1216529, 1216590, 1201554, 1216074, 1257877, 1311136, 1295427, 1217973, 1297682, 1302010, 1216954, 1294870, 1218187, 1215985}
			},
		},
	},
	-- MARK: DoN
	[1311] = {
		name = select(1, EJ_GetInstanceInfo(1311)) or "Den of Nalorakk",
		encounters = {
			[3207] = {
				events = {86, 87, 88},
				journalID = 2776,
				privateAuras = {1234846, 1234681, 1235125, 1235405},
			},
			[3208] = {
				events = {67, 68, 69, 70},
				journalID = 2777,
				privateAuras = {1235549, 1297749, 1236289, 1235841},
			},
			[3209] = {
				events = {90, 92, 89, 91, 598},
				journalID = 2778,
				privateAuras = {1242869, 1261781, 1297792, 1255577, 1297797, 1262253},
			},
			["trash"] = {
				privateAuras = {1238247, 1238439, 1238687, 1238801, 1297701, 1252825, 1233904, 1239860, 1266193, 1241464, 1309964, 1246957, 1311695, 1247367, 1246882}
			},
		},
	},
	-- MARK: VA
	[1313] = {
		name = select(1, EJ_GetInstanceInfo(1313)) or "Voidscar Arena",
		encounters = {
			[3285] = {
				events = {39, 40, 41, 42, 558, 782},
				journalID = 2791,
				privateAuras = {1222103, 1296967},
			},
			[3286] = {
				events = {46, 47, 54, 55, 297},
				journalID = 2792,
				privateAuras = {1263971, 1222642, 1222692, 1222484},
			},
			[3287] = {
				events = {56, 57, 58, 171, 961},
				journalID = 2793,
				privateAuras = {1264188, 1300372, 1263983},
			},
			["trash"] = {
				privateAuras = {1267894, 1250043, 1299913, 1311730, 1249712, 1298899, 1299244, 1299133, 1298917, 1298922, 1298902, 1298903, 1300138, 1233535, 1252406, 1310309}
			},

		},
	},
	-- MARK: AoF
	[1322] = {
		name = select(1, EJ_GetInstanceInfo(1322)) or "Altar of Fangs",
		encounters = {
			[3456] = {
				events = {795, 797, 798, 899, 902},
				journalID = 2878,
				privateAuras = {1297876, 1307700},
			},
			[3457] = {
				events = {813, 814, 815, 816, 817, 818},
				journalID = 2879,
				privateAuras = {1299189, 1300503, 1305368, 1299080},
			},
			[3458] = {
				events = {821, 822, 823, 824},
				journalID = 2880,
				privateAuras = {1300894, 1301508, 1301231},
			},
			["trash"] = {
				privateAuras = {1294569, 1306669, 1306550, 1306232, 1294557, 1294845, 1307571, 1307531, 1308518}
			},
		},
	},
	-- MARK: KR
	[1041] = {
		name = select(1, EJ_GetInstanceInfo(1041)) or "King's Rest",
		encounters = {
			[2139] = {
				events = {767, 891, 892, 893},
				journalID = 2165,
				privateAuras = {265773, 1306736, 265914}, -- damage aura (1306736) for 265773
			},
			[2142] = {
				events = {878, 879, 880, 973},
				journalID = 2171,
				privateAuras = {267702, 267626, 267763, 267618, 267874},
			},
			[2140] = {
				events = {870, 872, 871, 873, 874, 875, 876}, -- Command Constructs
				journalID = 2170,
				privateAuras = {266191, 266231, 267494, 266238},
			},
			[2143] = {
				events = {831, 832, 833, 834, 835, 836, 837},
				journalID = 2172,
				privateAuras = {1303267, 1303039, 1302945, 1303399, 1303490},
			},
			["trash"] = {
				privateAuras = {269936, 276031, 270003, 1298104, 1294815, 1297781, 1297918, 270927, 1306763, 270931, 270292, 271555, 270499, 1302028, 270492, 1301851, 1298304, 272021, 272388, 274387}
			},
		},
	},
	-- MARK: ToS
	[1030] = {
		name = select(1, EJ_GetInstanceInfo(1030)) or "Temple of Sethraliss",
		encounters = {
			[2124] = {
				events = {689, 690, 691, 692},
				journalID = 2142,
				privateAuras = {1288885, 1288457},
			},
			[2125] = {
				events = {701, 702, 703, 704, 705, 706},
				journalID = 2143,
				privateAuras = {1308838, {1290030, 263958}, {1289109, 1289588}, 1293048, 267027, 1300227, 264206},
			},
			[2126] = {
				events = {697, 698},
				journalID = 2144,
				privateAuras = {266923},
			},
			[2127] = {
				events = {354, 828},
				journalID = 2145,
				privateAuras = {1300704, 1300684, 1302158, 1303446, 1302618, 1300877, 1302826, 1300714},
			},
			["trash"] = {
				privateAuras = {1308113, 1295635, 1291399, 1291468, 272655, 1293133, 1289589, 1308148, 1293307, 1291815, 1225638, 273274, 1308546, 1296052, 1303596, 1303486}
			},
		},
	},
	-- MARK: RLP
	[1202] = {
		name = select(1, EJ_GetInstanceInfo(1202)) or "Ruby Life Pools",
		encounters = {
			[2609] = {
				events = {866, 867, 868, 869},
				journalID = 2488,
				privateAuras = {1305234, 384024, 385518, 373688, 372963}, -- 397077 is the global damage and pull aura for 385518
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
				privateAuras = {1305225, 1307205, 1305201, 373693, 373692, 1307372, 385536, 395292, 372047, 1306366, 1310361, 1310599, 392641, 385536}
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
				privateAuras = {1287434, 1288554, 1284103, 1307939, 1293214, 1300235, 1299988, 1300239, 1294933, 1284109, 1288772, 1297624, 1292751},
			},
			[3445] = {
				events = {637, 638, 639, 640, 643, 673, 788},
				journalID = 2874,
				privateAuras = {1284590, 1284947, 1284491, 1288260, 1288297, 1284471},
			},
			[3455] = {
				events = {754, 757, 759},
				journalID = 2882,
				privateAuras = {},
			},
			[3497] = {
				events = {721, 722, 725, 727, 729, 768, 776, 783},
				journalID = 2894,
				privateAuras = {1291929, 1291918, 1286922, 1295858, 1295954, 1295928, 1308853, 1297625, 1299854},
			},
			[3420] = {
				events = {653, 664, 665, 863},
				journalID = 2871,
				privateAuras = {{1297707, 1299899}},
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
	-- Temple of Sethraliss
	[1877] = {
		[48126] = true,
	},
	-- Altar of Fangs
	[2993] = {
		[141729] = true,
	},
}

-- MARK: Data Changes