local singletons = {}

singletons.guiman = nil
singletons.questman = nil
singletons.enemyman = nil

function singletons.get_questman()
    if not singletons.questman then
        singletons.questman = sdk.get_managed_singleton('snow.QuestManager')
    end
    return singletons.questman
end

function singletons.get_guiman()
    if not singletons.guiman then
        singletons.guiman = sdk.get_managed_singleton('snow.gui.GuiManager')
    end
    return singletons.guiman
end

function singletons.get_enemyman()
    if not singletons.enemyman then
        singletons.enemyman = sdk.get_managed_singleton("snow.enemy.EnemyManager")
    end
    return singletons.enemyman
end

function singletons.get_spacewatcher()
    if not singletons.spacewatcher then
        singletons.spacewatcher = sdk.get_managed_singleton('snow.wwise.WwiseChangeSpaceWatcher')
    end
    return singletons.spacewatcher
end

function singletons.init()
	singletons.get_questman()
	singletons.get_guiman()
	singletons.get_enemyman()
    singletons.get_spacewatcher()
end

return singletons