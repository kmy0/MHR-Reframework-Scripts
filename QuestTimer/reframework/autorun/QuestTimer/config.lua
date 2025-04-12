local config = {}

local table_helpers

config.config_file_name = 'QuestTimer/config.json'
config.version = '1.0.2'

config.default={
    bg=true,
    bg_color=2248146944.0,
    border_color=3366295651.0,
    font_color=4291480266.0,
    show_dps=true,
    show_ms=true,
    show_hp=true,
    show_timer=true,
    font_size=30.0,
    xpos=188.0,
    ypos=169.0,
    dps_relative=1,
    dps_target=1,
    show_village=false,
}


function config.load()
    local loaded_config = json.load_file(config.config_file_name)
    if loaded_config then
        config.current = table_helpers.merge(config.default, loaded_config)
    else
        config.current = table_helpers.deep_copy(config.default)
    end
end

function config.save()
    json.dump_file(config.config_file_name, config.current)
end

function config.init()
    table_helpers = require("QuestTimer.table_helpers")
    config.load()
end

return config