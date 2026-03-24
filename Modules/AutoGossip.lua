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
    self.eventFrame = CreateFrame("Frame", ADDON_NAME .. self.modName, UIParent)

    return self
end

-- MARK: RegisterEvents

---Register events
function AutoGossip:RegisterEvents()
    addon.core:RegisterEvent("GOSSIP_SHOW", self.eventFrame, self.modName)

    self.eventFrame:SetScript("OnEvent", function(_, event, ...)
        if event == "GOSSIP_SHOW" then
            local infos = C_GossipInfo.GetOptions()
            for _, info in ipairs(infos) do
                local gossipID = info.gossipOptionID or 0

                if addon.data.INSTANCE_GOSSIP[addon.states["instanceInfo"].instanceID or 0] then
                    if addon.data.INSTANCE_GOSSIP[addon.states["instanceInfo"].instanceID][gossipID] then
                        C_GossipInfo.SelectOption(gossipID)
                    end
                end
            end
        end
    end)
end

-- MARK: Register Module
addon.core:RegisterModule(AutoGossip.modName, function() return AutoGossip:Initialize() end)