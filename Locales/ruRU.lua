local ADDON_NAME, _ = ...
local L = LibStub("AceLocale-3.0"):NewLocale(ADDON_NAME, "ruRU")
if not L then return end
-- Translator ZamestoTV
L["Welecome"] = "|cff8788ee" .. ADDON_NAME .. "|r: Добро пожаловать! Ваш профиль был сброшен, вы можете настроить его здесь: Настройки-Параметры-Модификации-|cff8788ee" .. ADDON_NAME .. "|r"
L["WelecomeInfo"] = "Добро пожаловать! Спасибо за использование |cff8788ee" .. ADDON_NAME .. "|r!"
L["WelecomeSetting"] = "Вы можете изменить настройки с помощью команды \"|cff8788ee/hbes|r\" или открыть панель конфигурации в Настройки-Параметры-Модификации-|cff8788ee" .. ADDON_NAME .. "|r"
L["GUITitle"] = "Панель конфигурации |cff8788ee" .. ADDON_NAME .. "|r"
L["CombatLock"] = "|cffff0000В бою|r невозможно открыть панель конфигурации или включить тестовый режим"
L["Notifications"] = "Уведомления"
L["NotificationContent"] = "На вкладках отображаются модули, содержащиеся в этом аддоне, вы можете настроить каждый модуль отдельно." .. "\n\n" ..
"Вы можете найти на странице |cff8788eeHBLyx|r:" .. "\n" ..
"|cff8788eeHBLyx_Tools|r: коллекция модулей, включая индикатор боя, таймер боя, фокус-прерывание и другие модули" .. "\n" ..
"|cff8788eeMidnightFocusInterrupt|r: отдельная версия модуля фокус-прерывания" .. "\n" ..
"|cff8788eeHBLyx_Encounter_Sound|r: отдельная версия модуля звуков подземелий" .. "\n" ..
"|cff8788eeSharedMedia_HBLyx|r: созданный искусственным интеллектом китайский звуковой пакет (LibSharedMedia)"

-- MARK： Downloads/Update
L["Downloads/Update"] = "Скачать/Обновить"
L["Release_Info"] = "Официальная релизная версия |cffff0000доступна только на следующих сайтах, все остальные созданы не автором|r"

-- MARK: Change Log
L["ChangeLog"] = "Журнал изменений"
L["ChangeLogContent"] = "Полный журнал изменений можно найти здесь:"
L["ChangeLogLink"] = "https://discord.gg/NkjEKddwDr"

-- MARK: Contact
L["Contact"] = "Контакты"
L["GitHub"] = "Сообщить об ошибке на GitHub"
L["CurseForge"] = "Комментарии на CurseForge"

-- MARK: Sound Channel
L["SoundChannelSettings"] = "Звуковой канал"
L["SoundChannel"] = {
	Master = "Общий",
	SFX = "Звуковые эффекты",
	Music = "Музыка",
	Ambience = "Звуки окружения",
	Dialog = "Диалоги",
}

L["GroupRole"] = {
	TANK = "Танк",
	HEALER = "Лекарь",
	DAMAGER = "Боец",
}

-- MARK: Spell Flags
L["SpellFlagTank"] = "Танк"
L["SpellFlagDamager"] = "Боец"
L["SpellFlagHealer"] = "Лекарь"
L["SpellFlagHeroic"] = "|cffec8b27Г|rероический"
L["SpellFlagDeadly"] = "Смертельно"
L["SpellFlagImportant"] = "Важно"
L["SpellFlagInterrupt"] = "Прерывание"
L["SpellFlagMagic"] = "Магия"
L["SpellFlagCurse"] = "Проклятие"
L["SpellFlagPoison"] = "Яд"
L["SpellFlagDisease"] = "Болезнь"
L["SpellFlagEnrage"] = "Иступление"
L["SpellFlagMythic"] = "|cffbf42f5Э|rпохальный"
L["SpellFlagBleed"] = "Кровотечение"
L["SpellFlagTextWarning"] = "|cffffffffТ|rекстовое предупреждение"

-- MARK: Config
L["ConfigPanel"] = "Открыть панель конфигурации"
L["Test"] = "Разблокировать (Перетащить для перемещения)"
L["Enable"] = "Включить"
L["Hide"] = "Скрыть"
L["Show"] = "Показать"
L["Scale"] = "Масштаб"
L["CoreSettings"] = "Основные настройки"
L["BroadcastChannel"] = "Канал вещания"
L["SoundSettings"] = "Настройки звука"
L["Reload"] = "Перезагрузка (RL)"
L["ReloadNeeded"] = "Для применения изменений требуется перезагрузка интерфейса"
L["ResetMod"] = "Сбросить модуль"
L["ComfirmResetMod"] = "Вы уверены, что хотите сбросить все настройки этого модуля? (Это также перезагрузит интерфейс)"
L["General"] = "Общие"
L["Universal"] = "Универсальные"
L["UniversalSettings"] = "Универсальные настройки"
L["Skins"] = "Текстуры/Скины"
L["Others"] = "Другие"
L["Raid"] = "Рейд"
L["Dungeon"] = "Подземелье"
L["Profile"] = "Профиль"
L["Export"] = "Экспорт"
L["Import"] = "Импорт"
L["ProfileSettingsDesc"] = "Экспортируйте и импортируйте свой профиль с помощью строки ниже.\n"
L["ImportSuccess"] = "Профиль успешно импортирован. Пожалуйста, перезагрузите интерфейс, чтобы применить изменения."
L["Add"] = "Добавить"
L["Remove"] = "Удалить"
L["AddSuccess"] = "Успешно |cffffff00добавлено|r"
L["AddFailed"] = "Не удалось |cffffff00добавить|r"
L["UpdateSuccess"] = "Успешно |cffffff00обновлено|r"
L["RemoveSuccess"] = "Успешно |cffffff00удалено|r"
L["RemoveFailed"] = "Не удалось |cffffff00удалить|r"
L["LeftButton"] = "ЛКМ"
L["RightButton"] = "ПКМ"
L["HideMinimapIcon"] = "Скрыть иконку у мини-карты"
L["Select"] = "Выбрать"
L["PrivateAura"] = "Приватная аура"
L["EncounterSoundEffects"] = "Звуковые эффекты боссов"
L["VictorySound"] = "Звук победы"
L["StartSound"] = "Звук начала боя"
L["TestTimeline"] = "Тест таймлайна"
L["TestLoadFailed"] = "Тест |cffff0000не удался|r: Данные боя не найдены для: "
L["TestLoadSuccess"] = "Тестовая загрузка |cff00ff00успешна|r: Тест для боя - "
L["ClearPrivateAurasData"] = "Зарегистрированные звуки приватных аур очищены: "
L["ClearEventSound"] = "Зарегистрированные звуки событий очищены: "
L["CurrentProfile"] = "Текущий профиль: "
L["SelectAnEvent"] = "Выберите событие боя, чтобы начать настройку"
L["SelectPA"] = "Выберите приватную ауру, чтобы начать настройку"
L["NoSuchEncounterToTest"] = "Если вы хотите провести тест, введите ID босса в формате \"|cff8788ee\\hbes test <encounterID>|r\", где <encounterID> - это ID нужного босса"
L["DataMigration"] = "Миграция данных"
L["GeneralSettings"] = "Общие настройки"
L["HideEncounterPrint"] = "Скрыть сообщения о начале/окончании боя"
L["Applied"] = " применено"
L["Duplicated"] = "дублировано"
L["EmptyKey"] = "Пустой ключ"
L["MergedInto"] = "объединено с"
L["MergeSuccess"] = "Профиль |cffffff00успешно|r объединен"
L["MergeSummary"] = "|cffff5c00Результаты объединения|r"
L["Events"] = "события"
L["PrivateAuras"] = "приватные ауры"
L["New"] = "новые"
L["Overwritten"] = "перезаписано"
L["MergeDesc"] = "|cffff5c00Объединение конфигурации боссов|r\nОбъединяет файл конфигурации боссов с текущими настройками. Дублирующиеся записи будут перезаписаны данными из профиля.\nДействие объединит только параметры событий и настройки приватных аур, настройки других модулей не изменятся.\n\n"
L["Countdown"] = "Отсчет"
L["CountdownSound"] = "Звук отсчета"
L["CountdownSoundSettings"] = "Настройки звука отсчета"
L["CountdownTextWarning"] = " запускает отсчет: "
L["CountdownDesc"] = "Настраиваемая замена стандартного таймера отсчета от Blizzard с возможностью изменения звуковых оповещений."
L["FadeTime"] = "Время затухания"
L["Undo"] = "Отмена"
L["ShowSpellText"] = "Показывать текст заклинания"

-- MARK: Style
L["Color"] = "Цвет"
L["ColorSettings"] = "Настройки цвета"
L["FrameStrata"] = "Слой фрейма (Strata)"
L["StyleSettings"] = "Настройки стиля"
L["IconSettings"] = "Настройки иконок"
L["PositionSettings"] = "Настройки позиции"
L["FontSettings"] = "Настройки шрифта"
L["TextWarningSkinsSettings"] = "Текстовое предупреждение"
L["TextWarningSkinsSettingsDesc"] = "Настраиваемая замена стандартных текстовых предупреждений от Blizzard на боссах."
L["PrivateWarningSettings"] = "Приватное предупреждение"
L["PrivateWarningSettingsDesc"] = "Приватные предупреждения Blizzard, которые тесно связаны с приватными аурами. Они полностью контролируются Blizzard, за исключением точки привязки.\n\n"
L["PrivateAuraAnchorSettings"] = "Привязка приватной ауры"
L["PrivateAuraAnchorSettingsDesc"] = "Точки привязки приватных аур и настройка расположения их иконок."
L["HighlightIconsSettings"] = "Подсветка иконок"
L["HighlightIconsSettingsDesc"] = "Отображение подсвеченных событий (<= 5 сек) в виде иконок."
L["TimelineSkinsSettings"] = "Таймлайн"
L["TimelineSkinsSettingsDesc"] = "Настраиваемая замена стандартной временной шкалы способностей боссов от Blizzard."
L["IconSize"] = "Размер иконки"
L["Width"] = "Ширина"
L["Height"] = "Высота"
L["IconZoom"] = "Масштаб иконки"
L["Length"] = "Длина"
L["X"] = "Смещение по X"
L["Y"] = "Смещение по Y"
L["Font"] = "Шрифт"
L["FontSize"] = "Размер шрифта"
L["FontYOffset"] = "Смещение шрифта по Y"
L["FontYOffset"] = "Смещение шрифта по Y"
L["BackgroundAlpha"] = "Прозрачность фона"
L["TickAlpha"] = "Прозрачность делений"
L["Grow"] = "Направление роста"
L["TextGrow"] = "Рост текста"
L["VerticalLayout"] = "Вертикальное расположение"
L["FontAnchor"] = "Привязка шрифта"
L["TimeFontScale"] = "Масштаб шрифта времени"
L["ShowOnlyActive"] = "Показывать при активации"
L["ShowQueuedIcons"] = "Показывать иконки в очереди"
L["MaxAuras"] = "Макс. аур"
L["BorderScale"] = "Масштаб рамки"
L["ShowCountdownNumbers"] = "Показывать цифры отсчета"
L["CoTankAuras"] = "Ауры второго танка"
L["ShowCoTankAuras"] = "Показывать ауры второго танка"
L["HideBorder"] = "Скрыть рамку"
L["AutoGossip"] = "Авто-диалог"
L["Clear"] = "Очистить"
L["ClearAllRunes"] = "Очистить все руны"
L["Reverse"] = "Инвертировать"
L["ReverseOrder"] = "Обратный порядок"
L["Activate"] = "Открыть/Закрыть"
L["BackgroundOpacity"] = "Прозрачность фона"

-- MARK: Encounter Sound
L["EncounterSoundSettings"] = "Звук боссов"
L["EncounterSoundSettingsDesc"] = "Настройка и воспроизведение пользовательских звуковых оповещений для событий на таймлайне боссов и приватных аур.\n\n" ..
"Многие проблемы будут исправлены, а модуль улучшен по мере датамайнинга данных. Спасибо за ваши отзывы и поддержку!\n\n" ..
"Работа над этим модулем продолжается, и мы надеемся, что он сможет обеспечить более гибкие звуковые оповещения в боях с боссами.\n\n"

L["EncounterSettings"] = "Настройки событий боя"
L["SelectEncounter"] = "Выбрать босса"
L["SelectInstance"] = "Выбрать подземелье/рейд"
L["EncounterEventTrigger"] = "Триггер события боя"
L["EncounterEventSound"] = "Звук события боя"
L["OnTextWarningShown"] = "|cffff5c00Показ текстового предупреждения|r"
L["OnTextWarningShownDesc"] = ": срабатывает при первом появлении текстового предупреждения"
L["OnTimelineEventFinished"] = "|cffff5c00Завершение события|r"
L["OnTimelineEventFinishedDesc"] = ": срабатывает, когда событие завершается на таймлайне"
L["OnTimelineEventHighlight"] = "|cffff5c00Подсветка события|r"
L["OnTimelineEventHighlightDesc"] = ": срабатывает, когда до завершения события на таймлайне остается 5 секунд"
L["EventColor"] = "Цвет события"
L["PrivateAuraSettings"] = "Настройки приватной ауры"
L["EncounterEvent"] = "Событие боя"
L["SelectGroupRole"] = "Роль в группе"
L["EncounterSoundInstruction"] = "После выбора |cffffff00подземелья/рейда|r и |cffffff00босса|r ниже появятся соответствующие настройки для этого боя.\n\n"
L["EncounterEventsInstruction"] =
"|cffff0000ПРИМЕЧАНИЕ|r: Для работы соответствующих триггеров событий необходимо |cffffff00включить предупреждения боссов от Blizzard (включая текстовые предупреждения и таймлайн способностей боссов)|r.\n\n" ..
"|cffffff00Тест таймлайна|r: симулирует таймлайн для всех событий этого босса с интервалом в 6 секунд (не реальный таймлайн) для проверки правильности и эффекта настроек. Реальный триггер таймлайна работает иначе.\n\n" ..
"|cffff0000ПРИМЕЧАНИЕ|r: Тест таймлайна работает только с теми событиями, которые уже были настроены. Соответственно, |cffFF7C0Aесли для этого босса не настроено ни одно событие, тест таймлайна работать не будет|r.\n\n"
L["PrivateAuraInstruction"] = "Применяет звуковое оповещение для приватных аур. Звук воспроизводится, когда приватная аура накладывается на игрока (\"player\").\n\n"

-- MARK: Templates
L["TemplateSettings"] = "Шаблон"
L["SelectTemplate"] = "Выбрать шаблон"
L["TemplateNameNew"] = "Новый шаблон"
L["ApplyTemplate"] = "Применить шаблон"
L["TemplateDesc"] = "Быстрое применение шаблонов настроек для событий боя."

-- MARK: Lura Runes
L["AssisstantToBroadcast"] = "Только для уполномоченных"
L["AssisstantToBroadcastDesc"] = "Только лидер рейда и его помощники имеют право отправлять объявления."
L["LuraHelperSettings"] = "Помощник: Л'ура"
L["UndoLastRune"] = "Отменить последнюю руну"
L["LuraHelperSettingsDesc"] = "Модуль отправки объявлений для боя с Л'урой (3183)"
L["LuraHelperInstruction"] = "Связь между пользователями сильно зависит от каналов чата (/рейд и /объявление_рейда) из-за явных ограничений со стороны Blizzard на межмодификационную передачу данных.\n" ..
"Этот модуль загружается автоматически при начале боя с боссом или может быть включен вручную на панели конфигурации.\n" ..
"Кнопки рун и кнопка отмены отображаются только у лидера рейда или его помощников.\n" ..
"Чтобы избежать некорректных сообщений, пожалуйста, не пишите лишнего в следующие каналы чата: |cffFF7F00рейд|r/|cffFF4800объявление рейда|r\n\n"

-- MARK: Contributors
L["Contributors"] = "Авторы и помощники"
L["data correction"] = "Исправление данных"
L["testing"] = "Тестирование"
L["feedbacks"] = "Отзывы и багрепорты"
L["configuration sharing"] = "Обмен конфигурациями"
L["ThanksTo"] = "Благодарность за вклад следующим участникам:"
L["AnonymousContributors"] = "\nТакже выражаем благодарность многим другим пользователям, которые присылали исправления данных, отчеты об ошибках и свои предложения."
L["ContributeData"] = "Если вы хотите поделиться данными или сообщить о проблемах, пожалуйста, используйте GitHub или канал Discord! Вы можете найти ссылки в разделе «Контакты», при этом по возможности рекомендуется использовать Pull Request (PR).\n" ..
"Если вы хотите помочь улучшить данные, вы можете использовать команду \"|cff8788ee/hbes dev|r\", чтобы открыть панель инструментов разработчика. Там находится вкладка «Data Fetch», которая предоставляет инструменты для сбора игровых данных в формате CSV, и вы можете отправить их нам при необходимости. Большое спасибо!\n"
