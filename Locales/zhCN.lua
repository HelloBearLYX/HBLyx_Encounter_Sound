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
"v3.18\n" .. "-添加两个新模块: 私有光环锚点和文本警告美化\n" ..
"v3.17\n" .. "-添加时间轴美化模块, 提供可自定义的时间轴\n" ..
"v3.16\n" .. "-添加高亮图标模块, 显示高亮(<= 5秒)事件的图标\n" ..
"v3.15\n" .. "-实现了模板, 法术标签, 和高性能音效选择组件\n"

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

-- MARK: Spell Flags
L["SpellFlagTank"] = "坦克"
L["SpellFlagDamager"] = "输出"
L["SpellFlagHealer"] = "治疗"
L["SpellFlagHeroic"] = "|cffec8b27H|r英雄"
L["SpellFlagDeadly"] = "致命"
L["SpellFlagImportant"] = "重要"
L["SpellFlagInterrupt"] = "打断"
L["SpellFlagMagic"] = "魔法"
L["SpellFlagCurse"] = "诅咒"
L["SpellFlagPoison"] = "中毒"
L["SpellFlagDisease"] = "疾病"
L["SpellFlagEnrage"] = "激怒"
L["SpellFlagMythic"] = "|cffbf42f5M|r史诗"
L["SpellFlagBleed"] = "流血"
L["SpellFlagTextWarning"] = "|cffffffffT|r文本警告"

-- MARK: Config
L["ConfigPanel"] = "打开配置面板"
L["Test"] = "解锁(拖动移动)"
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
L["TestLoadSuccess"] = "测试加载|cff00ff00成功|r: 测试BOSS战-"
L["ClearPrivateAurasData"] = "已清除注册的私有光环音效: "
L["ClearEventSound"] = "已清除注册的事件音效: "
L["CurrentProfile"] = "当前配置文件: "
L["SelectAnEvent"] = "选择一个BOSS战事件开始设置"
L["SelectPA"] = "选择一个私有光环开始设置"
L["NoSuchEncounterToTest"] = "如果你想测试, 请输入类似\"|cff8788ee\\hbes test <encounterID>|r\"的命令, 其中<encounterID>是你想测试的BOSS战的ID"
L["DataMigration"] = "数据迁移"
L["GeneralSettings"] = "通用设置"
L["HideEncounterPrint"] = "隐藏BOSS战开始/结束的信息打印"
L["Applied"] = "已应用"
L["Duplicated"] = "重复"
L["EmptyKey"] = "空key"
L["MergedInto"] = "合并到"
L["MergeSuccess"] = "配置文件合并|cffffff00成功|r"
L["MergeSummary"] = "|cffff5c00合并总结|r"
L["Events"] = "事件"
L["PrivateAuras"] = "私有光环"
L["New"] = "新增"
L["Overwritten"] = "覆盖"
L["MergeDesc"] = "|cffff5c00合并BOSS战配置|r\n将Boss战配置文件与当前配置合并, 重复的条目将被输入的配置文件覆盖\n合并只会合并事件设置和私有光环设置, 其他模块的设置将不会被影响\n\n"
L["CountDown"] = "倒计时"

-- MARK: Style
L["ColorSettings"] = "颜色设置"
L["FrameStrata"] = "框架层级"
L["StyleSettings"] = "样式设置"
L["IconSettings"] = "图标设置"
L["PositionSettings"] = "位置设置"
L["FontSettings"] = "字体设置"
L["TextWarningSkinsSettings"] = "文本警告美化"
L["TextWarningSkinsSettingsDesc"] = "美化暴雪首领文本警告，可自定义大小、位置、生长方向和字体。\n\n"
L["PrivateWarningSettings"] = "私有警告"
L["PrivateWarningSettingsDesc"] = "暴雪的私有警告, 与私有光环高度相关, 除了锚点之外由暴雪控制\n\n"
L["PrivateAuraAnchorSettings"] = "私有光环锚点"
L["PrivateAuraAnchorSettingsDesc"] = "重新设置暴雪私有光环的锚点，并自定义图标布局。\n\n"
L["HighlightIconsSettings"] = "高亮图标"
L["HighlightIconsSettingsDesc"] = "将暴雪首领技能时间轴中被高亮的事件显示为图标\n\n你可以在这里调整图标大小、增长方向、字体位置和锚点。\n\n"
L["TimelineSkinsSettings"] = "时间轴美化"
L["TimelineSkinsSettingsDesc"] = "复制暴雪的首领技能时间轴并隐藏原有时间轴\n允许自定义时间轴的样式\n\n"
L["IconSize"] = "图标大小"
L["Width"] = "宽度"
L["Height"] = "高度"
L["IconZoom"] = "图标缩放"
L["Length"] = "长度"
L["X"] = "X"
L["Y"] = "Y"
L["Font"] = "字体"
L["FontSize"] = "字体大小"
L["FontXOffset"] = "字体X偏移"
L["FontYOffset"] = "字体Y偏移"
L["BackgroundAlpha"] = "背景透明度"
L["TickAlpha"] = "刻度透明度"
L["Grow"] = "生长"
L["TextGrow"] = "文本生长"
L["VerticalLayout"] = "纵向布局"
L["FontAnchor"] = "字体锚点"
L["TimeFontScale"] = "时间字体缩放"
L["ShowOnlyActive"] = "仅活跃时显示"
L["ShowQueuedIcons"] = "显示队列图标"
L["MaxAuras"] = "最大光环数"
L["BorderScale"] = "边框缩放"
L["ShowCountdownNumbers"] = "显示倒计时数字"
L["CoTankAuras"] = "副坦克光环"
L["ShowCoTankAuras"] = "显示副坦克光环"
L["HideBorder"] = "隐藏边框"
L["AutoGossip"] = "自动对话"

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
L["OnTextWarningShown"] = "|cffff5c00文本警告显示时|r"
L["OnTextWarningShownDesc"] = ": 当一个文本警告最初显示时触发"
L["OnTimelineEventFinished"] = "|cffff5c00事件完成时|r"
L["OnTimelineEventFinishedDesc"] = ": 当时间轴上的事件完成时触发"
L["OnTimelineEventHighlight"] = "|cffff5c00事件高亮时|r"
L["OnTimelineEventHighlightDesc"] = ": 当时间轴上的事件将在5秒内完成时触发"
L["EventColor"] = "事件颜色"
L["PrivateAuraSettings"] = "私有光环设置"
L["EncounterEvent"] = "BOSS战事件"
L["SelectGroupRole"] = "团队职责"
L["EncounterSoundInstruction"] = "选择|cffffff00一个副本|r和|cffffff00一个BOSS战|r后, 该BOSS战的设置将会在下面弹出\n\n"
L["EncounterEventsInstruction"] =
"|cffff0000注意|r: 你必须|cffffff00启用暴雪的首领预警(包括文本警告和时间轴)|r, 才能让相应的事件触发器激活\n\n" ..
"|cffffff00测试时间轴|r: 会模拟本Boss所有的时间轴事件(非实际Boss时间轴), 并以6秒为间隔, 以便测试设置的正确性和效果, 但是实际时间轴时间表现可能会不同\n\n" ..
"|cffff0000注意|r: 测试时间轴仅适用于已设置的事件, 因此, |cffFF7C0A如果该BOSS战没有设置任何事件, 测试时间轴将无法工作|r\n\n"
L["PrivateAuraInstruction"] = "为私有光环应用一个声音警报, 当私有光环被施加在\"玩家\"身上时播放声音警报\n\n"

-- MARK: Templates
L["TemplateSettings"] = "模板"
L["SelectTemplate"] = "选择模板"
L["TemplateNameNew"] = "新模板"
L["ApplyTemplate"] = "应用模板"
L["TemplateDesc"] = "模板用于快速应用于具有相似条件的事件\n\n" ..
"在你设置好模板后, 你可以将它应用于一个事件, 设置将会立即应用于该事件, 你也可以在应用模板后修改设置以适应特定事件\n\n" ..
"模板名称是|cffffff00模板的唯一键|r, 所以当你创建一个新模板时,请确保名称与现有模板不同\n\n" ..
"可以从下拉菜单中选择模板来删除/更新, 你可以通过输入一个新的模板名字来添加新模板"

-- MARK: Contributors
L["Contributors"] = "贡献者"
L["data correction"] = "数据修正"
L["testing"] = "测试"
L["feedbacks"] = "反馈"
L["configuration sharing"] = "配置共享"
L["ThanksTo"] = "感谢以下的贡献:"
L["AnonymousContributors"] = "\n也感谢其他许多提交数据修正, bug报告和建议的贡献者."
L["ContributeData"] = "如果你想贡献数据或有任何问题, 请使用GitHub或Discord频道! 你可以在联系方式部分找到链接, 如果可以的话, 推荐使用Pull Request(PR)的方式提交.\n" ..
"如果你想帮助改进数据, 你可以使用命令 \"|cff8788ee/hbes dev|r\" 来打开开发者工具面板, 里面有一个 \"Data Fetch\" 标签页提供了以CSV格式获取游戏内数据的工具, 如果需要的话你可以提交这些数据, 非常感谢!\n"