--------------------界面管理--------------------

local startView = require(string.format('%sview/startView', KefuRootPath))
local hackAppealView = require(string.format('%sview/hackAppealView', KefuRootPath))
local vipChatView = require(string.format('%sview/vipChatView', KefuRootPath))
local leaveMessageView = require(string.format('%sview/leaveMessageView', KefuRootPath))
local playerReportView  = require(string.format('%sview/playerReportView', KefuRootPath))
local normalChatView = require(string.format('%sview/normalChatView', KefuRootPath))


local Am = require(string.format('%sanimation', KefuRootPath))

local currentView = nil
local currentName = nil
local preView = nil
local preName = nil
local viewManager = {}

--界面配置信息
local sceneInfo = {
    ["StartView"] = startView,
    ["HackAppealView"] = hackAppealView,
    ["VipChatView"] = vipChatView,
    ["LeaveMessageView"] = leaveMessageView,
    ["PlayerReportView"] = playerReportView,
    ["NormalChatView"] = normalChatView,

}



local sceneInstance = {}


local function sceneInit()
    --显示上个界面
    viewManager.showPreView = function (...)
        if preName and preView then
            viewManager["show"..preName](...)
        end
    end

    viewManager.getViewName = function (view)
        for name, v in pairs(sceneInstance) do
            if v == view then
                return name
            end
        end
    end

    for name, classType in pairs(sceneInfo) do
        local funcName = "show"..name
        viewManager[funcName] = function (animType, ...)
           
            if currentName == name then return end 
            preName = currentName
            currentName = name

            preView = currentView

            if sceneInstance[name] then
                currentView = sceneInstance[name];
                
            else
                sceneInstance[name] = classType(...);
                currentView = sceneInstance[name];
            end
            currentView:onUpdate(...)
            currentView:onShow(animType or View_Anim_Type.RTOL);
            if preView then 
                preView:onHide(animType or View_Anim_Type.RTOL)
            end

            return sceneInstance[name]

        end

        local loadFunc = "preLoad"..name
        viewManager[loadFunc] = function (...)
            if not sceneInstance[name] then
                sceneInstance[name] = classType(...)
            end
        end

        local hideFunc = "hide"..name
        viewManager[hideFunc] = function ()
            if sceneInstance[name] then
                sceneInstance[name]:onHide()
                if currentName and currentName == name then
                    currentName = ""
                    currentView = nil
                end
            end
        end

        local getViewFunc = "get"..name
        viewManager[getViewFunc] = function ()
            return sceneInstance[name]
        end

        local deleteFunc = "delete"..name
        viewManager[deleteFunc] = function ()
            if sceneInstance[name] then
                if currentName and currentName == name then
                    currentName = ""
                    currentView = nil
                end

                sceneInstance[name]:onDelete()
                sceneInstance[name] = nil
            end
        end


    end

    viewManager.onBackEvent = function ()
        if currentView and currentView.onBackEvent then
            currentView:onBackEvent()
        end
    end

    EventDispatcher.getInstance():register(Event.Back, viewManager, viewManager.onBackEvent)

    viewManager.deleteAllView = function ()
        EventDispatcher.getInstance():unregister(Event.Back, viewManager, viewManager.onBackEvent)
        
        for i, v in pairs(sceneInstance or {}) do
            v:onDelete()
            v = nil
        end

        currentView = nil
        currentName = nil
        preView = nil
        preName = nil
        viewManager = {}
    end
end

sceneInit()


return viewManager
