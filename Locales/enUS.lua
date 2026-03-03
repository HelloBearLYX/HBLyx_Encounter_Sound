local ADDON_NAME, addon = ...
local L = LibStub("AceLocale-3.0"):NewLocale(ADDON_NAME, "enUS", true)

L["Welecome"] = "|cff8788ee" .. ADDON_NAME .. "|r: Welcome! Your profile has been reset, and you can set up in: ESC-Options-AddOns-|cff8788ee" .. ADDON_NAME .. "|r"
L["WelecomeInfo"] = "Welecome! Thank you for using |cff8788ee" .. ADDON_NAME .. "|r!"
L["WelecomeSetting"] = "You can change settings with \"|cff8788ee/hblyx|r\" or open configuration panel in ESC-Options-AddOns-|cff8788ee" .. ADDON_NAME .. "|r"
L["GUITitle"] = "|cff8788ee" .. ADDON_NAME .. "|r Configurations Panel"
L["CombatLock"] = "|cffff0000In combat|r, cannot open the configuration panel or turn on test mode"
L["Notifications"] = "Notifications"
L["NotificationContent"] = "The tabs shows modules contained in this addon, you can configure each module separately." .. "\n\n" ..
"You can find on |cff8788eeHBLyx|r's page:" .. "\n" ..
"|cff8788eeHBLyx_Tools|r: a collection of modules including Combat Indicator, Combat Timer, Focus Interrupt and more modules" .. "\n" ..
"|cff8788eeMidnightFocusInterrupt|r: Focus Interrupt module standalone version" .. "\n" ..
"|cff8788eeHBLyx_Encounter_Sound|r: Encounter Sound module standalone version" .. "\n" ..
"|cff8788eeSharedMedia_HBLyx|r: an AI-generated Chinese sound pack(LibSharedMedia)"

-- MARK： Downloads/Update
L["Downloads/Update"] = "Downloads/Update"
L["Release_Info"] = "The official release version is |cffff0000only available on the following sites, all others are not from the author|r"

-- MARK: Change Log
L["ChangeLog"] = "Change Log"
L["ChangeLogContent"] =
"v3.12\n" ..
"-Encounter Sound: totally despatch the Encounter Sound module from |cff8788eeHBLyx_Tools|r, and put it as a standalone module |cff8788eeHBLyx_Encounter_Sound|r\n" ..
"v3.11\n" ..
"-Encounter Sound: add a new option to set group role for encounter events sound alert\n" ..
"v3.10\n" ..
"-Encounter Sound: Private Auras sub-module has been implemented\n" ..
"v3.9\n" ..
"-Encounter Sound: add a new module \"Encounter Sound\" which set and play custom sound alert for encounter time line events\n"

--MARK: Issues
L["Issues"] = "Issues"
L["AnyIssues"] = "If you encounter any issue, please feedback to the author through the contact information"
L["IssuesContent"] = "Q: Can you add XXX spell as an interrupt spell in Focus Interrupt module?\nA: No, spells with GCD cannot be added due to Blizzard's API restrictions. If you want to add a spell without GCD, please inform me with the spell details" .. "\n\n" ..
"Q: The BattleRes cannot display at the start of some Beta M+ dungeons and \"reload\" can fix it, why?\nA: It is caused by Blizzard's failure to trigger the CHALLENGE_MODE_START event in some dungeons with M+ mode, there is currently no good solution, wait for Blizzard to fix it\n\n" ..
"Q: There are some missing/incorrect events/private auras in Encounter Sound module, will them be corrected?\nA: Yes, as this module is highly dependent on data mining toward the game and Blizzard is constantly changing the Boss fight, it takes some time to fetch new data\n\n" ..
"Thanks for your understanding and support!"

-- MARK: Contact
L["Contact"] = "Contact"
L["GitHub"] = "Submit issue on GitHub"
L["CurseForge"] = "Comments on CurseForge"

-- MARK: Sound Channel
L["SoundChannelSettings"] = "Sound Channel"
L["SoundChannel"] = {
	Master = "Master",
	SFX = "Effects",
	Music = "Music",
	Ambience = "Ambience",
	Dialog = "Dialog",
}

L["GroupRole"] = {
	TANK = "TANK",
	HEALER = "HEALER",
	DAMAGER = "DPS",
}

-- MARK: Config
L["ConfigPanel"] = "Open Configurations Panel"
L["Test"] = "Test/Unlock(Drag to Move)"
L["Enable"] = "Enable"
L["SoundSettings"] = "Sound Settings"
L["Reload"] = "Reload(RL)"
L["ReloadNeeded"] = "Need to reload to take effect of changes"
L["ResetMod"] = "Reset Module"
L["ComfirmResetMod"] = "Are you sure you want to reset all settings for this module?(also reload UI)"
L["General"] = "General"
L["Raid"] = "Raid"
L["Dungeon"] = "Dungeon"
L["Profile"] = "Profile"
L["Export"] = "Export"
L["Import"] = "Import"
L["ProfileSettingsDesc"] = "Export and import your profile with the string below.\n"
L["ImportSuccess"] = "Profile imported successfully. Please reload your UI to apply the changes."
L["Add"] = "Add"
L["Remove"] = "Remove"
L["AddSuccess"] = "|cffffff00added|r successfully"
L["AddFailed"] = "Failed to |cffffff00add|r"
L["UpdateSuccess"] = "|cffffff00updated|r successfully"
L["RemoveSuccess"] = "|cffffff00removed|r successfully"
L["RemoveFailed"] = "Failed to |cffffff00remove|r"
L["LeftButton"] = "Left Click"
L["RightButton"] = "Right Click"
L["HideMinimapIcon"] = "Hide Minimap Icon"
L["Select"] = "Select"
L["PrivateAura"] = "Private Aura"

-- MARK: Style
L["ColorSettings"] = "Color Settings"
L["FrameStrata"] = "Frame Strata Level"

-- MARK: Encounter Sound
L["EncounterSoundSettings"] = "Encounter Sound"
L["EncounterSoundSettingsDesc"] = "Set and play custom sound alert for encounter time line events.\n\n" ..
"Specifically, this module provide a customized sound alert setting for each Boss fight in the instances.(only include current season instances)\n\n\n" ..
"Firstly, added M+ dungeons in 12.0 season 1, and then will add raids soon. As this module is highly dependent on data mining toward the game data, it is relatively costly to get data.\n\n" ..
"Many issue will be fixed and module will be improved with the process of data mining, thanks for your feedback and support!\n\n" ..
"This module is still working in progress, and hope this module can provide more flexible sound alerts for encounters.\n\n" ..
"|cffff0000NOTE|r: This module is defaultly disabled, as it is still in early stage and changing may be frequent. You can enable it by the checkbox below.\n"

L["EncounterSettings"] = "Encounter Events Settings"
L["SelectEncounter"] = "Select Encounter"
L["SelectInstance"] = "Select Instance"
L["EncounterEventTrigger"] = "Encounter Event Trigger"
L["EncounterEventSound"] = "Encounter Event Sound"
L["OnTextWarningShown"] = "Text Warning Shown"
L["OnTimelineEventFinished"] = "Event Finished"
L["OnTimelineEventHighlight"] = "Event Highlighted"
L["EventColor"] = "Event Color"
L["PrivateAuraSettings"] = "Private Aura Settings"
L["EncounterEvent"] = "Encounter Event"
L["SelectGroupRole"] = "Group Role"
L["EncounterSoundInstruction"] = "After selected |cffffff00an instance|r and |cffffff00an encounter|r, the settings for the encounter will pop up below.\nThere is a 0.5 second delay for the settings to render, as game need to take time to load spell descriptions.\n\n"
L["EncounterEventsInstruction"] = "To set sound, select |cffffff00an event trigger|r and |cffffff00a valid sound|r, the settings will be applied accordingly. Also, you can use |cffffff00\"Remove\"|r to remove the sound setting for the trigger selected.\n\n"..
"To set color(Text Color of Event), just use the color picker to select a |cffffff00color|r, and it will be applied to the encounter event. To remove the color setting, you can use the |cffffff00\"Remove\"|r button similarly.\n\n"..
"|cffff0000NOTE|r: |cffffff00Event Triggers|r are provided by Blizzard's APIs, and descriptions below:\n" ..
"|cffff5c00Text Warning Shown|r: trigger when |cffff5c00an text warning is shown initially|r\n" ..
"|cffff5c00Events Finished|r: trigger when the event is |cffff5c00finished|r on the timeline\n" ..
"|cffff5c00Events Highlighted|r: trigger when the event |cffff5c00will be finished in 5 seconds|r on the timeline\n" ..
"More information about the triggers on: |cff00ffffhttps://warcraft.wiki.gg/wiki/API_C_EncounterEvents.SetEventSound|r\n\n" ..
"e.g. If you want a \"AoE Incoming-3-2-1\", you should join the \"AoE Incoming\" and countdown sound into a single media file, and set it to play on the \"Event Highlighted\" trigger(play at 5 seconds before the AoE).\n\n" ..
"|cffff0000NOTE|r: Must |cffffff00enable Blizzard's Boss Warnings(including Boss Text Warning and Boss Ability Timeline)|r to make the corresponding event triggers active\n"
L["PrivateAuraInstruction"] = "Apply a sound alert for private auras, and the sound alert is played when the private aura is applied on \"player\".\n\n" ..
"To prevent unneccessary conflicts or redundancy, private auras' anchor are not provided in this module, since there are many UI addons offer the customized position of private auras.\n\n" ..
"|cffff0000NOTE|r: As Blizzard just removed a huge amount of private auras in dungeons(03/02/2026), |cffff0000some private auras settings are temperarily not working|r. Even though, the private aura alerts are still working if have been set before if the private aura still exists."