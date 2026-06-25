local ADDON_NAME, addon = ...

---@class EventRecorder
local EventRecorder = {
    modName = "EventRecorder",
    isInitialized = false,
    isRecording = false,
    output = "",
    startingTime = nil,
    startingID = nil,
    outputText = nil,
}

-- MARK: Output Frame
local function RefreshOutputDisplay(self)
    if self.outputText then
        self.outputText:SetText(self.output or "")
    end
end

local function SetupDisplayFrame(self)
    local frame = self.eventFrame
    frame:ClearAllPoints()
    frame:SetPoint("TOPLEFT", UIParent, "TOPLEFT", 20, -20)
    frame:SetSize(400, 500)
    frame:SetBackdrop({
        bgFile = "Interface/Tooltips/UI-Tooltip-Background",
    })
    frame:SetBackdropColor(0, 0, 0, 1)
    frame:SetMovable(true)
    frame:EnableMouse(true)
    frame:RegisterForDrag("LeftButton")
    frame:SetScript("OnDragStart", frame.StartMoving)
    frame:SetScript("OnDragStop", frame.StopMovingOrSizing)

    local text = self.outputText or frame:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    text:ClearAllPoints()
    text:SetPoint("TOPLEFT", frame, "TOPLEFT", 10, 0)
    text:SetJustifyH("LEFT")
    text:SetJustifyV("TOP")
    text:SetFont("Fonts\\FRIZQT__.TTF", 12, "OUTLINE")
    text:SetText(self.output or "")

    self.outputText = text
    frame:Show()
    RefreshOutputDisplay(self)
end

-- MARK: Event Handler
local function OnTimelineEventAdded(self, ...)
    local id, spellName, spellID, duration
    local payload = ...

    -- Support both table payload and positional payload to avoid API-shape breakage.
    if type(payload) == "table" then
        id = payload.id or payload.eventID or payload.timelineEventID
        spellName = payload.spellName or payload.name
        spellID = payload.spellID
        duration = payload.duration
    else
        id, _, spellName, spellID, _, duration = ...
    end

    if not self.startingTime then
        return
    end

    local numericID = tonumber(id)
    if numericID and not self.startingID then
        self.startingID = numericID
    end

    local order = -1
    if numericID and self.startingID then
        order = numericID - self.startingID
    end

    local durationNum = tonumber(duration)
    local durationValue = durationNum and tostring(math.floor(durationNum)) or "-1"

    local time = GetTime() - self.startingTime
    local entry = string.format(
        "%s,%s,%s,%s,%d\n",
        tostring(order),
        tostring(spellName or "nil"),
        tostring(spellID or -1),
        durationValue,
        math.floor(time)
    )
    self.output = self.output .. entry
    RefreshOutputDisplay(self)
end

-- MARK: Encounter Monitor
local function MonitorEncounterInfo(self)
    local currentEncounter = addon.states.encounterInfo.encounterID
    if not currentEncounter then
        return
    elseif currentEncounter == 0 then
        if self.isRecording then
            self.isRecording = false
            self.startingID = nil
            self.eventFrame:UnregisterEvent("ENCOUNTER_TIMELINE_EVENT_ADDED")
            addon:debug("Event Recorder stopped")
        end
    else
        self.isRecording = true
        self.startingTime = GetTime()
        self.startingID = nil
        self.output = string.format("encounterID: %d\norder,spellName,spellID,duration,time\n", currentEncounter)
        self.eventFrame:RegisterEvent("ENCOUNTER_TIMELINE_EVENT_ADDED")
        addon:debug("Event Recorder started")
        RefreshOutputDisplay(self)
    end
end

-- MARK: Initialize

---@return EventRecorder
function EventRecorder:Initialize()
    self.eventFrame = CreateFrame("Frame", ADDON_NAME .. self.modName, UIParent, "BackdropTemplate")

    self.eventFrame:SetScript("OnEvent", function(_, event, ...)
        if event == "ENCOUNTER_TIMELINE_EVENT_ADDED" then
            OnTimelineEventAdded(self, ...)
        end
    end)

    addon:debug("Event Recorder module loaded")
    return self
end

-- MARK: InitializeRecorder

---@return boolean
function EventRecorder:InitializeRecorder()
    if self.isInitialized then
        return true
    end

    addon.core:RegisterStateMonitor("encounterInfo", self.modName, function()
        MonitorEncounterInfo(self)
    end)

    self.isInitialized = true
    SetupDisplayFrame(self)

    -- If user initializes mid-encounter, sync recorder state immediately.
    MonitorEncounterInfo(self)

    addon:debug("Event Recorder initialized")
    return true
end

-- MARK: RegisterEvents

function EventRecorder:RegisterEvents()
    -- Intentionally empty: this module is driven by encounterInfo state monitor.
end

-- MARK: GetOutput

---@return string
function EventRecorder:GetOutput()
    return self.output or ""
end

-- MARK: Register Module
addon.core:RegisterModule(EventRecorder.modName, function() return EventRecorder:Initialize() end)
