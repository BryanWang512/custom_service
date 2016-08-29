local M = {}
local function create_fbo_nvg(size, draw)
    local nvg = Nanovg(bit.bor(Nanovg.NVG_ANTIALIAS, Nanovg.NVG_DEBUG, Nanovg.NVG_STENCIL_STROKES))
    local container = Widget()
    container.size = size
    container.cache = true
    container.fbo.need_stencil = true
    local inst = LuaInstruction(function(self, canvas)
        nvg:begin_frame(canvas)
        draw(nvg)
        nvg:end_frame()
    end, true)
    local node = LuaWidget{
        do_draw = function(self, canvas)
            canvas:add(inst)
        end,
    }
    node.size = size
    container:add(node)
    --container.flip_vertical = true
    return {
        widget = container,
        innerNode = node,
        invalidate = function()
            node:invalidate()
        end,
    }
end

local function draw_button(nvg, size)
	local radius = 4
    local bg = nvg:linear_gradient(Point(0,0), Point(0, size.y), Colorf(1,1,1,32/255), Colorf(0,0,0,32/255))
    nvg:begin_path()
    nvg:rounded_rect(Rect(1, 1, size.x-2, size.y-2), radius-1)

    nvg:fill_color(Colorf(0,96/255,128/255,1));
    nvg:fill()

    nvg:fill_paint(bg)
    nvg:fill()

    nvg:begin_path()
    nvg:rounded_rect(Rect(0.5, 0.5, size.x-1, size.y-1), radius-0.5)
    nvg:stroke_color(Colorf(0,0,0,48/255))
    nvg:stroke()
end
local function draw_lines(nvg, r, t)
	local pad = 5.0
    local s = r.w/9.0 - pad*2
	local pts = {}
    local fx, fy
	local joins = {Nanovg.NVG_ROUND, Nanovg.NVG_BEVEL}
    joins[0] = Nanovg.NVG_MITER
	local caps = {Nanovg.NVG_ROUND, Nanovg.NVG_SQUARE}
    caps[0] = Nanovg.NVG_BUTT

    nvg:save()
	pts[0] = -s*0.25 + math.cos(t*0.3) * s*0.5;
	pts[1] = math.sin(t*0.3) * s*0.5;
	pts[2] = -s*0.25;
	pts[3] = 0;
	pts[4] = s*0.25;
	pts[5] = 0;
	pts[6] = s*0.25 + math.cos(-t*0.3) * s*0.5;
	pts[7] = math.sin(-t*0.3) * s*0.5;

    for i=0,2 do
        for j=0,2 do
			fx = r.x + s*0.5 + (i*3+j)/9.0*r.w + pad;
			fy = r.y - s*0.5 + pad;

            nvg:line_cap(caps[i])
            nvg:line_join(joins[j])

            nvg:stroke_width(s*0.3)
            nvg:stroke_color(Colorf(0,0,0,160/255))
            nvg:begin_path()
			nvg:move_to(Point(fx+pts[0], fy+pts[1]))
			nvg:line_to(Point(fx+pts[2], fy+pts[3]))
			nvg:line_to(Point(fx+pts[4], fy+pts[5]))
			nvg:line_to(Point(fx+pts[6], fy+pts[7]))
			nvg:stroke()

            nvg:line_cap(Nanovg.NVG_BUTT)
            nvg:line_join(Nanovg.NVG_BEVEL)

			nvg:stroke_width(1.0)
			nvg:stroke_color(Colorf(0,192/255,1,1))
			nvg:begin_path()
			nvg:move_to(Point(fx+pts[0], fy+pts[1]))
			nvg:line_to(Point(fx+pts[2], fy+pts[3]))
			nvg:line_to(Point(fx+pts[4], fy+pts[5]))
			nvg:line_to(Point(fx+pts[6], fy+pts[7]))
			nvg:stroke()
        end
    end

    nvg:restore()
end
local function draw_graph(nvg, r, t)
    nvg:begin_path()
    nvg:rect(r)
    local bg = nvg:linear_gradient(r:point(), Point(r.x+r.w,r.y+r.h), Colorf(1,1,1,1), Colorf(1,0,0,0.5))
    nvg:fill_paint(bg)
    nvg:fill()
    nvg:stroke_color(Colorf(1,1,1,1))
    nvg:stroke()

	local dx = r.w/5.0

    local samples = {}
	samples[0] = (1+math.sin(t*1.2345+math.cos(t*0.33457)*0.44))*0.5;
	samples[1] = (1+math.sin(t*0.68363+math.cos(t*1.3)*1.55))*0.5;
	samples[2] = (1+math.sin(t*1.1642+math.cos(t*0.33457)*1.24))*0.5;
	samples[3] = (1+math.sin(t*0.56345+math.cos(t*1.63)*0.14))*0.5;
	samples[4] = (1+math.sin(t*1.6245+math.cos(t*0.254)*0.3))*0.5;
	samples[5] = (1+math.sin(t*0.345+math.cos(t*0.03)*0.6))*0.5;

    local sx = {}
    local sy = {}
    for i=0,5 do
		sx[i] = r.x+i*dx
		sy[i] = r.y+r.h*samples[i]*0.8
    end

    local bg = nvg:linear_gradient(r:point(), Point(r.x, r.y+r.h), Colorf(0, 160/255, 192/255, 0), Colorf(0, 160/255, 192/255, 64/255))
	nvg:begin_path()
    nvg:move_to(Point(sx[0], sy[0]))
    for i=1,5 do
        nvg:bezier_to(Point(sx[i-1]+dx*0.5,sy[i-1]), Point(sx[i]-dx*0.5,sy[i]), Point(sx[i],sy[i]))
    end
    nvg:line_to(Point(r.x+r.w, r.y+r.h))
    nvg:line_to(Point(r.x, r.y+r.h))
    nvg:fill_paint(bg)
    nvg:fill()

	-- Graph line
    nvg:begin_path()
    nvg:move_to(Point(sx[0], sy[0]+2))
    for i=1,5 do
        nvg:bezier_to(Point(sx[i-1]+dx*0.5,sy[i-1]+2), Point(sx[i]-dx*0.5,sy[i]+2), Point(sx[i],sy[i]+2))
    end
    nvg:stroke_color(Colorf(0,0,0,32/255))
    nvg:stroke_width(3)
    nvg:stroke()

    nvg:begin_path()
    nvg:move_to(Point(sx[0], sy[0]))
    for i=1,5 do
        nvg:bezier_to(Point(sx[i-1]+dx*0.5,sy[i-1]), Point(sx[i]-dx*0.5,sy[i]), Point(sx[i],sy[i]))
    end
    nvg:stroke_color(Colorf(0, 160/255, 192/255, 1))
    nvg:stroke_width(3)
    nvg:stroke()

	-- Graph sample pos
    for i=0,5 do
        local bg = nvg:radial_gradient(Point(sx[i],sy[i]+2), 3.0,8.0, Colorf(0,0,0,32/255), Colorf(0,0,0,0))
        nvg:begin_path()
        nvg:rect(Rect(sx[i]-10, sy[i]-10+2, 20,20))
        nvg:fill_paint(bg)
        nvg:fill()
    end

    nvg:begin_path()
    for i=0,5 do
        nvg:circle(Point(sx[i], sy[i]), 4)
    end
    nvg:fill_color(Colorf(0,160/255,192/255,1))
    nvg:fill()
    nvg:begin_path()
    for i=0,5 do
        nvg:circle(Point(sx[i], sy[i]), 2)
    end
    nvg:fill_color(Colorf(220/255,220/255,220/255,1))
    nvg:fill()
end
local function draw_scissor(nvg, t)
    nvg:save()

	-- Draw first rect and set scissor to it's area.
	nvg:rotate(Nanovg.deg2rad(5))
	nvg:begin_path()
	nvg:rect(Rect(-20,-20,60,40))
	nvg:fill_color(Colorf(1,0,0,1));
	nvg:fill()
	nvg:scissor(Rect(-20,-20,60,40))

	-- Draw second rectangle with offset and rotation.
	nvg:translate(Point(40,0))
	nvg:rotate(t)

	-- Draw the intended second rectangle without any scissoring.
	nvg:save()
	nvg:reset_scissor()
	nvg:begin_path()
	nvg:rect(Rect(-20,-10,60,30))
	nvg:fill_color(Colorf(1,0.5,0,0.25))
	nvg:fill()
	nvg:restore()

	-- Draw second rectangle with combined scissoring.
	nvg:intersect_scissor(Rect(-20,-10,60,30))
	nvg:begin_path()
	nvg:rect(Rect(-20,-10,60,30))
	nvg:fill_color(Colorf(1,0.5,0,1))
	nvg:fill()

	nvg:restore()
end

local function draw_colorwheel(nvg, t, s)
	local hue = math.sin(t * 0.12);

    local w = s.x
    local h = s.y
    local center = Point(s.x*0.5, s.y*0.5)
	local r1 = (w < h and w or h) * 0.5 - 5.0
	local r0 = r1 - 20.0
	local aeps = 0.5 / r1 -- half a pixel arc length in radians (2pi cancels out).

    for i=0,6 do
		local a0 = i / 6.0 * math.pi * 2.0 - aeps;
		local a1 = (i+1.0) / 6.0 * math.pi * 2.0 + aeps;
        nvg:begin_path();
        nvg:arc(center, r0, a0, a1, Nanovg.NVG_CW)
		nvg:arc(center, r1, a1, a0, Nanovg.NVG_CCW)
        nvg:close_path()
        local a = center + Point(math.cos(a0) * (r0+r1)*0.5, math.sin(a0) * (r0+r1)*0.5)
        local b = center + Point(math.cos(a1) * (r0+r1)*0.5, math.sin(a1) * (r0+r1)*0.5)
		local paint = nvg:linear_gradient(a, b, Colorf.hsla(a0/(math.pi*2),1.0,0.55,1), Colorf.hsla(a1/(math.pi*2),1.0,0.55,1))
		nvg:fill_paint(paint)
		nvg:fill()
    end

	nvg:begin_path()
	nvg:circle(center, r0-0.5)
	nvg:circle(center, r1+0.5)
	nvg:stroke_color(Colorf(0,0,0,64/255))
	nvg:stroke_width(1)
	nvg:stroke()

	nvg:translate(center)
    nvg:rotate(hue*math.pi*2)

	nvg:stroke_width(2.0)
	nvg:begin_path()
	nvg:rect(Rect(r0-1,-3,r1-r0+2,6))
	nvg:stroke_color(Colorf(1,1,1,192/255))
	nvg:stroke()

	local paint = nvg:box_gradient(Rect(r0-3,-5,r1-r0+6,10), 2,4, Colorf(0,0,0,0.5), Colorf(0,0,0,0))
	nvg:begin_path()
	nvg:rect(Rect(r0-2-10,-4-10,r1-r0+4+20,8+20))
	nvg:rect(Rect(r0-2,-4,r1-r0+4,8))
	nvg:path_winding(Nanovg.NVG_HOLE)
	nvg:fill_paint(paint)
	nvg:fill()

	-- Center triangle
	local r = r0 - 6;
	a = Point(math.cos( 120.0/180.0*math.pi) * r, math.sin( 120.0/180.0*math.pi) * r)
	b = Point(math.cos(-120.0/180.0*math.pi) * r, math.sin(-120.0/180.0*math.pi) * r)
	nvg:begin_path()
	nvg:move_to(Point(r,0))
	nvg:line_to(a)
	nvg:line_to(b)
	nvg:close_path()
	paint = nvg:linear_gradient(Point(r,0), a, Colorf.hsla(hue,1.0,0.5,1), Colorf.hsla(1,1,1,1))
	nvg:fill_paint(paint)
    nvg:fill()
	paint = nvg:linear_gradient(Point((r+a.x)*0.5,(0+a.y)*0.5), b, Colorf(0,0,0,0), Colorf(0,0,0,1))
	nvg:fill_paint(paint)
	nvg:fill()
	nvg:stroke_color(Colorf(0,0,0,64/255))
	nvg:stroke()

	-- Select circle on triangle
	a = Point(math.cos(120.0/180.0*math.pi) * r*0.3, math.sin(120.0/180.0*math.pi) * r*0.4)
	nvg:stroke_width(2.0)
	nvg:begin_path()
	nvg:circle(a,5)
	nvg:stroke_color(Colorf(1,1,1,192/255))
	nvg:stroke()

	paint = nvg:radial_gradient(a, 7,9, Colorf(0,0,0,64/255), Colorf(0,0,0,0))
	nvg:begin_path()
	nvg:rect(Rect(a.x-20,a.y-20,40,40))
	nvg:circle(a,7);
	nvg:path_winding(Nanovg.NVG_HOLE)
	nvg:fill_paint(paint)
	nvg:fill()
end

local function draw_demo(nvg, t, s)
    nvg:begin_path()
    nvg:rect(Rect(0,0,s.x,s.y))
    nvg:fill_color(Colorf(1,1,1,0.8))
    nvg:fill()

    --nvg:translate(Point(300,300))
    --nvg:begin_path()
    --nvg:move_to(Point(0,0))
    --nvg:bezier_to(Point(100,40), Point(300,50), Point(300,300))
    --nvg:bezier_to(Point(0,40), Point(300,50), Point(300,0))
    --nvg:close_path()
    --nvg:stroke_color(Colorf(1,0,0,1))
    --nvg:fill_paint(nvg:box_gradient(Rect(0,0,300,300), 100, 43, Colorf(0,1,0,1), Colorf(0,0,1,1)))
    --nvg:fill()
    --nvg:stroke()

    nvg:save()
    draw_graph(nvg, Rect(0, 0, 800, 200), t)
    nvg:translate(Point(120, 50))
    draw_lines(nvg, Rect(0,0, 600, 50), t)
    --nvg:translate(Point(100,100))
    --draw_scissor(nvg, t)

    nvg:restore()
    nvg:save()
    nvg:translate(Point(150,400))
    draw_button(nvg, Point(140,56))

    nvg:restore()
    nvg:save()
    nvg:translate(Point(400,150))
    draw_colorwheel(nvg, t, Point(300,300))
end

function M.demo(size)
    local t = 0
    local obj = create_fbo_nvg(size, function(nvg)
        nvg:scale(Point(2,2))
        draw_demo(nvg, t, size)
    end)
    local handle = Clock.instance():schedule(function(dt)
        t = t + dt
        obj:invalidate()
    end)
    return obj, handle
end

function M.button(size)
    return create_fbo_nvg(size, function(nvg)
        draw_button(nvg, size)
    end)
end

function M.countdown(r)
    local center = Point(r+1,r+1)
    local t = 0
    local obj = create_fbo_nvg(Point((r+2)*2,(r+2)*2), function(nvg)
        if t >= math.pi * 2 then
            t = 0
        end

        local bg = nvg:radial_gradient(center, 0, r, Colorf(0.8,0.8,0.8,1), Colorf(0.5,0.5,0.5,1))
        nvg:begin_path()
        nvg:move_to(center)
        nvg:arc(center, r, math.pi/2, math.pi * 5 / 2 - t, Nanovg.NVG_CW)
        nvg:close_path()
        nvg:fill_paint(bg)
        nvg:fill()
        nvg:stroke_width(2)
        nvg:stroke_color(Colorf(1,1,1))
        nvg:stroke()
    end)
    local handle = Clock.instance():schedule(function(dt)
        t = t + dt
        obj:invalidate()
    end)
    return obj, handle
end

function M.test(root)
    local o, handle = M.demo(root.size)
    root:add(o.widget)
    local o, handle = M.countdown(100)
    root:add(o.widget)
end

M.test_scene = {
    duration = 5,
    handles = {},
    widget = nil,
    create = function(self, size)
        root = Widget(size)
        local o, handle = M.demo(size)
        root:add(o.widget)
        handle.paused = true
        table.insert(self.handles, handle)
        local o, handle = M.countdown(100)
        root:add(o.widget)
        handle.paused = true
        table.insert(self.handles, handle)
        self.widget = root
    end,
    start = function(self)
        for _, h in ipairs(self.handles) do
            h.paused = false
        end
    end,
    stop = function(self)
        for _, h in ipairs(self.handles) do
            h:cancel()
        end
        self.handles = {}
    end,
    delete = function(self)
        if self.widget ~= nil then
            self.widget:remove_from_parent()
            self.widget = nil
        end
    end,
}

return M
