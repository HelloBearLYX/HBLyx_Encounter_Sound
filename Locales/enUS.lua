local ADDON_NAME, addon = ...
local L = LibStub("AceLocale-3.0"):NewLocale(ADDON_NAME, "enUS", true)

L["Welecome"] = "|cff8788ee" .. ADDON_NAME .. "|r: Welcome! Your profile has been reset, and you can set up in: ESC-Options-AddOns-|cff8788ee" .. ADDON_NAME .. "|r"
L["WelecomeInfo"] = "Welecome! Thank you for using |cff8788ee" .. ADDON_NAME .. "|r!"
L["WelecomeSetting"] = "You can change settings with \"|cff8788ee/hbes|r\" or open configuration panel in ESC-Options-AddOns-|cff8788ee" .. ADDON_NAME .. "|r"
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
"v3.17\n" .. "-Added Timeline Skins module which provides customizable timeline\n" ..
"v3.16\n" .. "-Add Highlight Icons module which displays highlighted(<= 5s) events in icons\n" ..
"v3.15\n" .. "-Implemented Templates, Spell Tags, and High-Performance-Sound-Select-Widget\n" ..
"v3.14\n" .. "-Apply Blizzard 03/02/26 private aura data update, and continuously correct data\n"

--MARK: Issues
L["Issues"] = "Issues"
L["AnyIssues"] =
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

-- MARK: Spell Flags
L["SpellFlagTank"] = "Tank"
L["SpellFlagDamager"] = "Damager"
L["SpellFlagHealer"] = "Healer"
L["SpellFlagHeroic"] = "|cffec8b27H|reroic"
L["SpellFlagDeadly"] = "Deadly"
L["SpellFlagImportant"] = "Important"
L["SpellFlagInterrupt"] = "Interrupt"
L["SpellFlagMagic"] = "Magic"
L["SpellFlagCurse"] = "Curse"
L["SpellFlagPoison"] = "Poison"
L["SpellFlagDisease"] = "Disease"
L["SpellFlagEnrage"] = "Enrage"
L["SpellFlagMythic"] = "|cffbf42f5M|rythic"
L["SpellFlagBleed"] = "Bleed"

-- MARK: Config
L["ConfigPanel"] = "Open Configurations Panel"
L["Test"] = "Unlock(Drag to Move)"
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
L["EncounterSoundEffects"] = "Encounter Sound Effects"
L["VictorySound"] = "Victory Sound"
L["StartSound"] = "Start Sound"
L["TestTimeline"] = "Test Timeline"
L["TestLoadFailed"] = "Test |cffff0000Failed|r: No data found for encounter: "
L["TestLoadSuccess"] = "Test load |cff00ff00success|r: Test for encounter-"
L["ClearPrivateAurasData"] = "Cleared registed private aura sounds: "
L["ClearEventSound"] = "Cleared registed event sounds: "
L["CurrentProfile"] = "Current Profile: "
L["SelectAnEvent"] = "Select an encounter event to begin setting"
L["SelectPA"] = "Select a private aura to begin setting"
L["NoSuchEncounterToTest"] = "If you want to test, please enter the encounter ID like \"|cff8788ee\\hbes test <encounterID>|r\", where <encounterID> is the ID of the encounter you want to test"
L["DataMigration"] = "Data Migration"
L["GeneralSettings"] = "General Settings"
L["HideEncounterPrint"] = "Hide Encounter Start/End Print"
L["Applied"] = " applied"
L["Duplicated"] = "duplicated"
L["EmptyKey"] = "Empty key"
L["MergedInto"] = "merged into"
L["MergeSuccess"] = "Profile merged |cffffff00successfully|r"
L["MergeSummary"] = "|cffff5c00Merged Summary|r"
L["Events"] = "events"
L["PrivateAuras"] = "private auras"
L["New"] = "new"
L["Overwritten"] = "overwritten"
L["MergeDesc"] = "|cffff5c00Merge|r\nMerge profile with current profile, the duplicated entries will be overwritten by the input profile. The merge action will only merge the events' settings and private auras' settings, and other settings will not be merged(victory sound, start sound, and templates etc.).\n\n"
L["CountDown"] = "Countdown"

-- MARK: Style
L["ColorSettings"] = "Color Settings"
L["FrameStrata"] = "Frame Strata Level"
L["StyleSettings"] = "Style Settings"
L["IconSettings"] = "Icon Settings"
L["PositionSettings"] = "Position Settings"
L["FontSettings"] = "Font Settings"
L["HighlightIconsSettings"] = "Highlight Icons"
L["HighlightIconsSettingsDesc"] = "Show highlighted encounter timeline events as icons.\n\nYou can adjust icon size, grow direction, font placement, and anchor position here.\n\n"
L["TimelineSkinsSettings"] = "Timeline Skins"
L["TimelineSkinsSettingsDesc"] = "Make a copy of original Blizzard Encounter Timeline and hide the original timeline\nAllow customization of the timeline.\n"
L["IconSize"] = "Icon Size"
L["IconZoom"] = "Icon Zoom"
L["Length"] = "Length"
L["X"] = "X"
L["Y"] = "Y"
L["Font"] = "Font"
L["FontSize"] = "Font Size"
L["FontYOffset"] = "Font Y Offset"
L["BackgroundAlpha"] = "Background Alpha"
L["TickAlpha"] = "Tick Alpha"
L["GrowDirection"] = "Grow"
L["TextGrowDirection"] = "Text Grow"
L["VerticalLayout"] = "Vertical Layout"
L["FontAnchor"] = "Font Anchor"
L["TimeFontScale"] = "Time Font Scale"
L["ShowOnlyActive"] = "Show When Active"
L["ShowQueuedIcons"] = "Show Queued Icons"

-- MARK: Encounter Sound
L["EncounterSoundSettings"] = "Encounter Sound"
L["EncounterSoundSettingsDesc"] = "Set and play custom sound alert for encounter time line events and private auras.\n\n" ..
"Many issue will be fixed and module will be improved with the process of data mining, thanks for your feedback and support!\n\n" ..
"This module is keeping working in progress, and hope this module can provide more flexible sound alerts for encounters.\n\n"

L["EncounterSettings"] = "Encounter Events Settings"
L["SelectEncounter"] = "Select Encounter"
L["SelectInstance"] = "Select Instance"
L["EncounterEventTrigger"] = "Encounter Event Trigger"
L["EncounterEventSound"] = "Encounter Event Sound"
L["OnTextWarningShown"] = "|cffff5c00Text Warning Shown|r"
L["OnTextWarningShownDesc"] = ": trigger when an text warning is shown initially"
L["OnTimelineEventFinished"] = "|cffff5c00Event Finished|r"
L["OnTimelineEventFinishedDesc"] = ": trigger when the event is finished on the timeline"
L["OnTimelineEventHighlight"] = "|cffff5c00Event Highlighted|r"
L["OnTimelineEventHighlightDesc"] = ": trigger when the event will be finished in 5 seconds on the timeline"
L["EventColor"] = "Event Color"
L["PrivateAuraSettings"] = "Private Aura Settings"
L["EncounterEvent"] = "Encounter Event"
L["SelectGroupRole"] = "Group Role"
L["EncounterSoundInstruction"] = "After selected |cffffff00an instance|r and |cffffff00an encounter|r, the settings for the encounter will pop up below.\n\n"
L["EncounterEventsInstruction"] =
"|cffff0000NOTE|r: Must |cffffff00enable Blizzard's Boss Warnings(including Boss Text Warning and Boss Ability Timeline)|r to make the corresponding event triggers active\n\n" ..
"|cffffff00Test Timeline|r: simulate the timeline for all events of this Boss with 6 seconds intervals(not actual timeline), to test the correctness and effect of the settings, but the actual timeline trigger perform differently\n\n" ..
"|cffff0000NOTE|r: Test Timeline only works with the events which has been set already, and, therefore, |cffFF7C0Aif there is no event has been set for this encounter, Test Timeline will not work|r.\n\n"
L["PrivateAuraInstruction"] = "Apply a sound alert for private auras, and the sound alert is played when the private aura is applied on \"player\".\n\n" ..
"To prevent unneccessary conflicts or redundancy, private auras' anchor are not provided in this module, since there are many UI addons offer the customized position of private auras.\n\n"

-- MARK: Templates
L["TemplateSettings"] = "Template"
L["SelectTemplate"] = "Select Template"
L["TemplateNameNew"] = "New Template"
L["ApplyTemplate"] = "Apply Template"
L["TemplateDesc"] = "The templates are used to rapidly apply to events with similar conditions.\n\n" ..
"After you set templates up, you can apply it on an event, and the settings will be applied to the event immediately, and you can also modify the settings after applying template to fit the specific event.\n\n" ..
"The template name is the |cffffff00unique key for templates|r, so when you create a new template, please make sure the name is not the same as existing templates.\n\n" ..
"You can choose template from the dropdown menu to delete or update, and the new template will be added when enter the new template name in the editbos\n"

-- MARK: Contributors
L["Contributors"] = "Contributors"
L["data correction"] = "Data Correction"
L["testing"] = "Testing"
L["feedbacks"] = "Feedbacks"
L["configuration sharing"] = "Configuration Sharing"
L["ThanksTo"] = "Thanks for the contributons from the following:"
L["AnonymousContributors"] = "\nAlso thanks many others who submitted data correction, bug reports, and suggestions."
L["ContributeData"] = "If you want to Contribute data or any issues, please use the GitHub or Discord channel! You can find the links in the Contact section, the Pull Request(PR) is recommended if possible.\n" ..
"If you want to help to improve the data, you can use the command \"|cff8788ee/hbes dev|r\" to open the developer tools panel, and there is a \"Data Fetch\" tab which provide the data fetching tools to fetch in-game data in format of CSV, and you can submit it if needed. Thank you so much!\n"