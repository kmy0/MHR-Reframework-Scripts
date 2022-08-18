local playman = nil
local longshellman = nil
local bowgunshellman = nil
local hornshellman = nil
local vilman = nil
local questman = nil
local chatman = nil
local guiman = nil

local timer_font_color = nil
local border_color = nil
local timer_font = nil
local name_font = nil
local bg_h,bg_w = nil
local bg_x,bg_y = nil
local name_font_color = nil
local prog_bar_color = nil
local hide_all_timers = false
local background_offset = 6

local weapon = nil
local weapon_name = nil
local master_player = nil
local reload_wirebug_skills = false
local reload_weapon = false
local wire_skills = nil
local prev_quest_status = nil
local quest_status = nil

local timer_count = 0
local max_frame_count = 3

local rising_moon = nil
local setting_sun = nil
local wyverheart_loaded_flag = false
local prev_twin_vine_t = 0
local prev_rising_moon_time = 0
local prev_setting_sun_time = 0
local prev_wb = 0

local settings = {
                enabled=true,
                bg=true,
                border=true,
                pulse=true,
                pulse_color=4294124580,
                pulse_interval=30,
                show_minutes=true,
                hide_when_expired=false,
                hide_when_quest_hidden=true,
                pulse_below=10,
                stack_direction=2,
                bg_color=2248146944,
                border_pulse=true,
                border_color=3366295651,
                timer_font_color=4291480266,
                show_miss=true,
                show_milli=true,
                show_notif=true,
                show_miss_on_name=true,
                show_miss_on_border=true,
                pulse_name=true,
                pulse_border=true,
                miss_color=4294124580,
                bar_type=1,
                prog_bar_height=28,
                prog_bar_width=201,
                prog_bar_color=4291480266,
                size=40,
                xpos=219,
                ypos=282,
                only_active=false,
                show_name=true,
                timer_stack=1,
                border_thick=3,
                timer_space=9,
                name_place=4,
                name_font_color=4291480266,
                name_size=20,
                ['Power Sheathe']=true,
                ['Switch Charger']=true,
                ['Harvest Moon']=true,
                ['Fanning Maneuver']=true,
                ['Setting Sun']=true,
                ['Rising Moon']=true,
                ['Impact Burst']=true,
                ['Ground Splitter']=true,
                ['Anchor Rage']=true,
                ['Twin Vine']=true,
                ['Destroyer Oil']=true,
                ['Ironshine Silk']=true,
                ['Silkbind Shockwave']=true,
                ['Bead of Resonance']=true,
                ['Sonic Bloom']=true,
                ['Herculean Draw']=true,
                ['Bolt Boost']=true,
                ['Amp State']=true,
                ['Shield Charge']=true,
                ['Sword Charge']=true,
                ['Spirit Gauge Lv']=true,
                ['RWO']=true,
                ['Red']=true,
                ['White']=true,
                ['Orange']=true,
                ["Wyvern's Fire"]=true,
                ["Wyvernblast"]=true,
                ["Special Ammo"]=true,
                }

local pulse_direction = {}
local pulse_frame_count = {}
local timers_bg = {}
local timers = {}
local prog_bars_time_start = {}
local notification = {}
local expired_skill_frame_count = {}
local ignore_frame_count = {["Wyvernblast 1"]=true,["Wyvernblast 2"]=true,["Wyvernblast 3"]=true}
local prev_ig_buff_state = {['Red']=false,['White']=false,['Orange']=false,}
local wire_skills_type_ids = {
                [1]='A',
                [2]='B',
                [3]='C',
                [4]='D',
                [5]='E',
                [6]='F'
                }
local weapon_type_ids = {
                    [0]='GreatSword',
                    [1]='SlashAxe',
                    [2]='LongSword',
                    [3]='LightBowgun',
                    [4]='HeavyBowgun',
                    [5]='Hammer',
                    [6]='GunLance',
                    [7]='Lance',
                    [8]='ShortSword',
                    [9]='DualBlades',
                    [10]='Horn',
                    [11]='ChargeAxe',
                    [12]='InsectGlaive',
                    [13]='Bow',
                    }
local weapon_skill_fields = {
            GreatSword={
                    [1]={
                        skill_type='wirebug',
                        type='F',
                        equipped_val=0,
                        name='Power Sheathe',
                        field='MoveWpOffBuffGreatSwordTimer',
                        field_type='weapon'
                        }
                    },
            SlashAxe={
                    [1]={
                        skill_type='wirebug',
                        type='F',
                        equipped_val=0,
                        name='Switch Charger',
                        field='_NoUseSlashGaugeTimer',
                        field_type='weapon'
                        },
                    [2]={
                        skill_type='weapon',
                        name='Amp State',
                        field='_BottleAwakeDurationTimer',
                        field_type='weapon'
                        }
                    },
            LongSword={
                    [1]={
                        skill_type='wirebug',
                        type='F',
                        equipped_val=1,
                        name='Harvest Moon',
                        field='_lifeTimer',
                        field_type='shell'
                        },
                    [2]={
                        skill_type='weapon',
                        name='Spirit Gauge Lv',
                        field='_LongSwordGaugeLvTimer',
                        field_type='weapon'
                        },
                    },
            LightBowgun={
                    [1]={
                        skill_type='wirebug',
                        type='C',
                        equipped_val=1,
                        name='Fanning Maneuver',
                        field='LightBowgunWireBuffTimer',
                        field_type='weapon'
                        },
                    [2]={
                        skill_type='cooldown',
                        name="Wyvernblast",
                        }
                    },
            HeavyBowgun={
                    [1]={
                        skill_type='wirebug',
                        type='F',
                        equipped_val=1,
                        name='Setting Sun',
                        field='_Timer',
                        field_type='shell'
                        },
                    [2]={
                        skill_type='wirebug',
                        type='E',
                        equipped_val=1,
                        name='Rising Moon',
                        field='_Timer',
                        field_type='shell'
                        },
                    [3]={
                        skill_type='cooldown',
                        name="Special Ammo",
                        }
                    },
            Hammer={
                [1]={
                    skill_type='wirebug',
                    type='F',
                    equipped_val=1,
                    name='Impact Burst',
                    field='_ImpactPullsTimer',
                    field_type='weapon'
                    }
                },
            GunLance={
                    [1]={
                        skill_type='wirebug',
                        type='B',
                        equipped_val=1,
                        name='Ground Splitter',
                        field='_ShotDamageUpDurationTimer',
                        field_type='weapon'
                        },
                    [2]={
                        skill_type='cooldown',
                        name="Wyvern's Fire",
                        }
                    },
            Lance={
                [1]={
                    skill_type='wirebug',
                    type='A',
                    equipped_val=0,
                    name='Anchor Rage',
                    field='_GuardRageTimer',
                    field_type='weapon'
                },
                [2]={
                    skill_type='wirebug',
                    type='F',
                    equipped_val=0,
                    name='Twin Vine',
                    field='_lifeTimer',
                    field_type='shell'
                    }
                },
            ShortSword={
                    [1]={
                        skill_type='wirebug',
                        type='E',
                        equipped_val=1,
                        name='Destroyer Oil',
                        field='_OilBuffTimer',
                        field_type='weapon'
                        }
                    },
            DualBlades={
                    [1]={
                        skill_type='wirebug',
                        type='F',
                        equipped_val=1,
                        name='Ironshine Silk',
                        field='SharpnessRecoveryBuffValidTimer',
                        field_type='weapon'
                        }
                    },
            Horn={
                [1]={
                    skill_type='wirebug',
                    type='F',
                    equipped_val=1,
                    name='Silkbind Shockwave',
                    field='_ImpactPullsTimer',
                    field_type='weapon'
                    },
                [2]={
                    skill_type='wirebug',
                    type='C',
                    equipped_val=1,
                    name='Bead of Resonance',
                    field='_lifeTimer',
                    field_type='shell'
                    },
                [3]={
                    skill_type='wirebug',
                    type='E',
                    equipped_val=1,
                    name='Sonic Bloom',
                    field='_lifeTimer',
                    field_type='shell'
                    }
                },
            ChargeAxe={
                    [1]={
                        skill_type='weapon',
                        name='Shield Charge',
                        field='_ShieldBuffTimer',
                        field_type='weapon'
                        },
                    [2]={
                        skill_type='wirebug',
                        type='A',
                        equipped_val=0,
                        name='Sword Charge',
                        field='_SwordBuffTimer',
                        field_type='weapon'
                        },
                    },
            InsectGlaive={
                    [1]={
                        skill_type='weapon',
                        name='RWO',
                        field='_RedExtractiveTime',
                        field_type='weapon'
                        },
                    [2]={
                        skill_type='weapon',
                        name='Red',
                        field='_RedExtractiveTime',
                        field_type='weapon'
                        },
                    [3]={
                        skill_type='weapon',
                        name='White',
                        field='_WhiteExtractiveTime',
                        field_type='weapon'
                        },
                    [4]={
                        skill_type='weapon',
                        name='Orange',
                        field='_OrangeExtractiveTime',
                        field_type='weapon'
                        },
                    },
            Bow={
                [1]={
                    skill_type='wirebug',
                    type='F',
                    equipped_val=0,
                    name='Herculean Draw',
                    field='_WireBuffAttackUpTimer',
                    field_type='weapon'
                    },
                [2]={
                    skill_type='wirebug',
                    type='F',
                    equipped_val=1,
                    name='Bolt Boost',
                    field='_WireBuffArrowUpTimer',
                    field_type='weapon'
                    },
                }
            }

local function load_settings()
    local l_settings = json.load_file('WeaponTimers_settings.json')
    if l_settings then
        settings = l_settings
    end
end


load_settings()


local function get_guiman()
    if not guiman then
        guiman = sdk.get_managed_singleton('snow.gui.GuiManager')
    end
    return guiman
end

local function get_playman()
    if not playman then
        playman = sdk.get_managed_singleton('snow.player.PlayerManager')
    end
    return playman
end

local function get_chatman()
    if not chatman then
        chatman = sdk.get_managed_singleton('snow.gui.ChatManager')
    end
    return chatman
end

local function get_vilman()
    if not vilman then
        vilman = sdk.get_managed_singleton('snow.VillageAreaManager')
    end
    return vilman
end

local function get_longshellman()
    if not longshellman then
        longshellman = sdk.get_managed_singleton('snow.shell.LongSwordShellManager')
    end
    return longshellman
end

local function get_hornshellman()
    if not hornshellman then
        hornshellman = sdk.get_managed_singleton('snow.shell.HornShellManager')
    end
    return hornshellman
end

local function get_bowgunshellman()
    if not bowgunshellman then
        bowgunshellman = sdk.get_managed_singleton('snow.shell.LightBowgunShellManager')
    end
    return bowgunshellman
end

local function get_questman()
    if not questman then
        questman = sdk.get_managed_singleton('snow.QuestManager')
    end
    return questman
end

local function get_master_player()
    return get_playman():call("findMasterPlayer")
end

local function reload_player_skills(args)
    reload_wirebug_skills = true
end

local function reload_player_weapon(args)
    reload_weapon = true
end

local function post_message(skill,type)
    if type ~= 'cooldown' then
        str = 'The skill <COL YEL>' .. skill .. '</COL>\nhas expired.'
    elseif skill == 'Wyvernheart' then
        str = 'The skill <COL YEL>' .. skill .. '</COL>\nis fully reloaded.'
    else
        str = 'The skill <COL YEL>' .. skill .. '</COL>\nis available.'
    end
    get_chatman():call("reqAddChatInfomation",str,2289944406)
end

local function split(inputstr, sep)
    if sep == nil then
        sep = "%s"
    end
    local t={}
    for str in string.gmatch(inputstr, "([^"..sep.."]+)") do
      table.insert(t, str)
    end
    return t
end

local function int_to_string(int)
    local num = tostring(int)
    local leadzero = '0'
    if string.match(num, "(%w+)%.") then
        str = split(num,'.')
        if not settings.show_minutes then
            leadzero = string.rep(leadzero,3 - string.len(str[1]))
        end
        if string.len(str[1]) == 1 or (not settings.show_minutes and string.len(str[1]) < 3) then
            str[1] = leadzero .. str[1]
        end
        if string.len(str[2]) == 1 then
            str[2] = str[2] .. '0'
        end
        return str[1] .. '.' .. str[2]
    else
        if not settings.show_minutes then
            leadzero = string.rep(leadzero,3 - string.len(num))
        end
        if string.len(num) == 1 or (not settings.show_minutes and string.len(num) < 3) then
            return leadzero .. num
        else
            return num
        end
    end
end

local function round(number, decimals)
    local scale = 10^decimals
    local c = 2^52 + 2^51
    return ((number * scale + c ) - c) / scale
end

local function get_player_weapon()
    if master_player then
        local weapon_id = master_player:get_field('_playerWeaponType')
        weapon_name = weapon_type_ids[weapon_id]
        weapon = sdk.find_type_definition('snow.player.' .. weapon_name)
    else
        weapon_name = nil
        weapon = nil
    end
end

local function transform_time(time)
    local m = 0
    if settings.show_minutes then
        m = int_to_string(math.floor(time / 60))
    end
    local s = nil
    if settings.show_milli then
        s = int_to_string(round( time - ( m * 60 ),2 ))
    else
        s = tostring(time - ( m * 60 ))
        if string.match(s, "(%w+)%.") then
            s = split(s,'.')[1]
        end
        s = int_to_string(s)
    end
    if settings.show_minutes then
        return m .. ':' .. s
    else
        return s
    end
end

local function get_harvest_t(field)
    if not get_longshellman() then return 0 end
    local list = get_longshellman():call('getMaseterLongSwordShell010s',master_player:get_field('_PlayerIndex'))
    if list:get_field('mSize') ~= 0 then
        local element = list:call('get_Item',0)
        if element then
            return element:get_field(field)
        else
            return 0
        end
    else
        return 0
    end
end

local function get_moon_sun_t(field,name)
    if not get_bowgunshellman() then return 0 end
    local list = nil
    local list_size = nil
    local t = nil

    if name == 'Rising Moon' then
        list = get_bowgunshellman():call('get_getLightBowgunShell030s_SpeedBoost')
        list_size = list:get_field('mSize')
        if list_size ~= 0 then
            rising_moon = list:call('get_Item',0)
            if rising_moon then
                if rising_moon:get_field('<IsEnableHit>k__BackingField') then
                    t = rising_moon:get_field(field)
                    prev_rising_moon_time = t
                    return t
                else
                    if round(prev_rising_moon_time,0) == 0 then
                        return 0
                    else
                        return prev_rising_moon_time
                    end
                end
            end
        else
            rising_moon = nil
            prev_rising_moon_time = 0
            return 0
        end
    elseif name == 'Setting Sun' then
        list = get_bowgunshellman():call('get_getLightBowgunShell030s_All') --Setting Sun + Rising Moon
        list_size = list:get_field('mSize')
        if list_size == 1 and not rising_moon
        or list_size > 1 then
            setting_sun = list:call('get_Item',0)
            if tostring(setting_sun) == tostring(rising_moon) then
                setting_sun = list:call('get_Item',1)
            end

            if setting_sun then
                if setting_sun:get_field('<IsEnableHit>k__BackingField') then
                    t = setting_sun:get_field(field)
                    prev_setting_sun_time = t
                    return t
                else
                    if round(prev_setting_sun_time,0) == 0 then
                        return 0
                    else
                        return prev_setting_sun_time
                    end
                end
            end
        else
            setting_sun = nil
            prev_setting_sun_time = 0
            return 0
        end
    end
end

local function get_twin_vine_t(field)
    local shell = weapon:get_field('_ChainDeathMatchShell'):get_data(master_player)
    if shell then
        local t = shell:get_field(field) / 60
        if t == prev_twin_vine_t and t ~= 0  then
            return 0
        else
            prev_twin_vine_t = t
            return t
        end
    else
        return 0
    end
end

local function get_cocoon_t(field,name)
    if not get_hornshellman() then return 0 end
    local shell_fields = {
                    ['Bead of Resonance']='_HornShell003s',
                    ['Sonic Bloom']='_HornShell020s'
                    }
    local list = get_hornshellman():get_field(shell_fields[name])
    list = list:get_element(0)
    if list:get_field('mSize') ~= 0 then
        list = list:get_field('mItems')
        element = list:get_element(0)
        if element then
            return element:get_field(field)
        else
            return 0
        end
    else
        return 0
    end
end

local function get_eq_wireskills()
    master_player = get_master_player()
    wire_skills = {A={},B={},C={},D={},E={},F={}}
    if master_player then
        if settings.only_active then
            local fields = {
                        _replaceAttackTypeA='A',
                        _replaceAttackTypeB='B',
                        _replaceAttackTypeC='C',
                        _replaceAttackTypeD='D',
                        _replaceAttackTypeE='E',
                        _replaceAttackTypeF='F'
                        }
            for f,k in pairs(fields) do
                local val = master_player:get_field(f)
                wire_skills[k][val] = true
            end
        else
            local set_data = master_player:get_field('_ReplaceAtkMysetHolder'):get_field('_ReplaceAtkMysetData')
            local sets = {set_data:call('get_Item',0),set_data:call('get_Item',1)}
            for i,set in pairs(sets) do
                local wire_skill_data = set:get_field('_ReplaceAtkTypes'):get_elements()
                for i,ws in pairs(wire_skill_data) do
                    wire_skills[ wire_skills_type_ids[i] ][ ws:get_field('value__') ] = true
                end
            end
        end
    end
end

local function RGBAfromInt(argb_int)
    blue =  argb_int & 255
    green = (argb_int >> 8) & 255
    red = (argb_int >> 16) & 255
    alpha = (argb_int >> 24) & 255
    return red, green, blue, alpha
end

local function ARBGintfromRGBA(red,green,blue,alpha)
    return (alpha<<24) + (red<<16) + (green<<8) + blue
end

local function transition(value, maximum, start_point, end_point)
    return start_point + (end_point - start_point)*value/maximum
end

local function transition3(value, maximum, s1, s2, s3, e1, e2, e3)
    r1= transition(value, maximum, s1, e1)
    r2= transition(value, maximum, s2, e2)
    r3= transition(value, maximum, s3, e3)
    return r1, r2, r3
end

local function pulse(color1,color2,id)
    local r1,g1,b1,a,r2,g2,b2,r,g,b = nil

    r1,g1,b1,a = RGBAfromInt(color1)
    r2,g2,b2,_ = RGBAfromInt(color2)
    r,g,b = transition3(pulse_frame_count[id],settings.pulse_interval,r1,g1,b1,r2,g2,b2)

    return ARBGintfromRGBA(math.floor(r),math.floor(g),math.floor(b),a)
end

local function create_timer(timer,timer_name,timer_count,id,hide,type)
    if timer == 0 or timer < 0 then

        if expired_skill_frame_count[id] and expired_skill_frame_count[id] < max_frame_count then expired_skill_frame_count[id] = expired_skill_frame_count[id] + 1 end

        if expired_skill_frame_count[id] == max_frame_count or not expired_skill_frame_count[id] or ignore_frame_count[timer_name] then
            if settings.show_notif then
                if notification[id] then
                    post_message(timer_name,type)
                    notification[id] = false
                end
            else
                if notification[id] then notification[id] = false end
            end

            if settings.show_miss and type ~= 'cooldown' then
                timer_font_color = settings.miss_color
                border_color = settings.miss_color
                prog_bar_color = settings.miss_color

                if settings.show_miss_on_name then
                    name_font_color = settings.miss_color
                else
                    name_font_color = settings.name_font_color
                end

                if settings.show_miss_on_border then
                    border_color = settings.miss_color
                else
                    border_color = settings.border_color
                end

            else
                timer_font_color = settings.timer_font_color
                border_color = settings.border_color
                name_font_color = settings.name_font_color
                prog_bar_color = settings.prog_bar_color
            end
        end
    elseif type == 'cooldown' and timer > 0 then

            if settings.show_miss then
                timer_font_color = settings.miss_color
                border_color = settings.miss_color
                prog_bar_color = settings.miss_color

                if settings.show_miss_on_name then
                    name_font_color = settings.miss_color
                else
                    name_font_color = settings.name_font_color
                end

                if settings.show_miss_on_border then
                    border_color = settings.miss_color
                else
                    border_color = settings.border_color
                end

            else
                timer_font_color = settings.timer_font_color
                border_color = settings.border_color
                name_font_color = settings.name_font_color
                prog_bar_color = settings.prog_bar_color
            end

    else
        timer_font_color = settings.timer_font_color
        border_color = settings.border_color
        name_font_color = settings.name_font_color
        prog_bar_color = settings.prog_bar_color
    end

    if hide then return end

    if settings.pulse and timer < settings.pulse_below and timer ~= 0 then

        if pulse_frame_count[id] == 0 then
            pulse_direction[id] = true
        elseif pulse_frame_count[id] == settings.pulse_interval or pulse_frame_count[id] > settings.pulse_interval then
            pulse_direction[id] = false
        end

        timer_font_color = pulse(settings.timer_font_color,settings.pulse_color,id)
        prog_bar_color = pulse(settings.prog_bar_color,settings.pulse_color,id)

        if settings.pulse_border then
            border_color = pulse(settings.border_color,settings.pulse_color,id)
        end

        if settings.pulse_name then
            name_font_color = pulse(settings.name_font_color,settings.pulse_color,id)
        end

        if pulse_direction[id] then
            pulse_frame_count[id] = pulse_frame_count[id] + 1
        else
            pulse_frame_count[id] = pulse_frame_count[id] - 1
        end

    else
        pulse_frame_count[id] = 0
        pulse_direction[id] = true
    end

    if timers_bg[id] then
        bg_x = timers_bg[id]['bg_x']
        bg_y = timers_bg[id]['bg_y']
        bg_w = timers_bg[id]['bg_w']
        bg_h = timers_bg[id]['bg_h']
        if settings.bg then d2d.fill_rect(bg_x, bg_y, bg_w + background_offset * 2, bg_h, settings.bg_color) end
        if settings.bg and settings.border then d2d.outline_rect(bg_x, bg_y, bg_w + background_offset * 2, bg_h, settings.border_thick, border_color) end
    end

    local offset = nil
    local name_x = nil
    local name_y = nil

    if settings.bar_type == 1 then
        local text_x = settings.xpos
        local text_y = settings.ypos
        local text = transform_time(timer)

        bg_w,bg_h = timer_font:measure(text)
        bg_x = settings.xpos - background_offset
        bg_y = settings.ypos + 1

        if settings.timer_stack == 1 then

            offset = (bg_h + settings.timer_space) * timer_count

            if settings.stack_direction == 2 then
                text_y = text_y + offset
                bg_y = bg_y + offset
            else
                text_y = text_y - offset
                bg_y = bg_y - offset
            end

        elseif settings.timer_stack == 2 then

            offset = (bg_w + background_offset * 2 + settings.timer_space) * timer_count

            if settings.stack_direction == 2 then
                text_x = text_x + offset
                bg_x = bg_x + offset
            else
                text_x = text_x - offset
                bg_x = bg_x - offset
            end

        end

        d2d.text(timer_font,text, text_x, text_y, timer_font_color)

    elseif settings.bar_type == 2 then

        local rect_w = nil
        local rect_x = nil
        local rect_y = nil

        if prog_bars_time_start[id] ~= 0 then
            rect_w = settings.prog_bar_width * ( ( ( timer * 100 ) / prog_bars_time_start[id]) / 100 )
        else
            rect_w = 0
        end

        rect_x = settings.xpos
        rect_y = settings.ypos
        bg_w = settings.prog_bar_width
        bg_h = settings.prog_bar_height + background_offset * 2
        bg_x = settings.xpos-background_offset
        bg_y = settings.ypos-background_offset

        if settings.timer_stack == 1 then

            offset = (bg_h + settings.timer_space) * timer_count
            if settings.stack_direction == 2 then
                bg_y = bg_y + offset
                rect_y = rect_y + offset
            else
                bg_y = bg_y - offset
                rect_y = rect_y - offset
            end

        elseif settings.timer_stack == 2 then

            offset = (bg_w + background_offset * 2 + settings.timer_space) * timer_count
            if settings.stack_direction == 1 then
                bg_x = bg_x + offset
                rect_x = rect_x + offset
            else
                bg_x = bg_x - offset
                rect_x = rect_x - offset
            end
        end

        d2d.fill_rect(rect_x, rect_y, rect_w, settings.prog_bar_height, prog_bar_color)
    end

    if not timers_bg[id] then timers_bg[id] = {} end

    timers_bg[id]['bg_x'] = bg_x
    timers_bg[id]['bg_y'] = bg_y
    timers_bg[id]['bg_w'] = bg_w
    timers_bg[id]['bg_h'] = bg_h

    if settings.show_name then
        local name_w,name_h = name_font:measure(timer_name)
        if settings.name_place == 1 then

            name_x = bg_x + bg_w / 2 - name_w / 2 + background_offset
            name_y = bg_y - name_h

        elseif settings.name_place == 2 then

            name_x = bg_x + bg_w / 2 - name_w / 2 + background_offset
            name_y = bg_y + bg_h

        elseif settings.name_place == 3 then

            name_x = bg_x - name_w - background_offset
            name_y = bg_y + bg_h / 2 - name_h / 2

        elseif settings.name_place == 4 then

            name_x = bg_x + bg_w + background_offset * 3
            name_y = bg_y + bg_h / 2 - name_h / 2
        elseif settings.name_place == 5 then

            name_x = bg_x + bg_w / 2 - name_w / 2 + background_offset
            name_y = bg_y + bg_h / 2 - name_h / 2
        end

        d2d.text(name_font,timer_name,name_x,name_y, name_font_color)
    end
end


sdk.hook(sdk.find_type_definition('snow.player.PlayerBase'):get_method('reflectReplaceAtkMyset'),reload_player_skills)
sdk.hook(sdk.find_type_definition('snow.player.PlayerReplaceAtkMysetHolder'):get_method('init'),reload_player_weapon)


re.on_frame(
        function()
            if get_playman() then master_player = get_master_player() end

            if get_playman() and not weapon or reload_weapon then
                get_player_weapon()
                reload_weapon = false
                reload_wirebug_skills = true
            end

            if get_playman() and not wire_skills or reload_wirebug_skills then
                get_eq_wireskills()
                reload_wirebug_skills = false
            end

            if get_questman() then
                prev_quest_status = quest_status
                quest_status = get_questman():get_field("_QuestStatus")
                if prev_quest_status ~= quest_status then
                    longshellman = nil
                    bowgunshellman = nil
                    hornshellman = nil
                end
            end

            local t = nil
            local ids = {}
            timers = {}
            if master_player and weapon and settings.enabled and ( quest_status == 2 or (get_vilman() and get_vilman():call('checkCurrentArea_TrainingArea') )) then

                if settings.hide_when_quest_hidden then
                    local gui_hud = get_guiman():get_field('<refGuiHud>k__BackingField')
                    if gui_hud then
                        local gui_state = gui_hud:get_field('_IsPartVisible')
                        hide_all_timers = not gui_state
                    else
                        hide_all_timers = true
                    end
                else
                    hide_all_timers = false
                end

                if weapon_skill_fields[weapon_name] then
                    for i,ws in ipairs(weapon_skill_fields[weapon_name]) do
                        local skill_name = ws['name']
                        local hide = false

                        if hide_all_timers then hide = true end

                        if not settings[skill_name] then
                            notification[i] = false
                            pulse_frame_count[i] = 0
                            goto continue
                        end

                        local skill_field = ws['field']
                        local field_type = ws['field_type']
                        local skill_type = ws['type']
                        local equipped_val = ws['equipped_val']

                        if ws['skill_type'] == 'wirebug' and wire_skills[ skill_type ][ equipped_val ]
                        or ws['skill_type'] == 'weapon'
                        or ws['skill_type'] == 'cooldown' then

                            if not expired_skill_frame_count[i] then expired_skill_frame_count[i] = 0 end

                            if field_type == 'weapon' then
                                local timer_field = weapon:get_field(skill_field)
                                if timer_field then
                                    t = timer_field:get_data(master_player) / 60
                                end

                            elseif field_type == 'shell' then
                                if weapon_name == 'LongSword' then
                                    t = get_harvest_t(skill_field)
                                elseif weapon_name == 'HeavyBowgun' then
                                    t = get_moon_sun_t(skill_field,skill_name)
                                elseif weapon_name == 'Lance' then
                                    t = get_twin_vine_t(skill_field)
                                elseif weapon_name == 'Horn' then
                                    t = get_cocoon_t(skill_field,skill_name)
                                end
                            elseif not field_type then
                                if weapon_name == 'GunLance' then
                                    t = weapon:get_method('get_ChargeDragonSlayCannonTime'):call(master_player)
                                elseif weapon_name == 'LightBowgun' then
                                    local cd = weapon:get_field('_WyvernBlastReloadTime'):get_data(master_player)
                                    local pd = master_player:call('get_PlayerData')
                                    local elapsed = pd:get_field('_WyvernBlastReloadTimer')
                                    local max_wb = weapon:get_field('_WyvernBlastGaugeMax'):get_data(master_player)
                                    local cur_wb = pd:get_field('_WyvernBlastGauge')

                                    if cur_wb > prev_wb then
                                        t = 0
                                        skill_name = skill_name .. ' ' .. prev_wb + 1
                                    elseif cur_wb == max_wb then
                                        t = 0
                                    else
                                        t = (cd - elapsed) / 60
                                        skill_name = skill_name .. ' ' .. cur_wb + 1
                                    end
                                    prev_wb = cur_wb
                                elseif weapon_name == 'HeavyBowgun' then
                                    local pd = master_player:call('get_PlayerData')
                                    local special_ammo = weapon:get_field('_SpecialBullet'):get_data(master_player)
                                    if special_ammo == 1 then
                                        t = pd:get_field('_HeavyBowgunWyvernSnipeTimer') / 60
                                        skill_name = 'Wyvernsnipe'
                                    elseif special_ammo == 50 then
                                        local cd = 300
                                        local max_bullet = weapon:get_field('_SpecialBulletMax'):get_data(master_player)
                                        local cur_bullet = pd:get_field('_HeavyBowgunWyvernMachineGunBullet')
                                        local elapsed = pd:get_field('_HeavyBowgunWyvernMachineGunTimer')

                                        if max_bullet == cur_bullet then
                                            t = 0
                                        else
                                            t = ((max_bullet - cur_bullet) * cd - (cd - elapsed)) / 60
                                        end

                                        skill_name = 'Wyvernheart'
                                    end
                                end
                            end

                            if weapon_name == 'LongSword' and skill_name == 'Spirit Gauge Lv' then
                                local lvl = weapon:get_field("_LongSwordGaugeLv"):get_data(master_player)
                                if lvl ~= 0 then skill_name = skill_name .. ' ' .. lvl end
                            elseif weapon_name == 'InsectGlaive' then
                                local all_ig_buff_state = weapon:get_method('isGetAllExtractive'):call(master_player)
                                if settings['RWO'] and all_ig_buff_state then
                                    if skill_name ~= 'RWO' then
                                        hide = true
                                        notification[i] = false
                                        pulse_frame_count[i] = 0
                                        goto continue
                                    end
                                elseif skill_name == 'RWO' and not settings['Red'] and not settings['White'] and not settings['Orange'] then
                                    hide = false
                                elseif skill_name == 'RWO' then
                                    hide = true
                                end
                                if all_ig_buff_state and not prev_ig_buff_state[skill_name] then
                                    prog_bars_time_start[i] = t
                                    notification[i] = true
                                    expired_skill_frame_count[i] = 0
                                    pulse_frame_count[i] = 0
                                end
                                prev_ig_buff_state[skill_name] = all_ig_buff_state
                            end

                            if not t then t = 0 end

                            if t == 0 then

                                prog_bars_time_start[i] = t
                                if settings.hide_when_expired then hide = true end

                            elseif prog_bars_time_start[i] == 0
                            or not prog_bars_time_start[i]
                            or t > prog_bars_time_start[i] then

                                prog_bars_time_start[i] = t
                                notification[i] = true
                                expired_skill_frame_count[i] = 0
                                pulse_frame_count[i] = 0

                            end

                            table.insert(timers,{timer=t,name=skill_name,id=i,hide=hide,type=ws['skill_type']})

                            ids[i] = true

                        end
                        ::continue::
                    end
                end
            end

            for i,v in pairs(notification) do
                if not ids[i] then notification[i] = false end
            end

        end
)

d2d.register(
    function()
        timer_font = d2d.Font.new('Consolas', settings.size)
        name_font = d2d.Font.new('Consolas', settings.name_size)
        timer_font_color = settings.timer_font_color
        name_font_color = settings.name_font_color
        prog_bar_color = settings.prog_bar_color
        border_color = settings.border_color
        x,y = d2d.surface_size()
    end,
    function()
        if settings.enabled and ( (get_questman() and get_questman():get_field("_QuestStatus") == 2) or (get_vilman() and get_vilman():call('checkCurrentArea_TrainingArea') ) ) then
            local hide_count = 0
            for i,timer in pairs(timers) do

                if timer['hide'] then
                    hide_count = hide_count + 1
                end
            end

            for i,timer in pairs(timers) do
                local timer_count = i-1-hide_count
                if timer_count < 0 then timer_count = 0 end
                create_timer(timer['timer'],timer['name'],timer_count,timer['id'],timer['hide'],timer['type'])
            end
        end
    end
)


re.on_draw_ui(function()
    if imgui.tree_node("Weapon Timers") then
        if settings.timer_stack == 1 then
            stack_direction_list = {'Up','Down'}
        elseif settings.timer_stack == 2 then
            stack_direction_list = {'Left','Right'}
        end

        _,settings.enabled = imgui.checkbox('Enabled', settings.enabled)
        _,settings.bar_type = imgui.combo('Bar Type',settings.bar_type,{'Timer','Progress Bar'})
        _,settings.bg = imgui.checkbox('Show Background', settings.bg)
        _,settings.show_name = imgui.checkbox('Show Skill Name', settings.show_name)
        _,settings.show_miss = imgui.checkbox('Show Expired Color', settings.show_miss)
        _,settings.show_notif = imgui.checkbox('Show Chat Notification', settings.show_notif)
        _,settings.hide_when_expired = imgui.checkbox('Hide When Expired', settings.hide_when_expired)
        _,settings.hide_when_quest_hidden = imgui.checkbox('Hide When Quest Hud is Hidden', settings.hide_when_quest_hidden)
        _,settings.pulse = imgui.checkbox('Pulse when near expiration', settings.pulse)
        changed,settings.only_active = imgui.checkbox('Only show bars for skills from active scroll', settings.only_active)
        _,settings.xpos = imgui.slider_int('X Pos', settings.xpos, 0, x)
        _,settings.ypos = imgui.slider_int('Y Pos', settings.ypos, 0, y)
        if imgui.tree_node("Skill Options") then
            if imgui.tree_node("Great Sword") then
                _,settings['Power Sheathe'] = imgui.checkbox('Power Sheathe', settings['Power Sheathe'])
                imgui.tree_pop()
            end
            if imgui.tree_node("Switch Axe") then
                _,settings['Switch Charger'] = imgui.checkbox('Switch Charger', settings['Switch Charger'])
                _,settings['Amp State'] = imgui.checkbox('Amp State', settings['Amp State'])
                imgui.tree_pop()
            end
            if imgui.tree_node("Long Sword") then
                _,settings['Harvest Moon'] = imgui.checkbox('Harvest Moon', settings['Harvest Moon'])
                _,settings['Spirit Gauge Lv'] = imgui.checkbox('Spirit Gauge Lv', settings['Spirit Gauge Lv'])
                imgui.tree_pop()
            end
            if imgui.tree_node("Light Bowgun") then
                _,settings['Fanning Maneuver'] = imgui.checkbox('Fanning Maneuver', settings['Fanning Maneuver'])
                _,settings['Wyvernblast'] = imgui.checkbox('Wyvernblast', settings['Wyvernblast'])
                imgui.tree_pop()
            end
            if imgui.tree_node("Heavy Bowgun") then
                _,settings['Setting Sun'] = imgui.checkbox('Setting Sun', settings['Setting Sun'])
                _,settings['Rising Moon'] = imgui.checkbox('Rising Moon', settings['Rising Moon'])
                _,settings['Special Ammo'] = imgui.checkbox('Special Ammo', settings['Special Ammo'])
                imgui.tree_pop()
            end
            if imgui.tree_node("Hammer") then
                _,settings['Impact Burst'] = imgui.checkbox('Impact Burst', settings['Impact Burst'])
                imgui.tree_pop()
            end
            if imgui.tree_node("Gun Lance") then
                _,settings['Ground Splitter'] = imgui.checkbox('Ground Splitter', settings['Ground Splitter'])
                _,settings["Wyvern's Fire"] = imgui.checkbox("Wyvern's Fire", settings["Wyvern's Fire"])
                imgui.tree_pop()
            end
            if imgui.tree_node("Lance") then
                _,settings['Anchor Rage'] = imgui.checkbox('Anchor Rage', settings['Anchor Rage'])
                _,settings['Twin Vine'] = imgui.checkbox('Twin Vine', settings['Twin Vine'])
                imgui.tree_pop()
            end
            if imgui.tree_node("Sword and Shield") then
                _,settings['Destroyer Oil'] = imgui.checkbox('Destroyer Oil', settings['Destroyer Oil'])
                imgui.tree_pop()
            end
            if imgui.tree_node("Dual Blades") then
                _,settings['Ironshine Silk'] = imgui.checkbox('Ironshine Silk', settings['Ironshine Silk'])
                imgui.tree_pop()
            end
            if imgui.tree_node("Hunting Horn") then
                _,settings['Silkbind Shockwave'] = imgui.checkbox('Silkbind Shockwave', settings['Silkbind Shockwave'])
                _,settings['Bead of Resonance'] = imgui.checkbox('Bead of Resonance', settings['Bead of Resonance'])
                _,settings['Sonic Bloom'] = imgui.checkbox('Sonic Boom', settings['Sonic Bloom'])
                imgui.tree_pop()
            end
            if imgui.tree_node("Charge Blade") then
                _,settings['Sword Charge'] = imgui.checkbox('Sword Charge', settings['Sword Charge'])
                _,settings['Shield Charge'] = imgui.checkbox('Shield Charge', settings['Shield Charge'])
                imgui.tree_pop()
            end
            if imgui.tree_node("Insect Glaive") then
                _,settings['RWO'] = imgui.checkbox('RWO', settings['RWO'])
                _,settings['Red'] = imgui.checkbox('Red', settings['Red'])
                _,settings['White'] = imgui.checkbox('White', settings['White'])
                _,settings['Orange'] = imgui.checkbox('Orange', settings['Orange'])
                imgui.tree_pop()
            end
            if imgui.tree_node("Bow") then
                _,settings['Herculean Draw'] = imgui.checkbox('Herculean Draw', settings['Herculean Draw'])
                _,settings['Bolt Boost'] = imgui.checkbox('Bolt Boost', settings['Bolt Boost'])
                imgui.tree_pop()
            end
            imgui.tree_pop()
        end
        if imgui.tree_node("Bar Options") then
            _,settings.timer_stack = imgui.combo('Bar Stacking',settings.timer_stack,{'Vertical','Horizontal'})
            _,settings.stack_direction = imgui.combo('Stack Direction',settings.stack_direction,stack_direction_list)
            _,settings.timer_space = imgui.slider_int('Spacing Between Bars', settings.timer_space, 1, 1000)
            _,settings.show_miss_on_name = imgui.checkbox('Show Expired Color On Name', settings.show_miss_on_name)
            _,settings.show_miss_on_border = imgui.checkbox('Show Expired Color On Border', settings.show_miss_on_border)
            if imgui.tree_node("Expired color") then
                _,settings.miss_color = imgui.color_picker_argb('',settings.miss_color)
                imgui.tree_pop()
            end
            imgui.tree_pop()
        end
        if imgui.tree_node("Timer Options") then
            _,settings.show_milli = imgui.checkbox('Show Milliseconds', settings.show_milli)
            _,settings.show_minutes = imgui.checkbox('Show Minutes', settings.show_minutes)
            _,settings.size = imgui.slider_int('Timer Font Size (reqs script restart)', settings.size, 1, 500)
            if imgui.tree_node("Timer Font Color") then
                _,settings.timer_font_color = imgui.color_picker_argb('',settings.timer_font_color)
                imgui.tree_pop()
            end
            imgui.tree_pop()
        end
        if imgui.tree_node("Skill Name Options") then
            _,settings.name_place = imgui.combo('Skill Name Placement',settings.name_place,{'Top','Bottom','Left','Right','Center'})
            _,settings.name_size = imgui.slider_int('Name Font Size (reqs script restart)', settings.name_size, 1, 500)
            if imgui.tree_node("Name Font Color") then
                _,settings.name_font_color = imgui.color_picker_argb('',settings.name_font_color)
                imgui.tree_pop()
            end
            imgui.tree_pop()
        end
        if imgui.tree_node("Progress Bar Options") then
            _,settings.prog_bar_height = imgui.slider_int('Progress Bar Height', settings.prog_bar_height, 1, 1000)
            _,settings.prog_bar_width = imgui.slider_int('Progress Bar Width', settings.prog_bar_width, 1, 1000)
            if imgui.tree_node("Progress Bar Color") then
                _,settings.prog_bar_color = imgui.color_picker_argb('',settings.prog_bar_color)
                imgui.tree_pop()
            end
            imgui.tree_pop()
        end
        if imgui.tree_node("Background Options") then
            _,settings.border = imgui.checkbox('Show Border', settings.border)
            _,settings.border_thick = imgui.slider_int('Border Thickness', settings.border_thick, 1, 10)
            if imgui.tree_node("BG Color") then
                _,settings.bg_color = imgui.color_picker_argb('',settings.bg_color)
                imgui.tree_pop()
            end
            if imgui.tree_node("Border Color") then
                _,settings.border_color = imgui.color_picker_argb('',settings.border_color)
                imgui.tree_pop()
            end
            imgui.tree_pop()
        end
        if imgui.tree_node("Pulse Options") then
            _,settings.pulse_name = imgui.checkbox('Pulse Name', settings.pulse_name)
            _,settings.border_pulse = imgui.checkbox('Pulse Border', settings.border_pulse)
            _,settings.pulse_below = imgui.slider_int('Pulse Threshold', settings.pulse_below, 1, 60)
            _,settings.pulse_interval = imgui.slider_int('Pulse Interval', settings.pulse_interval, 2, 500)
            if imgui.tree_node("Pulse Color") then
                _,settings.pulse_color = imgui.color_picker_argb('',settings.pulse_color)
                imgui.tree_pop()
            end
            imgui.tree_pop()
        end
        if changed then reload_wirebug_skills = true end
        imgui.tree_pop()
    end
end
)

re.on_config_save(function()
    json.dump_file('WeaponTimers_settings.json', settings)
end)
