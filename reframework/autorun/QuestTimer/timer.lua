local timer = {}

local config
local singletons

timer.draw = {}

local monsters = {
	big={},
	all={},
    current_target=nil,
    final_update=false,
}
local times = {
    join=0,
    first_hit=nil,
    combat={
        start=0,
        periods={}
    },
}


local function is_quest_target(enemy)
    local enemy_type = enemy:get_field("<EnemyType>k__BackingField")
    local target_types = singletons.questman:getQuestTargetEmTypeList()
    if target_types then
        local target_count = target_types:get_Count()
        for i = 0, target_count-1 do
            local target_type = target_types:get_Item(i)
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
    local vit_param = enemy:get_field("<PhysicalParam>k__BackingField"):getVital(0, 0)
    local max_hp = vit_param:get_Max()
    monsters.big[enemy] = {
        quest_target=is_quest_target(enemy),
        max_hp=max_hp,
        current_hp=vit_param:get_Current(),
        combat=enemy:get_IsCombatMode(),
        first_hit_time=nil,
        combat_start_time=nil,
        last_combat_end_hp=max_hp,
        combat_start_hp=nil,
        current_active_dps=0,
        current_quest_dps=0,
        current_join_dps=0,
        current_first_hit_dps=0,
        combat_times={},
        dead=false,
        on_map=true,
        last_update=false,
        final_active_dps=nil
    }
end

local function calc_dps(hp_dif, time_dif)
    if hp_dif > 0 then
        return math.floor((hp_dif / math.floor(time_dif)) * 10) / 10
    else
        return 0
    end
end

local function sum(t)
    local sum = 0
    for _, v in pairs(t) do
        sum = sum + v
    end
    return sum
end

local function is_player_in_combat()
    for _, enemy in pairs(monsters.big) do
        if enemy.combat and not enemy.dead then
            return true
        end
    end
    return false
end

local function isinf(n) return tostring(n) == 'inf' end

local function update_monster_data(enemy, last_update)
    local hp = nil
    local queststatus = singletons.questman:get_field("_QuestStatus")
    local is_combat = nil

    if queststatus == 3 or last_update then

        if monsters.big[enemy].quest_target then
            monsters.big[enemy].dead = true
            hp = 0.0
        else
            hp = monsters.big[enemy].current_hp
        end

        is_combat = false
        monsters.big[enemy].combat = is_combat

    else

        monsters.big[enemy].dead = enemy:checkDie()
        monsters.big[enemy].on_map = enemy:isDispIconMiniMap()
        hp = enemy:get_field("<PhysicalParam>k__BackingField"):getVital(0, 0):get_Current()
        is_combat = enemy:get_IsCombatMode()

    end

    monsters.big[enemy].current_hp = hp
    monsters.big[enemy].current_quest_dps = calc_dps(
        monsters.big[enemy].max_hp - hp,
        math.floor(singletons.questman:getQuestElapsedTimeSec())
    )
    monsters.big[enemy].current_join_dps = calc_dps(
        monsters.big[enemy].max_hp - hp,
        math.floor(singletons.questman:getQuestElapsedTimeSec() - times.join)
    )

    if monsters.big[enemy].first_hit_time then
        local time_dif = math.floor(
            singletons.questman:getQuestElapsedTimeSec()
            - monsters.big[enemy].first_hit_time
        )
        monsters.big[enemy].current_first_hit_dps = calc_dps(
            monsters.big[enemy].max_hp - hp,
            time_dif
        )
    end

    if (
        not monsters.big[enemy].combat
        and is_combat
        or (
            monsters.big[enemy].combat
            and is_combat
            and not monsters.big[enemy].combat_start_hp
        )
    ) then

        monsters.big[enemy].combat_start_time = singletons.questman:getQuestElapsedTimeSec()

        if not monsters.big[enemy].first_hit_time then
            monsters.big[enemy].first_hit_time = monsters.big[enemy].combat_start_time
        end

        if not times.first_hit then
            times.first_hit = monsters.big[enemy].combat_start_time
        end

        if not is_player_in_combat() then
            times.combat.start = monsters.big[enemy].combat_start_time
        end

        monsters.big[enemy].combat_start_hp = monsters.big[enemy].last_combat_end_hp
        monsters.big[enemy].combat = is_combat

    elseif (
        monsters.big[enemy].combat
        and not is_combat
        or monsters.big[enemy].dead
    ) then

        monsters.big[enemy].combat = is_combat
        local time_dif = math.floor(
            singletons.questman:getQuestElapsedTimeSec()
            - monsters.big[enemy].combat_start_time
        )
        table.insert(
            monsters.big[enemy].combat_times,
            time_dif
        )

        if not is_player_in_combat() then
            local time_dif = math.floor(
                singletons.questman:getQuestElapsedTimeSec()
                - times.combat.start
            )
            table.insert(
                times.combat.periods,
                time_dif
            )
        end

        monsters.big[enemy].last_combat_end_hp = hp
        monsters.big[enemy].combat_start_time = nil
        monsters.big[enemy].current_dps = nil
        monsters.big[enemy].combat_start_hp = nil

    elseif (
        monsters.big[enemy].combat
        and monsters.big[enemy].combat_start_hp
        and is_combat
    ) then

        local time_dif = math.floor(
            singletons.questman:getQuestElapsedTimeSec()
            - monsters.big[enemy].combat_start_time
        )
        monsters.big[enemy].current_active_dps = calc_dps(
            monsters.big[enemy].combat_start_hp - hp,
            time_dif
        )

    end

    if monsters.big[enemy].dead then
        monsters.big[enemy].final_active_dps = calc_dps(
            monsters.big[enemy].max_hp,
            sum(monsters.big[enemy].combat_times)
        )
    end

    if (
        monsters.big[enemy].dead
        or not monsters.big[enemy].on_map
        or queststatus == 3
    ) then
        monsters.big[enemy].last_update = true
    end
end

local function enemy_update(args)
    if (
        not config.current.show_hp
        and not config.current.show_dps
        or singletons.questman:get_field("_QuestStatus") ~= 2
    ) then
        return
    end

    local enemy = sdk.to_managed_object(args[2])

    if not monsters.all[enemy] then
        monsters.all[enemy] = true
        if enemy:get_isBossEnemy() then
            init_monster_data(enemy)
        end
    end

    if (
        monsters.big[enemy]
        and (
             not monsters.big[enemy].dead
             or (
                 monsters.big[enemy].dead
        	     and not monsters.big[enemy].last_update
             )
        )
    ) then
		update_monster_data(enemy, false)
    end

    local highlight_id = singletons.guiman:get_refGuiHud_TgCamera():get_field("OldTargetingEmIndex")

    if highlight_id ~= -1 then
        monsters.current_target = singletons.enemyman:getBossEnemy(highlight_id)
        while monsters.current_target:checkDie() or not monsters.current_target:isDispIconMiniMap() do
            highlight_id = highlight_id + 1
            local other_target = singletons.enemyman:getBossEnemy(highlight_id)
            if not other_target then
                return
            else
                monsters.current_target = other_target
            end
        end
    else
        monsters.current_target = nil
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

local function time_to_string(time, show_ms)
    local rtime = math.floor(time)
    local ms = int_to_string(math.floor((time - rtime) * 100))
    local m = int_to_string(math.floor(rtime / 60 ))
    local s = int_to_string(rtime - ( m * 60 ))
    if show_ms then
        return m .. ':' .. s .. '.' .. ms
    else
        return m .. ':' .. s
    end
end

local function get_dps()
    local dps = 0
    local key = nil
    local active_time = nil
    local queststatus = singletons.questman:get_field("_QuestStatus")

    if config.current.dps_relative == 1 then
        key = 'current_first_hit_dps'
    elseif config.current.dps_relative == 2 then
        key = 'current_quest_dps'
    elseif config.current.dps_relative == 3 then
        key = 'current_join_dps'
    elseif config.current.dps_relative == 4 then
        key = 'current_active_dps'
    end

    if queststatus == 2 then
        if config.current.dps_target == 1 and monsters.current_target then
            if monsters.big[monsters.current_target].quest_target then
                dps = monsters.big[monsters.current_target][key]
            end
        elseif config.current.dps_target == 2 then
            for _, enemy in pairs(monsters.big) do
                if enemy.quest_target and not enemy.dead then
                    dps = dps + enemy[key]
                elseif enemy.quest_target and enemy.dead then
                    if key == 'current_active_dps' then
                        dps = dps + enemy.final_active_dps
                    else
                        if key == 'current_first_hit_dps' then
                            dps = dps + calc_dps(enemy.max_hp, singletons.questman:getQuestElapsedTimeSec() - times.first_hit)
                        elseif key == 'current_quest_dps' then
                            dps = dps + calc_dps(enemy.max_hp, singletons.questman:getQuestElapsedTimeSec())
                        elseif key == 'current_join_dps' then
                            dps = dps + calc_dps(enemy.max_hp, singletons.questman:getQuestElapsedTimeSec() - times.join)
                        end
                    end
                end
            end
        end

    elseif queststatus == 3 then
        local total_hp = 0
        local time = 0
        for _, enemy in pairs(monsters.big) do
            if enemy.quest_target then
                total_hp = total_hp + enemy.max_hp
            end
        end

        if config.current.dps_relative == 2 then
            time = singletons.questman:getQuestElapsedTimeSec()
        else
            if config.current.dps_relative == 4 then
                time = sum(times.combat.periods)
            elseif config.current.dps_relative == 3 then
                time = singletons.questman:getQuestElapsedTimeSec() - times.join
            elseif config.current.dps_relative == 1 then
                time = singletons.questman:getQuestElapsedTimeSec() - times.first_hit
            end
            active_time = time
        end
        dps = calc_dps(total_hp, time)
    end
    return active_time, dps
end

local function get_string(test)
    local strings = {}
    local string_ = ''
    local queststatus = singletons.questman:get_field("_QuestStatus")

    if config.current.show_village and queststatus == 0 then
        if config.current.show_timer then
            local s = '00:00'
            if config.current.show_ms then
                s = '00:00.00'
            end
            table.insert(
                    strings,
                    s
                    )
        end
        if config.current.show_hp then
            table.insert(
                    strings,
                    '00000'
                    )
        end
        if config.current.show_dps then
            table.insert(
                    strings,
                    '00.00'
                    )

        end
    else
        if config.current.show_timer then
            local show_ms = config.current.show_ms
            if singletons.questman:get_field("_QuestStatus") == 3 then
                show_ms = true
            end
            table.insert(
                    strings,
                    time_to_string(singletons.questman:getQuestElapsedTimeSec(), show_ms)
                    )
        end

        if (
            config.current.show_hp
            and monsters.current_target
            and monsters.big[monsters.current_target].current_hp ~= 0
            and queststatus ~= 3
        ) then
            table.insert(
                    strings,
                    math.floor(monsters.big[monsters.current_target].current_hp)
                    )
        end
        if config.current.show_dps then
            local active_time, dps = get_dps()
            if active_time then
                table.insert(
                        strings,
                        time_to_string(active_time, config.current.show_ms)
                        )
            end
            if dps and dps ~= 0 and not isinf(dps) then
                table.insert(
                        strings,
                        dps
                        )
            end
        end
    end

    for i, s in ipairs(strings) do
        if i > 1 then
            string_ = string_..'\n'..s
        else
            string_ = s
        end
    end
    return string_
end

local function last_update()
    for enemy, v in pairs(monsters.big) do
        if not v.last_update then
            update_monster_data(enemy, true)
        end
    end
    monsters.final_update = true
end

local function display()
    if (
        not config.current.show_timer
        and not config.current.show_hp
        and not config.current.show_dps
        and not config.current.show_village
        or singletons.questman:get_field("_QuestUIFlow") == 1
    ) then
        return false
    end

    local guihud = singletons.guiman:get_field('<refGuiHud>k__BackingField')
    if guihud and not guihud:get_field('_IsPartVisible') then
        return false
    end

    local queststatus = singletons.questman:get_field("_QuestStatus")
    local questendflow = singletons.questman:get_field("_EndFlow")

    if (
        queststatus == 2
        or (
            queststatus == 3
            and questendflow < 8
        ) or (
              config.current.show_village
              and singletons.spacewatcher:get_field('_GameState') == 4
        )
    ) then
        return true
    else
        monsters = {
            big={},
            all={},
            current_target=nil,
            final_update=false,
        }
        times = {
            join=0,
            first_hit=nil,
            combat={
                start=0,
                times={}
            },
        }
        return false
    end
end


sdk.hook(sdk.find_type_definition("snow.enemy.EnemyCharacterBase"):get_method("update"),
    function(args) enemy_update(args) end
)

sdk.hook(sdk.find_type_definition("snow.QuestManager"):get_method("questStart"),
    function(args)
        times.join = singletons.questman:getQuestElapsedTimeSec()
    end
)


d2d.register(
    function()
        timer.draw.font = d2d.Font.new('Consolas', config.current.font_size)
        timer.draw.x, timer.draw.y = d2d.surface_size()
    end,
    function()

        if singletons.questman and display() then
            if singletons.questman:get_field("_QuestStatus") == 3 and not monsters.final_update then
                last_update()
            end

            timer.draw.text = get_string(config.current.test)
            timer.draw.bg_w, timer.draw.bg_h = timer.draw.font:measure(timer.draw.text)
            timer.draw.text_h = select(2, string.gsub(timer.draw.text, '\n', "")) + 1
            timer.draw.bg_w_offset = timer.draw.bg_h / timer.draw.text_h / 3

            if config.current.bg then
                d2d.fill_rect(
                    config.current.xpos-timer.draw.bg_w_offset/2,
                    config.current.ypos,
                    timer.draw.bg_w+timer.draw.bg_w_offset,
                    timer.draw.bg_h,
                    config.current.bg_color
                )
                d2d.outline_rect(
                    config.current.xpos-timer.draw.bg_w_offset/2,
                    config.current.ypos,
                    timer.draw.bg_w+timer.draw.bg_w_offset,
                    timer.draw.bg_h,
                    4,
                    config.current.border_color
                )
            end

            d2d.text(
                timer.draw.font,
                timer.draw.text,
                config.current.xpos,
                config.current.ypos,
                config.current.font_color
            )
        end
    end
)

function timer.init()
	singletons = require("QuestTimer.singletons")
	config = require("QuestTimer.config")
end

return timer
