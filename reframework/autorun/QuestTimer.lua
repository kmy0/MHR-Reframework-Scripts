local questman = nil
local guiman = nil
local enemyman = nil

local phys_param_field = nil
local get_vit = nil
local check_die = nil
local is_on_map = nil
local is_big = nil
local get_vital = nil
local get_max = nil
local get_cur = nil
local camera = nil

local display = false
local final_update_done = false
local test = nil
local x,y = nil
local img_w,img_h = nil

local target_indexes = nil
local current_target = nil

local highlight_id = -1
local line_count = 0
local known_big_monsters = {}
local known_all_monsters = {}
local active_combat_times = {
                        start_time=0,
                        times={}
                        }

local settings = {
                bg=true,
                bg_color=2248146944.0,
                border_color=3366295651.0,
                color=4291480266.0,
                show_active_dps=true,
                show_dps=true,
                show_highlighted_dps=false,
                show_hp=true,
                show_timer=true,
                size=30.0,
                xpos=188.0,
                ypos=169.0
                }


local function load_settings()
    local l_settings = json.load_file('QuestTimer_settings.json')
    if l_settings then
        settings = l_settings
    end
end


load_settings()


local function get_questman()
    if not questman then
        questman = sdk.get_managed_singleton('snow.QuestManager')
    end
    return questman
end

local function get_quest_status()
    return get_questman():get_field("_QuestStatus")
end


if get_questman() and (get_quest_status() == 2 or get_quest_status() == 3) then return end 


local function get_guiman()
    if not guiman then
        guiman = sdk.get_managed_singleton('snow.gui.GuiManager')
    end
    return guiman
end

local function get_enemyman()
    if not enemyman then
        enemyman = sdk.get_managed_singleton("snow.enemy.EnemyManager")
    end
    return enemyman
end

local function get_target(i)
    return get_enemyman():call("getBossEnemy", i)
end

local function get_camera()
    if not camera then
        camera = sdk.find_type_definition("snow.gui.GuiManager"):get_method("get_refGuiHud_TgCamera")
    end
    return camera
end

local function get_highlight()
    local target_camera = get_camera():call( get_guiman() )
    local target_indexes = get_camera():get_return_type():get_field("OldTargetingEmIndex")
    return target_indexes:get_data(target_camera)
end

local function get_time()
    return get_questman():call('getQuestElapsedTimeSec')
end

local function get_quest_endflow()
    return get_questman():get_field("_EndFlow")
end

local function get_methods()
    local ecb_type = sdk.find_type_definition("snow.enemy.EnemyCharacterBase")
    phys_param_field = ecb_type:get_field("<PhysicalParam>k__BackingField")
    local phys_param_type = phys_param_field:get_type()
    get_vit = phys_param_type:get_method("getVital")
    check_die = ecb_type:get_method("checkDie")
    is_on_map = ecb_type:get_method("isDispIconMiniMap")
    is_big = ecb_type:get_method("get_isBossEnemy")
    local vital_type = get_vit:get_return_type()
    get_max = vital_type:get_method("get_Max")
    get_cur = vital_type:get_method("get_Current")
end

local function sum(t)
    local sum = 0
    for k,v in pairs(t) do
        sum = sum + v
    end
    return sum
end

local function display()
    if not settings.show_timer and not settings.show_hp and not settings.show_dps then return false end
    local queststatus = get_quest_status()
    local questendflow = get_quest_endflow()

    if queststatus == 2 or queststatus == 3 and questendflow < 8 or test then 
        return true 
    else
        current_hp = nil
        dps = 0
        highlight_id = -1
        known_big_monsters = {}
        known_all_monsters = {} 
        active_combat_times = {
                        start_time=0,
                        times={}
                        } 
        final_update_done = false
        known_big_monsters_names = {}  
        return false
    end
end

local function int_to_string(int)
    local num = tostring(int)
    if string.len(num) == 1 then
        return '0' .. num
    else
        return num
    end
end

local function transform_time(time)
    time = math.floor(time)
    local m = int_to_string(math.floor(time / 60 ))
    local s = int_to_string(time - ( m * 60 ))
    return m .. ':' .. s
end

local function calc_dps(hp_dif,time_dif)
    if hp_dif > 0 then
        return math.floor( ( hp_dif / math.floor( time_dif )) * 10 ) / 10
    else
        return 0
    end
end

local function is_quest_target(enemy)
    local enemy_type = enemy:get_field("<EnemyType>k__BackingField")
    local target_types = get_questman():call("getQuestTargetEmTypeList")
    if target_types then
        local target_count = target_types:call("get_Count")
        for i = 0, target_count-1 do
            local target_type = target_types:call("get_Item", i)
            if target_type == enemy_type then
                if target_type ~= 0 then
                    return true
                else
                    return false
                end
            end
        end
    end
end

local function init_monster_data(enemy)
    local phys_param = phys_param_field:get_data(enemy)
    local vit_param = get_vit:call(phys_param, 0, 0)
    local max_hp = get_max:call(vit_param)
    known_big_monsters[enemy] = {
                        is_quest_target=is_quest_target(enemy),
                        max_hp=max_hp,
                        cur_hp=get_cur:call(vit_param),
                        is_in_combat=enemy:call("get_IsCombatMode"),
                        combat_start_time=nil,
                        last_combat_end_hp=max_hp,
                        combat_start_hp=nil,
                        cur_active_dps=0,
                        cur_quest_dps=0,
                        combat_times={},
                        is_dead=false,
                        is_on_map=true,
                        last_update=false,
                        final_active_dps=nil
                        }

end

local function is_player_in_combat()
    local combat = false
    for i,enemy in pairs(known_big_monsters) do
        if enemy['is_in_combat'] and not enemy['is_dead'] then
            combat = true
            break
        end
    end
    return combat
end

local function update_monster_data(enemy)
    local hp = nil
    local quest_status = get_quest_status()
    local is_combat = nil

    if quest_status == 3 then

        if known_big_monsters[enemy]['is_quest_target'] then
            known_big_monsters[enemy]['is_dead'] = true
            hp = 0.0
        else
            hp = known_big_monsters[enemy]['cur_hp']
        end

        is_combat = false
        known_big_monsters[enemy]['is_in_combat'] = is_combat

    else

        known_big_monsters[enemy]['is_dead'] = check_die:call(enemy)
        known_big_monsters[enemy]['is_on_map'] = is_on_map:call(enemy)
        local phys_param = phys_param_field:get_data(enemy)
        local vit_param = get_vit:call(phys_param, 0, 0)
        hp = get_cur:call(vit_param)
        is_combat = enemy:call("get_IsCombatMode")

    end

    known_big_monsters[enemy]['cur_hp'] = hp
    known_big_monsters[enemy]['cur_quest_dps'] = calc_dps(
                                                known_big_monsters[enemy]['max_hp'] - hp,
                                                math.floor(get_time())
                                                )   

    if not known_big_monsters[enemy]['is_in_combat'] and is_combat then

        known_big_monsters[enemy]['combat_start_time'] = get_time()

        if not is_player_in_combat() then
            active_combat_times['start_time'] = known_big_monsters[enemy]['combat_start_time']
        end

        known_big_monsters[enemy]['combat_start_hp'] = known_big_monsters[enemy]['last_combat_end_hp']
        known_big_monsters[enemy]['is_in_combat'] = is_combat

    elseif known_big_monsters[enemy]['is_in_combat'] and not is_combat or known_big_monsters[enemy]['is_dead'] then

        known_big_monsters[enemy]['is_in_combat'] = is_combat
        table.insert(
                known_big_monsters[enemy]['combat_times'],
                math.floor( get_time() - known_big_monsters[enemy]['combat_start_time'] )
                )

        if not is_player_in_combat() then
            table.insert(
                    active_combat_times['times'],
                    math.floor( get_time() - active_combat_times['start_time'] )
                    )
        end

        known_big_monsters[enemy]['last_combat_end_hp'] = hp
        known_big_monsters[enemy]['combat_start_time'] = nil
        known_big_monsters[enemy]['cur_dps'] = nil
        known_big_monsters[enemy]['combat_start_hp'] = nil

    elseif known_big_monsters[enemy]['is_in_combat'] and is_combat then

        known_big_monsters[enemy]['cur_active_dps'] = calc_dps(
                                                known_big_monsters[enemy]['combat_start_hp'] - hp,
                                                math.floor( get_time() - known_big_monsters[enemy]['combat_start_time'] )
                                                ) 

    end

    if known_big_monsters[enemy]['is_dead'] then
        known_big_monsters[enemy]['final_active_dps'] = calc_dps(
                                            known_big_monsters[enemy]['max_hp'],
                                            sum(known_big_monsters[enemy]['combat_times'])
                                            )
    end

    if known_big_monsters[enemy]['is_dead'] or not known_big_monsters[enemy]['is_on_map'] or quest_status == 3 then
        known_big_monsters[enemy]['last_update'] = true
    end

end

local function get_dps()
    local dps = 0
    local key = nil
    local active_time = 0
    local quest_status = get_quest_status()
    if settings.show_active_dps then key = 'cur_active_dps' else key = 'cur_quest_dps' end
    if quest_status == 2 then
        if settings.show_highlighted_dps and current_target then
            if known_big_monsters[current_target]['is_quest_target'] then
                dps = known_big_monsters[current_target][key]
            end
        elseif not settings.show_highlighted_dps then
            for i,enemy in pairs(known_big_monsters) do
                if enemy['is_quest_target'] and not enemy['is_dead'] then
                    dps = dps + enemy[key]
                elseif enemy['is_quest_target'] and enemy['is_dead'] then
                    if key == 'cur_active_dps' then
                        dps = dps + enemy['final_active_dps']
                    else
                        dps = dps + calc_dps(enemy['max_hp'],get_time())
                    end

                end
            end
        end

    elseif quest_status == 3 then
        local total_hp = 0
        local time = 0
        for i,enemy in pairs(known_big_monsters) do
            if enemy['is_quest_target'] then
                total_hp = total_hp + enemy['max_hp']
            end
        end
        if settings.show_active_dps then 
            time = sum(active_combat_times['times']) 
            active_time = time
        else 
            time = get_time()
            active_time = 0

        end
        dps = calc_dps(total_hp,time)
    end
    return active_time,dps  
end

local function enemy_update(args)
    if not settings.show_hp and not settings.show_dps or get_quest_status() ~= 2 then return args end
    if not check_die then get_methods() end
    local enemy = sdk.to_managed_object(args[2])
    if not known_all_monsters[enemy] then
        known_all_monsters[enemy] = 1
        if is_big:call(enemy) then
            init_monster_data(enemy)
        end
    end

    if known_big_monsters[enemy] then
        if not known_big_monsters[enemy]['is_dead'] or (known_big_monsters[enemy]['is_dead'] and not known_big_monsters[enemy]['last_update']) then
            update_monster_data(enemy)
        end
    else
        return args 
    end

    highlight_id = get_highlight() 

    if highlight_id ~= -1 then
        current_target = get_target(highlight_id)

        while check_die:call(current_target) or not is_on_map:call(current_target) do
            local ct = get_target(highlight_id)
            if ct == nil then return args else current_target = ct end
            highlight_id = highlight_id + 1
        end

        if enemy == current_target then
            current_hp = known_big_monsters[enemy]['cur_hp']
        end
        
    else
        current_target = nil
        current_hp = nil
    end

    return args
end

local function check_for_line(str)
    if line_count > 0 then
        return str .. '\n'
    else
        return str
    end
end

local function isinf(n) return tostring(n) == 'inf' end

local function get_string()
    local string_ = ''
    if settings.show_timer then
        string_ = transform_time(get_time())
        line_count = line_count + 1
    end
    if settings.show_hp and highlight_id ~= -1 and current_hp ~= 0 and get_quest_status() ~= 3 then
        string_ = check_for_line(string_) .. math.floor(current_hp)
        line_count = line_count + 1
    end
    if settings.show_dps then
        active_time,dps = get_dps()
        if active_time and active_time ~= 0 then
            string_ = check_for_line(string_) .. transform_time(active_time)
            line_count = line_count + 1
        end
        if dps and dps ~= 0 and not isinf(dps) then
            string_ = check_for_line(string_) .. dps
        end
    end
    line_count = 0
    return string_
end

local function run_last_update()
    for enemy,v in pairs(known_big_monsters) do
        if not v['last_update'] then
            update_monster_data(enemy)
        end
    end
    final_update_done = true
end

local function get_test_string()
    local string_=''
    if settings.show_timer then
        string_ = "00:00"
        line_count = line_count + 1
    end
    if settings.show_hp then
        string_ = check_for_line(string_) .. '00000'
        line_count = line_count + 1
    end
    if settings.show_dps then
        string_ = check_for_line(string_) .. '000.0'
    end
    line_count = 0
    return string_
end




sdk.hook(sdk.find_type_definition("snow.enemy.EnemyCharacterBase"):get_method("update"),
    function(args)
        enemy_update(args)
    end,
    function(retval) return retval 
end)


d2d.register(function()
    font = d2d.Font.new('Consolas', settings.size)
    x,y = d2d.surface_size()
end,
function()
    if display() then
        if get_quest_status() == 3 and not final_update_done then run_last_update() end
        if test then
            text = get_test_string()
        else
            text = get_string()
        end
        bg_w,bg_h = font:measure(text)
        if settings.bg then d2d.fill_rect(settings.xpos-8, settings.ypos+1, bg_w+15, bg_h, settings.bg_color) end
        if settings.bg then d2d.outline_rect(settings.xpos-8, settings.ypos+1, bg_w+15, bg_h, 3, settings.border_color) end
        d2d.text(font,text, settings.xpos, settings.ypos, settings.color)  
    end
end)


re.on_draw_ui(function()
    if imgui.tree_node("QuestTimer") then
        _,settings.show_timer = imgui.checkbox('Show Quest Timer', settings.show_timer)
        _,settings.show_hp = imgui.checkbox('Show Monster HP', settings.show_hp)
        _,settings.show_dps = imgui.checkbox('Show DPS', settings.show_dps)
        _,test = imgui.checkbox('Test', test)
        _,settings.bg = imgui.checkbox('Show Background', settings.bg)
        _,settings.size = imgui.slider_int('Font size (reqs script restart)', settings.size, 1, 100)
        _,settings.xpos = imgui.slider_int('X Pos', settings.xpos, 0, x)
        _,settings.ypos = imgui.slider_int('Y Pos', settings.ypos, 0, y)
        if imgui.tree_node("DPS Options") then
            _,settings.show_active_dps = imgui.checkbox('Show dps based of active combat time', settings.show_active_dps)
            _,settings.show_highlighted_dps = imgui.checkbox('Show current dps only to highligthed target', settings.show_highlighted_dps)
        end
        if imgui.tree_node("Font color") then _,settings.color = imgui.color_picker_argb('',settings.color) end
        if imgui.tree_node("BG color") then _,settings.bg_color = imgui.color_picker_argb('',settings.bg_color) end
        if imgui.tree_node("Border color") then _,settings.border_color = imgui.color_picker_argb('',settings.border_color) end
    end
end
)

re.on_config_save(function()
    json.dump_file('QuestTimer_settings.json', settings)
end)
