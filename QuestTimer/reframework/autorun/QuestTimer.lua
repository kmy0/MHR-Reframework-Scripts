local singletons = require("QuestTimer.singletons")
local config = require("QuestTimer.config")
local config_menu = require("QuestTimer.config_menu")
local timer = require("QuestTimer.timer")
local table_helpers = require("QuestTimer.table_helpers")


singletons.init()
config.init()
config_menu.init()
timer.init()


re.on_draw_ui(function()
    if imgui.button("QuestTimer "..config.version) then
        config_menu.is_opened = not config_menu.is_opened
    end
end
)

re.on_frame(function()
    singletons.init()

    if not reframework:is_drawing_ui() then
        config_menu.is_opened = false
    end

    if config_menu.is_opened then
        pcall(config_menu.draw)
    end
end
)

re.on_config_save(function()
    config.save()
end
)