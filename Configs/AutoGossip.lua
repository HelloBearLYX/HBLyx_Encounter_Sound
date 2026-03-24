local ADDON_NAME, addon = ...
local L = LibStub("AceLocale-3.0"):GetLocale(ADDON_NAME)
local GUI = addon.GUI
local MOD_KEY = "AutoGossip"

-- MARK: Defaults
addon.configurationList[MOD_KEY] = {
	Enabled = true,
}