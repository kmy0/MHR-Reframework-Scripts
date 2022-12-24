local config_menu = {}
local config
local timer

config_menu.window_flags = 0x10120
config_menu.window_pos = Vector2f.new(400, 200)
config_menu.window_pivot = Vector2f.new(0, 0)
config_menu.window_size = Vector2f.new(560, 600)
config_menu.is_opened = false

local dps_relative = {'First Hit','Quest Time','Join Time','Active Combat'}
local dps_target = {'Target','All'}

function config_menu.draw()
    imgui.set_next_window_pos(config_menu.window_pos, 1 << 3, config_menu.window_pivot)
    imgui.set_next_window_size(config_menu.window_size, 1 << 3)

   	config_menu.is_opened = imgui.begin_window("QuestTimer "..config.version,config_menu.is_opened, config_menu.window_flags)

	if not config_menu.is_opened then
		imgui.end_window()
		return
	end

    _,config.current.show_timer = imgui.checkbox('Show Quest Timer', config.current.show_timer)
    _,config.current.show_hp = imgui.checkbox('Show Monster HP', config.current.show_hp)
    _,config.current.show_dps = imgui.checkbox('Show DPS', config.current.show_dps)
    _,config.current.test = imgui.checkbox('Test', config.current.test)
    _,config.current.bg = imgui.checkbox('Show Background', config.current.bg)
    _,config.current.font_size = imgui.slider_int('Font size (reqs script restart)', config.current.font_size, 1, 100)
    _,config.current.xpos = imgui.slider_int('X Pos', config.current.xpos, 0, timer.draw.x)
    _,config.current.ypos = imgui.slider_int('Y Pos', config.current.ypos, 0, timer.draw.y)

    if imgui.tree_node("DPS Options") then
    	_,config.current.dps_relative = imgui.combo('DPS Calc',config.current.dps_relative,dps_relative)
    	_,config.current.dps_target = imgui.combo('DPS Dealt To',config.current.dps_target,dps_target)
    	imgui.tree_pop()
    end
    if imgui.tree_node("Timer Options") then
        _,config.current.show_ms = imgui.checkbox('Show Miliseconds', config.current.show_ms)
        imgui.tree_pop()
    end
    if imgui.tree_node("Font color") then
    	_,config.current.font_color = imgui.color_picker_argb('',config.current.font_color)
    	imgui.tree_pop()
    end
    if imgui.tree_node("BG color") then
    	_,config.current.bg_color = imgui.color_picker_argb('',config.current.bg_color)
    	imgui.tree_pop()
    end
    if imgui.tree_node("Border color") then
    	_,config.current.border_color = imgui.color_picker_argb('',config.current.border_color)
    	imgui.tree_pop()
    end

end


function config_menu.init()
	config = require("QuestTimer.config")
	timer = require("QuestTimer.timer")
end

return config_menu