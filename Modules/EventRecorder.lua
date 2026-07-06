local ADDON_NAME, addon = ...

---@class EventRecorder
local EventRecorder = {
    modName = "EventRecorder",
    isInitialized = false,
    isRecording = false,
    data = {},
    startingTime = nil,
    startingID = nil,
    encounterID = nil,
    columnFrames = nil,
    row = 1,
    entryWidth = 0,
    entryHeight = 15,
}

-- MARK: Output Frame
local FEATURES = {
    "order",
    "spellName",
    "spellID",
    "duration",
    "time",
    "isCancelled",
}
local FRAME_WIDTH = 900
local FRAME_HEIGHT = 600
local ENTRY_WIDTH = math.floor(FRAME_WIDTH / #FEATURES)
local ENTRY_HEIGHT = 15
local CANCEL_WINDOW_SECONDS = 1

local function CreateEntryFrame(self, x, y, text)
    local entryFrame = CreateFrame("Frame", nil, self.eventFrame, "BackdropTemplate")
    entryFrame:SetSize(ENTRY_WIDTH, ENTRY_HEIGHT)
    entryFrame:SetPoint("TOPLEFT", self.eventFrame, "TOPLEFT", x, y)
    entryFrame:SetBackdrop({
        bgFile = "Interface/Tooltips/UI-Tooltip-Background",
    })
    entryFrame:SetBackdropColor(0, 0, 0, 1)

    local entryText = entryFrame:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    entryText:SetAllPoints()
    entryText:SetJustifyH("LEFT")
    entryText:SetJustifyV("TOP")
    entryText:SetFont("Fonts\\FRIZQT__.TTF", 12, "OUTLINE")
    entryText:SetTextColor(1, 1, 1, 1)
    entryText:SetSize(ENTRY_WIDTH, ENTRY_HEIGHT)
    if text then
        entryText:SetText(text)
    end

    entryFrame.text = entryText
    entryFrame:Show()

    return entryFrame
end

local function SetupDisplayFrame(self)
    local frame = self.eventFrame

    frame:SetPoint("CENTER", UIParent, "CENTER", 0, 0)
    frame:SetSize(FRAME_WIDTH, FRAME_HEIGHT)
    frame:SetFrameStrata("TOOLTIP")
    frame:SetBackdrop({
        bgFile = "Interface/Tooltips/UI-Tooltip-Background",
    })
    frame.border = CreateFrame("Frame", nil, frame, "BackdropTemplate")
    frame.border:SetAllPoints()
    frame.border:SetBackdrop({edgeFile = "Interface\\Buttons\\WHITE8x8", edgeSize = 1, insets = {left = 1, right = 1, top = 1, bottom = 1}})
    frame.border:SetBackdropBorderColor(0, 0, 0, 1)
    frame:SetBackdropColor(0, 0, 0, 0.5)
    frame:SetMovable(true)
    frame:EnableMouse(true)
    frame:RegisterForDrag("LeftButton")
    frame:SetScript("OnDragStart", frame.StartMoving)
    frame:SetScript("OnDragStop", frame.StopMovingOrSizing)

    -- set the hide button
    local hideButton = CreateFrame("Button", nil, UIParent)
    hideButton:SetSize(80, 20)
    hideButton:SetPoint("BOTTOMLEFT", frame, "TOPLEFT", 0, 0)
    hideButton.background = hideButton:CreateTexture(nil, "BACKGROUND")
    hideButton.background:SetAllPoints()
    hideButton.background:SetColorTexture(0, 0, 0, 0.5)
    hideButton.border = CreateFrame("Frame", nil, hideButton, "BackdropTemplate")
    hideButton.border:SetAllPoints()
    hideButton.border:SetBackdrop({edgeFile = "Interface\\Buttons\\WHITE8x8", edgeSize = 1, insets = {left = 1, right = 1, top = 1, bottom = 1}})
    hideButton.border:SetBackdropBorderColor(0, 0, 0, 1)
    hideButton.text = hideButton:CreateFontString(nil, "OVERLAY")
    hideButton.text:SetAllPoints()
    hideButton.text:SetFont("Fonts\\FRIZQT__.TTF", 12, "OUTLINE")
    hideButton.text:SetTextColor(1, 1, 1, 1)
    hideButton.text:SetText("Hide")
    hideButton.hide = false
    hideButton:SetScript("OnClick", function(self)
        if self.hide then
            self.text:SetText("Hide")
            frame:Show()
            self.hide = false
        else
            frame:Hide()
            self.text:SetText("HBES Dev")
            self.hide = true
        end
    end)
    frame.hideButton = hideButton

    self.displayTable = {}

    -- set up header row
    for order, feature in ipairs(FEATURES) do
        local featureFrame = CreateEntryFrame(self, ((order - 1) * ENTRY_WIDTH), 0, feature)

        self.displayTable[feature] = {}
        -- set first row to feature header
        self.displayTable[feature][1] = featureFrame
    end

    -- Row 1 is header; data rows start from row 2.
    self.row = 2

    frame:Show()
end

local function UpdateRowData(self, eventID)
    if not eventID then
        return nil
    end

    local data = self.data[eventID]
    if not data then
        return nil
    end

    local rowIndex
    if data.row then
        rowIndex = data.row
    else
        rowIndex = self.row
        data.row = rowIndex
        self.row = self.row + 1
    end

    for order, feature in ipairs(FEATURES) do
        local entryFrame = self.displayTable[feature][rowIndex]
        if not entryFrame then
            entryFrame = CreateEntryFrame(self, ((order - 1) * ENTRY_WIDTH), (rowIndex - 1) * ENTRY_HEIGHT * -1)
            self.displayTable[feature][rowIndex] = entryFrame
        end

        -- if the row is cancelled, set the backdrop color to red to indicate cancellation
        if data.isCancelled then
            entryFrame:SetBackdropColor(1, 0, 0, 1)
        end

        local value = data[feature]
        if value == nil then
            value = "nil"
        end
        entryFrame.text:SetText(tostring(value))
    end

    -- return the row index of the last updated row (excluding header row)
    return rowIndex
end

-- MARK: Event Handler
local function BuildSpellNameWithIcon(spellName, iconFileID)
    local output = ""
    if iconFileID then
        output = string.format("|T%s|t%s", iconFileID, spellName or "nil")
    else
        output = spellName or "nil"
    end

    return output
end

local function OnTimelineEventAdded(self, ...)
    local id, spellName, spellID, iconFileID, duration
    local payload = ...

    -- Support both table payload and positional payload to avoid API-shape breakage.
    if type(payload) == "table" then
        id = payload.id or payload.eventID or payload.timelineEventID
        spellName = payload.spellName or payload.name
        spellID = payload.spellID
        iconFileID = payload.iconFileID or payload.icon
        duration = payload.duration
    else
        id, _, spellName, spellID, iconFileID, duration = ...
    end

    if not self.startingTime then
        return
    end

    local numericID = tonumber(id)
    if numericID and not self.startingID then
        self.startingID = numericID
    end

    if not id then
        return
    end

    local durationNum = tonumber(duration)
    local durationValue = durationNum and math.floor(durationNum) or -1
    local order = -1
    if numericID and self.startingID then
        order = numericID - self.startingID
    end

    local now = GetTime()
    local time = now - self.startingTime
    local eventKey = tostring(id)
    local previous = self.data[eventKey]

    self.data[eventKey] = {
        order = order,
        spellName = BuildSpellNameWithIcon(spellName, iconFileID),
        spellID = spellID,
        duration = durationValue,
        time = math.floor(time),
        isCancelled = previous and previous.isCancelled or false,
        row = previous and previous.row or nil,
    }

    UpdateRowData(self, eventKey)
end

local function OnTimelineEventStateChanged(self, ...)
    local payload = ...
    local eventID

    if type(payload) == "table" then
        eventID = payload.id or payload.eventID or payload.timelineEventID
    else
        eventID = select(1, ...)
    end

    if not eventID then
        return
    end

    local state = C_EncounterTimeline.GetEventState(eventID)
    local isCancelledState = (
        state == Enum.EncounterTimelineEventState.Finished
        or state == Enum.EncounterTimelineEventState.Canceled
        or state == Enum.EncounterTimelineEventState.Paused
        or C_EncounterTimeline.IsEventBlocked(eventID)
    )

    if not isCancelledState then
        return
    end

    local eventKey = tostring(eventID)
    local data = self.data[eventKey]
    if not data then
        return
    end

    local eventTime = tonumber(data.time)
    if not eventTime or not self.startingTime then
        return
    end

    local currentTime = math.floor(GetTime() - self.startingTime)
    local withinCancelWindow = (currentTime - eventTime) <= CANCEL_WINDOW_SECONDS
    if withinCancelWindow then
        data.isCancelled = true
        UpdateRowData(self, eventKey)
    end
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
            self.eventFrame:UnregisterEvent("ENCOUNTER_TIMELINE_EVENT_STATE_CHANGED")
            addon:debug("Event Recorder stopped")
        end
    else
        self.isRecording = true
        self.encounterID = currentEncounter
        self.startingTime = GetTime()
        self.startingID = nil

        -- reset data and clear display table for new encounter except for header row
        self.data = {}
        self.row = 2
        for _, feature in ipairs(FEATURES) do
            for row, entryFrame in pairs(self.displayTable[feature]) do
                if row ~= 1 then
                    entryFrame.text:ClearText()
                    entryFrame:SetBackdropColor(0, 0, 0, 1)
                end
            end
        end
        
        -- Register events to listen for timeline events
        self.eventFrame:RegisterEvent("ENCOUNTER_TIMELINE_EVENT_ADDED")
        self.eventFrame:RegisterEvent("ENCOUNTER_TIMELINE_EVENT_STATE_CHANGED")
        addon:debug("Event Recorder started")
    end
end

-- MARK: Initialize

---@return EventRecorder
function EventRecorder:Initialize()
    self.eventFrame = CreateFrame("Frame", ADDON_NAME .. self.modName, UIParent, "BackdropTemplate")

    self.eventFrame:SetScript("OnEvent", function(_, event, ...)
        if event == "ENCOUNTER_TIMELINE_EVENT_ADDED" then
            OnTimelineEventAdded(self, ...)
        elseif event == "ENCOUNTER_TIMELINE_EVENT_STATE_CHANGED" then
            OnTimelineEventStateChanged(self, ...)
        end
    end)
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

---@return table
function EventRecorder:GetOutput()
    return self.data or {}
end

-- MARK: Register Module
addon.core:RegisterModule(EventRecorder.modName, function() return EventRecorder:Initialize() end)
