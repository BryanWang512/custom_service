local UI = require('byui.basic');
local AutoLayout = require('byui/autolayout');
local Layout = require('byui/layout');
local class, mixin, super = unpack(require('byui/class'))


local facePage = class('facePage', nil, {
	__init__ = function (self,obj,callBack)
		self.m_obj = obj;
		self.m_root = obj:getRoot();
		self.m_callBack = callBack;
		self.m_pageView = UI.PageView {
            dimension = kHorizental,
            max_number = 5,
            is_cache = true,
        }
        self.m_prevPage = 1;
        self.m_gridLayouts = {}

        self.m_pageView:add_rules({
        	AutoLayout.width:eq(AutoLayout.parent('width')),
	        AutoLayout.height:eq(AutoLayout.parent('height')-30),
        	})
        self.m_root:add(self.m_pageView);


        self.m_pageView.create_cell = function(pageView,index)
            local page = self:initPage(index);
            return page
        end;


        self.m_pageView.on_page_change = function(obj,index)
        	if self.m_callBack and self.m_obj then
            	self.m_callBack(self.m_obj,index , self.m_prevPage);
            	self.m_prevPage = index;
            end
        end;

        self.m_pageView:update_data();

	end,
	
	setIconEvent = function (self, func)
		self.m_iconFunc = func
	end,

	setDelIconEvent = function (self, func)
		self.m_delIconFunc = func
	end,

	initPage = function(self, index)
		if self.m_gridLayouts[index] then return self.m_gridLayouts[index] end

		local start = (index-1)*20 + 1;
		local num = index * 20;
		if num > 90 then
			num = 90
		end

		local layout = Layout.GridLayout{
	        cols = 7,
	        rows = 3,
	        dimension = kVertical,
	        align = ALIGN.CENTER
	    }
	    self.m_gridLayouts[index] = layout

	    local btnPath = "";
	    for i=start, num do
	    	local strIdx = tostring(i)
	    	if i < 10 then
	    		strIdx = string.format("00%d", i)
	    	elseif i < 100 then
	    		strIdx = string.format("0%d", i)
	    	end

	        btnPath = string.format('face/appkefu_f%s.png', strIdx);
	        local faceBtn = UI.Button {
	            text = '',
	            radius = 0,
	            image =
	            {
	                normal = TextureUnit(TextureCache.instance():get(btnPath)),
	            },
	            border = 0,
	        }

	        faceBtn:add_rules({
	            AutoLayout.width:eq(60),
	            AutoLayout.height:eq(60),
	        })

	        faceBtn.on_click = function()
	        	if self.m_iconFunc then
	            	self.m_iconFunc(i)
	        	end
	        	
	        end
	        layout:add(faceBtn);
	    end
	    
	    layout:add_rules( {
	        	AutoLayout.width:eq(AutoLayout.parent('width')),
	            AutoLayout.height:eq(AutoLayout.parent('height')),
	        })


	    local delBtn = UI.Button {
	            text = '',
	            radius = 0,
	           
	            image =
	            {
	                normal = TextureUnit(TextureCache.instance():get(KefuResMap.face_del_btn_nor)),
	            },
	            border = 0,
	        }

        delBtn:add_rules({
            AutoLayout.width:eq(58),
            AutoLayout.height:eq(50),
        })

        delBtn.on_click = function()
            if self.m_delIconFunc then
            	self.m_delIconFunc()
            end
        end

        layout:add(delBtn);

	    return layout;
	end,


})

return facePage;