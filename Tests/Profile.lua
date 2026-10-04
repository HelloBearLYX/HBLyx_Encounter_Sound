-- Run from the addon root with Lua 5.1. WoW APIs and widgets are mocked.
---@diagnostic disable: undefined-global
local addon = {
    version = "4.2.3",
    configurationList = {},
    GUI = {},
    Utilities = {},
    core = {},
}
local messages, widgets = {}, {}
---@type string|nil
local popup
local L = setmetatable({}, { __index = function(_, key) return key end })

dofile("Libs\\LibStub\\LibStub.lua")
LibStub:NewLibrary("AceLocale-3.0", 1).GetLocale = function() return L end
dofile("Libs\\AceSerializer-3.0\\AceSerializer-3.0.lua")
dofile("Libs\\LibDeflate\\LibDeflate.lua")
local serializer = LibStub("AceSerializer-3.0")
local compress = LibStub("LibDeflate")
local prefix = "!HBLyx_Tools_EncounterSound_"

function addon.Utilities:print(message)
    table.insert(messages, message)
end
function addon.Utilities:SetPopupDialog(_, text)
    popup = text
end
function addon.GUI:RegisterModule(name, render)
    self[name] = render
end
function addon.GUI:CreateTabGroup() end
function addon.GUI:CreateScrollFrame() return {} end
function addon.GUI:CreateInlineGroup()
    return { AddChild = function() end }
end
function addon.GUI:CreateInformationTag() end
function addon.GUI:CreateLinebreaker() end
function addon.GUI:CreateButton() end
function addon.GUI:CreateMultiLineEditBox(_, label, text, callback)
    local widget = { text = text, callback = callback }
    function widget:SetText(value) self.text = value end
    widgets[label or "merge"] = widget
    return widget
end
addon.GUI.CreateEditBox = addon.GUI.CreateMultiLineEditBox

assert(loadfile("Configs\\EncounterSound.lua"))("TestAddon", addon)
addon.configurationList.OtherModule = { Enabled = true, data = {} }
assert(loadfile("Configs\\Profile.lua"))("TestAddon", addon)

local function Encode(profile)
    return prefix .. compress:EncodeForPrint(compress:CompressDeflate(serializer:Serialize({ profile = profile })))
end
local function Decode(text)
    local success, payload = serializer:Deserialize(compress:DecompressDeflate(compress:DecodeForPrint(text:sub(#prefix + 1))))
    assert(success)
    return payload.profile
end
local function Reset()
    addon.db = {
        Version = addon.version,
        EncounterSound = {
            ProfileName = "profile_old",
            SoundChannel = "Dialog",
            EnablePrivateAuras = true,
            data = { [100] = {
                [10] = { ["0"] = { sound = "old" }, ["2"] = { sound = "removed" } },
                [11] = { color = "ffffffff" },
            } },
            dataPA = { [200] = {
                [20] = { [0] = "old", [2] = "removed" },
                [21] = { [1] = "keep" },
            } },
        },
        OtherModule = { Enabled = false, data = { keep = true } },
    }
    HBLyx_Encounter_Sound_DB = addon.db
    messages, popup, widgets = {}, nil, {}
end
local function Incoming()
    return {
        EncounterSound = {
            ProfileName = "profile_new",
            SoundChannel = "Master",
            data = { [100] = {
                [10] = { ["1"] = { sound = "finish", role = { HEALER = true } }, color = "ff123456" },
                [12] = { ["0"] = { sound = "warning" } },
            } },
            dataPA = { [200] = {
                [20] = { [0] = "applied", [1] = "removed", [2] = "player" },
                [22] = { [2] = "new" },
            } },
        },
        OtherModule = { Enabled = true },
    }
end

local passed = 0
local function Test(name, callback)
    Reset()
    callback()
    passed = passed + 1
    print("PASS: " .. name)
end

Test("current schema merge, overwrite semantics, counts, name and settings", function()
    local original = addon.db
    assert(addon:MergeProfile(Encode(Incoming())))
    local profile = addon.db.EncounterSound
    assert(addon.db == original and HBLyx_Encounter_Sound_DB == original)
    assert(profile.ProfileName == "profile_new" and profile.version == addon.version)
    assert(profile.SoundChannel == "Dialog" and addon.db.OtherModule.Enabled == false)
    assert(addon.db.OtherModule.data.keep)
    assert(profile.data[100][10]["0"] == nil and profile.data[100][10]["2"] == nil)
    assert(profile.data[100][10]["1"].sound == "finish" and profile.data[100][10]["1"].role.HEALER)
    assert(profile.data[100][10].color == "ff123456" and profile.data[100][11].color == "ffffffff")
    assert(profile.data[100][12]["0"].sound == "warning")
    assert(profile.dataPA[200][20][0] == "applied" and profile.dataPA[200][20][1] == "removed")
    assert(profile.dataPA[200][20][2] == "player" and profile.dataPA[200][21][1] == "keep")
    assert(profile.dataPA[200][22][2] == "new")
    assert(messages[1]:find("2 Events", 1, true) and messages[1]:find("2 PrivateAuras", 1, true))
    assert(messages[1]:find("1 New", 1, true) and messages[1]:find("1 Overwritten", 1, true))
    local text = assert(popup)
    assert(text:find("profile_new", 1, true) and text:find("profile_old", 1, true))
end)

Test("legacy aura formats convert on merge and import", function()
    local incoming = Incoming()
    incoming.EncounterSound.version = "3.2.20"
    incoming.EncounterSound.dataPA[200] = {
        [20] = { trigger = { "0", 2, 2 }, sound = "legacy" },
        [22] = "string sound",
        [23] = { sound = "default trigger" },
        [24] = { trigger = {}, sound = "empty triggers" },
    }
    addon.db.EncounterSound.dataPA[200][21] = { trigger = { 1 }, sound = "old current" }
    assert(addon:MergeProfile(Encode(incoming)))
    assert(addon.db.EncounterSound.dataPA[200][21][1] == "old current")
    assert(addon:ImportProfile(Encode(incoming)))
    local pa = addon.db.EncounterSound.dataPA[200]
    assert(pa[20][0] == "legacy" and pa[20][2] == "legacy" and pa[20][1] == nil)
    assert(pa[20].trigger == nil and pa[20].sound == nil)
    assert(pa[22][0] == "string sound" and pa[23][0] == "default trigger" and pa[24][0] == "empty triggers")
    assert(addon.db.EncounterSound.version == addon.version)
end)

Test("full import defaults and export round trip", function()
    assert(addon:ImportProfile(Encode(Incoming())))
    assert(addon.db == HBLyx_Encounter_Sound_DB)
    assert(addon.db.Version == addon.version)
    assert(addon.db.EncounterSound.Enabled and addon.db.EncounterSound.EnablePrivateAuras)
    assert(addon.db.EncounterSound.EnableVictorySound == false)
    assert(addon.db.OtherModule.Enabled and type(addon.db.OtherModule.data) == "table")
    assert(addon.db.OtherModule.data ~= addon.configurationList.OtherModule.data)
    local exported = addon:ExportProfile()
    local decoded = Decode(exported)
    assert(decoded.EncounterSound.dataPA[200][20][0] == "applied")
    assert(decoded.EncounterSound.dataPA[200][20][2] == "player")
    assert(decoded.EncounterSound.data[100][10]["1"].role.HEALER)
    assert(addon:ImportProfile(exported))
    local roundTrip = Decode(addon:ExportProfile())
    assert(roundTrip.EncounterSound.ProfileName == "profile_new")
    assert(roundTrip.EncounterSound.dataPA[200][20][1] == "removed")
    assert(roundTrip.EncounterSound.data[100][10].color == "ff123456")
end)

Test("empty encounter profile fills defaults without resetting on reload", function()
    assert(addon:ImportProfile(Encode({ EncounterSound = {} })))
    assert(addon.db.EncounterSound.ProfileName == "Default")
    assert(type(addon.db.EncounterSound.data) == "table" and type(addon.db.EncounterSound.dataPA) == "table")
    assert(addon.db.Version == addon.version and addon.db.OtherModule.Enabled)
end)

Test("invalid encoding and payloads fail without changing the database", function()
    local cases = {
        false, 123, "", "wrong prefix", prefix, prefix .. "!!!",
        prefix .. compress:EncodeForPrint("not deflate"),
        prefix .. compress:EncodeForPrint(compress:CompressDeflate("not serialized")),
        Encode({}), Encode({ EncounterSound = false }),
        Encode({ EncounterSound = { ProfileName = {} } }),
        Encode({ EncounterSound = { data = { [100] = false } } }),
        Encode({ EncounterSound = { data = { [100] = { [10] = { ["0"] = "bad" } } } } }),
        Encode({ EncounterSound = { data = { [100] = { [10] = { color = "bad" } } } } }),
        Encode({ EncounterSound = { dataPA = { [200] = { [20] = { [3] = "bad" } } } } }),
        Encode({ EncounterSound = { dataPA = { [200] = { [20] = { [0.5] = "bad" } } } } }),
        Encode({ EncounterSound = { dataPA = { [200] = { [20] = { [0] = {} } } } } }),
        Encode({ EncounterSound = { Enabled = "bad" } }),
        Encode({ EncounterSound = {}, OtherModule = false }),
    }
    for _, input in ipairs(cases) do
        local original = addon.db
        local exported = addon:ExportProfile()
        local before = #messages
        assert(not addon:ImportProfile(input))
        assert(not addon:MergeProfile(input))
        assert(addon.db == original and HBLyx_Encounter_Sound_DB == original)
        assert(addon:ExportProfile() == exported and popup == nil)
        assert(#messages == before + 2)
    end
    assert(not addon:ImportProfile(nil) and not addon:MergeProfile(nil))
end)

Test("profile panel refreshes name and export only on success", function()
    addon.GUI.Profile({})
    widgets.merge.callback(Encode(Incoming()))
    assert(widgets.CurrentProfile.text == "profile_new")
    assert(Decode(widgets.Export.text).EncounterSound.dataPA[200][20][2] == "player")
    local exported = widgets.Export.text
    widgets.merge.callback("invalid")
    assert(widgets.Export.text == exported and widgets.CurrentProfile.text == "profile_new")
    local incoming = Incoming()
    incoming.EncounterSound.ProfileName = "imported"
    widgets.Import.callback(Encode(incoming))
    assert(widgets.CurrentProfile.text == "imported")
    assert(Decode(widgets.Export.text).EncounterSound.ProfileName == "imported")
end)

Test("merged and imported data is consumed by the Encounter Sound module", function()
    ---@type (fun(): table)|nil
    local initialize
    local monitors, auraSounds, eventSounds, colors = {}, {}, {}, {}
    function addon.core:RegisterModule(_, _, callback) initialize = callback end
    function addon.core:RegisterStateMonitor(state, _, callback) monitors[state] = callback end
    function addon.core:RegisterEvent() end
    function addon.Utilities:CheckVersion() return false end
    addon.LSM = { Fetch = function(_, _, sound) return sound end }
    addon.states = {
        encounterInfo = { encounterID = 100, encounterName = "Test" },
        instanceInfo = { instanceID = 300 },
    }
    addon.data = {
        INSTANCE_JOURNAL = { [300] = 200 },
        MAP_ENCOUNTER_EVENTS = { [200] = { name = "Test", encounters = {} } },
    }
    CreateFrame = function() return { SetScript = function() end } end
    SetCVar = function() end
    InCombatLockdown = function() return false end
    UnitGroupRolesAssigned = function() return "HEALER" end
    CreateColorFromHexString = function(color) return color end
    C_EncounterEvents = {
        SetEventColor = function(eventID, _, color) colors[eventID] = color end,
        SetEventSound = function(eventID, trigger, info)
            eventSounds[eventID] = eventSounds[eventID] or {}
            eventSounds[eventID][trigger] = info
        end,
    }
    C_UnitAuras = {
        AddAuraSound = function(trigger, info)
            auraSounds[info.spellID] = auraSounds[info.spellID] or {}
            auraSounds[info.spellID][trigger] = info.soundFileName
            return 1
        end,
    }
    assert(loadfile("Modules\\EncounterSound.lua"))("TestAddon", addon)
    for _, operation in ipairs({ "MergeProfile", "ImportProfile" }) do
        Reset()
        assert(addon[operation](addon, Encode(Incoming())))
        local module = assert(initialize)()
        module:RegisterEvents()
        monitors.encounterInfo()
        monitors.instanceInfo()
        assert(eventSounds[10][1].file == "finish")
        assert(colors[10] == "ff123456")
        assert(auraSounds[20][0] == "applied" and auraSounds[20][1] == "removed")
        assert(auraSounds[20][2] == "player" and auraSounds[22][2] == "new")
    end
end)

print(string.format("%d profile regression tests passed.", passed))
