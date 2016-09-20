local UI = require('byui/basic');
local AutoLayout = require('byui/autolayout');
local Layout = require('byui/layout');
local class, mixin, super = unpack(require('byui/class'))

local bottomPage = class('bottomPage', nil, {
	__init__ = function (self,root,callBack)
		self.m_root = root;
		self.m_callBack = callBack;
        self:initIconWidget();
	end,

	initIconWidget = function(self)
		local space = 20
		local wH = 16
		local allSpace = (space+wH)*4+wH
		self.m_ArrImage = {};
		for i=1,5 do
			local sprite = Sprite();
			sprite.unit = TextureUnit(TextureCache.instance():get(KefuResMap.face_page_normal));
			
	        sprite:add_rules({
	        	AutoLayout.width:eq(wH),
	            AutoLayout.height:eq(wH),
	            AutoLayout.left:eq((AutoLayout.parent('width')-allSpace)/2+(i-1)*(space+wH) ),
	            AutoLayout.bottom:eq(AutoLayout.parent('height')-14),
	        })
	        self.m_ArrImage[i] = sprite;
	        self.m_root:add(sprite);
		end
		self.m_ArrImage[1].unit = TextureUnit(TextureCache.instance():get(KefuResMap.face_page_active));
	end,

	changeIcon = function(self,index,prevPage)
		index = index or 1;
		prevPage = prevPage or 1;
		self.m_ArrImage[prevPage].unit  = TextureUnit(TextureCache.instance():get(KefuResMap.face_page_normal));
		self.m_ArrImage[index].unit  = TextureUnit(TextureCache.instance():get(KefuResMap.face_page_active));
	end,

})

return bottomPage;