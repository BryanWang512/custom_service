require("EngineCore/config")
require('common/kefuConstant')
require("util/log")



local function main()
    
    Label.set_emoji_baseline(0.8)
    Label.set_emoji_scale(1)

    local kefuCommon = require('kefuCommon')
    kefuCommon.initFaceEmoji()
    

    print("==========begin==============")
    ViewManager.showStartView();
    
end

function event_resize(width, height)
    System.updateLayout()
    SCREENWIDTH = System.getScreenScaleWidth()
    SCREENHEIGHT = System.getScreenScaleHeight()
end

function event_load(width, height)
    System.onInit()
    main()
end
