local ADDON_NAME, addon = ...
local L = LibStub("AceLocale-3.0"):GetLocale(ADDON_NAME)

---@class TimelineSkins
local TimelineSkins = {
    modName = "TimelineSkins",
}

-- MARK: Constants
local UNKNOWN_SPELL_TEXTURE = 134400
local TIMELINE_LENGTH_SECONDS = 12
local TICK_POSITION_SECONDS = 5
local TICK_POSITION = TICK_POSITION_SECONDS / TIMELINE_LENGTH_SECONDS

-- MARK: Initialize

---Initialize (Constructor)
---@return TimelineSkins TimelineSkins a TimelineSkins object
function TimelineSkins:Initialize()
    -- force enable encounter timeline
    SetCVar("encounterTimelineEnabled", "1")

    -- hide original timeline but keep it to fetch data from it
    EncounterTimeline:Hide()
    EncounterTimeline:HookScript("OnShow", function() EncounterTimeline:Hide() end)

    self.frame = CreateFrame("Frame", ADDON_NAME .. "_" .. self.modName, UIParent, "BackdropTemplate")

    self.tickLine = self.frame:CreateTexture(nil, "ARTWORK")

    self.frame.background = self.frame:CreateTexture(nil, "BACKGROUND")
    self.frame.background:SetAllPoints()

    self.spareIcons = {}
    self.queueIcons = {}
    self.activeIcons = {}
    self.queueHead = CreateFrame("Frame", nil, self.frame) -- a dummy frame to attach the queue icons
    self.queueTail = nil

    self:UpdateFrameVisibility()

    return self
end

-- MARK: Frame Visibility

---Update timeline frame visibility based on current settings and icon state.
---@param self TimelineSkins self
function TimelineSkins:UpdateFrameVisibility()
    if addon.db[self.modName]["ShowOnlyActive"] then
        if next(self.activeIcons) or next(self.queueIcons) then
            self.frame:Show()
        else
            self.frame:Hide()
        end
    else
        self.frame:Show()
    end
end

-- MARK: Update Style Icon

---Apply current style settings to an icon frame.
---@param self TimelineSkins self
---@param frame Frame icon frame to update
local function UpdateIconStyle(self, frame)
    frame:SetSize(addon.db[self.modName]["IconSize"], addon.db[self.modName]["IconSize"])
    frame.cooldown:SetScale(addon.db[self.modName]["TimeFontScale"])
    frame.icon:SetTexCoord(addon.db[self.modName]["IconZoom"], 1 - addon.db[self.modName]["IconZoom"], addon.db[self.modName]["IconZoom"], 1 - addon.db[self.modName]["IconZoom"])
    frame.text:SetFont(
        addon.LSM:Fetch("font", addon.db[self.modName]["Font"]) or "Fonts\\FRIZQT__.TTF",
        addon.db[self.modName]["FontSize"],
        "OUTLINE"
    )
    frame.text:ClearAllPoints()
    frame.text:SetPoint(self.textAnchorFrom, frame.textFrame, self.textAnchorTo, 0, 0)
    frame.text:SetWidth(addon.db[self.modName]["IconSize"] * 2)
    frame.text:SetHeight(addon.db[self.modName]["FontSize"] * 3)
end

-- MARK: Create Timeline Icon

---Create a reusable timeline icon frame.
---@param self TimelineSkins self
---@return Frame frame timeline icon frame
local function CreateTimelineIcon(self)
    local frame = CreateFrame("Frame", nil, UIParent)

    frame.cooldown = CreateFrame("Cooldown", nil, frame, "CooldownFrameTemplate")
    frame.cooldown:SetAllPoints()
    frame.cooldown:SetDrawSwipe(false)
    frame.cooldown:SetDrawEdge(false)
    frame.cooldown:SetReverse(true)

    frame.icon = frame:CreateTexture(nil, "ARTWORK")
    frame.icon:SetAllPoints()
    
    frame.textFrame = CreateFrame("Frame", nil, frame)
    frame.textFrame:SetAllPoints()
    frame.text = frame.textFrame:CreateFontString(nil, "OVERLAY")

    UpdateIconStyle(self, frame)

    frame.border = CreateFrame("Frame", nil, frame, "BackdropTemplate")
    frame.border:SetAllPoints()
    frame.border:SetBackdrop({edgeFile = "Interface\\Buttons\\WHITE8x8", edgeSize = 1, insets = {left = 1, right = 1, top = 1, bottom = 1}})
    frame.border:SetBackdropBorderColor(0, 0, 0, 1)

    frame.active = false
    frame.timer = nil

    return frame
end

-- MARK: Queue Helpers

---Insert an icon at the end of the queue list.
---@param self TimelineSkins self
---@param frame Frame icon frame to queue
local function QueueInsert(self, frame)
    if not self.queueTail then -- if the queue is empty, insert after the head
        frame:ClearAllPoints()
        frame:SetPoint(self.anchorFrom, self.queueHead, self.anchorFrom, 0, 0)
        frame.prev = self.queueHead
    else -- insert after the tail 
        frame:ClearAllPoints()
        frame:SetPoint(self.anchorFrom, self.queueTail, self.anchorTo, 0, 0)
        frame.prev = self.queueTail
        frame.prev.next = frame
    end
    self.queueTail = frame
end

---Remove an icon from the queue list.
---@param self TimelineSkins self
---@param frame Frame icon frame to remove
local function QueueRemove(self, frame)
    if frame.prev == self.queueHead then
        if frame.next then
            frame.next:ClearAllPoints()
            frame.next:SetPoint(self.anchorFrom, self.queueHead, self.anchorFrom, 0, 0)
            frame.next.prev = self.queueHead
        else
            self.queueTail = nil
        end
    elseif frame.prev then
        if frame.next then
            frame.next:ClearAllPoints()
            frame.next:SetPoint(self.anchorFrom, frame.prev, self.anchorTo, 0, 0)
            frame.next.prev = frame.prev
            frame.prev.next = frame.next
        else
            frame.prev.next = nil
            self.queueTail = frame.prev
        end
    end
    frame.prev = nil
    frame.next = nil
end

-- MARK: DeactivateIcon

---Deactivate an icon and recycle it back to spare pool.
---@param self TimelineSkins self
---@param frame Frame icon frame to deactivate
local function DeactivateIcon(self, frame)
    if frame.timer then
        frame.timer:Cancel()
        frame.timer = nil
    end
    frame:Hide()
    frame.active = false
    frame.cooldown:SetCooldownDuration(0)
    frame.icon:SetTexture(UNKNOWN_SPELL_TEXTURE)
    frame.text:SetText("")
    frame:SetScript("OnUpdate", nil) -- clear OnUpdate script to stop updating position

    QueueRemove(self, frame)

    self.activeIcons[frame.eventID] = nil
    self.queueIcons[frame.eventID] = nil
    table.insert(self.spareIcons, frame)

    self:UpdateFrameVisibility()
end

-- MARK: MoveToQueue

---Move an active icon back to queue state.
---@param self TimelineSkins self
---@param frame Frame icon frame to move
local function MoveToQueue(self, frame)
    frame.active = false
    frame:SetScript("OnUpdate", nil)

    QueueInsert(self, frame)

    -- set up timer for activation
    local remaining = C_EncounterTimeline.GetEventTimeRemaining(frame.eventID)
    if frame.timer then
        frame.timer:Cancel()
        frame.timer = C_Timer.NewTimer(math.max(remaining - TIMELINE_LENGTH_SECONDS, 0), function()
            self:ActivateIcon(frame)
        end)
    end
    self.activeIcons[frame.eventID] = nil
    self.queueIcons[frame.eventID] = frame
end

-- MARK: ON_UPDATE

---Update icon position each frame while active.
---@param self TimelineSkins self
---@param frame Frame active icon frame
local function OnUpdateIcon(self, frame)
    if frame.active then
        local remaining = C_EncounterTimeline.GetEventTimeRemaining(frame.eventID)
        if remaining <= 0 then
            DeactivateIcon(self, frame)
        elseif remaining >= TIMELINE_LENGTH_SECONDS then
            MoveToQueue(self, frame)
        else
            local position = math.min(remaining, TIMELINE_LENGTH_SECONDS) / TIMELINE_LENGTH_SECONDS * addon.db[self.modName]["Length"]
            frame:ClearAllPoints()
            if addon.db[self.modName]["isVertical"] then
                if self.anchorFrom == "BOTTOM" then -- UP
                    frame:SetPoint(self.anchorFrom, self.frame, self.anchorFrom, 0, position)
                else -- DOWN
                    frame:SetPoint(self.anchorFrom, self.frame, self.anchorFrom, 0, -position)
                end
            else
                if self.anchorFrom == "LEFT" then -- RIGHT
                    frame:SetPoint(self.anchorFrom, self.frame, self.anchorFrom, position, 0)
                else -- LEFT
                    frame:SetPoint(self.anchorFrom, self.frame, self.anchorFrom, -position, 0)
                end
            end
        end
    end
end

-- MARK: ActivateIcon

---Activate a queued icon and start position updates.
---@param frame Frame icon frame to activate
function TimelineSkins:ActivateIcon(frame)
    frame:Show()
    frame.active = true

    QueueRemove(self, frame)
    frame:ClearAllPoints()

    -- move from queue to active
    self.queueIcons[frame.eventID] = nil
    self.activeIcons[frame.eventID] = frame

    frame:SetScript("OnUpdate", function()
        OnUpdateIcon(self, frame)
    end)
end

-- MARK: Load Event
---Create or reuse an icon for a timeline event and queue it.
---@param self TimelineSkins self
---@param eventInfo table encounter timeline event payload
local function LoadEvent(self, eventInfo)
    -- Blizzard left many always paused events
    -- never load them, as they are always paused and will always be cancelled
    local state = C_EncounterTimeline.GetEventState(eventInfo.id)
    if state == Enum.EncounterTimelineEventState.Paused then
        return
    end

    local frame
    if self.spareIcons[#self.spareIcons] then
        frame = table.remove(self.spareIcons, #self.spareIcons)
    else
        frame = CreateTimelineIcon(self)
    end

    local text = eventInfo.spellName or ""
    frame.eventID = eventInfo.id
    local remaining = C_EncounterTimeline.GetEventTimeRemaining(frame.eventID)
    frame.cooldown:SetCooldownDuration(remaining)
    frame.icon:SetTexture(eventInfo.iconFileID or C_Spell.GetSpellInfo(eventInfo.spellID).iconID or UNKNOWN_SPELL_TEXTURE)
    frame.text:SetText(text)

    QueueInsert(self, frame)
    self.queueIcons[frame.eventID] = frame

    frame.timer = C_Timer.NewTimer(math.max(remaining - TIMELINE_LENGTH_SECONDS, 0), function()
        self:ActivateIcon(frame)
    end)

    self:UpdateFrameVisibility()
    if addon.db[self.modName]["ShowQueuedIcons"] then
        frame:Show()
    else
        frame:Hide()
    end
end

-- MARK: ON_EVENT

---Handle newly added encounter timeline event.
---@param self TimelineSkins self
---@param eventInfo table encounter timeline event payload
local function ON_ENCOUNTER_TIMELINE_EVENT_ADDED(self, eventInfo)
    LoadEvent(self, eventInfo)
end

---Handle removed encounter timeline event.
---@param self TimelineSkins self
---@param eventID number encounter timeline event id
local function ON_ENCOUNTER_TIMELINE_EVENT_REMOVED(self, eventID)
    local frame = self.activeIcons[eventID] or self.queueIcons[eventID]
    if frame then
        DeactivateIcon(self, frame)
    end
end

---Handle encounter timeline event state updates.
---@param self TimelineSkins self
---@param eventID number encounter timeline event id
local function ON_ENCOUNTER_TIMELINE_EVENT_STATE_CHANGED(self, eventID)
    local frame = self.activeIcons[eventID] or self.queueIcons[eventID]
    local state = C_EncounterTimeline.GetEventState(eventID)

    if frame then
        if state == Enum.EncounterTimelineEventState.Finished or state == Enum.EncounterTimelineEventState.Canceled then
            DeactivateIcon(self, frame)
        elseif state == Enum.EncounterTimelineEventState.Paused or C_EncounterTimeline.IsEventBlocked(eventID) then -- paused or blocked
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
                frame.timer = C_Timer.NewTimer(math.max(C_EncounterTimeline.GetEventTimeRemaining(eventID) - TIMELINE_LENGTH_SECONDS, 0), function()
                    self:ActivateIcon(frame)
                end)
            end
        end
    end
end

-- MARK: Update Tick Style

---Update tick marker size, position, and alpha.
---@param self TimelineSkins self
local function UpdateTickStyle(self)
    -- tick
    self.tickLine:SetColorTexture(1, 1, 1, addon.db[self.modName]["TickAlpha"] or 0.5)
    if addon.db[self.modName]["isVertical"] then
        self.tickLine:SetSize(addon.db[self.modName]["IconSize"], 2)
        self.tickLine:ClearAllPoints()
        if self.anchorFrom == "BOTTOM" then -- UP
            self.tickLine:SetPoint(self.anchorFrom, self.frame, self.anchorFrom, 0, addon.db[self.modName]["Length"] * TICK_POSITION)
        else -- DOWN
            self.tickLine:SetPoint(self.anchorFrom, self.frame, self.anchorFrom, 0, -addon.db[self.modName]["Length"] * TICK_POSITION)
        end
    else
        self.tickLine:SetSize(2, addon.db[self.modName]["IconSize"])
        self.tickLine:ClearAllPoints()
        if self.anchorFrom == "LEFT" then -- RIGHT
            self.tickLine:SetPoint(self.anchorFrom, self.frame, self.anchorFrom, addon.db[self.modName]["Length"] * TICK_POSITION, 0)
        else -- LEFT
            self.tickLine:SetPoint(self.anchorFrom, self.frame, self.anchorFrom, -addon.db[self.modName]["Length"] * TICK_POSITION, 0)
        end
    end
end

-- MARK: Update Queue Style

---Update queue head anchor according to growth direction and icon size.
---@param self TimelineSkins self
local function UpdateQueueStyle(self)
    self.queueHead:ClearAllPoints()
    if addon.db[self.modName]["isVertical"] then
        if self.anchorFrom == "BOTTOM" then -- UP
            self.queueHead:SetPoint(self.anchorFrom, self.frame, self.anchorTo, 0, addon.db[self.modName]["IconSize"])
        else -- DOWN
            self.queueHead:SetPoint(self.anchorFrom, self.frame, self.anchorTo, 0, -addon.db[self.modName]["IconSize"])
        end
    else
        if self.anchorFrom == "LEFT" then -- RIGHT
            self.queueHead:SetPoint(self.anchorFrom, self.frame, self.anchorTo, addon.db[self.modName]["IconSize"], 0)
        else -- LEFT
            self.queueHead:SetPoint(self.anchorFrom, self.frame, self.anchorTo, -addon.db[self.modName]["IconSize"], 0)
        end
    end
    self.queueHead:SetSize(addon.db[self.modName]["IconSize"], addon.db[self.modName]["IconSize"])
end

-- MARK: UpdateStyle

---Update style settings and render them in-game for CustomTracker
---@param self TimelineSkins self
function TimelineSkins:UpdateStyle()
    self.anchorFrom, self.anchorTo = addon.Utilities:GetGrowAnchors(addon.db[self.modName]["Grow"])
    self.textAnchorFrom, self.textAnchorTo = addon.Utilities:GetGrowAnchors(addon.db[self.modName]["TextGrow"])

    self.frame:SetFrameStrata(addon.db[self.modName]["FrameStrata"] or "BACKGROUND")

    self.frame:ClearAllPoints()
    self.frame:SetPoint(self.anchorFrom, UIParent, "CENTER", addon.db[self.modName]["X"], addon.db[self.modName]["Y"])
    if addon.db[self.modName]["isVertical"] then
        self.frame:SetSize(addon.db[self.modName]["IconSize"], addon.db[self.modName]["Length"])
    else
        self.frame:SetSize(addon.db[self.modName]["Length"], addon.db[self.modName]["IconSize"])
    end

    UpdateQueueStyle(self)
    UpdateTickStyle(self)

    self.frame.background:SetColorTexture(0, 0, 0, addon.db[self.modName]["BackgroundAlpha"] or 0.5)

    for _, frame in pairs(self.spareIcons) do
        UpdateIconStyle(self, frame)
    end
    for _, frame in pairs(self.activeIcons) do
        UpdateIconStyle(self, frame)
    end
    for _, frame in pairs(self.queueIcons) do
        UpdateIconStyle(self, frame)
    end
end

-- MARK: Test

---Test Mode
---@param on boolean turn the Test mode on or off
function TimelineSkins:Test(on)
    if not addon.db[self.modName]["Enabled"] then -- if the module is not enabled, do not allow test mode
        return
    end

    if on then
        self.frame:Show()
        addon.Utilities:MakeFrameDragPosition(self.frame, self.modName, "X", "Y")
        C_EncounterTimeline.AddEditModeEvents()
    else
        self:UpdateFrameVisibility()
        C_EncounterTimeline.CancelEditModeEvents()
    end
end

-- MARK: RegisterEvents

---Register events
---@param self TimelineSkins self
function TimelineSkins:RegisterEvents()
    addon.core:RegisterEvent("ENCOUNTER_TIMELINE_EVENT_ADDED", self.frame, self.modName)
    addon.core:RegisterEvent("ENCOUNTER_TIMELINE_EVENT_REMOVED", self.frame, self.modName)
    addon.core:RegisterEvent("ENCOUNTER_TIMELINE_EVENT_STATE_CHANGED", self.frame, self.modName)

    self.frame:SetScript("OnEvent", function(_, event, ...)
        if event == "ENCOUNTER_TIMELINE_EVENT_ADDED" then
            local eventInfo = select(1, ...)
            ON_ENCOUNTER_TIMELINE_EVENT_ADDED(self, eventInfo)
        elseif event == "ENCOUNTER_TIMELINE_EVENT_REMOVED" then
            local eventID = select(1, ...)
            ON_ENCOUNTER_TIMELINE_EVENT_REMOVED(self, eventID)
        elseif event == "ENCOUNTER_TIMELINE_EVENT_STATE_CHANGED" then
            local eventID = select(1, ...)
            ON_ENCOUNTER_TIMELINE_EVENT_STATE_CHANGED(self, eventID)
        end
    end)
end

-- MARK: Register Module
addon.core:RegisterModule(TimelineSkins.modName, function() return TimelineSkins:Initialize() end)