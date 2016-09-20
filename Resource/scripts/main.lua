KefuRootPath = ""
require(string.format('%sEngineCore/config', KefuRootPath))
require(string.format('%scommon/kefuConstant', KefuRootPath))


local function main()
    
    Label.set_emoji_baseline(0.8)
    Label.set_emoji_scale(1)

    local kefuCommon = require(string.format('%skefuCommon', KefuRootPath))
    kefuCommon.initFaceEmoji()
    

    print("==========begin==============")
    ViewManager.showStartView();

    local layoutScale = System.getLayoutScale()
    if layoutScale < 1 then
        Label.set_default_line_scale(1/layoutScale)
    end
end

function event_resize(width, height)
    System.updateLayout()
    SCREENWIDTH = System.getScreenScaleWidth()
    SCREENHEIGHT = System.getScreenScaleHeight()
    local layoutScale = System.getLayoutScale()
    --保证下划线高度>=1
    if layoutScale < 1 then
        Label.set_default_line_scale(1/layoutScale)
    end
end

function event_load(width, height)
    System.onInit()
    main()
end
