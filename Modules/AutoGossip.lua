local ADDON_NAME, addon = ...
local L = LibStub("AceLocale-3.0"):GetLocale(ADDON_NAME)

---@class AutoGossip
local AutoGossip = {
    modName = "AutoGossip",
}

-- MARK: Constants

-- MARK: Initialize

---Initialize (Constructor)
---@return AutoGossip AutoGossip a AutoGossip object
function AutoGossip:Initialize()
    -- TODO: Initialize your module here

    return self
end

-- MARK: UpdateStyle

---Update style settings and render them in-game for CustomTracker
function AutoGossip:UpdateStyle()
    -- TODO: Update style settings and render them in-game when the user changes custom options
end

-- MARK: Test

---Test Mode
---@param on boolean turn the Test mode on or off
function AutoGossip:Test(on)
    if not addon.db[self.modName]["Enabled"] then -- if the module is not enabled, do not allow test mode
        return
    end

    if on then
        -- TODO: Implement test mode for your module
    else
        -- TODO: Disable test mode for your module
    end
end

-- MARK: RegisterEvents

---Register events
function AutoGossip:RegisterEvents()
    -- TODO: Register events needed by your module here, for example:
    -- local handle = function() Handler(self) end
    -- addon.core:RegisterEvent("EVENT_NAME", handle)
end

-- MARK: Register Module
addon.core:RegisterModule(AutoGossip.modName, function() return AutoGossip:Initialize() end)