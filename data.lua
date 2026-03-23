local ADDON_NAME, addon = ...
local L = LibStub("AceLocale-3.0"):GetLocale(ADDON_NAME)
addon.data = {}

addon.data.MAP_ENCOUNTER_EVENTS = {
	-- MARK: current season 12.0
    [1201] = {
		seasonMapID = 402,
		name = select(1, EJ_GetInstanceInfo(1201)) or "Algeth'ar Academy",
		encounters = {
			[2562] = {
				events = {274, 275, 276, 277},
				journalID = 2509,
				privateAuras = {386201, 391977}
			},
			[2563] = {
				events = {282, 283, 284, 285},
				journalID = 2512,
				privateAuras = {388544, 389033, 396716}
			},
			[2564] = {
				events = {278, 279, 280, 397},
				journalID = 2495,
				privateAuras = {376760, 376997, 377009}
			},
			[2565] = {
				events = {293, 294, 295, 296},
				journalID = 2514,
				privateAuras = {389007, 389011}
			},
		},
	},
	[945] = {
		seasonMapID = 239,
		name = select(1, EJ_GetInstanceInfo(945)) or "Seat of the Triumvirate",
		encounters = {
			[2065] = {
				events = {223, 224, 225, 226, 238},
				journalID = 1979,
				privateAuras = {244588, 244599}
			},
			[2066] = {
				events = {234, 235, 236, 237, 243},
				journalID = 1980,
				privateAuras = {245742, 246026, 1263523, 1280064}
			},
			[2067] = {
				events = {246, 247, 376, 245},
				journalID = 1981,
				privateAuras = {1263542, 1268733, 1263532}
			},
			[2068] = {
				events = {248, 249, 250, 251, 252, 253, 254},
				journalID = 1982,
				privateAuras = {1265426, 1265650}
			},
		},
	},
	[1316] = {
		seasonMapID = 559,
		name = select(1, EJ_GetInstanceInfo(1316)) or "Nexus-Point Xenas",
		encounters = {
			[3328] = {
				events = {106, 107, 108, 172},
				journalID = 2813,
				privateAuras = {1251785, 1257836}
			},
			[3332] = {
				events = {33, 34, 35, 36, 313},
				journalID = 2814,
				privateAuras = {1249020, 1252828, 1282678}
			},
			[3333] = {
				events = {109, 110, 111, 112},
				journalID = 2815,
				privateAuras = {}
			},
		},
	},
	[1315] = {
		seasonMapID = 560,
		name = select(1, EJ_GetInstanceInfo(1315)) or "Maisara Caverns",
		encounters = {
			[3212] = {
				events = {150, 151, 152, 153, 154, 155},
				journalID = 2810,
				privateAuras = {1249478, 1260643}
			},
			[3213] = {
				events = {16, 17, 19, 20},
				journalID = 2811,
				privateAuras = {1251775}
			},
			[3214] = {
				events = {156, 157, 158},
				journalID = 2812,
				privateAuras = {1252675}
			},
		},
	},
	[476] = {
		seasonMapID = 161,
		name = select(1, EJ_GetInstanceInfo(476)) or "Skyreach",
		encounters = {
			[1698] = {
				events = {298, 299, 300, 301},
				journalID = 965,
				privateAuras = {153757, 1252733}
			},
			[1699] = {
				events = {302, 303, 304},
				journalID = 966,
				privateAuras = {154150}
			},
			[1700] = {
				events = {305, 306, 308, 603},
				journalID = 967,
				privateAuras = {1253511, 1253520}
			},
			[1701] = {
				events = {309, 310, 311, 312},
				journalID = 968,
				privateAuras = {153954, 1253541}
			},
		},
	},
	[1299] = {
		seasonMapID = 557,
		name = select(1, EJ_GetInstanceInfo(1299)) or "Windrunner Spire",
		encounters = {
			[3056] = {
				events = {239, 241, 242},
				journalID = 2655,
				privateAuras = {}
			},
			[3057] = {
				events = {25, 26, 27, 28, 29},
				journalID = 2656,
				privateAuras = {472793, 474129}
			},
			[3058] = {
				events = {210, 211, 212, 215, 216}, -- 213 is not a real event(same as 211)， 214 is not a real event(same as 215)
				journalID = 2657,
				privateAuras = {467620, 470966, 1283247}
			},
			[3059] = {
				events = {21, 22, 23, 24, 538},
				journalID = 2658,
				privateAuras = {472662, 1282911, 1253979, 1282911}
			},
		},
	},
	[1300] = {
		seasonMapID = 558,
		name = select(1, EJ_GetInstanceInfo(1300)) or "Magister's Terrace",
		encounters = {
			[3071] = {
				events = {281, 286, 287, 288},
				journalID = 2659,
				privateAuras = {}
			},
			[3072] = {
				events = {93, 94, 513, 96},
				journalID = 2661,
				privateAuras = {1225787, 1225792}
			},
			[3073] = {
				events = {635, 97, 98, 100},
				journalID = 2660,
				privateAuras = {1253709}
			},
			[3074] = {
				events = {290, 292, 420},
				journalID = 2662,
				privateAuras = {1215157, 1269631}
			},
		},
	},
	[278] = {
		seasonMapID = 556,
		name = select(1, EJ_GetInstanceInfo(278)) or "Pit of Saron",
		encounters = {
			[1999] = {
				events = {144, 145, 146, 147},
				journalID = 608,
				privateAuras = {1261286, 1261799, 1261540}
			},
			[2000] = {
				events = {164, 165, 166, 167, 168, 375},
				journalID = 610,
				privateAuras = {1262772, 1262596, 1263716, 1276648}
			},
			[2001] = {
				events = {203, 204, 205, 206, 561},
				journalID = 609,
				privateAuras = {1264453, 1264299, 1264246}
			},
		},
	},
	-- MARK: Non-season Dungeons 
	[1309] = {
		name = select(1, EJ_GetInstanceInfo(1309)) or "The Blinding Vale",
		encounters = {
			[3199] = {
				events = {177, 173, 174, 175, 176},
				journalID = 2769,
				privateAuras = {1261276}
			},
			[3200] = {
				events = {179, 180, 178},
				journalID = 2770,
				privateAuras = {}
			},
			[3201] = {
				events = {181, 182, 184, 188, 115, 183},
				journalID = 2771,
				privateAuras = {1240222}
			},
			[3202] = {
				events = {192, 191, 189, 190},
				journalID = 2772,
				privateAuras = {}
			},
		},
	},
	[1304] = {
		name = select(1, EJ_GetInstanceInfo(1304)) or "Murder Row",
		encounters = {
			[3101] = {
				events = {610, 202, 122, 120},
				journalID = 2679,
				privateAuras = {}
			},
			[3102] = {
				events = {124, 127, 193, 123, 125},
				journalID = 2680,
				privateAuras = {474545}
			},
			[3103] = {
				events = {30, 31, 32},
				journalID = 2681,
				privateAuras = {}
			},
			[3105] = {
				events = {37, 38, 207},
				journalID = 2682,
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
				privateAuras = {}
			},
			[3208] = {
				events = {67, 70, 68, 69},
				journalID = 2777,
				privateAuras = {1235549}
			},
			[3209] = {
				events = {92, 90, 89, 91},
				journalID = 2778,
				privateAuras = {}
			},

		},
	},
	[1313] = {
		name = select(1, EJ_GetInstanceInfo(1313)) or "Voidscar Arena",
		encounters = {
			[3285] = {
				events = {39, 558, 40, 42, 41},
				journalID = 2791,
				privateAuras = {}
			},
			[3286] = {
				events = {297, 47, 54, 55, 46},
				journalID = 2792,
				privateAuras = {}
			},
			[3287] = {
				events = {56, 57, 58, 171},
				journalID = 2793,
				privateAuras = {}
			},

		},
	},
    -- -- MARK: Raid
	[1314] = {
		name = select(1, EJ_GetInstanceInfo(1314)) or "The Dreamrift",
		encounters = {
			[3306] = {
				events = {118, 117, 307, 119, 51, 53, 458, 50, 149, 431, 555, 49, 217, 48, 170},
				journalID = 2795,
				privateAuras = {1245698, 1262020, 1250953, 1253744, 1264756, 1246653, 1257087, 1258192}
			},
		},
	},
	[1307] = {
		name = select(1, EJ_GetInstanceInfo(1307)) or "The Voidspire",
		encounters = {
			[3176] = {
				events = {197, 200, 194, 195, 201, 198, 492, 199, 209, 419, 196},
				journalID = 2733,
				privateAuras = {1275059, 1280075, 1284786, 1265540, 1283069, 1255680, {1249265, 1260203}, 1280023, 1260981}
			},
			[3177] = {
				events = {133, 59, 60, 62, 61},
				journalID = 2734,
				privateAuras = {1272527, 1243270, 1241844}
			},
			[3179] = {
				events = {140, 143, 148, 141, 142, 139},
				journalID = 2736,
				privateAuras = {1250828, 1245960, 1250991, 1245592, 1251213, 1248697, 1248709, 1250686, 1260030, {1253024, 1268992}}
			},
			[3178] = {
				events = {104, 105, 221, 220, 101, 102, 381, 103, 219, 377, 378, 379, 380},
				journalID = 2735,
				privateAuras = {1244672, 1252157, 1245554, 1270852, 1245175, 1265152, 1255763, {1262656, 1262999, 1262676}, 1255612, 1245421, 1245059, {1248865, 1249595}, 1270497}
			},
			[3180] = {
				events = {74, 80, 85, 79, 365, 78, 82, 71, 81, 75, 77, 373, 358, 359, 360, 535, 83, 374, 84, 76, 73},
				journalID = 2737,
				privateAuras = {1276982, 1246158, 1272324, 1246736, 1251857, 1249130, {1248985, 1248994}, {1249008, 1249024}, 1248652, 1246487, 1248721}
			},
			[3181] = {
				events = {15, 8, 12, 66, 65, 11, 131, 4, 14, 132, 13, 10, 5, 9, 137, 7, 6, 64, 135, 136},
				journalID = 2738,
				privateAuras = {1233602, 1242553, 1243753, 1238206, 1237038, {1232470, 1260027}, 1238708, 1283236, 1243981, 1234570, 1246462, {1237623, 1259861}, 1227557, 1239111, 1255453}
			},
		},
	},
	[1308] = {
		name = select(1, EJ_GetInstanceInfo(1308)) or "March on Quel'Danas",
		encounters = {
			[3182] = {
				events = {130, 494, 482, 384, 497, 134, 272, 138, 161, 273, 218, 495, 483, 385, 128},
				journalID = 2739,
				privateAuras = {1241292, 1241339, 1244348, 1266404, 1242803, 1242815, 1241840, 1241841, 1241992, 1242091},
			},
			[3183] = {
				events = {632, 259, 261, 364, 256, 434, 363, 437, 435, 362, 255, 433, 258, 636, 260, 405, 263, 262, 436, 650, 649, 644},
				journalID = 2740,
				privateAuras = {1282027, 1249609, 1249584, 1251789, 1284699, 1265842, 1262055, 1281184, 1266113, 1253104, 1282470, 1284984, 1253031, 1279512, 1282016, 1284527, 1284531, 1263514, 1275429, 1266946}
			},
		},
	},
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
    [153757] = {[2] = true, [13] = true},
    [154135] = {[2] = true},
    [154162] = {[14] = true},
    [154396] = {[6] = true},
    [156793] = {[5] = true, [14] = true},
    [244750] = {[0] = true, [6] = true},
    [248831] = {[6] = true, [14] = true},
    [376997] = {[0] = true},
    [377004] = {[14] = true},
    [377182] = {[5] = true, [14] = true},
    [385958] = {[0] = true},
    [387691] = {[5] = true, [14] = true},
    [388544] = {[0] = true},
    [388820] = {[14] = true},
    [388923] = {[2] = true, [5] = true, [14] = true},
    [466064] = {[0] = true},
    [466556] = {[2] = true},
    [467040] = {[14] = true},
    [467620] = {[0] = true},
    [468429] = {[5] = true, [14] = true},
    [472043] = {[5] = true, [14] = true},
    [472662] = {[0] = true},
    [472736] = {[5] = true},
    [472745] = {[2] = true},
    [472795] = {[5] = true},
    [472888] = {[0] = true},
    [473898] = {[0] = true},
    [474105] = {[8] = true, [12] = true},
    [474197] = {[14] = true},
    [474345] = {[5] = true},
    [474496] = {[0] = true},
    [474528] = {[2] = true},
    [1214357] = {[5] = true},
    [1218203] = {[14] = true},
    [1218347] = {[4] = true, [13] = true, [14] = true},
    [1218465] = {[14] = true},
    [1218466] = {[14] = true},
    [1222085] = {[0] = true},
    [1222274] = {[14] = true},
    [1222371] = {[14] = true},
    [1222642] = {[0] = true, [9] = true},
    [1222758] = {[14] = true},
    [1222795] = {[0] = true, [9] = true},
    [1223847] = {[12] = true, [14] = true},
    [1224478] = {[14] = true},
    [1224903] = {[12] = true},
    [1225011] = {[14] = true},
    [1225193] = {[5] = true, [14] = true},
    [1230304] = {[5] = true, [14] = true},
    [1233602] = {[5] = true},
    [1233787] = {[0] = true},
    [1233819] = {[14] = true},
    [1233865] = {[2] = true, [7] = true},
    [1234233] = {[14] = true},
    [1234564] = {[5] = true},
    [1234753] = {[0] = true, [12] = true},
    [1235548] = {[2] = true, [7] = true},
    [1235564] = {[5] = true, [14] = true},
    [1235640] = {[13] = true, [12] = true},
    [1235656] = {[14] = true},
    [1235783] = {[5] = true, [12] = true},
    [1236746] = {[12] = true, [14] = true},
    [1237614] = {[5] = true},
    [1238843] = {[4] = true, [14] = true},
    [1239080] = {[5] = true},
    [1239824] = {[2] = true},
    [1241058] = {[13] = true},
    [1241067] = {[5] = true},
    [1241292] = {[5] = true},
    [1241313] = {[5] = true, [14] = true},
    [1241339] = {[5] = true},
    [1242260] = {[4] = true, [3] = true},
    [1242792] = {[4] = true},
    [1243011] = {[14] = true},
    [1243743] = {[14] = true},
    [1243853] = {[14] = true},
    [1244221] = {[7] = true, [12] = true},
    [1244344] = {[2] = true},
    [1245391] = {[5] = true},
    [1245396] = {[14] = true},
    [1245404] = {[14] = true},
    [1245452] = {[14] = true},
    [1245645] = {[0] = true},
    [1245844] = {[4] = true},
    [1246162] = {[5] = true, [12] = true, [3] = true, [14] = true},
    [1246175] = {[1] = true, [5] = true, [14] = true},
    [1246372] = {[5] = true},
    [1246461] = {[0] = true},
    [1246485] = {[7] = true},
    [1246621] = {[2] = true},
    [1246666] = {[10] = true},
    [1246736] = {[0] = true},
    [1246749] = {[2] = true},
    [1246858] = {[12] = true},
    [1246918] = {[14] = true},
    [1247685] = {[0] = true},
    [1247937] = {[0] = true},
    [1248184] = {[14] = true},
    [1248449] = {[5] = true, [12] = true, [3] = true, [14] = true},
    [1248451] = {[5] = true, [12] = true, [3] = true, [14] = true},
    [1248674] = {[1] = true},
    [1248689] = {[0] = true, [7] = true},
    [1248847] = {[5] = true},
    [1249017] = {[6] = true, [7] = true},
    [1249130] = {[1] = true},
    [1249251] = {[2] = true},
    [1249479] = {[5] = true, [12] = true},
    [1249748] = {[4] = true, [5] = true},
    [1249796] = {[2] = true},
    [1250686] = {[2] = true},
    [1250708] = {[6] = true},
    [1250898] = {[4] = true},
    [1251023] = {[0] = true},
    [1251204] = {[5] = true},
    [1251361] = {[5] = true, [12] = true},
    [1251386] = {[5] = true},
    [1251554] = {[0] = true},
    [1251583] = {[4] = true},
    [1251767] = {[5] = true},
    [1251775] = {[4] = true},
    [1251857] = {[0] = true},
    [1252676] = {[5] = true},
    [1252703] = {[14] = true},
    [1253026] = {[12] = true, [14] = true},
    [1253272] = {[14] = true},
    [1253510] = {[12] = true},
    [1253519] = {[0] = true},
    [1253527] = {[14] = true},
    [1253788] = {[5] = true},
    [1253811] = {[14] = true},
    [1253915] = {[4] = true},
    [1253950] = {[0] = true},
    [1254081] = {[12] = true},
    [1255385] = {[2] = true},
    [1255702] = {[6] = true},
    [1255738] = {[2] = true},
    [1257085] = {[7] = true, [3] = true},
    [1257512] = {[14] = true},
    [1257567] = {[14] = true},
    [1260088] = {[14] = true},
    [1260731] = {[5] = true, [12] = true},
    [1260763] = {[0] = true},
    [1261299] = {[5] = true},
    [1261546] = {[0] = true},
    [1262029] = {[4] = true, [14] = true},
    [1262289] = {[5] = true, [12] = true},
    [1262582] = {[0] = true},
    [1262623] = {[5] = true},
    [1262846] = {[14] = true},
    [1262972] = {[14] = true},
    [1262983] = {[14] = true},
    [1263399] = {[12] = true, [14] = true},
    [1263406] = {[1] = true, [5] = true, [14] = true},
    [1263440] = {[0] = true},
    [1263542] = {[2] = true},
    [1263982] = {[14] = true},
    [1264048] = {[14] = true},
    [1264151] = {[14] = true},
    [1264287] = {[0] = true},
    [1264363] = {[5] = true, [14] = true},
    [1264439] = {[14] = true},
    [1264453] = {[4] = true},
    [1265131] = {[0] = true},
    [1265419] = {[5] = true, [12] = true},
    [1265689] = {[12] = true},
    [1266003] = {[4] = true},
    [1266388] = {[4] = true},
    [1266480] = {[0] = true},
    [1266622] = {[4] = true},
    [1266897] = {[3] = true},
    [1272310] = {[12] = true},
    [1272726] = {[13] = true},
    [1273158] = {[12] = true},
    [1276635] = {[12] = true},
    [1276639] = {[12] = true},
    [1276648] = {[12] = true},
    [1279420] = {[4] = true},
    [1280015] = {[7] = true, [12] = true},
    [1280458] = {[0] = true},
    [1281194] = {[5] = true},
    [1282001] = {[5] = true},
    [1282249] = {[12] = true},
    [1282251] = {[0] = true},
    [1282412] = {[2] = true},
    [1282856] = {[14] = true},
    [1283787] = {[14] = true},
    [1284525] = {[12] = true, [3] = true},
    [1284931] = {[12] = true},
    [1284980] = {[12] = true},
}

-- MARK: Data Changes
addon.data.CHANGED_EVENTS = {
}

addon.data.CHANGED_PRIVATEAURAS = {
	[3176] = {
		[1249265] = {1249265, 1260203},
	},
	[3177] = {
		[1259186] = false,
	},
	[3179] = {
		[1253024] = {1253024, 1268992},
	},
	[3178] = {
		[1262656] = {1262656, 1262999, 1262676},
		[1248865] = {1248865, 1249595},
		[1255979] = false,
		[1264467] = false,
	},
	[3180] = {
		[1248985] = {1248985, 1248994},
		[1249008] = {1249008, 1249024},
		[1258514] = false,
		[1246502] = false,
	},
	[3181] = {
		[1233865] = false,
		[1233887] = false,
		[1232470] = {1232470, 1260027},
		[1237623] = {1237623, 1259861},
	},
	[3306] = {
		[1272726] = false,
		[1265940] = false,
	},
}
