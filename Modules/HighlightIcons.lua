local ADDON_NAME, addon = ...
local L = LibStub("AceLocale-3.0"):GetLocale(ADDON_NAME)

---@class HighlightIcons
local HighlightIcons = {
    modName = "HighlightIcons", -- unique name for your module, should be the same as the file name
}

-- MARK: Constants
local UNKNOWN_SPELL_TEXTURE = 134400

-- MARK: Initialize

---Initialize (Constructor)
---@return HighlightIcons HighlightIcons a HighlightIcons object
function HighlightIcons:Initialize()
    self.head = CreateFrame("Frame", ADDON_NAME .. "_" .. self.modName, UIParent) -- create a frame for your module, you can use it to register events or as a parent for other frames
    self.tail = nil
    self.activeFrames = {} -- table to store active icons, key is eventID, value is the frame
    self.spareFrames = {} -- table to store spare frames for reuse
    self.head:Show()

    return self
end

-- MARK: Create Event Icon

--- Create a frame for an event
--- @returns frame the created frame
local function CreateEventIcon(self)
    local frame = CreateFrame("Frame", nil, UIParent)

    frame.cooldown = CreateFrame("Cooldown", nil, frame, "CooldownFrameTemplate")
    frame.cooldown:SetAllPoints()
    frame.cooldown:SetReverse(true)
    frame.cooldown:SetDrawEdge(false)

    frame.icon = frame:CreateTexture(nil, "ARTWORK")
    frame.icon:SetAllPoints()
    frame.icon:SetTexCoord(addon.db[self.modName]["IconZoom"], 1 - addon.db[self.modName]["IconZoom"], addon.db[self.modName]["IconZoom"], 1 - addon.db[self.modName]["IconZoom"])

    frame.textFrame = CreateFrame("Frame", nil, frame)
    frame.textFrame:SetAllPoints()
    frame.name = frame.textFrame:CreateFontString(nil, "OVERLAY")
    frame.name:SetFont(
        addon.LSM:Fetch("font", addon.db[self.modName]["Font"]) or "Fonts\\FRIZQT__.TTF",
        addon.db[self.modName]["FontSize"],
        "OUTLINE"
    )
    frame.name:SetPoint("CENTER", frame.textFrame, addon.db[self.modName]["FontAnchor"], 0, addon.db[self.modName]["FontYOffset"])
    frame.name:SetWidth(addon.db[self.modName]["IconSize"] * 2)
    frame.name:SetHeight(addon.db[self.modName]["FontSize"] * 3)

    frame.border = CreateFrame("Frame", nil, frame, "BackdropTemplate")
    frame.border:SetAllPoints()
    frame.border:SetBackdrop({edgeFile = "Interface\\Buttons\\WHITE8x8", edgeSize = 1, insets = {left = 1, right = 1, top = 1, bottom = 1}})
    frame.border:SetBackdropBorderColor(0, 0, 0, 1)

    frame:SetSize(addon.db[self.modName]["IconSize"], addon.db[self.modName]["IconSize"])
    frame.cooldown:SetScale(addon.db[self.modName]["TimeFontScale"])

    frame.active = false -- custom property to track if the frame is active or not
    frame.timer = nil

    return frame
end

-- MARK: List Helpers

local function ListInsert(self, frame)
    local anchorFrom, anchorTo = addon.Utilities:GetGrowAnchors(addon.db[self.modName]["Grow"])
    if not self.tail then
        frame:ClearAllPoints()
        frame:SetPoint(anchorFrom, self.head, anchorFrom, 0, 0)
        frame.prev = self.head
    else
        frame:ClearAllPoints()
        frame:SetPoint(anchorFrom, self.tail, anchorTo, 0, 0)
        frame.prev = self.tail
        frame.prev.next = frame
    end
    self.tail = frame
end

local function ListRemove(self, frame)
    local anchorFrom, anchorTo = addon.Utilities:GetGrowAnchors(addon.db[self.modName]["Grow"])
    if frame.prev == self.head then
        if frame.next then
            frame.next:ClearAllPoints()
            frame.next:SetPoint(anchorFrom, self.head, anchorFrom, 0, 0)
            frame.next.prev = self.head
        else
            self.tail = nil
        end
    else
        if frame.next then
            frame.next:ClearAllPoints()
            frame.next:SetPoint(anchorFrom, frame.prev, anchorTo, 0, 0)
            frame.next.prev = frame.prev
            frame.prev.next = frame.next
        else
            frame.prev.next = nil
            self.tail = frame.prev
        end
    end
    frame.prev = nil
    frame.next = nil
end

-- MARK: Unload Event

---Unload an event and hide its frame
---@param self HighlightIcons self reference
---@param frame frame the frame to unload
local function UnloadEvent(self, frame)
    if frame.timer then
        frame.timer:Cancel()
        frame.timer = nil
    end

    ListRemove(self, frame)

    -- reset frame properties and hide it
    frame.active = false
    frame.eventTimelineID = nil
    frame.icon:SetTexture(UNKNOWN_SPELL_TEXTURE)
    frame.name:SetText("")
    frame:Hide()
    if frame.timer then
        frame.timer:Cancel()
        frame.timer = nil
    end
    self.activeFrames[frame.eventID] = nil -- remove the frame from active icons
    table.insert(self.spareFrames, frame) -- add the frame back to the spare frames for reuse
end

-- MARK: Load Event

--- Load an event and show its frame
--- @param self HighlightIcons self reference
--- @param frame frame the frame to load
--- @param eventTimelineID number the event timeline ID to load
local function LoadHighlightEvent(self, frame, eventTimelineID)
    ListInsert(self, frame)

    -- set the frame properties and show it
    frame.eventID = eventTimelineID
    frame.active = true
    frame.eventTimelineID = eventTimelineID
    local eventInfo = C_EncounterTimeline.GetEventInfo(eventTimelineID)

    frame.icon:SetTexture(C_Spell.GetSpellInfo(eventInfo.spellID).iconID or UNKNOWN_SPELL_TEXTURE)
    frame.name:SetText(eventInfo.spellName or "")
    local duration = C_EncounterTimeline.GetEventTimeRemaining(eventTimelineID)
    frame.cooldown:SetCooldownDuration(duration)
    frame.timer = C_Timer.NewTimer(duration, function()
        UnloadEvent(self, frame)
    end)
    frame:Show()
end

--- Load an event and show its frame, reusing spare frames if available
--- @param self HighlightIcons self reference
--- @param eventTimelineID number the event timeline ID to load
local function LoadEvent(self, eventTimelineID)
    local frame
    if self.spareFrames[#self.spareFrames] then -- if there are spare frames, reuse one
        frame = table.remove(self.spareFrames, #self.spareFrames) -- pop the last spare frame to reduce the table.remove() run-time
    else
        frame = CreateEventIcon(self)
    end

    LoadHighlightEvent(self, frame, eventTimelineID)
    self.activeFrames[frame.eventID] = frame -- add the frame to active icons
end

-- MARK: ON_STATE_CHANGED

local function ON_ENCOUNTER_TIMELINE_EVENT_STATE_CHANGED(self, eventID)
    local frame = self.activeFrames[eventID]

    if frame then
        local state = C_EncounterTimeline.GetEventState(eventID)
        if state == Enum.EncounterTimelineEventState.Finished or state == Enum.EncounterTimelineEventState.Canceled then
            UnloadEvent(self, frame)
        elseif  state == Enum.EncounterTimelineEventState.Paused or C_EncounterTimeline.IsEventBlocked(eventID) then -- paused or blocked
            frame.cooldown:Pause()
            if frame.timer then
                frame.timer:Cancel()
                frame.timer = nil
            end
        elseif state == Enum.EncounterTimelineEventState.Active then
            if frame.cooldown:IsPaused() then
                frame.cooldown:Resume()
            end
            
            if frame.timer then
                frame.timer:Cancel()
            end
            frame.timer = C_Timer.NewTimer(math.max(C_EncounterTimeline.GetEventTimeRemaining(eventID), 0), function()
                UnloadEvent(self, frame)
            end)
        else
        end
    end
end

-- MARK: UpdateStyle

---Update style settings and render them in-game for CustomTracker
function HighlightIcons:UpdateStyle()
    self.head:SetFrameStrata(addon.db[self.modName]["FrameStrata"] or "MEDIUM")
    self.head:SetSize(addon.db[self.modName]["IconSize"], addon.db[self.modName]["IconSize"])
    self.head:SetPoint("CENTER", UIParent, "CENTER", addon.db[self.modName]["X"], addon.db[self.modName]["Y"])

    for _, frame in pairs(self.spareFrames) do
        frame:SetSize(addon.db[self.modName]["IconSize"], addon.db[self.modName]["IconSize"])
        frame.cooldown:SetScale(addon.db[self.modName]["TimeFontScale"])
        frame.icon:SetTexCoord(addon.db[self.modName]["IconZoom"], 1 - addon.db[self.modName]["IconZoom"], addon.db[self.modName]["IconZoom"], 1 - addon.db[self.modName]["IconZoom"])
        frame.name:SetFont(
            addon.LSM:Fetch("font", addon.db[self.modName]["Font"]) or "Fonts\\FRIZQT__.TTF",
            addon.db[self.modName]["FontSize"],
            "OUTLINE"
        )
        frame.name:ClearAllPoints()
        frame.name:SetPoint("CENTER", frame, addon.db[self.modName]["FontAnchor"], 0, addon.db[self.modName]["FontYOffset"])
        frame.name:SetWidth(addon.db[self.modName]["IconSize"] * 2)
        frame.name:SetHeight(addon.db[self.modName]["FontSize"] * 3)
    end

    for _, frame in pairs(self.activeFrames) do
        frame:SetSize(addon.db[self.modName]["IconSize"], addon.db[self.modName]["IconSize"])
        frame.cooldown:SetScale(addon.db[self.modName]["TimeFontScale"])
        frame.icon:SetTexCoord(addon.db[self.modName]["IconZoom"], 1 - addon.db[self.modName]["IconZoom"], addon.db[self.modName]["IconZoom"], 1 - addon.db[self.modName]["IconZoom"])
        frame.name:SetFont(
            addon.LSM:Fetch("font", addon.db[self.modName]["Font"]) or "Fonts\\FRIZQT__.TTF",
            addon.db[self.modName]["FontSize"],
            "OUTLINE"
        )
        frame.name:ClearAllPoints()
        frame.name:SetPoint("CENTER", frame, addon.db[self.modName]["FontAnchor"], 0, addon.db[self.modName]["FontYOffset"])
        frame.name:SetWidth(addon.db[self.modName]["IconSize"] * 2)
        frame.name:SetHeight(addon.db[self.modName]["FontSize"] * 3)
    end
end

-- MARK: Test

---Test Mode
---@param on boolean turn the Test mode on or off
function HighlightIcons:Test(on)
    if not addon.db[self.modName]["Enabled"] then -- if the module is not enabled, do not allow test mode
        return
    end

    if on then
        addon.Utilities:ShowDragRegion(self.head, L["HighlightIconsSettings"])
        addon.Utilities:MakeFrameDragPosition(self.head, self.modName, "X", "Y")
    else
        addon.Utilities:HideDragRegion(self.head)
    end
end

-- MARK: RegisterEvents

---Register events
function HighlightIcons:RegisterEvents()
    local function OnEvent(_, event, ...)
        if event == "ENCOUNTER_TIMELINE_EVENT_HIGHLIGHT" then
            local eventTimelineID = select(1, ...)
            LoadEvent(self, eventTimelineID)
        elseif event == "ENCOUNTER_TIMELINE_EVENT_STATE_CHANGED" then
            local eventID = select(1, ...)
            ON_ENCOUNTER_TIMELINE_EVENT_STATE_CHANGED(self, eventID)
        end
    end

    addon.core:RegisterEvent("ENCOUNTER_TIMELINE_EVENT_HIGHLIGHT", self.head, self.modName)
    addon.core:RegisterEvent("ENCOUNTER_TIMELINE_EVENT_STATE_CHANGED", self.head, self.modName)

    self.head:SetScript("OnEvent", OnEvent)
end

-- MARK: Register Module
addon.core:RegisterModule(HighlightIcons.modName, function() return HighlightIcons:Initialize() end)
