-- Widget is based on the AceGUIWidget-DropDown.lua supplied with AceGUI-3.0
-- Widget created for HBLyx: keeps only the main speaker button and sort and cache the sound list to improve performance

local AceGUI = LibStub("AceGUI-3.0")
local Media = LibStub("LibSharedMedia-3.0")

local AGSMW = LibStub("AceGUISharedMediaWidgets-1.0")

do
	local widgetType = "LSM30_Sound_HBLyx"
	local widgetVersion = 1

	local function OnItemValueChanged(this, event, checked)
		local self = this:GetUserData("obj")
		if not self then
			return
		end
		local itemValue = this:GetUserData("value")
		if checked then
			self:SetValue(itemValue)
			self:Fire("OnValueChanged", itemValue)
		else
			this:SetValue(true)
		end

		if self.open then
			self.pullout:Close()
		end
	end

	local function AddListItem(self, value, text, itemType)
		if not itemType then itemType = "Dropdown-Item-Toggle" end
		local exists = AceGUI:GetWidgetVersion(itemType)
		if not exists then
			error(("The given item type, %q, does not exist within AceGUI-3.0"):format(tostring(itemType)), 2)
		end

		local item = AceGUI:Create(itemType)
		---@diagnostic disable-next-line: undefined-field
		if item.SetText then
			---@diagnostic disable-next-line: undefined-field
			item:SetText(text)
		end
		item:SetUserData("obj", self)
		item:SetUserData("value", value)
		item:SetCallback("OnValueChanged", OnItemValueChanged)
		self.pullout:AddItem(item)
	end

	local sortlist = {}
	local function sortTbl(x, y)
		local num1, num2 = tonumber(x), tonumber(y)
		if num1 and num2 then
			return num1 < num2
		end
		return tostring(x) < tostring(y)
	end

	local function RebuildPullout(self, order, itemType)
		if not self.pullout then
			return
		end

		self.pullout:Clear()
		if not self.list then
			return
		end

		if type(order) ~= "table" then
			for key in pairs(self.list) do
				sortlist[#sortlist + 1] = key
			end
			table.sort(sortlist, sortTbl)
			for i, key in ipairs(sortlist) do
				AddListItem(self, key, key, itemType)
				sortlist[i] = nil
			end
		else
			for _, key in ipairs(order) do
				if self.list[key] ~= nil then
					AddListItem(self, key, key, itemType)
				end
			end
		end
	end

	local function WidgetPlaySound(this)
		local self = this.obj
		local sound = self.frame.text:GetText()
		if not sound or sound == "" then
			return
		end
		local soundPath = (self.list and self.list[sound] ~= sound and self.list[sound]) or Media:Fetch("sound", sound)
		if soundPath then
			PlaySoundFile(soundPath, "Master")
		end
	end

	local function Drop_OnEnter(this)
		this.obj:Fire("OnEnter")
	end

	local function Drop_OnLeave(this)
		this.obj:Fire("OnLeave")
	end

	local function Dropdown_OnHide(this)
		local self = this.obj
		if self.open then
			self.pullout:Close()
		end
	end

	local function ToggleDrop(this)
		local self = this.obj
		if self.open then
			self.open = nil
			self.pullout:Close()
			AceGUI:ClearFocus()
		else
			self.open = true
			self.pullout:SetWidth(self.pulloutWidth or self.frame:GetWidth())
			self.pullout:Open("TOPLEFT", self.frame, "BOTTOMLEFT", 0, -2)
			AceGUI:SetFocus(self)
		end
	end

	local function OnPulloutOpen(this)
		local self = this:GetUserData("obj")
		if not self then
			return
		end
		local value = self.value
		for _, item in this:IterateItems() do
			local itemValue = item:GetUserData("value")
			if itemValue ~= nil and item.SetValue then
				item:SetValue(itemValue == value)
			end
		end
		self.open = true
		self:Fire("OnOpened")
	end

	local function OnPulloutClose(this)
		local self = this:GetUserData("obj")
		if not self then
			return
		end
		self.open = nil
		self:Fire("OnClosed")
	end

	local function OnAcquire(self)
		---@diagnostic disable-next-line: param-type-mismatch
		local pullout = AceGUI:Create("Dropdown-Pullout")
		self.pullout = pullout
		pullout:SetUserData("obj", self)
		pullout:SetCallback("OnClose", OnPulloutClose)
		pullout:SetCallback("OnOpen", OnPulloutOpen)

		self:SetHeight(44)
		self:SetWidth(200)
		self:SetLabel("")
		self:SetPulloutWidth(nil)
		self:SetList(Media:HashTable("sound"))
	end

	local function OnRelease(self)
		if self.open and self.pullout then
			self.pullout:Close()
		end
		if self.pullout then
			AceGUI:Release(self.pullout)
			self.pullout = nil
		end

		self:SetText("")
		self:SetLabel("")
		self:SetDisabled(false)

		self.value = nil
		self.list = nil
		self.open = nil
		self.hasClose = nil

		self.frame:ClearAllPoints()
		self.frame:Hide()
	end

	local function SetText(self, text)
		self.frame.text:SetText(text or "")
	end

	local function SetLabel(self, text)
		self.frame.label:SetText(text or "")
	end

	local function SetValue(self, value)
		if self.list then
			self:SetText(value or "")
		end
		self.value = value
	end

	local function GetValue(self)
		return self.value
	end

	local function SetList(self, list, order, itemType)
		self.list = list or Media:HashTable("sound")
		RebuildPullout(self, order, itemType)
		if self.value ~= nil then
			self:SetValue(self.value)
		end
	end

	local function AddItem(self, key, value, itemType)
		self.list = self.list or {}
		self.list[key] = value
		if self.pullout then
			AddListItem(self, key, key, itemType)
		end
	end
	local SetItemValue = AddItem

	local function SetMultiselect(self, flag)
		self.multiselect = false
	end
	local function GetMultiselect()
		return false
	end
	local function SetItemDisabled(self, key, disabled)
		if not self.pullout then return end
		for _, item in self.pullout:IterateItems() do
			if item:GetUserData("value") == key then
				item:SetDisabled(disabled)
			end
		end
	end

	local function SetPulloutWidth(self, width)
		self.pulloutWidth = width
	end

	local function SetDisabled(self, disabled)
		self.disabled = disabled
		if disabled then
			self.frame:Disable()
			self.soundbutton:Disable()
			self.speaker:SetDesaturated(true)
			self.speakeron:SetDesaturated(true)
		else
			self.frame:Enable()
			self.soundbutton:Enable()
			self.speaker:SetDesaturated(false)
			self.speakeron:SetDesaturated(false)
		end
	end

	local function ClearFocus(self)
		if self.open and self.pullout then
			self.pullout:Close()
		end
	end

	local function Constructor()
		local frame = AGSMW:GetBaseFrame()
		local self = {}

		self.type = widgetType
		self.frame = frame
		frame.obj = self
		frame.dropButton.obj = self
		frame.dropButton:SetScript("OnEnter", Drop_OnEnter)
		frame.dropButton:SetScript("OnLeave", Drop_OnLeave)
		frame.dropButton:SetScript("OnClick", ToggleDrop)
		frame:SetScript("OnHide", Dropdown_OnHide)

		local soundbutton = CreateFrame("Button", nil, frame)
		soundbutton:SetWidth(16)
		soundbutton:SetHeight(16)
		soundbutton:SetPoint("LEFT", frame.DLeft, "LEFT", 26, 1)
		soundbutton:SetScript("OnClick", WidgetPlaySound)
		soundbutton.obj = self
		self.soundbutton = soundbutton
		frame.text:SetPoint("LEFT", soundbutton, "RIGHT", 2, 0)

		local speaker = soundbutton:CreateTexture(nil, "BACKGROUND")
		speaker:SetTexture("Interface\\Common\\VoiceChat-Speaker")
		speaker:SetAllPoints(soundbutton)
		self.speaker = speaker

		local speakeron = soundbutton:CreateTexture(nil, "HIGHLIGHT")
		speakeron:SetTexture("Interface\\Common\\VoiceChat-On")
		speakeron:SetAllPoints(soundbutton)
		self.speakeron = speakeron

		self.alignoffset = 31

		self.OnRelease = OnRelease
		self.OnAcquire = OnAcquire
		self.ClearFocus = ClearFocus
		self.SetText = SetText
		self.SetValue = SetValue
		self.GetValue = GetValue
		self.SetList = SetList
		self.SetLabel = SetLabel
		self.SetDisabled = SetDisabled
		self.AddItem = AddItem
		self.SetMultiselect = SetMultiselect
		self.GetMultiselect = GetMultiselect
		self.SetItemValue = SetItemValue
		self.SetItemDisabled = SetItemDisabled
		self.SetPulloutWidth = SetPulloutWidth
		self.ToggleDrop = ToggleDrop

		AceGUI:RegisterAsWidget(self)
		return self
	end

	AceGUI:RegisterWidgetType(widgetType, Constructor, widgetVersion)
end
