local AL = require(string.format('%sbyui/autolayout', KefuRootPath))
local Am = require(string.format('%sanimation', KefuRootPath))
local UI = require(string.format('%sbyui/basic', KefuRootPath))

--头像大小
local headH = 80
--底部空格
local SpaceH = 40

KefuCommon = {}


--创建时间Item
KefuCommon.createTimeWidget = function (dataStr)

	local wg = Widget()
	wg.background_color = Colorf(220/255, 220/255, 220/255,0.0)
    local bg = BorderSprite(TextureUnit(TextureCache.instance():get(KefuResMap.chat_bottombar_button_pressed)))
    bg.v_border = {11,11,11,11}
    bg.t_border = {11,11,11,11}
--    wg:add(bg)


    local txtTitle = Label()

    local data = {}
    table.insert(data, {
        text = dataStr,                       -- 文本
        color = Color(190,190,190,255),                -- 文字颜色
        bg = Color(220,220,220,255),                 -- 背景色
        size = 26,                           -- 字号
        weight=1,                            -- 字体粗细

    })

    txtTitle:set_data(data)
    txtTitle.absolute_align = ALIGN.CENTER
    txtTitle:update()
    bg:add_rules{
        AL.width:eq(txtTitle.width+10),
        AL.height:eq(txtTitle.height+16),
        AL.left:eq((AL.parent('width')-txtTitle.width-10)/2),
    }
    wg:add_rules{
        AL.width:eq(AL.parent('width')),
    }
    wg.height = txtTitle.height+35
    wg:add(txtTitle)


	return wg
end



KefuCommon.createUpdateIcon = function ()
    local wg = Widget()
    wg:add_rules{
        AL.width:eq(AL.parent("width")),
    }
    wg.height = 120

    local icon = Sprite(TextureUnit(TextureCache.instance():get(KefuResMap.chat_kefu_load_more)))
    wg:add(icon)
    local wh = 70
    icon:add_rules{
        AL.width:eq(wh),
        AL.height:eq(wh),
        AL.top:eq(15),
        AL.left:eq((AL.parent("width")-wh)/2),
    }

    icon.anchor = Point(0.5,0.5)

    local txt = Label()
    txt:set_rich_text("<font color=#C3C3C3 bg=#00000000 size=25>正在刷新...</font>")
    wg:add(txt)
    txt.absolute_align = ALIGN.BOTTOM


    local ac = Am.value(0, 359)
    wg.animTor = Am.Animator(Am.timing(Am.linear, Am.duration(1.5, ac)), function (v)
        icon.rotation = v
    end, kAnimRepeat)

    wg.show = function ()
        wg.visible = true
    --    wg.animTor:start()
    end

    wg.hide = function ()
        wg.visible = false
    --    wg.animTor:stop()
    end


    return wg
end


--创建正在发送的图标
KefuCommon.createSendingItem = function ()
    KefuCommon.SendindIcons = KefuCommon.SendindIcons or {}

    for i, v in ipairs(KefuCommon.SendindIcons) do
        if not v.isUsing then return v end 
    end

    local wg = Widget()
    local wh = 35
    wg:add_rules{
        AL.width:eq(wh),
        AL.height:eq(wh),
    }
    wg.visible = false

    local icons = {}
    local num = 8
    for i=1, num do
        local path = string.format("commonLoading%d", i-1)
        icons[i] = Sprite(TextureUnit(TextureCache.instance():get(KefuResMap[path])))
        icons[i]:add_rules{
            AL.width:eq(AL.parent('width')),
            AL.height:eq(AL.parent('height')),
        }

        wg:add(icons[i])
    end

    wg.show = function ()
        wg.visible = true
        wg.isUsing = true
        for i, v in ipairs(icons) do
            v.visible = false
        end

        local idx = 0
        icons[idx+1].visible = true
        if wg.playClock then
            wg.playClock:cancel()
            wg.playClock = nil
        end

        wg.playClock = Clock.instance():schedule(function()
            icons[idx+1].visible = false
            idx = (idx+1)%num
            icons[idx+1].visible = true     
        end, 0.05)
              
    end

    wg.hide = function ()
        wg.isUsing = nil
        if wg.playClock then
            wg.playClock:cancel()
            wg.playClock = nil
        end
        wg.visible = false
        wg:remove_from_parent()
    end

    table.insert(KefuCommon.SendindIcons, wg)
    return wg
end

KefuCommon.deleteSendingItems = function ()
    for i, v in ipairs(KefuCommon.SendindIcons or {}) do
        if v.playClock then
            v.playClock:cancel()
            v.playClock = nil
        end
        v = nil
    end
    KefuCommon.SendindIcons = nil
end


--创建头像
KefuCommon.createHeadIcon = function (parent, path, isLeft)
    local UserData = require(string.format('%sconversation/sessionData', KefuRootPath))
    local data = UserData.getStatusData() or {}

    local headIcon = nil
    
    if isLeft then
        --表明已经下载头像资源完毕
        if data.serviceHeadFinish then
            local path = System.getStorageImagePath()..data.servicerHeadPath
            if os.isexist(path) then
                headIcon = Sprite(TextureUnit(TextureCache.instance():get(data.servicerHeadPath)))
            else
                headIcon = Sprite(TextureUnit(TextureCache.instance():get(KefuResMap.chatDefaultAvatar)))
            end
        else
            headIcon = Sprite(TextureUnit(TextureCache.instance():get(KefuResMap.chatDefaultAvatar)))
            if data.needUpdateIcons then
                table.insert(data.needUpdateIcons, headIcon)
            end
        end
        headIcon:add_rules{
            AL.width:eq(headH),
            AL.height:eq(headH),
            AL.top:eq(0),
            AL.left:eq(20),
        }
    else
        headIcon = Sprite(TextureUnit(TextureCache.instance():get(path or KefuResMap.chatDefaultAvatar)))
        headIcon:add_rules{
            AL.width:eq(headH),
            AL.height:eq(headH),
            AL.top:eq(0),
            AL.right:eq(AL.parent("width")-20),
        }
    end

    parent:add(headIcon)

    return headIcon
end

--创建客服左边对话界面
KefuCommon.createLeftChatMsg = function (str, headPath)
    local wg = Widget()

    local chatBg = BorderSprite(TextureUnit(TextureCache.instance():get(KefuResMap.chatfrom_bg_normal9)))
    chatBg.v_border = {20,50,18,20}
    chatBg.t_border = {20,50,18,20}
    wg:add(chatBg)

    local txtWg = Widget()
    wg:add(txtWg)

    local txt = Label()
    txtWg:add(txt)
    txt.absolute_align = ALIGN.CENTER


    txt:set_rich_text(string.format("<font color=#000000 bg=#00000000 size=30>%s</font>", str))
    txt.layout_size = Point(SCREENWIDTH*0.6, 0)
    txt:update()

    KefuCommon.createHeadIcon(wg, headPath, true)
    

    local w,h = txt.width, txt.height
    local realH = h+40 > headH and h+40 or headH

    chatBg:add_rules{
        AL.width:eq(w+60),
        AL.height:eq(realH),
        AL.top:eq(0),
        AL.left:eq(120),
    }
    
    txtWg:add_rules{
        AL.width:eq(w+60),
        AL.height:eq(realH),
        AL.top:eq(0),
        AL.left:eq(120),
    }

    wg:add_rules{
        AL.width:eq(AL.parent("width")),
    }
    wg.height = realH+SpaceH

    return wg

end


--创建左边机器人对话界面
KefuCommon.createRobotChatMsg = function (str, links, headPath)

    for i, v in pairs(HTMLTB) do
        str = string.gsub(str, i, v)
    end

    local wg = Widget()

    local chatBg = BorderSprite(TextureUnit(TextureCache.instance():get(KefuResMap.chatfrom_bg_normal9)))
    chatBg.v_border = {20,50,18,20}
    chatBg.t_border = {20,50,18,20}
    wg:add(chatBg)

    local txtWg = Widget()
    wg:add(txtWg)

    local txt = Label()
    txtWg:add(txt)
    txt.absolute_align = ALIGN.CENTER

    -----留言
    if links and #links == 1 and links[1].type == 21 then
        txt:set_rich_text(string.format("<font color=#000000 bg=#00000000 size=30>%s</font><font color=#0000ff bg=#00000000 size=30><a tag=link>  %s</a></font>", str, links[1].text))
        txt:init_link(function (self, tag)
            ViewManager.showLeaveMessageView()
        end)
    else
        txt:set_rich_text(string.format("<font color=#000000 bg=#00000000 size=30>%s</font>", str))
    end

    txt.layout_size = Point(SCREENWIDTH*0.6, 0)
    txt:update()

    local posY = txt.height+40
    local realW = txt.width+60

    txtWg:add_rules{
        AL.width:eq(realW),
        AL.height:eq(txt.height+40),
        AL.top:eq(0),
        AL.left:eq(120),
    }



    KefuCommon.createHeadIcon(wg, headPath, true)

    local linkBtns = {}
    local linkTxts = {}

    --解决，未解决项
    if links and links[1].type == 11 then
        local icons = {}
        icons[1] = Sprite(TextureUnit(TextureCache.instance():get(KefuResMap.chat_kefu_satisfacted_heart)))
        icons[2] = Sprite(TextureUnit(TextureCache.instance():get(KefuResMap.chat_kefu_notsatisfacted_heart)))

        for i, v in ipairs(links) do
            linkTxts[i] = Label()
            linkTxts[i].absolute_align = ALIGN.CENTER
            linkTxts[i]:set_rich_text(string.format("<font color=#0000ff bg=#00000000 size=28>%s</font>", v.text))
            linkTxts[i]:set_underline(Color(0,0,255))
            linkTxts[i]:update()

            linkBtns[i] = UI.Button{
                image =
                {
                    normal = Colorf(1.0,0.0,0.0,0.0),
                    down = Colorf(0.81,0.81,0.81,0.0),
                },
                border = false,
                text = "",

            }
            wg:add(linkBtns[i])

            linkBtns[i]:add(linkTxts[i])
            linkBtns[i]:add(icons[i])
            local w = linkTxts[i].width+10
            local h = linkTxts[i].height+14
            local iconW, iconH = 30*1.2, 24*1.2
            local lf = 148+(i-1)*(realW - w - 110)+iconW+5

            linkBtns[i]:add_rules{
                AL.width:eq(w),
                AL.height:eq(h),
                AL.top:eq(posY),
                AL.left:eq(lf),
            }

            
            icons[i]:add_rules{
                AL.width:eq(iconW),
                AL.height:eq(iconH),
                AL.top:eq((h-iconH)/2),
                AL.left:eq(-iconW),
            }

        
        end
        posY = posY + linkTxts[1].height+15

        for i, v in ipairs(links) do
            linkBtns[i].on_click = function ()
                local str = json.encode(v) 
                linkTxts[i]:set_rich_text(string.format("<font color=#ff5555 bg=#00000000 size=28>%s</font>",v.text))
                linkTxts[i]:set_underline(Color(255,85,85))
                NetWorkControl.sendProtocol("sendChatMsg", str, MessageType_Map.ROBOT)
                linkBtns[1].enabled = false
                linkBtns[2].enabled = false
            end
        end
    else
        for i, v in ipairs(links or {}) do
            if v.type == 21 and #links == 1 then
                break
            end

            linkTxts[i] = Label()
            linkTxts[i].absolute_align = ALIGN.CENTER
            --留言回复
            -- if v.type == 21 and #links == 1 then
            --     linkTxts[i]:set_rich_text(string.format("<font color=#0000ff bg=#00000000 size=28>%s</font>", v.text))
            -- else
                linkTxts[i]:set_rich_text(string.format("<font color=#0000ff bg=#00000000 size=28>%d.%s</font>", i, v.text))
            --end

            linkTxts[i]:set_underline(Color(0,0,255))
            linkTxts[i].layout_size = Point(SCREENWIDTH*0.6, 0)
            linkTxts[i]:update()

            if realW < linkTxts[i].width+55 then
                realW = linkTxts[i].width+55
            end

            linkBtns[i] = UI.Button{
                image =
                {
                    normal = Colorf(1.0,0.0,0.0,0.0),
                    down = Colorf(0.81,0.81,0.81,0.0),
                },
                border = false,
                text = "",
                on_click = function ()
                    if v.type ~= 21 then
                        local str = json.encode(v) 
                        linkTxts[i]:set_rich_text(string.format("<font color=#ff5555 bg=#00000000 size=28>%d.%s</font>",i, v.text))
                        linkTxts[i]:set_underline(Color(255,85,85))
                        NetWorkControl.sendProtocol("sendChatMsg", str, MessageType_Map.ROBOT)
                    
                    else        --type == 21需要跳转到留言界面  
                        ViewManager.showLeaveMessageView()
                    end
                end,
            }
            wg:add(linkBtns[i])

            linkBtns[i]:add(linkTxts[i])
            linkBtns[i]:add_rules{
                AL.width:eq(linkTxts[i].width+10),
                AL.height:eq(linkTxts[i].height+14),
                AL.top:eq(posY),
                AL.left:eq(148),
            }
            posY = posY + linkTxts[i].height+20
        end
    end

    if linkTxts[1] then
        posY = posY + 10
    end

    chatBg:add_rules{
        AL.width:eq(realW),
        AL.height:eq(posY),
        AL.top:eq(0),
        AL.left:eq(120),
    }

    wg:add_rules{
        AL.width:eq(AL.parent("width")),
    }
    wg.height = posY+20+SpaceH
    wg.linkBtns = linkBtns
    return wg


end

--创建右边对话
KefuCommon.createRightChatMsg = function (str, isVip, headPath)
    local wg = Widget()
    local path = KefuResMap.chatto_bg_normal9

    if isVip then
        path = KefuResMap.chatto_vip_bg_normal9
    end

    local chatBg = BorderSprite(TextureUnit(TextureCache.instance():get(path)))
    chatBg.v_border = {20,50,18,20}
    chatBg.t_border = {20,50,18,20}
    wg:add(chatBg)

    local txtWg = Widget()
    wg:add(txtWg)
    local txt = Label()
    txtWg:add(txt)
    txt.absolute_align = ALIGN.CENTER

    txt:set_rich_text(string.format("<font color=#000000 bg=#00000000 size=30>%s</font>", str))
    txt.layout_size = Point(SCREENWIDTH*0.6, 0)
    txt:update()



    KefuCommon.createHeadIcon(wg, headPath)

    local w,h = txt.width, txt.height
    local realH = h+40 > headH and h+40 or headH


    chatBg:add_rules{
        AL.width:eq(w+60),
        AL.height:eq(realH),
        AL.top:eq(0),
        AL.right:eq(AL.parent("width")-120),
    }

    txtWg:add_rules{
        AL.width:eq(w+60),
        AL.height:eq(realH),
        AL.top:eq(0),
        AL.right:eq(AL.parent("width")-120),
    }

    local tx = 20
    if realH == headH then
        tx = (headH - h)/2
    end

    txt:add_rules{
        AL.top:eq(tx),
        AL.left:eq(AL.parent("width") - (w+35+120)),
    }


    wg:add_rules{
        AL.width:eq(AL.parent("width")),
    }
    wg.height = realH+SpaceH

    return wg


end

--创建图片项
KefuCommon.createLeftImageItem= function (path, headPath)
    local maxImgW = System.getScreenScaleWidth() * 0.4
    local wg = Widget()

    local chatBg = BorderSprite(TextureUnit(TextureCache.instance():get(KefuResMap.chatfrom_bg_normal9)))
    chatBg.v_border = {20,50,18,20}
    chatBg.t_border = {20,50,18,20}
    wg:add(chatBg)

    KefuCommon.createHeadIcon(wg, headPath, true)



    local img = Sprite(TextureUnit(TextureCache.instance():get(path)))
    wg:add(img)

    if img.width > maxImgW then
        img.height = maxImgW / img.width * img.height
        img.width = maxImgW
    end



    local realH = img.height > headH and img.height or headH

    chatBg:add_rules{
        AL.width:eq(img.width+80),
        AL.height:eq(realH),
        AL.top:eq(0),
        AL.left:eq(120),
    }

    local iy = 2
    if realH == headH then
        iy = (headH - img.height)/2
    end

    img:add_rules{
        AL.top:eq(iy),
        AL.left:eq(164),
        AL.width:eq(img.width),
        AL.height:eq(img.height-2),
    }


    wg:add_rules{
        AL.width:eq(AL.parent("width")),
    }
    wg.height = realH+SpaceH

    return wg

end


KefuCommon.createRightImageItem = function (path, isVip)
    local maxImgW = System.getScreenScaleWidth() * 0.4

    local bgPath = KefuResMap.chatto_bg_normal9

    if isVip then
        bgPath = KefuResMap.chatto_vip_bg_normal9
    end
    
    local wg = Widget()

    local chatBg = BorderSprite(TextureUnit(TextureCache.instance():get(bgPath)))
    chatBg.v_border = {20,50,18,20}
    chatBg.t_border = {20,50,18,20}
    wg:add(chatBg)

    KefuCommon.createHeadIcon(wg, headPath)

    local img = Sprite(TextureUnit(TextureCache.instance():get(path)))
    wg:add(img)

    if img.width > maxImgW then
        img.height = maxImgW / img.width * img.height
        img.width = maxImgW
    end

    local realH = img.height > headH and img.height or headH

    chatBg:add_rules{
        AL.width:eq(img.width+80),
        AL.height:eq(realH),
        AL.top:eq(0),
        AL.right:eq(AL.parent("width")-120),
    }

    --发送过程icon
    wg.sendingIcon = KefuCommon.createSendingItem()
    chatBg:add(wg.sendingIcon)
    wg.sendingIcon:add_rules{
        AL.right:eq(-12),
        AL.top:eq((realH-35)/2),
    }

    wg.failBtn = UI.Button{
        image =
        {
            normal = TextureUnit(TextureCache.instance():get(KefuResMap.chatMsgStateFailResend)),
            down = TextureUnit(TextureCache.instance():get(KefuResMap.chatStateFailResendPressed)),
        },
        border = false,
        text = "",
        radius = 0,
    }
    wg.failBtn:add_rules{
        AL.width:eq(44),
        AL.height:eq(44),
        AL.top:eq((realH-44)/2),
        AL.right:eq(-10),
    }
    chatBg:add(wg.failBtn)
    wg.failBtn.visible = false



    local iy = 1
    if realH == headH then
        iy = (headH - img.height)/2
    end

    img:add_rules{
        AL.top:eq(iy),
        AL.right:eq(AL.parent("width")-162),
        AL.width:eq(img.width),
        AL.height:eq(img.height-1),
    }

    wg:add_rules{
        AL.width:eq(AL.parent("width")),
    }
    wg.height = realH+SpaceH

    return wg
    
end


local minVoiceW = 150
local maxVoiceW = SCREENWIDTH - 150

KefuCommon.createLeftVoiceItem = function (voicePath)
    local wg = Widget()

    local chatBg = BorderSprite(TextureUnit(TextureCache.instance():get(KefuResMap.chatfrom_bg_normal9)))
    chatBg.v_border = {20,50,18,20}
    chatBg.t_border = {20,50,18,20}
    wg:add(chatBg)

    KefuCommon.createHeadIcon(wg, headPath, true)

    local time = math.floor(Record.getAudioDuration(voicePath)/1000+0.5)
    local realW = time*9 + minVoiceW
    if realW > maxVoiceW then
        realW = maxVoiceW
    end

    chatBg:add_rules{
        AL.width:eq(realW),
        AL.height:eq(headH),
        AL.top:eq(0),
        AL.left:eq(120),
    }

    local icons = {}
    for i=1,4 do
        local path = string.format("chatfrom_voice_playing_f%d", i)
        icons[i] = Sprite(TextureUnit(TextureCache.instance():get(KefuResMap.path)))
        wg:add(icons[i])
        icons[i]:add_rules{
            AL.width:eq(24),
            AL.height:eq(34),
            AL.top:eq((headH-34)/2),
            AL.left:eq(160),
        }
        icons[i].visible = false
    end

    icons[4].visible = true

    local txt = Label()
    txt:set_rich_text(string.format("<font color=#9C9C9C bg=#00000000 size=27>%d\"</font>", time) )
    wg:add(txt)
    txt:update()

    txt.x = 120+realW+20
    txt.y = (headH - txt.height)/2

    wg:add_rules{
        AL.width:eq(AL.parent("width")),
    }
    wg.height = headH+SpaceH

    wg.failBtn = UI.Button{
        image =
        {
            normal = TextureUnit(TextureCache.instance():get(KefuResMap.chatMsgStateFailResend)),
            down = TextureUnit(TextureCache.instance():get(KefuResMap.chatStateFailResendPressed)),
        },
        border = false,
        text = "",
        radius = 0,
    }
    wg.failBtn:add_rules{
        AL.width:eq(44),
        AL.height:eq(44),
        AL.top:eq((headH-44)/2),
        AL.left:eq(120+realW+20+txt.width),
    }
    wg:add(wg.failBtn)

    --点击播放语音
    wg.btn = UI.Button{
        image =
        {
            normal = Colorf(1.0,0.0,0.0,0.0),
            down = Colorf(0.81,0.81,0.81,0.0),
        },
        border = false,
        text = "",

    }

    wg:add(wg.btn)
    wg.btn:add_rules{
        AL.width:eq(realW),
        AL.height:eq(headH),
        AL.top:eq(0),
        AL.left:eq(120),
    }

    --播放序列帧
    local isPlaying = false
    wg.btn.on_click = function ()
        isPlaying = not isPlaying
        if isPlaying then
            local idx = 0
            for i=1,4 do
                icons[i].visible = false
            end
            icons[idx+1].visible = true
            wg.playClock = Clock.instance():schedule(function()
                icons[idx+1].visible = false
                idx = (idx+1)%3
                icons[idx+1].visible = true     
            end,0.2)

            wg.stopClock = Clock.instance():schedule_once(function()
                if isPlaying then
                    isPlaying = false
                    if wg.playClock then
                        wg.playClock:cancel()
                        wg.playClock = nil
                    end
                    icons[1].visible = false
                    icons[2].visible = false
                    icons[3].visible = false
                    icons[4].visible = true
                end   
            end, time)
            Record.getInstance():startTrack(voicePath);--开始播放语音
        else
            wg.playClock:cancel()
            wg.playClock = nil
            wg.stopClock:cancel()
            wg.stopClock = nil
            icons[1].visible = false
            icons[3].visible = false
            icons[4].visible = true
            Record.getInstance():stopTrack(voicePath);--停止播放
        end
    end

    return wg


end

--创建聊天语音项
KefuCommon.createRightVoiceItem = function (time, voicePath, isVip)
    local wg = Widget()
    local path = KefuResMap.chatto_bg_normal9

    if isVip then
        path = KefuResMap.chatto_vip_bg_normal9
    end

    local chatBg = BorderSprite(TextureUnit(TextureCache.instance():get(path)))
    chatBg.v_border = {20,50,18,20}
    chatBg.t_border = {20,50,18,20}
    wg:add(chatBg)

    Log.v("createRightVoiceItem" ,"voicePath: "..voicePath);
    time = time or Record.getInstance():getAudioDuration(voicePath)

    local timeSpace = SCREENWIDTH/25
    local realW = time*timeSpace + minVoiceW
    if realW > maxVoiceW then
        realW = maxVoiceW
    end 

    chatBg:add_rules{
        AL.width:eq(realW),
        AL.height:eq(headH),
        AL.top:eq(0),
        AL.right:eq(AL.parent("width")-120),
    }

    KefuCommon.createHeadIcon(wg, headPath)
    --正在发送的表现
    wg.sendingIcon = KefuCommon.createSendingItem()
    chatBg:add(wg.sendingIcon)
    wg.sendingIcon:add_rules{
        AL.right:eq(-60),
    }
    wg.sendingIcon.y = (headH-34)/2


    local icons = {}

    for i=1,3 do
        icons[i] = Sprite(TextureUnit(TextureCache.instance():get(KefuResMap["chatVoiceIcon"..i])))
        wg:add(icons[i])
        icons[i]:add_rules{
            AL.width:eq(24),
            AL.height:eq(34),
            AL.top:eq((headH-34)/2),
            AL.right:eq(AL.parent("width")-160),
        }
        icons[i].visible = false
    end

    icons[3].visible = true

    

    
    local txt = Label()
    txt:set_rich_text(string.format("<font color=#9C9C9C bg=#00000000 size=27>%d\"</font>", time) )
    wg:add(txt)
    txt:update()
    --txt.align_v = (ALIGN.CENTER - ALIGN.CENTER % 4)/4
    txt:add_rules{
        AL.left:eq(AL.parent("width")-140-realW-txt.width),
    }

    txt.y = (headH - txt.height)/2

    wg:add_rules{
        AL.width:eq(AL.parent("width")),
    }
    wg.height = headH+SpaceH

    wg.failBtn = UI.Button{
        image =
        {
            normal = TextureUnit(TextureCache.instance():get(KefuResMap.chatMsgStateFailResend)),
            down = TextureUnit(TextureCache.instance():get(KefuResMap.chatStateFailResendPressed)),
        },
        border = false,
        text = "",
        radius = 0,
    }
    wg.failBtn:add_rules{
        AL.width:eq(44),
        AL.height:eq(44),
        AL.top:eq((headH-44)/2),
        AL.left:eq(AL.parent("width")-140-realW-txt.width - 44),
    }
    wg:add(wg.failBtn)
    wg.failBtn.visible = false

    --点击播放语音
    wg.btn = UI.Button{
        image =
        {
            normal = Colorf(1.0,0.0,0.0,0.0),
            down = Colorf(0.81,0.81,0.81,0.0),
        },
        border = false,
        text = "",

    }

    wg:add(wg.btn)
    wg.btn:add_rules{
        AL.width:eq(realW),
        AL.height:eq(headH),
        AL.top:eq(0),
        AL.right:eq(AL.parent("width")-120),
    }

    --播放序列帧
    local isPlaying = false
    wg.btn.on_click = function ()
        isPlaying = not isPlaying
        if isPlaying then
            Record.getInstance():stopTrack()
            local idx = 0
            for i=1,3 do
                icons[i].visible = false
            end
            icons[idx+1].visible = true
            wg.playClock = Clock.instance():schedule(function()
                icons[idx+1].visible = false
                idx = (idx+1)%3
                icons[idx+1].visible = true     
            end,0.2)

            wg.stopClock = Clock.instance():schedule_once(function()
                if isPlaying then
                    isPlaying = false
                    if wg.playClock then
                        wg.playClock:cancel()
                        wg.playClock = nil
                    end
                    icons[1].visible = false
                    icons[2].visible = false
                    icons[3].visible = true
                end
                Record.getInstance():stopTrack()   
            end, time)
            Record.getInstance():startTrack(voicePath);--开始播放语音
        else
            wg.playClock:cancel()
            wg.playClock = nil
            wg.stopClock:cancel()
            wg.stopClock = nil
            icons[1].visible = false
            icons[2].visible = false
            icons[3].visible = true

            Record.getInstance():stopTrack()
        end
    end

    return wg
    
end


--显示tips
KefuCommon.showTips = function (dataStr)
    local wg = Widget()

    local bg = BorderSprite(TextureUnit(TextureCache.instance():get(KefuResMap.chat_bottombar_button_pressed)))
    bg.v_border = {11,11,11,11}
    bg.t_border = {11,11,11,11}
    wg:add(bg)

    local txtWg = Widget()
    wg:add(txtWg)

    local txtTitle = Label()

    local data = {}
    table.insert(data, {
        text = dataStr,                       -- 文本
        color = Color(255,255,255,255),                -- 文字颜色
        bg = Color(220,220,220,0),                 -- 背景色
        size = 24,                           -- 字号
        weight=1,                            -- 字体粗细

    })

    txtTitle:set_data(data)
    txtTitle.absolute_align = ALIGN.CENTER
    txtTitle:update()

    local bgW = SCREENWIDTH - 350
    if bgW < (txtTitle.width + 20) then
        bgW = txtTitle.width + 20
    end

    bg:add_rules{
        AL.width:eq(bgW),
        AL.height:eq(txtTitle.height+12),
        AL.left:eq((AL.parent('width')-bgW)/2),
    }

    txtWg:add_rules{
        AL.width:eq(bgW),
        AL.height:eq(txtTitle.height+12),
        AL.left:eq((AL.parent('width')-bgW)/2),
    }

    wg:add_rules{
        AL.width:eq(AL.parent('width')),
    }
    wg.height = txtTitle.height+35
    txtWg:add(txtTitle)


    return wg
end

--初始化emoji
KefuCommon.initFaceEmoji = function ()

    local tb = {}
    local start = EmojiStartIdx
    KefuCommon.StartEmojiIdx = start
    for i=1,EmojiNum do
        local strIdx = tostring(i)
        if i < 10 then
            strIdx = string.format("00%d", i)
        elseif i < 100 then
            strIdx = string.format("0%d", i)
        end

        local key = tostring(start)
        local path = string.format("face_f%s", strIdx)
        tb[key] = {file = KefuResMap[path]}
        start = start + 1
    end
    Label.add_emoji(tb)
end


KefuCommon.createExceptionTip = function ()
    local wg = Widget()
    wg.background_color = Colorf(1.0, 223/255, 223/255, 1.0)
    local txt = Label()
    wg:add(txt)
    txt:set_rich_text(ConstString.login_failed)
    txt.absolute_align = ALIGN.CENTER
    txt.layout_size = Point(SCREENWIDTH-50, 0)
    txt:update()

    wg:add_rules{
        AL.width:eq(AL.parent('width')),
        AL.height:eq(txt.height+30),
        AL.top:eq(0),
        AL.left:eq(0),
    }

    return wg
end


KefuCommon.createSubmitTips = function ()
    local btn = UI.Button{
        image =
        {
            normal = Colorf(0.6,0.6,0.6,0.5),
            down = Colorf(0.6,0.6,0.6,0.5),
        },
        border = false,
        text = "",
        on_click = function ()

        end,
    }

    btn:add_rules{
        AL.width:eq(AL.parent('width')),
        AL.height:eq(AL.parent('height')),
    }
    local bg = BorderSprite(TextureUnit(TextureCache.instance():get(KefuResMap.chat_kefu_voice_rcd_hint_bg)))
    bg.v_border = {11,11,11,11}
    bg.t_border = {11,11,11,11}

    bg:add_rules{
        AL.width:eq(300),
        AL.height:eq(200),
        AL.top:eq((AL.parent('height')-200)/2),
        AL.left:eq((AL.parent('width')-300)/2),
    }

    local txtShow = Label()    
    bg:add(txtShow)
    txtShow:add_rules{
        AL.left:eq(45),
        AL.top:eq(75),
    }

    local txtHide = Label()
    bg:add(txtHide)
    txtHide.absolute_align = ALIGN.CENTER


    local tips = {"正在提交.", "正在提交..", "正在提交..."}
    btn.showTips = function ()
        btn.visible = true
        bg.visible = true
        txtShow.visible = true
        txtHide.visible = false

        local i = 1
        txtShow:set_rich_text(string.format("<font color=#ffffff bg=#00000000 size=42 weight=2>%s</font>", tips[i]))
        btn.showClock = Clock.instance():schedule(function()
            i = (i+1)%3
            if i == 0 then
                i = 3
            end

            txtShow:set_rich_text(string.format("<font color=#ffffff bg=#00000000 size=42 weight=2>%s</font>", tips[i]))
        end,0.15)
    end

    

    btn.hideTips = function (str, time)
        if btn.showClock then
            btn.showClock:cancel()
            btn.showClock = nil
        end
        txtShow.visible = false
        txtHide.visible = true
        txtHide:set_rich_text(string.format("<font color=#ffffff bg=#00000000 size=42 weight=2>%s</font>", str))
        Clock.instance():schedule_once(function()
            btn.visible = false
            bg.visible = false
        end, time or 1)
    end
    return btn, bg
end


--unicode字符串转换成utf8字符
KefuCommon.unicodeToChar = function (unicode)

    local resultStr=""
 
    if unicode <= 0x007f then

        resultStr=string.char(bit.band(unicode,0x7f))


    elseif unicode >= 0x0080 and unicode <= 0x07ff then

        resultStr=string.char(bit.bor(0xc0,bit.band(bit.brshift(unicode,6),0x1f)))

        resultStr=resultStr..string.char(bit.bor(0x80,bit.band(unicode,0x3f)))


    elseif unicode >= 0x0800 and unicode <= 0xffff then


        resultStr=string.char(bit.bor(0xe0,bit.band(bit.brshift(unicode,12),0x0f)))

        resultStr=resultStr..string.char(bit.bor(0x80,bit.band(bit.brshift(unicode,6),0x3f)))

        resultStr=resultStr..string.char(bit.bor(0x80,bit.band(unicode,0x3f)))
    elseif unicode >= 0x00010000 and unicode <= 0x001FFFFF then 
        resultStr = string.char(bit.bor(0xF0, bit.band(0x07, bit.brshift(unicode,18))))
        resultStr = resultStr..string.char(bit.bor(0x80, bit.band(0x3F, bit.brshift(unicode,12))))
        resultStr = resultStr..string.char(bit.bor(0x80, bit.band(0x3F, bit.brshift(unicode,6))))
        resultStr = resultStr..string.char(bit.bor(0x80, bit.band(0x3F, unicode)))

    end

    return resultStr
end

--utf8字符转换成unicode
KefuCommon.utf8to32 = function (utf8str)
    assert(type(utf8str) == "string")
    local res, seq, val = {}, 0, nil
    for i = 1, #utf8str do
        local c = string.byte(utf8str, i)
        if seq == 0 then
            table.insert(res, val)
            seq = c < 0x80 and 1 or c < 0xE0 and 2 or c < 0xF0 and 3 or
                  c < 0xF8 and 4 or --c < 0xFC and 5 or c < 0xFE and 6 or
                  error("invalid UTF-8 character sequence")
            val = bit.band(c, 2^(8-seq) - 1)
        else
            val = bit.bor(bit.blshift(val, 6), bit.band(c, 0x3F))
        end
        seq = seq - 1
    end
    table.insert(res, val)
    table.insert(res, 0)
    return res
end


--转换时间, msgTime(秒)
KefuCommon.getStringTime = function (msgTime)
    local curTime = os.time()

    local curHour = tonumber(os.date("%H", curTime))
    local curMin = tonumber(os.date("%M", curTime))
    local curSecond = tonumber(os.date("%S", curTime))
    local startT = curTime - curHour*3600 - curMin*60 - curSecond
    local endT = startT + 24*3600

    local hour = tonumber(os.date("%H", msgTime))
    local msgHour = os.date("%H", msgTime)
    local msgMin = os.date("%M", msgTime)

    local format = ""
    --今天
    if msgTime >= startT and msgTime < endT then
        if hour > 17 then
            format = string.format("晚上 %s:%s", msgHour, msgMin)
        elseif hour >= 0 and hour <= 6 then
             format = string.format("凌晨 %s:%s", msgHour, msgMin)
        elseif hour > 11 and hour <= 17 then
            format = string.format("下午 %s:%s", msgHour, msgMin)
        else
            format = string.format("上午 %s:%s", msgHour, msgMin)
        end
    --昨天
    elseif msgTime >= startT - 24*3600 and msgTime < startT then
        format = string.format("昨天 %s:%s", msgHour, msgMin)
    else
        local month = tonumber(os.date("%m", msgTime))
        local day = tonumber(os.date("%d", msgTime))
        format = string.format("%d月%d日 %s:%s", month, day,msgHour, msgMin)
    end

    return format
end


KefuCommon.subUTF8String = function (s, n)
    local dropping = string.byte(s, n+1)    
    if not dropping then return s end    
    if dropping >= 128 and dropping < 192 then    
        return KefuCommon.subUTF8String(s, n-1)    
    end    
    return string.sub(s, 1, n) 
end

KefuCommon.isTelPhoneNumber = function (text)
    if string.len(text) ~= 11 then return false end

    if string.sub(text,1,1) ~= "1" then return false end 
    local two = string.sub(text,2,2)
    if two == "3" or two == "5" or two == "8" then return true end

    return false
end

--根据年月算天数
KefuCommon.getDayNum = function (year, month)
    if month == 1 or month == 3 or month == 5 or month == 7 or month == 8 or month == 10 or month == 12 then
        return 31
    elseif month == 4 or month == 6 or month == 9 or month == 11 then
        return 30
    else
        --闰年
        if year % 400 == 0 then
            return 29
        else
            if year % 4 == 0 and year % 100 ~= 0 then
                return 29
            else
                return 28
            end
        end
    end
end


return KefuCommon