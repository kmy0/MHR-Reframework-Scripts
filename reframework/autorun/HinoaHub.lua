local config = {
    enabled=true
}
local name = 'HinoaHub'
local config_path = name .. '/config.json'
local version = '1.0.3'
local original = false
local current_area = nil
local village_area_man = nil
local lobbyman = nil
local scene = sdk.call_native_func(sdk.get_native_singleton("via.SceneManager"), sdk.find_type_definition("via.SceneManager"), "get_CurrentScene()")


local function get_village_area_man()
    if not village_area_man then
        village_area_man = sdk.get_managed_singleton('snow.VillageAreaManager')
    end
    return village_area_man
end

function get_lobbyman()
    if not lobbyman then
        lobbyman = sdk.get_managed_singleton('snow.LobbyManager')
    end
    return lobbyman
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

local function get_component(game_object, type_name)
    local t = sdk.typeof(type_name)

    if t == nil then
        return nil
    end

    return game_object:call("getComponent(System.Type)", t)
end


load_config()
original = config.enabled
if get_village_area_man() then
    current_area = get_village_area_man():get__CurrentAreaNo()
end


re.on_frame(
    function()
        if (
            village_area_man
            and current_area == 0
            and (
                 config.enabled
                 and original
                 or (
                     not config.enabled
                     and not original
                 )
            )
        ) then
            local game_object = scene:call("findGameObject(System.String)", 'nid002')
            if game_object then
                local access_pop_marker = get_component(game_object, 'snow.access.ObjectPopMarker')
                if config.enabled then
                    access_pop_marker._Category = 3
                    original = false
                else
                    access_pop_marker._Category = 2
                    original = true
                end
            end
        end
    end
)

sdk.hook(
    sdk.find_type_definition('snow.VillageAreaManager'):get_method('onDestroy'),
    function()
        village_area_man = nil
        current_area = nil
        original = true
    end
)

sdk.hook(
    sdk.find_type_definition('snow.VillageAreaManager'):get_method('callAfterAreaActivation'),
    function()
        current_area = get_village_area_man():get__CurrentAreaNo()
        original = config.enabled
    end
)

sdk.hook(
    sdk.find_type_definition('snow.LobbyManager'):get_method('createRoom'),
    function()
    end,
    function()
        if config.enabled and current_area == 0 then
            sdk.get_managed_singleton('snow.gui.fsm.questcounter.GuiQuestCounterFsmManager'):set_field('<QuestCounterType>k__BackingField',0)
        end
    end
)

sdk.hook(
    sdk.find_type_definition('snow.gui.fsm.questcounter.GuiQuestCounterFsmCreateQuestSessionAction'):get_method('setQuestInfoToQuestManager'),
    function()
    end,
    function()
        if config.enabled and current_area == 0 and not get_lobbyman():isOnline() then
            sdk.get_managed_singleton('snow.gui.fsm.questcounter.GuiQuestCounterFsmManager'):set_field('<QuestCounterType>k__BackingField',0)
        end
    end
)

re.on_draw_ui(
    function()
        if imgui.button(name .. " " .. version) then
            config.enabled = not config.enabled
            original = config.enabled
            save_config()
        end
        imgui.same_line()
        imgui.text('Status: ' .. (config.enabled and 'Enabled' or 'Disabled'))
    end
)
