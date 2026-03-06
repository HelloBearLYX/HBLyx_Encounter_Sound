local ADDON_NAME, _ = ...
local L = LibStub("AceLocale-3.0"):NewLocale(ADDON_NAME, "zhCN")
if not L then return end

L["Welecome"] = "|cff8788ee" .. ADDON_NAME .. "|r: 欢迎! 你的配置已经被重置, 你可以在: ESC-选项-插件-|cff8788ee" .. ADDON_NAME .. "|r里更改设置"
L["WelecomeInfo"] = "欢迎! 感谢你使用|cff8788ee" .. ADDON_NAME .. "|r!"
L["WelecomeSetting"] = "你可以使用 \"|cff8788ee/hbes|r\" 命令或在 ESC-选项-插件-|cff8788ee" .. ADDON_NAME .. "|r 中打开配置面板来更改设置"
L["GUITitle"] = "|cff8788ee" .. ADDON_NAME .. "|r配置面板"
L["CombatLock"] = "|cffff0000战斗中|r, 无法打开配置面板或开启测试模式"
L["Notifications"] = "通知"
L["NotificationContent"] = "选项界面中的标签页显示了本插件包含的模块, 你可以分别配置每个模块" .. "\n\n" ..
"你可以在|cff8788eeHBLyx|r的页面里找到:" .. "\n" ..
"|cff8788eeHBLyx_Tools|r: 一个包含战斗指示器, 战斗计时器, 焦点打断以及更多模块的集合" .. "\n" ..
"|cff8788eeMidnightFocusInterrupt|r: 焦点打断模块的独立版本" .. "\n" ..
"|cff8788eeHBLyx_Encounter_Sound|r: BOSS战音效模块的独立版本" .. "\n" ..
"|cff8788eeSharedMedia_HBLyx|r: 一个AI生成的中文语音素材包(LibSharedMedia)"

-- MARK： Downloads/Update
L["Downloads/Update"] = "下载/更新"
L["Release_Info"] = "官方发布版本|cffff0000仅在以下地址提供, 其他所有版本均非作者发布|r"

-- MARK: Change Log
L["ChangeLog"] = "更新日志"
L["ChangeLogContent"] =
"v3.12\n" ..
"-BOSS战音效: 完全将BOSS战音效模块从 |cff8788eeHBLyx_Tools|r 中拆分出来, 并作为独立模块 |cff8788eeHBLyx_Encounter_Sound|r\n" ..
"v3.11\n" ..
"-BOSS战音效: 为BOSS战事件的音效警报添加了一个新的选项用于设置团队职责\n" ..
"v3.10\n" ..
"-BOSS战音效: 私有光环子模块已实现\n" ..
"v3.9\n" ..
"-BOSS战音效: 新增模块\"BOSS战音效\", 用于为BOSS战时间线事件设置和播放自定义音效\n"

--MARK: Issues
L["Issues"] = "问题"
L["AnyIssues"] = "如果你遇到任何问题, 请通过联系方式向插件作者反馈"
L["IssuesContent"] =
"Q: 在BOSS战音效模块中, 有一些事件或私有光环缺失或不正确, 会被修正吗?\nA: 会的, 由于该模块高度依赖于对游戏的数据挖掘, 而且暴雪不断更改BOSS战斗, 获取新数据需要一些时间\n\n" ..
"感谢你的理解和支持!"

-- MARK: Contact
L["Contact"] = "联系方式"
L["GitHub"] = "在GitHub提交问题"
L["CurseForge"] = "在CurseForge发表评论"

-- MARK: Sound Channel
L["SoundChannelSettings"] = "声音通道"
L["SoundChannel"] = {
	Master = "主音量",
	SFX = "效果",
	Music = "音乐",
	Ambience = "环境音",
	Dialog = "对话",
}

L["GroupRole"] = {
	TANK = "坦克",
	HEALER = "治疗",
	DAMAGER = "输出",
}

-- MARK: Config
L["ConfigPanel"] = "打开配置面板"
L["Test"] = "测试/解锁(拖动移动)"
L["Enable"] = "启用"
L["SoundSettings"] = "声音设置"
L["Reload"] = "重载(RL)"
L["ReloadNeeded"] = "需要重载(Reload)才能使更改生效"
L["ResetMod"] = "重置本模块"
L["ComfirmResetMod"] = "您确定要重置此模块的所有设置吗?(同时重载)"
L["General"] = "综合"
L["Raid"] = "团队副本"
L["Dungeon"] = "地下城"
L["Profile"] = "配置文件"
L["Export"] = "导出"
L["Import"] = "导入"
L["ProfileSettingsDesc"] = "使用下面的字符串导出和导入你的配置文件\n"
L["ImportSuccess"] = "配置文件导入成功,请重载界面以应用更改"
L["Add"] = "添加"
L["Remove"] = "删除"
L["AddSuccess"] = "成功|cffffff00添加|r"
L["AddFailed"] = "|cffffff00添加|r失败"
L["UpdateSuccess"] = "成功|cffffff00更新|r"
L["RemoveSuccess"] = "成功|cffffff00删除|r"
L["RemoveFailed"] = "|cffffff00删除|r失败"
L["LeftButton"] = "左键"
L["RightButton"] = "右键"
L["HideMinimapIcon"] = "隐藏小地图图标"
L["Select"] = "选择"
L["PrivateAura"] = "私有光环"
L["EncounterSoundEffects"] = "BOSS战音效"
L["VictorySound"] = "胜利音效"
L["StartSound"] = "BOSS战开始音效"
L["TestTimeline"] = "测试时间轴"
L["TestLoadFailed"] = "测试|cffff0000失败|r: 没有找到BOSS战数据: "
L["TestLoadSuccess"] = "测试加载|cff00ff00成功|r: 测试BOSS战: "
L["ClearPrivateAurasData"] = "已清除注册的私有光环音效: "
L["ClearEventSound"] = "已清除注册的事件音效: "
L["CurrentProfile"] = "当前配置文件: "
L["SelectAnEvent"] = "选择一个BOSS战事件开始设置"
L["SelectPA"] = "选择一个私有光环开始设置"

-- MARK: Style
L["ColorSettings"] = "颜色设置"
L["FrameStrata"] = "框架层级"

-- MARK: Encounter Sound
L["EncounterSoundSettings"] = "BOSS战音效"
L["EncounterSoundSettingsDesc"] = "为BOSS战时间轴事件和私有光环设置和播放自定义音效\n" ..
"随着数据挖掘的过程, 许多问题将被修复, 模块也会得到改进, 感谢你的反馈和支持!\n" ..
"这个模块持续开发中, 希望这个模块可以为BOSS战提供更灵活的音效警报\n\n"

L["EncounterSettings"] = "BOSS战事件设置"
L["SelectEncounter"] = "选择BOSS战"
L["SelectInstance"] = "选择副本"
L["EncounterEventTrigger"] = "BOSS战事件触发器"
L["EncounterEventSound"] = "BOSS战事件音效"
L["OnTextWarningShown"] = "|cffff5c00文本警告显示时|r: 当一个文本警告最初显示时触发"
L["OnTimelineEventFinished"] = "|cffff5c00事件完成时|r: 当时间轴上的事件完成时触发"
L["OnTimelineEventHighlight"] = "|cffff5c00事件高亮时|r: 当时间轴上的事件将在5秒内完成时触发"
L["EventColor"] = "事件颜色"
L["PrivateAuraSettings"] = "私有光环设置"
L["EncounterEvent"] = "BOSS战事件"
L["SelectGroupRole"] = "团队职责"
L["EncounterSoundInstruction"] = "选择|cffffff00一个副本|r和|cffffff00一个BOSS战|r后, 该BOSS战的设置将会在下面弹出\n\n"
L["EncounterEventsInstruction"] =
"|cffff0000注意|r: 你必须|cffffff00启用暴雪的首领预警(包括文本警告和时间轴)|r, 才能让相应的事件触发器激活\n\n" ..
"|cffffff00测试时间轴|r: 会模拟本Boss所有的时间轴事件(非实际Boss时间轴), 并以6秒为间隔, 以便测试设置的正确性和效果, 但是实际时间轴时间表现可能会不同\n\n"
L["PrivateAuraInstruction"] = "为私有光环应用一个声音警报, 当私有光环被施加在\"玩家\"身上时播放声音警报\n\n" ..
"为了防止不必要的冲突或冗余, 私有光环的锚点在这个模块中没有提供, 因为有许多UI插件提供了私有光环的自定义位置\n\n" ..
"|cffff0000注意|r: 由于暴雪(03/02/2026)删除了大量副本中的私有光环, |cffff0000部分私有光环设置被暂时不会生效|r。即使如此, 如果之前已经设置了私有光环警报, 它们仍然可以正常工作, 如果这个私有光环还存在的话。"