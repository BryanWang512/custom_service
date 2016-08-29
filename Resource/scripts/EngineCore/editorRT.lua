
package.preload[ "editorRT/sceneLoader" ] = function( ... )
SceneLoader = class();
local grayScale = require("libEffect.shaders.grayScale");
SceneLoader.registLoadFunc = function(name, func)
	SceneLoader.loadFuncMap[name] = func;
end

SceneLoader.load = function(t)
	if type(t) ~= "table" then
		return;
	end

	local root;
	local isPreset = t.isPreset;
	root = SceneLoader.loadUI(t);
	if isPreset ~= 1 then
		for _,v in ipairs(t) do
			local node = SceneLoader.load(v);
			root:add(node);
		end
	end

	Window.instance().drawing_root:add(root)
	-- root:addToRoot();
	return root;
end


----------------------------private functions, don't use these functions in your code ------------------------

SceneLoader.loadUI = function(t)
	if t.isPreset == 1 then
		return SceneLoader.loadFuncMap["Preset"](t);
	end
	local node = SceneLoader.loadFuncMap[t.typeName](t);
	if node ~= nil and t.effect ~= nil then
		if t.effect["shader"] == "mirror" and (typeof(node, DrawingImage) or typeof(node, BorderSprite.___class)) then
			if t.effect["mirrorType"] == 0 then
				node.mirror_x = true
				node.mirror_y = true
			elseif t.effect["mirrorType"] == 1 then
				node.mirror_x = true
			elseif t.effect["mirrorType"] == 2 then
				node.mirror_y = true
			end
		elseif t.effect["shader"] == "gray" then
			grayScale.applyToDrawing(node,{intensity = 0});
		end
	end
	return node;
end

SceneLoader.loadButton = function(t)
	local node = new(Button,SceneLoader.getResPath(t,t.file),SceneLoader.getResPath(t,t.file2),nil,nil,t.gridLeft,t.gridRight,t.gridTop,t.gridBottom);
	SceneLoader.setBaseInfo(node,t);
	return node;
end

SceneLoader.loadImage = function(t)
	local node = new(Image,SceneLoader.getResPath(t,t.file),nil,nil,t.gridLeft,t.gridRight,t.gridTop,t.gridBottom);
	SceneLoader.setBaseInfo(node,t);
	return node;
end

SceneLoader.loadText = function(t)
	local node = new(Text,t.string,t.width,t.height,t.textAlign or t.align,"",t.fontSize,t.colorRed,t.colorGreen,t.colorBlue);
	node:setName(t.name or "");
	node:setPos(t.x,t.y);
	node:setAlign(t.nodeAlign);
	node:setVisible(t.visible==1 and true or false);
	return node;
end

SceneLoader.loadTextView = function(t)
	local node = new(TextView,t.string,t.width,t.height,t.textAlign or t.align,"",t.fontSize,t.colorRed,t.colorGreen,t.colorBlue);
	node:setName(t.name or "");
	node:setPos(t.x,t.y);
	node:setAlign(t.nodeAlign);
	node:setVisible(t.visible==1 and true or false);
	return node;
end

SceneLoader.loadEditText = function(t)
	local node = new(EditText,t.string,t.width,t.height,t.textAlign or t.align,"",t.fontSize,t.colorRed,t.colorGreen,t.colorBlue);
	node:setName(t.name or "");
	node:setPos(t.x,t.y);
	node:setAlign(t.nodeAlign);
	node:setVisible(t.visible==1 and true or false);
	return node;
end

SceneLoader.loadEditTextView = function(t)
	local node = new(EditTextView,t.string,t.width,t.height,t.textAlign or t.align,"",t.fontSize,t.colorRed,t.colorGreen,t.colorBlue);
	node:setName(t.name or "");
	node:setPos(t.x,t.y);
	node:setAlign(t.nodeAlign);
	node:setVisible(t.visible==1 and true or false);
	return node;
end

SceneLoader.loadNilNode = function(t)
	local node = new(Node);
	SceneLoader.setBaseInfo(node,t);
	return node;
end

SceneLoader.loadCheckBoxGroup = function(t)
	local node = new(CheckBoxGroup);
	SceneLoader.setBaseInfo(node,t);
	return node;
end

SceneLoader.loadCheckBox = function(t)
	local param;
	if t.file and t.file2 then
		param = {t.file,t.file2};
	end
	local node = new(CheckBox,param);
	SceneLoader.setBaseInfo(node,t);
	return node;
end

SceneLoader.loadRadioButtonGroup = function(t)
	local node = new(RadioButtonGroup);
	SceneLoader.setBaseInfo(node,t);
	return node;
end

SceneLoader.loadRadioButton = function(t)
	local param;
	if t.file and t.file2 then
		param = {t.file,t.file2};
	end
	local node = new(RadioButton,param);
	SceneLoader.setBaseInfo(node,t);
	return node;
end

SceneLoader.loadAutoScrollView = function(t)
	local node = new(ScrollView,t.x,t.y,t.width,t.height,true);
	SceneLoader.setBaseInfo(node,t);
	return node;
end

SceneLoader.loadScrollView = function(t)
	local node = new(ScrollView,t.x,t.y,t.width,t.height);
	SceneLoader.setBaseInfo(node,t);
	return node;
end

SceneLoader.loadSlider = function(t)
	local node = new(Slider,t.width,t.height,t.bgFile,t.fgFile,t.buttonFile);
	SceneLoader.setBaseInfo(node,t);
	return node;
end

SceneLoader.loadSwitch = function(t)
	local node = new(Switch,t.width,t.height,t.onFile,t.offFile,t.buttonFile);
	SceneLoader.setBaseInfo(node,t);
	return node;
end

SceneLoader.loadListView = function(t)
	local node = new(ListView,t.x,t.y,t.width,t.height);
	SceneLoader.setBaseInfo(node,t);
	return node;
end

SceneLoader.loadViewPager = function(t)
	local node = new(ViewPager,t.x,t.y,t.width,t.height);
	SceneLoader.setBaseInfo(node,t);
	return node;
end

SceneLoader.loadSwf = function(t)
	local swfInfoLua = require(t.swfInfoLua);
	local swfPinLua = require(t.swfPinLua);
	local node = new(SwfPlayer,swfInfoLua,swfPinLua);
	if t.swfAuto==1 then
		node:play(t.swfFrame,t.swfKeep == 1,t.swfRepeat,t.swfDelay,t.swfAutoClean==1);
	end
	SceneLoader.setBaseInfo(node,t);
	return node;
end

SceneLoader.loadPreset = function(t)
	t.isPreset = 0;
	local node;
	local success, fn = pcall(function () 
    	return require(t.preLuaPath)
	end)
	if success == true then
		node = fn(t);
	elseif t.preLuaPath ~= nil then
		t.isPreset = 1;
		error("get error at require "..t.preLuaPath)
	else
		node = SceneLoader.load(t);
	end
	t.isPreset = 1;
	return node;
end

SceneLoader.getResPath = function(t, filename)
	if not filename then
		return filename;
	end

	if type(filename) == "table" then
		return filename;
	end

	if not t.packFile then
		return filename;
	end

	local findName = function(str)
		local pos;
		local found = 0;
		while found do
			pos = found;
			found = string.find(str,"/",pos+1,true);
		end

		if not pos then
			pos = 0;
		end
		return string.sub(str,pos+1);
	end

	local tb = require(t.packFile);

	return tb[findName(filename)];
end

SceneLoader.getWH = function(t)
	local w = t.width and t.width>0 and t.width or nil;
	local h = t.height and t.height>0 and t.height or nil;
	return w,h;
end

SceneLoader.setBaseInfo = function(node, t)
	node.name = t.name or "";
	SceneLoader.setRules(node,t.rules or {})
	node:setFillParent(t.fillParentWidth==1 and true or false,
						t.fillParentHeight==1 and true or false);
	if t.fillTopLeftX or t.fillTopLeftY 
		or t.fillBottomRightX or t.fillBottomRightY then
		node:setFillRegion(true,t.fillTopLeftX or 0,t.fillTopLeftY or 0,
			t.fillBottomRightX or 0,t.fillBottomRightY or 0);
	end
	node:setPos(t.x,t.y);
	node:setAlign(t.nodeAlign);
	node:setSize(SceneLoader.getWH(t));
	node.visible = t.visible==1 and true or false;
end


--------------byui loader-----------
local BYUI = require('byui/basic')
local AL = require('byui/autolayout')
local BYLayout = require('byui/layout')

rawset(TextureUnit, 'load', function(fileName)
	if not fileName then
		return nil;
	end
	if type(fileName) == "table" then
		local unit = TextureUnit(TextureCache.instance():get(fileName.file))
		unit.rect = Rect(fileName.x,fileName.y,fileName.width,fileName.height);
		if fileName.rotated == true then
			unit.trim_border = {fileName.offsetX,fileName.offsetY,
								fileName.utWidth - fileName.height - fileName.offsetX,
								fileName.utHeight - fileName.width - fileName.offsetY};
      	else
      		unit.trim_border = {fileName.offsetX,fileName.offsetY,
								fileName.utWidth - fileName.width - fileName.offsetX,
								fileName.utHeight - fileName.height - fileName.offsetY};
     	end
		unit.rotated = fileName.rotated;
		return unit;
	else
		return TextureUnit(TextureCache.instance():get(fileName));
	end
end)

SceneLoader.getButtonImage = function(state,t,gridIndex)
	if type(t[state]) == "number" then
		return Colorf(t[state .. "R"],t[state .. "G"],t[state .. "B"],t[state .. "A"] or 1);
	else
		if not t[state] or t[state] == "" then
			return nil;
		end
		return {unit = TextureUnit.load(t[state]),
				t_border = {t["gridLeft"..gridIndex],t["gridTop"..gridIndex],t["gridRight"..gridIndex],t["gridBottom"..gridIndex]}}
	end
end

SceneLoader.setRules = function(uiWidget,rules_tb)
	local rules = {}
	for _,v in ipairs(rules_tb) do
		local rule;
		if v[1] == "right" then
			if v[2] == "parent" then
				rule = AL[v[1]]:eq(AL.parent('width') - AL.parent(v[4]) * v[5] + v[6])
			else
				rule = AL[v[1]]:eq(AL.parent('width') - AL.sibling(v[3])(v[4]) * v[5] + v[6])
			end
		elseif v[1] == "bottom" then
			if v[2] == "parent" then
				rule = AL[v[1]]:eq(AL.parent('height') - AL.parent(v[4]) * v[5] + v[6])
			else
				rule = AL[v[1]]:eq(AL.parent('height') - AL.sibling(v[3])(v[4]) * v[5] + v[6])
			end
		else
			if v[2] == "parent" then
				rule = AL[v[1]]:eq(AL.parent(v[4]) * v[5] + v[6])
			else
				rule = AL[v[1]]:eq(AL.sibling(v[3])(v[4]) * v[5] + v[6])
			end
		end
		table.insert(rules,rule)
	end
	uiWidget:add_rules(rules)
end

SceneLoader.loadView2 = function(t)
	local widget = Widget();
	SceneLoader.setBaseInfo(widget,t);
	return widget;
end

SceneLoader.loadButton2 = function(t)
	local widget = BYUI.Button{
								size = (t.btnW and t.btnH) and Point(t.btnW,t.btnH) or nil;
								image = {
									normal = SceneLoader.getButtonImage("normal",t,1),
									down = SceneLoader.getButtonImage("down",t,2),
									disabled = SceneLoader.getButtonImage("disable",t,3),
								},
								align = t.l_nodeAlign,
								v_border = {t.rLeft or 0,t.rTop or 0,t.rRight or 0,t.rBottom or 0},
								margin = {t.mLeft or 0,t.mTop or 0,t.mRight or 0,t.mBottom or 0},
								text = t.string}
	SceneLoader.setBaseInfo(widget,t);
	return widget;
end

SceneLoader.loadSimpleButton2 = function(t)
	local widget = BYUI.Button{
								size = (t.btnW and t.btnH) and Point(t.btnW,t.btnH) or nil;
								image = {
									normal = SceneLoader.getButtonImage("normal",t,1),
									down = SceneLoader.getButtonImage("down",t,2),
									disabled = SceneLoader.getButtonImage("disable",t,3),
								},
								align = t.l_nodeAlign,
								v_border = {t.rLeft or 0,t.rTop or 0,t.rRight or 0,t.rBottom or 0},
								margin = {t.mLeft or 0,t.mTop or 0,t.mRight or 0,t.mBottom or 0},
								text = ""}
	SceneLoader.setBaseInfo(widget,t);
	return widget;
end

SceneLoader.loadToggleButton2 = function(t)
	local widget = BYUI.ToggleButton{
								size = (t.btnW and t.btnH) and Point(t.btnW,t.btnH) or nil;
								image = {
									checked_enabled = SceneLoader.getButtonImage("cEnabled",t,1),
					                unchecked_enabled = SceneLoader.getButtonImage("uEnabled",t,2),
					                checked_disabled = SceneLoader.getButtonImage("cDisabled",t,3),
					                unchecked_disabled = SceneLoader.getButtonImage("uDisabled",t,4)},
								align = t.l_nodeAlign,
								v_border = {t.rLeft or 0,t.rTop or 0,t.rRight or 0,t.rBottom or 0},
								margin = {t.mLeft or 0,t.mTop or 0,t.mRight or 0,t.mBottom or 0},
								text = t.string}
	SceneLoader.setBaseInfo(widget,t);
	return widget;
end

SceneLoader.loadImage2 = function(t)
	local widget = BorderSprite();

	widget.unit = TextureUnit.load(t.file);
	
	widget.t_border = {t.gridLeft or 0,t.gridTop or 0,t.gridRight or 0,t.gridBottom or 0};
	widget.v_border = {t.rLeft or 0,t.rTop or 0,t.rRight or 0,t.rBottom or 0};
	widget.size = Point(t.width,t.height);
	SceneLoader.setBaseInfo(widget,t);

	return widget;
end

SceneLoader.loadRoundedView2 = function(t)
	local widget = RoundedView();
	widget.colorf = Colorf(t.fillColorR,t.fillColorG,t.fillColorB,t.fillColorA or 1);
	widget.v_border = {t.rLeft or 0,t.rTop or 0,t.rRight or 0,t.rBottom or 0};
	SceneLoader.setBaseInfo(widget,t);
	return widget;
end

SceneLoader.loadLabel2 = function(t)
	local  widget = Label();
	widget.layout_size = Point(t.width,t.height);
	widget:set_rich_text(t.string);
	widget.align_h = t.alignH;
	widget.align_v = t.alignV;
	SceneLoader.setBaseInfo(widget,t);
	return widget;
end

SceneLoader.loadEditBox2 = function(t)
	local  widget = BYUI.EditBox{
								text = t.string,
								background_style = t.editorBg,
								icon_style = t.editorStyle,
							};
	widget.hint_text = t.hint_text;
	SceneLoader.setBaseInfo(widget,t);
	return widget;
end

SceneLoader.loadMultilineEditBox2 = function(t)
	local  widget = BYUI.MultilineEditBox{
								text = t.string,
							};
	widget.hint_text = t.hint_text;
	SceneLoader.setBaseInfo(widget,t);
	return widget;
end

SceneLoader.loadSwitch2 = function(t)
	local widget = BYUI.Switch{
							on_tint = Colorf(t.foreColorR,t.foreColorG,t.foreColorB,t.foreColorA or 1),
							off_tint = Colorf(t.bgColorR,t.bgColorG,t.bgColorB,t.bgColorA or 1),
							thumb_tint = Colorf(t.btnColorR,t.btnColorG,t.btnColorB,t.btnColorA or 1),
						};
	SceneLoader.setBaseInfo(widget,t);
	return widget;
end

SceneLoader.loadProgressBar2 = function(t)
	local widget = BYUI.ProgressBar{size=Point(t.width,t.height),
									base_color = Colorf(t.bgColorR,t.bgColorG,t.bgColorB,t.bgColorA or 1),
									progress_color = Colorf(t.foreColorR,t.foreColorG,t.foreColorB,t.foreColorA or 1)};
	widget.value = t.initValue or 0;
	SceneLoader.setBaseInfo(widget,t);
	return widget;
end

SceneLoader.loadSlider2 = function(t)
	local widget = BYUI.Slider{width=t.width,
								base_color = Colorf(t.bgColorR,t.bgColorG,t.bgColorB,t.bgColorA or 1),
								progress_color = Colorf(t.foreColorR,t.foreColorG,t.foreColorB,t.foreColorA or 1),
								thumb_color = Colorf(t.btnColorR,t.btnColorG,t.btnColorB,t.btnColorA or 1)};
	widget.value = t.initValue or 0;
	SceneLoader.setBaseInfo(widget,t);
	return widget;
end

SceneLoader.loadCheckBox2 = function(t)
	local widget = BYUI.Checkbox{image = {
					                checked_enabled = SceneLoader.getButtonImage("cEnabled",t,1),
					                unchecked_enabled = SceneLoader.getButtonImage("uEnabled",t,2),
					                checked_disabled = SceneLoader.getButtonImage("cDisabled",t,3),
					                unchecked_disabled = SceneLoader.getButtonImage("uDisabled",t,4)},
					            size = Point(t.width,t.height),
					            checked = true};
	widget.v_border = {t.rLeft or 0,t.rTop or 0,t.rRight or 0,t.rBottom or 0};
	SceneLoader.setBaseInfo(widget,t);
	return widget;
end

SceneLoader.loadScrollView2 = function(t)
	local widget = BYUI.ScrollView{size=Point(t.width,t.height)};
	SceneLoader.setBaseInfo(widget,t);
	return widget;
end

SceneLoader.loadListView2 = function(t)
	local widget = BYUI.ListView{size=Point(t.width,t.height)};
	SceneLoader.setBaseInfo(widget,t);
	return widget;
end

SceneLoader.loadPageView2 = function(t)
	local widget = BYUI.PageView{
								size=Point(t.width,t.height)
							};
	SceneLoader.setBaseInfo(widget,t);
	return widget;
end

SceneLoader.loadFloatLayout2 = function(t)
	local widget = BYLayout.FloatLayout{size=Point(t.width,t.height)};
	SceneLoader.setBaseInfo(widget,t);
	return widget;
end

SceneLoader.loadGridLayout2 = function(t)
	local widget = BYLayout.GridLayout{size=Point(t.width,t.height)};
	SceneLoader.setBaseInfo(widget,t);
	return widget;
end

SceneLoader.loadLoading2 = function(t)
	local widget = BYUI.Loading{style=t.loadingStyle};
	-- widget:start_animating();
	SceneLoader.setBaseInfo(widget,t);
	return widget;
end

SceneLoader.loadSectionView2 = function(t)
	local widget = BYUI.SectionView{};
	SceneLoader.setBaseInfo(widget,t);
	return widget;
end

SceneLoader.loadRadioButtonGroup2 = function(t)
	local widget = BYUI.RadioContainer{}
	SceneLoader.setBaseInfo(widget,t);
	return widget;
end

SceneLoader.loadRadioButton2 = function(t)
	local widget = BYUI.RadioButton{image = {
					                checked_enabled = SceneLoader.getButtonImage("cEnabled",t,1),
					                unchecked_enabled = SceneLoader.getButtonImage("uEnabled",t,2),
					                checked_disabled = SceneLoader.getButtonImage("cDisabled",t,3),
					                unchecked_disabled = SceneLoader.getButtonImage("uDisabled",t,4)},
					            	size = Point(t.width,t.height)};
	widget.v_border = {t.rLeft or 0,t.rTop or 0,t.rRight or 0,t.rBottom or 0};
	SceneLoader.setBaseInfo(widget,t);
	return widget;
end

SceneLoader.loadFuncMap = {
	["View"]				= SceneLoader.loadNilNode;
	["Button"]				= SceneLoader.loadButton;
	["Image"]				= SceneLoader.loadImage;
	["Text"]				= SceneLoader.loadText;
	["TextView"]			= SceneLoader.loadTextView;
	["EditText"]			= SceneLoader.loadEditText;
	["EditTextView"]		= SceneLoader.loadEditTextView;
	["CheckBoxGroup"]		= SceneLoader.loadCheckBoxGroup;
	["CheckBox"]			= SceneLoader.loadCheckBox;
	["RadioButtonGroup"]	= SceneLoader.loadRadioButtonGroup;
	["RadioButton"]			= SceneLoader.loadRadioButton;
	["AutoScrollView"]		= SceneLoader.loadAutoScrollView;
	["ScrollView"]			= SceneLoader.loadScrollView;
	["Slider"]				= SceneLoader.loadSlider;
	["Switch"]				= SceneLoader.loadSwitch;
	["ListView"]			= SceneLoader.loadListView;
	["ViewPager"]			= SceneLoader.loadViewPager;
	["Swf"]					= SceneLoader.loadSwf;
	["Preset"]              = SceneLoader.loadPreset;

	------byui-----
	["View2"]               = SceneLoader.loadView2;
	["RoundedView2"]        = SceneLoader.loadRoundedView2; --
	["Button2"]             = SceneLoader.loadButton2;               -- on_click
	["ToggleButton2"]       = SceneLoader.loadToggleButton2;         -- on_change
	["Image2"]              = SceneLoader.loadImage2;
	["Label2"]              = SceneLoader.loadLabel2;
	["EditBox2"]            = SceneLoader.loadEditBox2;              -- on_text_changed
	["MultilineEditBox2"]   = SceneLoader.loadMultilineEditBox2;     -- on_text_changed
	["Switch2"]             = SceneLoader.loadSwitch2;               -- on_change
	["ProgressBar2"]        = SceneLoader.loadProgressBar2;
	["Slider2"]             = SceneLoader.loadSlider2;
	["CheckBox2"]           = SceneLoader.loadCheckBox2;             -- on_change
	["ScrollView2"]         = SceneLoader.loadScrollView2;
	["ListView2"]           = SceneLoader.loadListView2;
	["FloatLayout2"]        = SceneLoader.loadFloatLayout2;
	["Loading2"]            = SceneLoader.loadLoading2;
	["PageView2"]           = SceneLoader.loadPageView2;
	["GridLayout2"]         = SceneLoader.loadGridLayout2;
	["RadioButtonGroup2"]   = SceneLoader.loadRadioButtonGroup2;
	["Radiobutton2"]        = SceneLoader.loadRadioButton2;          -- on_change
	["SimpleButton2"]       = SceneLoader.loadSimpleButton2;
};


end
        

package.preload[ "editorRT.sceneLoader" ] = function( ... )
    return require('editorRT/sceneLoader')
end
            

package.preload[ "editorRT/version" ] = function( ... )
--返回EditorRT版本号

return '3.1(d320db408d31cd3250ca811a969b70fcab7db33f)'

end
        

package.preload[ "editorRT.version" ] = function( ... )
    return require('editorRT/version')
end
            
require("editorRT.sceneLoader");
require("editorRT.version");