local config = {
    last_boss_clouds=false,
    music_override=false,
    random=false
}
local version = '1.0.2'
local config_path = 'ElgadoClouds/config.json'
local window = {
    flags=0x10120,
    pos=Vector2f.new(50, 50),
    pivot=Vector2f.new(0, 0),
    size=Vector2f.new(200, 200),
    condition=1 << 3,
    is_opened=false
}

local condition_id = 0
local village_dark_id = 21

local musicman = nil


local function get_musicman()
    if not musicman then
        musicman = sdk.get_managed_singleton('snow.wwise.WwiseMusicManager')
    end
    return musicman
end

local function load_config()
    local loaded_config = json.load_file(config_path)
    if loaded_config then
        config = loaded_config
    end
end

local function save_config()
    json.dump_file(config_path, config)
end

local function draw()
    imgui.set_next_window_pos(window.pos, window.condition, window.pivot)
    imgui.set_next_window_size(window.size, window.condition)

    window.is_opened = imgui.begin_window("ElgadoClouds " .. version, window.is_opened, window.flags)

    if not window.is_opened then
        imgui.end_window()
        save_config()
        return
    end

    imgui.text('Status: ' .. (config.last_boss_clouds and 'Dark' or 'Standard'))
    _,config.music_override = imgui.checkbox('Override Music', config.music_override)
    _,config.random = imgui.checkbox('Randomize', config.random)

    if imgui.is_item_hovered() then
        imgui.set_tooltip('Randomize on quest return')
    end

    if imgui.button("Change Clouds") then
        config.last_boss_clouds = not config.last_boss_clouds

        local village_stage_manager = sdk.get_managed_singleton('snow.stage.VillageStageManager')
        if village_stage_manager then
            local village_weather_controller_list = village_stage_manager._VillageWeatherControllerList

            if village_weather_controller_list.mSize > 0 then
                local village_weather_controller = village_weather_controller_list:get_Item(0)
                village_weather_controller:requestReload()

                if config.last_boss_clouds then
                    get_musicman()._IsSerious = true
                else
                    get_musicman()._IsSerious = false
                end

                get_musicman():onChangeVillageSpace(get_musicman()._CurrentVillageSpace)
            end
        end
    end
    imgui.end_window()
end


load_config()


sdk.hook(
    sdk.find_type_definition('snow.progress.userdata.ProgressConditionBookUserData'):get_method('isTrueProgressCondition'),
    function(args)
        condition_id = sdk.to_int64(args[3])
    end,
    function(retval)
        if condition_id == village_dark_id then
            return sdk.to_ptr(config.last_boss_clouds)
        else
            return retval
        end
    end
)

sdk.hook(
    sdk.find_type_definition('snow.wwise.WwiseMusicManager'):get_method('onChangeVillageSpace'),
    function()
    end,
    function()
        if config.last_boss_clouds and not config.music_override then
            get_musicman()._IsSerious = false
        end
    end
)

sdk.hook(
    sdk.find_type_definition('snow.VillageState'):get_method('.ctor'),
    function()
        if config.random then
            local bool = {true,false}
            config.last_boss_clouds = bool[math.random(#bool)]
            save_config()
        end
    end
)

re.on_draw_ui(
    function()
        if imgui.button("ElgadoClouds " .. version) then
            window.is_opened = not window.is_opened
        end
    end
)

re.on_frame(
    function()
        if not reframework:is_drawing_ui() then
            window.is_opened = false
        end

        if window.is_opened then
            pcall(draw)
        end
    end
)

re.on_script_reset(save_config)
