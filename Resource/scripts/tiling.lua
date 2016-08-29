local M = {}
local vs = [[
#ifdef GL_ES
precision highp float;
#endif

uniform     mat4    projection;
uniform     mat4    modelview;
uniform     vec4    color;
uniform     float   opacity;

attribute   vec2    position;
attribute   vec2    texcoord0;
attribute   float   tiling_index;

varying     vec2    varyTexCoord;
varying     vec4    varyColor;
varying     float   varyIndex;

void main (void)
{
    gl_Position = projection * modelview * vec4(position,0,1);
    varyColor = color * vec4(1, 1, 1, opacity);

    varyTexCoord = texcoord0;
    varyIndex = tiling_index;
}]];

local fs = [[
#ifdef GL_ES
precision highp float;
#endif

uniform     sampler2D   texture0;
uniform     sampler2D   texture1;

varying     vec2        varyTexCoord;
varying     vec4        varyColor;
varying     float       varyIndex;

void main (void)
{
    vec4 rect = texture2D(texture1, vec2(0, varyIndex));
    vec2 coord = vec2(
        fract(varyTexCoord.x) * rect.z + rect.x,
        fract(varyTexCoord.y) * rect.w + rect.y
    );

    gl_FragColor = varyColor * texture2D(texture0, coord);
}
]];

local _atlas_tiling_shader
function M.get_shader()
    if _atlas_tiling_shader == nil then
        local uniforms = ShaderRegistry.instance().default_desc[3]
        table.insert(uniforms, {
            'texture1', gl.GL_INT, 1, Shader.uniform_value_int(1)
        })
        _atlas_tiling_shader = ShaderRegistry.instance():register_shader_desc{
            vs,fs,uniforms
        }
    end
    return _atlas_tiling_shader
end

local _atlas_tiling_vertex_format
function M.get_vertex_format()
    if _atlas_tiling_vertex_format == nil then
        local v = VBO.default_format_desc()
        table.insert(v, {'tiling_index', 1, gl.GL_FLOAT})
        _atlas_tiling_vertex_format = VBO.register_vertex_format(v)
    end
    return _atlas_tiling_vertex_format
end

function M.TileManager(capacity)
    local texture = DataTexture.create(nil, Point(1, capacity), gl.GL_RGBA, gl.GL_UNSIGNED_BYTE)
    local cache = {}
    local uniq = 0
    return {
        texture = texture,
        register = function(self, rect)
            if uniq > capacity then
                return -1
            end
            local key = tostring(rect)
            if cache[key] == nil then
                cache[key] = uniq
                --print('rect', rect)
                local m = math.pow(2, 8)-1
                local buf = struct.pack('BBBB', rect.x * m, rect.y * m, rect.w * m, rect.h * m)
                texture:update(Point(0, uniq), Point(1,1), buf)
                uniq = uniq + 1
            end
            return cache[key]
        end,
    }
end
M.tilingManager = M.TileManager(1024)

function M.tile_rectangle(size, matrix, uv_rect, tiling_index)
    local fmt = 'ffffff'
    return LuaVertexBuilder(M.get_vertex_format(), gl.GL_TRIANGLES, function()
        local pos = {
            matrix:transform_point(Point(0,      0)),
            matrix:transform_point(Point(size.x, 0)),
            matrix:transform_point(Point(size.x, size.y)),
            matrix:transform_point(Point(0,      size.y))
        }
        local uv = {
            Point(uv_rect.x,             uv_rect.y),
            Point(uv_rect.x + uv_rect.w, uv_rect.y),
            Point(uv_rect.x + uv_rect.w, uv_rect.y + uv_rect.h),
            Point(uv_rect.x,             uv_rect.y + uv_rect.h)
        }
        local vertexes = {}
        for i=1,4 do
            table.insert(vertexes, struct.pack(fmt, pos[i].x, pos[i].y, 0, uv[i].x, uv[i].y, tiling_index))
        end
        return vertexes, {0,1,2,2,3,0}
    end)
end

function M.tile_sprite(unit, uv_offset)
    local tile_index = M.tilingManager:register(unit.uv_rect)
    if tile_index == -1 then
        return
    end
    uv_offset = uv_offset or Point(0,0)
    local sprite = LuaWidget{
        do_draw = function(self, canvas)
            local size = self.size
            local uv_size = size / unit.size
            local uv_rect = Rect(uv_offset.x, uv_offset.y, uv_size.x, uv_size.y)
            canvas:add(BindTexture(M.tilingManager.texture, 1))
            canvas:add(BindTexture(unit.texture, 0))
            local inst = M.tile_rectangle(self.size, self.relative_matrix, uv_rect, tile_index)
            canvas:add(inst)
        end,
    }
    sprite.size = unit.size
    return {
        widget = sprite,
        set_uv_offset = function(self, offset)
            uv_offset = offset
            sprite:invalidate()
        end,
    }
end

function M.test_widget(size, unit)
    local container = Widget()
    container.shader = M.get_shader()
    local s = M.tile_sprite(unit)
    s.widget.size = size
    container:add(s.widget)
    return {
        widget = container,
        tile_sprite = s,
    }
end

function M.test(root, unit)
    unit = unit or TextureUnit(TextureCache.instance():get('sprite.png'))
    local o = M.test_widget(root.size, unit)
    root:add(o.widget)
    local inc = 0
    return Clock.instance():schedule(function(dt)
        inc = inc + dt
        o.tile_sprite:set_uv_offset(Point(inc,inc))
    end)
end

return M
