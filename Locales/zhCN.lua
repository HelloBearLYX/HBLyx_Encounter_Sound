local ADDON_NAME, addon = ...
local L = LibStub("AceLocale-3.0"):NewLocale(ADDON_NAME, "zhCN")
if not L then return end

L["Welecome"] = "|cff8788ee" .. ADDON_NAME .. "|r: 欢迎! 你的配置已经被重置, 你可以在: ESC-选项-插件-|cff8788ee" .. ADDON_NAME .. "|r里更改设置"
L["WelecomeInfo"] = "欢迎! 感谢你使用|cff8788ee" .. ADDON_NAME .. "|r!"
L["WelecomeSetting"] = "你可以使用 \"|cff8788ee/hblyx|r\" 命令或在 ESC-选项-插件-|cff8788ee" .. ADDON_NAME .. "|r 中打开配置面板来更改设置"
L["WarlockWelecome"] = "你好,|cff8788ee术士|r大人,本恶魔随时为你服务!"
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
"v3.11\n" ..
"-BOSS战音效: 为BOSS战事件的音效警报添加了一个新的选项用于设置团队职责\n" ..
"v3.10\n" ..
"-BOSS战音效: 私有光环子模块已实现\n" ..
"v3.9\n" ..
"-BOSS战音效: 新增模块\"BOSS战音效\", 用于为BOSS战时间线事件设置和播放自定义音效\n" ..
"v3.8\n" ..
"-焦点打断: 增加了一个目标施法条选项,可以创建一个与焦点施法条同样的目标施法条\n" ..
"v3.7\n" ..
"-自定义光环追踪: 光环可以通过专精加载(新增相应的自定义选项)\n" ..
"v3.6\n" ..
"-自定义光环追踪: 新增模块\"自定义光环追踪器\", 用于追踪\"玩家\"触发的光环, 并显示和播放声音警报, 支持自定义选项\n"

--MARK: Issues
L["Issues"] = "问题"
L["AnyIssues"] = "如果你遇到任何问题, 请通过联系方式向插件作者反馈"
L["IssuesContent"] = "Q:能否在焦点打断模块中添加XXX技能作为打断技能?\nA: 不能,由于暴雪的API限制,带有GCD的技能无法添加。若你想添加一个无GCD的技能,请告知我(提供技能详情)" .. "\n\n" ..
"Q:战复计时器在部分Beta大秘境开始时无法正确显示,必须重载,这是为什么?\nA: 这是暴雪部分副本的大秘境开始事件(CHALLENGE_MODE_START)没有正确触发导致的,目前没有好的解决方法,只能等暴雪修复了\n\n" ..
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
L["Mute"] = "静音"
L["Enable"] = "启用"
L["SoundSettings"] = "声音设置"
L["PetSettings"] = "宠物提醒设置"
L["PetStanceEnable"] = "启用宠物姿态检查"
L["PetTypeSettings"] = "启用宠物类型检查"
L["FadeTime"] = "淡入/淡出时间"
L["IconSize"] = "图标大小"
L["BackgroundAlpha"] = "背景透明度"
L["Texture"] = "材质"
L["Width"] = "宽度"
L["Height"] = "高度"
L["Sound"] = "音效"
L["TimeFontScale"] = "时间大小缩放"
L["StackFontSize"] = "层数/充能字体大小"
L["Reminders"] = "提醒"
L["Ready"] = "就绪"
L["NotLearned"] = "尚未学习"
L["Reload"] = "重载(RL)"
L["ReloadNeeded"] = "需要重载(Reload)才能使更改生效"
L["IconZoom"] = "图标缩放"
L["ResetMod"] = "重置本模块"
L["ComfirmResetMod"] = "您确定要重置此模块的所有设置吗?(同时重载)"
L["Anchor"] = "锚点"
L["Grow"] = "成长方向"
L["General"] = "综合"
L["Profile"] = "配置文件"
L["Export"] = "导出"
L["Import"] = "导入"
L["Export/Import"] = "导出/导入"
L["ProfileSettingsDesc"] = "使用下面的字符串导出和导入你的配置文件\n\n导出的字符串是和|cff8788eeHBLyx_Tools|r兼容的,如果你想把同样的设置应用到|cff8788eeHBLyx_Tools|r里的模块,你可以在|cff8788eeHBLyx_Tools|r的模块配置部分导入这个字符串"
L["ImportSuccess"] = "配置文件导入成功,请重载界面以应用更改"
L["ModuleProfile"] = "模块配置文件"
L["ModuleProfileDesc"] = "你可以选择一个模块来单独导出/导入配置文件\n\n导出时先在下面选择模块,导入时字符串会自动识别模块"
L["SelectModule"] = "选择模块"
L["SpellID"] = "法术ID"
L["Duration"] = "持续时间"
L["Cooldown"] = "冷却时间"
L["ActiveSound"] = "激活音效"
L["ExpireSound"] = "过期音效"
L["Add"] = "添加"
L["Remove"] = "删除"
L["AddSuccess"] = "成功|cffffff00添加|r"
L["AddFailed"] = "|cffffff00添加|r失败"
L["UpdateSuccess"] = "成功|cffffff00更新|r"
L["RemoveSuccess"] = "成功|cffffff00删除|r"
L["RemoveFailed"] = "|cffffff00删除|r失败"
L["LoadingSpecs"] = "加载专精"
L["LoadingSpecsDesc"] = "选择光环将在哪些专精下生效(可以选择多个或不选择), |cffff0000如果没有选择任何专精, 光环将在所有专精下生效|r\n\n" .. "当你选择一个已经存在的光环时, 专精相关信息也会被自动填充到专精选择中"
L["LeftButton"] = "左键"
L["RightButton"] = "右键"
L["ShowInInstance"] = "仅在副本中显示"
L["HideMinimapIcon"] = "隐藏小地图图标"
L["Select"] = "选择"
L["PrivateAura"] = "私有光环"
L["HideIfFriendly"] = "友方则隐藏"

-- MARK: Style
L["StyleSettings"] = "样式设置"
L["Font"] = "字体"
L["FontSize"] = "字体大小"
L["FontSettings"] = "字体设置"
L["X"] = "水平位置"
L["Y"] = "垂直位置"
L["PositionSettings"] = "位置设置"
L["IconSettings"] = "图标设置"
L["TextureSettings"] = "材质设置"
L["SizeSettings"] = "大小设置"
L["ColorSettings"] = "颜色设置"
L["TextSettings"] = "文本设置"
L["InterruptibleColor"] = "可打断颜色"
L["NotInterruptibleColor"] = "不可打断颜色"
L["FrameStrata"] = "框架层级"

-- MARK: Input
L["InvalidInput"] = "输入无效, 请检查所有必填项及其格式和类型"
L["InvalidSpellID"] = "无效的法术ID, 法术ID必须是一个正整数, 并且游戏中必须存在"
L["SpellIDNotFound"] = "游戏中未找到此法术ID"
L["InvalidTime"] = "无效的时间, 时间必须是一个非负的数字(允许浮点数/小数), 单位为秒"

-- current season
L["Algeth'ar Academy"] = "艾杰斯亚学院"
L["Seat of the Triumvirate"] = "执政团之座"
L["Nexus-Point Xenas"] = "节点希纳斯"
L["Maisara Caverns"] = "迈萨拉洞窟"
L["Skyreach"] = "通天峰"
L["Windrunner Spire"] = "风行者之塔"
L["Magister's Terrace"] = "魔导师平台"
L["Pit of Saron"] = "萨隆矿坑"
-- short for current season
L["Algeth'ar Academy_short"] = "艾杰斯亚学院"
L["Seat of the Triumvirate_short"] = "执政团之座"
L["Nexus-Point Xenas_short"] = "节点希纳斯"
L["Maisara Caverns_short"] = "迈萨拉洞窟"
L["Skyreach_short"] = "通天峰"
L["Windrunner Spire_short"] = "风行者之塔"
L["Magister's Terrace_short"] = "魔导师平台"
L["Pit of Saron_short"] = "萨隆矿坑"
-- pre-patch
L["ARAK"] = "回响之城"
L["TD"] = "破晨号"
L["ED"] = "生态圆顶"
L["HOA"] = "赎罪大厅"
L["OF"] = "水闸行动"
L["PSF"] = "圣焰隐修院"
L["GAMBIT"] = "宏图"
L["STREET"] = "天街"

-- MARK: Encounter Sound
L["EncounterSoundSettings"] = "BOSS战音效"
L["EncounterSoundSettingsDesc"] = "为BOSS战时间轴事件设置和播放自定义音效\n" ..
"具体来说, 这个模块为副本中的每个BOSS战提供了一个自定义的音效警报设置(仅包括当前赛季的副本)\n\n" ..
"首先添加了12.0第一赛季的大秘境, 然后很快会添加团队副本。由于这个模块高度依赖于对游戏数据的数据挖掘, 实际上获取数据是相对耗时的\n" ..
"随着数据挖掘的过程, 许多问题将被修复, 模块也会得到改进, 感谢你的反馈和支持!\n" ..
"这个模块仍在开发中, 希望这个模块可以为BOSS战提供更灵活的音效警报\n\n" ..
"|cffff0000注意|r: 这个模块默认是禁用的, 因为它仍处于早期阶段, 可能会频繁更改, 你可以通过下面的选项启用它。\n"
L["EncounterSettings"] = "BOSS战事件设置"
L["SelectEncounter"] = "选择BOSS战"
L["SelectInstance"] = "选择副本"
L["EncounterEventTrigger"] = "BOSS战事件触发器"
L["EncounterEventSound"] = "BOSS战事件音效"
L["OnTextWarningShown"] = "文本警告显示时"
L["OnTimelineEventFinished"] = "事件完成时"
L["OnTimelineEventHighlight"] = "事件高亮时"
L["EventColor"] = "事件颜色"
L["PrivateAuraSettings"] = "私有光环设置"
L["EncounterEvent"] = "BOSS战事件"
L["SelectGroupRole"] = "团队职责"
L["EncounterSoundInstruction"] = "选择|cffffff00一个副本|r和|cffffff00一个BOSS战|r后, 该BOSS战的设置将会在下面弹出\n由于游戏需要时间加载法术描述, 设置的渲染会有0.5秒的延迟\n\n"
L["EncounterEventsInstruction"] = "要设置音效, 选择|cffffff00一个事件触发器|r和|cffffff00一个有效的音效|r, 设置自动套用。同时, 你可以使用|cffffff00\"删除\"|r来删除所选触发器的音效设置\n\n" ..
"要设置颜色(事件的文本颜色), 只需使用颜色选择器选择一个|cffffff00颜色|r, 它将被应用于该BOSS战事件。要删除颜色设置, 你可以类似地使用|cffffff00\"删除\"|r按钮\n\n" ..
"|cffff0000注意|r: |cffffff00事件触发器|r由暴雪的API提供, 下面是描述:\n" ..
"|cffff5c00文本警告显示时|r: 当|cffff5c00一个文本警告最初显示时|r触发\n" ..
"|cffff5c00事件完成时|r: 当时间轴上的事件|cffff5c00完成|r时触发\n" ..
"|cffff5c00事件高亮时|r: 当时间轴上的事件|cffff5c00将在5秒内完成|r时触发\n" ..
"更多关于触发器的信息在: |cff00ffffhttps://warcraft.wiki.gg/wiki/API_C_EncounterEvents.SetEventSound|r\n\n" ..
"例子: 如果你需要一个\"准备AoE-3-2-1\", 你应该将\"准备AoE\"和倒计时音效合并到一个媒体文件中, 并设置在\"事件高亮\"触发器上播放(在AoE的5秒前播放)\n\n" ..
"|cffff0000注意|r: 你必须|cffffff00启用暴雪的首领预警(包括文本警告和时间轴)|r, 才能让相应的事件触发器激活\n"
L["PrivateAuraInstruction"] = "为私有光环应用一个声音警报, 当私有光环被施加在\"玩家\"身上时播放声音警报\n\n" ..
"为了防止不必要的冲突或冗余, 私有光环的锚点在这个模块中没有提供, 因为有许多UI插件提供了私有光环的自定义位置\n\n" ..
"|cffff0000注意|r: 由于暴雪(03/02/2026)删除了大量副本中的私有光环, |cffff0000部分私有光环设置被暂时不会生效|r。即使如此, 如果之前已经设置了私有光环警报, 它们仍然可以正常工作, 如果这个私有光环还存在的话。"