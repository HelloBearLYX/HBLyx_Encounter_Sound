local ADDON_NAME, addon = ...
local L = LibStub("AceLocale-3.0"):GetLocale(ADDON_NAME)
local GUI = addon.GUI

---@class HB_GUI
---@field frame Frame? the movable root frame which holds every part of the configuration UI
---@field tabGroup table? the sidebar and content area which show the selected tab's panel
---@field isOpened boolean is the GUI opened
addon.GUI = {
    frame = nil,
    tabGroup = nil,
    isOpened = false,
}
GUI = addon.GUI

-- MARK: Default values
local PANEL_WIDTH = 855
local PANEL_HEIGHT = 600
local SIDEBAR_WIDTH = 155
local TOOLBAR_HEIGHT = 20
local TOOLBAR_BUTTON_WIDTH = 155
-- the toolbar window and the close button share this height, so they line up
local TOOLBAR_FRAME_HEIGHT = TOOLBAR_HEIGHT + 10
local CLOSE_BUTTON_SIZE = TOOLBAR_FRAME_HEIGHT
local HIGHLIGHT_TEXT_COLOR = "|c" .. addon.Utilities:RGBToHex(unpack(addon.UICore:GetHighlightColor()))
local CLOSE_BUTTON_TEXTURE = "Interface\\AddOns\\" .. ADDON_NAME .. "\\GUI\\Assets\\Close_Button.png"
local TITLE_ICON = "|TInterface\\AddOns\\" .. ADDON_NAME .. "\\Media\\HBLyx.png:0|t "

-- MARK: General Panel

local LINKS = {
    { text = "|TInterface\\AddOns\\" .. ADDON_NAME .. "\\Media\\Curseforge.png:0|t CurseForge", url = "https://www.curseforge.com/wow/addons/hblyx-encounter-sound" },
    { text = "新手盒子", url = "https://www.wclbox.com/games/1/PluginItem/17821?version=2" },
}

local CONTACTS = {
    { text = "|TInterface\\AddOns\\" .. ADDON_NAME .. "\\Media\\Discord.png:0|t Discord", url = "https://discord.gg/EVFmd6uVYg" },
    { text = "|TInterface\\AddOns\\" .. ADDON_NAME .. "\\Media\\GitHub.png:0|t " .. L["GitHub"], url = "https://github.com/HelloBearLYX/HBLyx_Encounter_Sound/issues" },
    { text = "|TInterface\\AddOns\\" .. ADDON_NAME .. "\\Media\\Curseforge.png:0|t " .. L["CurseForge"], url = "https://www.curseforge.com/wow/addons/hblyx-encounter-sound/comments" },
}

---Create a labelled, read-only edit box so the URL can be selected and copied
local function CreateLink(container, info)
    return GUI:CreateEditBox(container, info.text, info.url, function() end)
end

local function CreateGeneralPanel(container)
    local panel = GUI:CreateScrollFrame(container)

    GUI:CreateInformationTag(panel, L["WelecomeInfo"], "CENTER")

    local releaseGroup = GUI:CreateInlineGroup(panel, L["Downloads/Update"])
    GUI:CreateInformationTag(releaseGroup, L["Release_Info"], "LEFT")
    for _, info in ipairs(LINKS) do
        CreateLink(releaseGroup, info)
    end

    local notificationsGroup = GUI:CreateInlineGroup(panel, L["Notifications"])
    GUI:CreateInformationTag(notificationsGroup, L["NotificationContent"], "LEFT")

    local changeLogGroup = GUI:CreateInlineGroup(panel, L["ChangeLog"])
    GUI:CreateInformationTag(changeLogGroup, L["ChangeLogContent"], "LEFT")
    GUI:CreateEditBox(changeLogGroup, "", L["ChangeLogLink"], function() end)

    local contactGroup = GUI:CreateInlineGroup(panel, L["Contact"])
    for _, info in ipairs(CONTACTS) do
        CreateLink(contactGroup, info)
    end

    return panel
end

-- MARK: Contributors Panel

local CONTRIBUTORS = {
    { text = "RUI", url = "https://space.bilibili.com/26688835", contributionKeys = { "data correction", "testing", "feedbacks", "configuration sharing" } },
    { text = "XR行而", url = "https://space.bilibili.com/28719367", contributionKeys = { "configuration sharing", "feedbacks" } },
}

local function CreateContributorPanel(container)
    local panel = GUI:CreateScrollFrame(container)

    local contributorsGroup = GUI:CreateInlineGroup(panel, L["ThanksTo"])
    for _, info in ipairs(CONTRIBUTORS) do
        local contributions = {}
        for _, key in ipairs(info.contributionKeys) do
            table.insert(contributions, L[key])
        end
        CreateLink(contributorsGroup, { text = string.format("|cff0070DD%s|r - %s", info.text, table.concat(contributions, ", ")), url = info.url })
    end
    GUI:CreateInformationTag(contributorsGroup, L["AnonymousContributors"], "LEFT")
    GUI:CreateInformationTag(panel, L["ContributeData"], "LEFT")

    local contactGroup = GUI:CreateInlineGroup(panel, L["Contact"])
    for _, info in ipairs(CONTACTS) do
        CreateLink(contactGroup, info)
    end

    return panel
end

-- MARK: TABS
local TABS = {
    {text = L["Universal"], type = "Text"},
    {text = L["General"], type = "Button", panelFunction = function(container) return CreateGeneralPanel(container) end},
    {text = L["UniversalSettings"], type = "Button", panelFunction = function(container) return addon.GUI.TagPanels.EncounterSound:CreateGeneralPanel(container) end},
    {text = L["LuraHelperSettings"], type = "Button", tooltip = L["LuraHelperSettingsDesc"], panelFunction = function(container) return addon.GUI.TagPanels.LuraHelper:CreateTabPanel(container) end},
    {text = L["GossipHelperSettings"], type = "Button", tooltip = L["GossipHelperSettingsDesc"], panelFunction = function(container) return addon.GUI.TagPanels.GossipHelper:CreateTabPanel(container) end},
    {text = L["EncounterSoundEffects"], type = "Text"},
    {text = L["Raid"], type = "Button", panelFunction = function(container) return addon.GUI.TagPanels.EncounterSound:CreateTabPanel(container, true) end},
    {text = L["Dungeon"], type = "Button", panelFunction = function(container) return addon.GUI.TagPanels.EncounterSound:CreateTabPanel(container, false) end},
    {text = L["Skins"], type = "Text"},
    {text = L["HighlightIconsSettings"], type = "Button", tooltip = L["HighlightIconsSettingsDesc"], panelFunction = function(container) return addon.GUI.TagPanels.HighlightIcons:CreateTabPanel(container) end},
    {text = L["PrivateAuraAnchorSettings"], type = "Button", tooltip = L["PrivateAuraAnchorSettingsDesc"], panelFunction = function(container) return addon.GUI.TagPanels.PrivateAuraAnchor:CreateTabPanel(container) end},
    {text = L["TimelineSkinsSettings"], type = "Button", tooltip = L["TimelineSkinsSettingsDesc"], panelFunction = function(container) return addon.GUI.TagPanels.TimelineSkins:CreateTabPanel(container) end},
    {text = L["TextWarningSkinsSettings"], type = "Button", tooltip = L["TextWarningSkinsSettingsDesc"], panelFunction = function(container) return addon.GUI.TagPanels.TextWarningSkins:CreateTabPanel(container) end},
    {text = L["Countdown"], type = "Button", tooltip = L["CountdownDesc"], panelFunction = function(container) return addon.GUI.TagPanels.Countdown:CreateTabPanel(container) end},
    {text = L["Others"], type = "Text"},
    {text = L["Profile"], type = "Button", panelFunction = function(container) return addon.GUI.TagPanels.Profile:CreateTabPanel(container) end},
    {text = L["Contributors"], type = "Button", panelFunction = function(container) return CreateContributorPanel(container) end},
}

-- MARK: Initialize GUI

---The root frame carries the drag, every other frame is anchored inside of it
local function CreateRootFrame()
    local root = CreateFrame("Frame", "HBLyxEncounterSoundConfigFrame", UIParent)
    root:SetSize(SIDEBAR_WIDTH + PANEL_WIDTH, TOOLBAR_FRAME_HEIGHT + PANEL_HEIGHT)
    root:SetPoint("CENTER")
    root:SetFrameStrata("HIGH")
    root:SetMovable(true)
    root:EnableMouse(true)
    root:RegisterForDrag("LeftButton")
    root:SetScript("OnDragStart", root.StartMoving)
    root:SetScript("OnDragStop", root.StopMovingOrSizing)
    root:SetClampedToScreen(true)
    root:Hide()

    return root
end

---A mouse enabled child swallows the drag, so it has to move the root itself
local function AddDragHandle(frame, root)
    frame:EnableMouse(true)
    frame:RegisterForDrag("LeftButton")
    frame:SetScript("OnDragStart", function() root:StartMoving() end)
    frame:SetScript("OnDragStop", function() root:StopMovingOrSizing() end)
end

---Fill the toolbar window with the settings which are not owned by a module
local function RenderToolbar(toolbar)
    local testButton = addon.UICore:Build("TextButton")
    testButton:SetSize(TOOLBAR_BUTTON_WIDTH, TOOLBAR_HEIGHT)
    testButton:SetText(L["Test"])
    testButton:SetOnClick(function() addon.core:TestMode() end)
    toolbar:AddWidget(testButton)

    local minimapToggle = addon.UICore:Build("ToggleBox")
    minimapToggle:SetSize(TOOLBAR_BUTTON_WIDTH, TOOLBAR_HEIGHT)
    minimapToggle:SetText(L["HideMinimapIcon"])
    minimapToggle:SetValue(addon.db.MinimapIcon.hide)
    minimapToggle:SetOnClick(function(_, value)
        addon.db.MinimapIcon.hide = value
        if value then
            LibStub("LibDBIcon-1.0"):Hide(ADDON_NAME)
        else
            LibStub("LibDBIcon-1.0"):Show(ADDON_NAME)
        end
    end)
    toolbar:AddWidget(minimapToggle)
end

---Build the main frame, the sidebar and the content area once
local function BuildGUI(self)
    local root = CreateRootFrame()
    self.frame = root

    -- the toolbar sits above the main frame, like the tab window sits next to it
    local toolbar = addon.UICore:Build("Window")
    toolbar:SetParent(root)
    toolbar:SetSize(PANEL_WIDTH, TOOLBAR_FRAME_HEIGHT)
    toolbar:SetPoint("TOPRIGHT", root, "TOPRIGHT", 0, 0)
    toolbar:SetRenderer(RenderToolbar)
    toolbar:Rerender()
    toolbar:Show()
    AddDragHandle(toolbar.frame, root)
    self.toolbar = toolbar

    -- anchored above the toolbar instead of laid out as a row widget, so it never competes for row space
    local title = toolbar.frame:CreateFontString(nil, "OVERLAY")
    title:SetFont(addon.UICore:GetDefaultFont(), 24, "OUTLINE")
    title:SetTextColor(1, 1, 1, 1)
    title:SetText(string.format(L["GUITitle"], HIGHLIGHT_TEXT_COLOR, addon:GetVersion()))
    title:SetPoint("BOTTOM", toolbar.frame, "TOP", 0, 0)
    self.title = title

    local close = CreateFrame("Button", nil, toolbar.frame, "BackdropTemplate")
    close:SetBackdrop({
        bgFile = "Interface\\Buttons\\WHITE8x8",
        edgeFile = "Interface\\Buttons\\WHITE8x8",
        tile = false, tileSize = 1, edgeSize = 1,
        insets = { left = 1, right = 1, top = 1, bottom = 1 }
    })
    addon.UICore:SetBackdropColor(close)
    addon.UICore:SetBorderColor(close)
    close:SetSize(CLOSE_BUTTON_SIZE, CLOSE_BUTTON_SIZE)
    close:SetPoint("TOPRIGHT", toolbar.frame, "TOPRIGHT", 0, 0)
    close:SetNormalTexture(CLOSE_BUTTON_TEXTURE)
    close:SetPushedTexture(CLOSE_BUTTON_TEXTURE)
    close:SetHighlightTexture(CLOSE_BUTTON_TEXTURE)
    close:GetHighlightTexture():SetAlpha(0.75)
    close:SetScript("OnClick", function() addon.GUI:CloseGUI() end)
    addon.UICore:BuildHover(close)
    self.closeButton = close

    -- the sidebar spans the full height, the content area sits below the toolbar
    local tabGroup = addon.UICore:Build("VerticalTabGroup")
    tabGroup:SetParent(root)
    tabGroup:SetSidebarWidth(SIDEBAR_WIDTH)
    tabGroup:SetContentTopInset(TOOLBAR_FRAME_HEIGHT)
    tabGroup:SetSize(SIDEBAR_WIDTH + PANEL_WIDTH, PANEL_HEIGHT + TOOLBAR_FRAME_HEIGHT)
    tabGroup:SetPoint("TOPLEFT", root, "TOPLEFT", 0, 0)
    tabGroup:SetTabs(TABS)
    tabGroup:Show()
    AddDragHandle(tabGroup.sidebar.frame, root)
    self.tabGroup = tabGroup
end

---Initialize/Constructor for GUI
function addon.GUI:Render()
    if self.isOpened or addon.states["inCombat"] then
        if addon.states["inCombat"] then
            addon.Utilities:print(L["CombatLock"])
        end

        return
    end

    if not self.frame then
        BuildGUI(self)
    end

    self.isOpened = true
    self.frame:Show()
end

-- MARK: Open/Close GUI

---Open GUI
function addon.GUI:OpenGUI()
    addon.GUI:Render()
end

---Close GUI
function addon.GUI:CloseGUI()
    if not self.frame then return end

    self.isOpened = false
    self.frame:Hide()
    addon.core:TestMode(false) -- turn off test mode when closing GUI
end

-- MARK: Widget factories
-- every factory adds the widget to the container when one is given, and returns the widget,
-- so the config panels can keep a reference and disable, resize or re-fill it later

local function Attach(container, widget)
    if container then
        container:AddWidget(widget)
    end
    return widget
end

---The config panels are laid out by the container itself, so a group is only a title
---@param parent table the container
---@param title string title
---@return table container the very same container
function addon.GUI:CreateInlineGroup(parent, title)
    if parent and title and title ~= "" then
        parent:NewRow()
        self:CreateHeader(parent, title)
    end

    return parent
end

---@param parent table the container
function addon.GUI:CreateLinebreaker(parent)
    if parent then parent:NewRow() end
end

---@param parent table the container
---@param mod string the module key, passed to ResetModule and the reload prompt
---@param modLocale string the localized module title shown in the confirmation dialog
---@return table widget
function addon.GUI:CreateResetModButton(parent, mod, modLocale)
    return self:CreateButton(parent, L["ResetMod"], function()
        addon.Utilities:SetPopupDialog(
            ADDON_NAME .. "ResetMod",
            "|cffC41E3A" .. modLocale .. "|r: " .. L["ComfirmResetMod"],
            true,
            {button1 = YES, button2 = NO, OnButton1 = function()
                addon.Utilities:ResetModule(mod)
                ReloadUI()
            end}
        )
    end)
end

---@param parent table the container
---@return table? widget
function addon.GUI:CreateSeperator(parent)
    if not parent then return end

    local line = addon.UICore:Build("LineSeperator")
    line:SetFullWidth(true)

    parent:AddWidget(line)
    parent:NewRow()

    return line
end

---@param parent table the container
---@return table container the container itself, the panels are already scrollable
function addon.GUI:CreateScrollFrame(parent)
    return parent
end

---@param parent table the container
---@param title string title
---@return table widget
function addon.GUI:CreateHeader(parent, title)
    -- a header always opens a new section, so it carries the separator
    self:CreateSeperator(parent)

    local header = addon.UICore:Build("TextRegion")
    header:SetFontSize(14)
    header:SetText(HIGHLIGHT_TEXT_COLOR .. (title or "") .. "|r")
    header:SetFullWidth(true)

    Attach(parent, header)
    if parent then parent:NewRow() end

    return header
end

---@param parent table the container
---@param description string the description to display
---@param textJustification string? "LEFT", "CENTER" or "RIGHT"
---@return table widget
function addon.GUI:CreateInformationTag(parent, description, textJustification)
    local text = addon.UICore:Build("TextRegion")
    text:SetText(description or "")
    text:SetJustifyH(textJustification or "CENTER")
    text:SetFullWidth(true)

    Attach(parent, text)
    if parent then parent:NewRow() end

    return text
end

---@param parent table the container
---@param label string label
---@param get boolean the value to set
---@param callback fun(newValue: boolean) called when the value changed
---@return table widget
function addon.GUI:CreateToggleCheckBox(parent, label, get, callback)
    local toggle = addon.UICore:Build("ToggleBox")
    toggle:SetText(label or "")
    toggle:SetValue(get)
    toggle:SetOnClick(function(_, value)
        if callback then callback(value) end
    end)

    return Attach(parent, toggle)
end

---@param parent table the container
---@param label string label
---@param callback fun() called when the button is clicked
---@return table widget
function addon.GUI:CreateButton(parent, label, callback)
    local button = addon.UICore:Build("TextButton")
    button:SetText(label or "")
    button:SetOnClick(function()
        if callback then callback() end
    end)

    return Attach(parent, button)
end

---@param parent table the container
---@param label string label
---@param min number minimum of the slider
---@param max number maximum of the slider
---@param step number step size of the slider
---@param get number the value to set
---@param callback fun(newValue: number) called when the value changed
---@return table widget
function addon.GUI:CreateSlider(parent, label, min, max, step, get, callback)
    local slider = addon.UICore:Build("Slider")
    slider:SetLabel(label or "")
    slider:SetMinMaxValues(min, max, step)
    slider:SetValue(get)
    slider:SetOnValueChanged(function(_, value)
        if callback then callback(value) end
    end)

    return Attach(parent, slider)
end

---@param parent table the container
---@param label string label
---@param get string the value to set
---@param callback fun(newValue: string) called when the text is committed
---@return table widget
function addon.GUI:CreateEditBox(parent, label, get, callback)
    local editBox = addon.UICore:Build("EditBox")
    editBox:SetLabel(label or "")
    editBox:SetText(get or "")
    editBox:SetOnEnterPressed(function(_, text)
        if callback then callback(text) end
    end)

    return Attach(parent, editBox)
end

---@param parent table the container
---@param label string label
---@param get string the value to set
---@param callback fun(newValue: string) called when the text is committed
---@return table widget
function addon.GUI:CreateMultiLineEditBox(parent, label, get, callback)
    local editBox = addon.UICore:Build("MultiLineEditBox")
    editBox:SetLabel(label or "")
    editBox:SetText(get or "")
    editBox:SetFullWidth(true)
    editBox:SetOnEnterPressed(function(_, text)
        if callback then callback(text) end
    end)

    Attach(parent, editBox)
    if parent then parent:NewRow() end

    return editBox
end

---@param parent table the container
---@param label string label
---@param list table the value to display map
---@param order table? optional display order
---@param get any the value to set
---@param callback fun(key: any) called when the value changed
---@return table widget
function addon.GUI:CreateDropdown(parent, label, list, order, get, callback)
    local dropdown = addon.UICore:Build("Dropdown")
    dropdown:SetLabel(label or "")
    dropdown:SetList(list or {}, order)
    dropdown:SetValue(get)
    dropdown:SetOnValueChanged(function(_, key)
        if callback then callback(key) end
    end)

    return Attach(parent, dropdown)
end

---@param parent table the container
---@param label string label
---@param hasAlpha boolean whether the alpha channel can be edited
---@param get string the hex color to set
---@param callback fun(hexColor: string) called with the new hex color
---@return table widget
function addon.GUI:CreateColorPicker(parent, label, hasAlpha, get, callback)
    local colorPicker = addon.UICore:Build("ColorPicker")
    colorPicker:SetLabel(label or "")
    colorPicker:SetHasAlpha(hasAlpha)
    colorPicker:SetHexColor(get)
    colorPicker:SetOnColorChanged(function(widget)
        if callback then callback(widget:GetHexColor()) end
    end)

    return Attach(parent, colorPicker)
end

---@param parent table the container
---@param label string label
---@param get string the value to set
---@param callback fun(key: string) called when the value changed
---@return table widget
function addon.GUI:CreateFontSelect(parent, label, get, callback)
    local fontSelect = addon.UICore:Build("FontDropdown")
    fontSelect:SetLabel(label or "")
    fontSelect:SetValue(get)
    fontSelect:SetOnValueChanged(function(_, key)
        if callback then callback(key) end
    end)

    return Attach(parent, fontSelect)
end

---@param parent table the container
---@param label string label
---@param get string the value to set
---@param callback fun(key: string) called when the value changed
---@return table widget
function addon.GUI:CreateTextureSelect(parent, label, get, callback)
    local textureSelect = addon.UICore:Build("TextureDropdown")
    textureSelect:SetLabel(label or "")
    textureSelect:SetValue(get)
    textureSelect:SetOnValueChanged(function(_, key)
        if callback then callback(key) end
    end)

    return Attach(parent, textureSelect)
end

---@param parent table the container
---@param label string label
---@param get string the value to set
---@param callback fun(key: string) called when the value changed
---@return table widget
function addon.GUI:CreateSoundSelect(parent, label, get, callback)
    local soundSelect = addon.UICore:Build("SoundDropdown")
    soundSelect:SetLabel(label or "")
    soundSelect:SetValue(get)
    soundSelect:SetOnValueChanged(function(_, key)
        if callback then callback(key) end
    end)

    return Attach(parent, soundSelect)
end

---@param parent table the container
---@param get string the value to set
---@param callback fun(strata: string) called with the frame strata
---@return table widget
function addon.GUI:CreateFrameStrataDropdown(parent, get, callback)
    local order = {"BACKGROUND", "LOW", "MEDIUM", "HIGH", "DIALOG", "FULLSCREEN", "FULLSCREEN_DIALOG"}
    return addon.GUI:CreateDropdown(parent, L["FrameStrata"], addon.Utilities.FrameStrata, order, get, function(key)
        if callback then
            callback(addon.Utilities.FrameStrata[key])
        end
    end)
end

-- MARK: Multi Dropdown

---Create a multi select dropdown
---@param parent table the container
---@param label string label
---@param list table the value to display map
---@param order table? optional display order
---@param get table? the keys to select
---@return table component with GetSelectedKeys, ClearSelections, SetSelectedKeys and GetWidget
function addon.GUI:CreateMultiDropdown(parent, label, list, order, get)
    local component = {}

    local dropdown = addon.UICore:Build("MultiDropdown")
    dropdown:SetLabel(label or "")
    dropdown:SetList(list or {}, order)
    dropdown:SetValue(get)
    Attach(parent, dropdown)

    component.widget = dropdown

    function component:GetSelectedKeys()
        return self.widget:GetSelectedKeys()
    end

    function component:ClearSelections()
        self.widget:ClearSelections()
    end

    function component:SetSelectedKeys(keys)
        self.widget:SetSelectedKeys(keys or {})
    end

    function component:GetWidget()
        return self.widget
    end

    return component
end

-- MARK: Specs Dropdown

---Create a specialization select dropdown
---@param parent table the container
---@param label string label
---@return table component with GetSelectedSpecs, ClearSpecSelection, SetSelectedSpecs and GetWidget
function addon.GUI:CreateSpecSelectDropdown(parent, label)
    local component = {}
    local specClassList = addon.Utilities:GetAllSpecIconList(true)
    local specsList, specsOrder = {}, {}
    for _, specs in pairs(specClassList) do
        for specID, specStr in pairs(specs) do
            specsList[specID] = specStr
            table.insert(specsOrder, specID)
        end
    end

    component.dropdown = addon.GUI:CreateMultiDropdown(parent, label, specsList, specsOrder, nil)

    function component:GetSelectedSpecs()
        return self.dropdown:GetSelectedKeys()
    end

    function component:ClearSpecSelection()
        self.dropdown:ClearSelections()
    end

    function component:SetSelectedSpecs(loadingSpecs)
        self.dropdown:SetSelectedKeys(loadingSpecs)
    end

    function component:GetWidget()
        return self.dropdown:GetWidget()
    end

    return component
end

-- Initialize Tag Panels
addon.GUI.TagPanels = {}
