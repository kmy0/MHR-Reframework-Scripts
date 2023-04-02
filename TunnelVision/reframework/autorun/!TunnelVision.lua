local name = 'TunnelVision'
local version = '1.0'

local config = {
    current={
        combo=1
    },
    path=name .. '/config.json'
}
local combo = {
    'Enabled',
    'Disabled',
    'When monster is in combat',
    'When player is targeted'
}
local counter = 0


function config.load()
    local loaded_config = json.load_file(config.path)
    if loaded_config then
        config.current = loaded_config
    end
end

function config.save()
    json.dump_file(config.config, config.current)
end


sdk.hook(
    sdk.find_type_definition('snow.enemy.EnemyCharacterBase'):get_method('setTarget(snow.enemy.EnemyDef.EnemyTargetType, System.Int32, System.Boolean)'),
    function(args)
        if config.current.combo ~= 2 and sdk.to_int64(args[3]) & 0xFF == 6 then
            local enemy = sdk.to_managed_object(args[2])
            if enemy:get_isBossEnemy() then
                if (
                    config.current.combo == 1
                    or (
                        config.current.combo == 3
                        and enemy:get_IsCombatMode()
                    ) or (
                          config.current.combo == 4
                          and enemy:isTargetPlayer()
                      )
                ) then
                    counter = counter + 1
                    return sdk.PreHookResult.SKIP_ORIGINAL
                end
            end
        end
    end
)

config.load()

re.on_draw_ui(
    function()
        if imgui.tree_node(string.format("%s %s", name, version)) then
            imgui.push_item_width(200)
            _, config.current.combo = imgui.combo('##1', config.current.combo, combo)
            imgui.pop_item_width()
            imgui.text('Stopped ' .. counter .. ' attempts')
            imgui.tree_pop()
        end
    end
)

re.on_config_save(config.save)
