local vert_src = [[
#ifdef GL_ES
precision highp float;
#endif

uniform vec4 box;
uniform vec2 window;
uniform float sigma;

attribute   vec2    position;
varying     vec2    vertex;

void main() {
  float padding = 3.0 * sigma;
  vertex = mix(box.xy - padding, box.zw + padding, position);
  gl_Position = vec4(vertex / window * 2.0 - 1.0, 0.0, 1.0);
}]];


local frag_src = [[
#ifdef GL_ES
precision highp float;
#endif

uniform vec4 box;
uniform vec4 color;
uniform float sigma;
uniform float corner;

varying vec2 vertex;

// A standard gaussian function, used for weighting samples
float gaussian(float x, float sigma) {
  const float pi = 3.141592653589793;
  return exp(-(x * x) / (2.0 * sigma * sigma)) / (sqrt(2.0 * pi) * sigma);
}

// This approximates the error function, needed for the gaussian integral
vec2 erf(vec2 x) {
  vec2 s = sign(x), a = abs(x);
  x = 1.0 + (0.278393 + (0.230389 + 0.078108 * (a * a)) * a) * a;
  x *= x;
  return s - s / (x * x);
}

// Return the blurred mask along the x dimension
float roundedBoxShadowX(float x, float y, float sigma, float corner, vec2 halfSize) {
  float delta = min(halfSize.y - corner - abs(y), 0.0);
  float curved = halfSize.x - corner + sqrt(max(0.0, corner * corner - delta * delta));
  vec2 integral = 0.5 + 0.5 * erf((x + vec2(-curved, curved)) * (sqrt(0.5) / sigma));
  return integral.y - integral.x;
}

// Return the mask for the shadow of a box from lower to upper
float roundedBoxShadow(vec2 lower, vec2 upper, vec2 point, float sigma, float corner) {
  // Center everything to make the math easier
  vec2 center = (lower + upper) * 0.5;
  vec2 halfSize = (upper - lower) * 0.5;
  point -= center;

  // The signal is only non-zero in a limited range, so don\'t waste samples
  float low = point.y - halfSize.y;
  float high = point.y + halfSize.y;
  float start = clamp(-3.0 * sigma, low, high);
  float end = clamp(3.0 * sigma, low, high);

  // Accumulate samples (we can get away with surprisingly few samples)
  float step = (end - start) / 4.0;
  float y = start + step * 0.5;
  float value = 0.0;
  for (int i = 0; i < 4; i++) {
    value += roundedBoxShadowX(point.x, point.y - y, sigma, corner, halfSize) * gaussian(y, sigma) * step;
    y += step;
  }

  return value;
}

void main() {
  gl_FragColor = color;
  gl_FragColor.a *= roundedBoxShadow(box.xy, box.zw, vertex, sigma, corner);
}]]

local _shadow_shader = -1
local function get_shadow_shader()
    if _shadow_shader == -1 then
        local uniforms = ShaderRegistry.instance().default_desc[3]
        table.insert(uniforms, {'box', gl.GL_FLOAT_VEC4, 1, Shader.uniform_value_float4(0,0,0,0)})
        table.insert(uniforms, {'window', gl.GL_FLOAT_VEC2, 1, Shader.uniform_value_float2(0,0)})
        table.insert(uniforms, {'sigma', gl.GL_FLOAT, 1, Shader.uniform_value_float(0)})
        table.insert(uniforms, {'corner', gl.GL_FLOAT, 1, Shader.uniform_value_float(0)})
        _shadow_shader = ShaderRegistry.instance():register_shader_desc{
            vert_src, frag_src, uniforms
        }
    end
    return _shadow_shader
end

local _buffer_id = -1
local function get_buffer()
    if _buffer_id == -1 then
        _buffer_id = gl.glGenBuffers(1)
        gl.glBindBuffer(gl.GL_ARRAY_BUFFER, _buffer_id)
        gl.glBufferData(gl.GL_ARRAY_BUFFER, 32, struct.pack('ffffffff', 0, 0, 1, 0, 0, 1, 1, 1), gl.GL_STATIC_DRAW)
        assert(gl.glGetError() == gl.GL_NO_ERROR)
    end
    return _buffer_id
end

local shader = Shader.create(get_shadow_shader())
local function draw_rounded_rect(rect, radius, shadow_offset, shadow_color)
    return LuaInstruction(function(self, canvas)
        shader:use()
        local vp = canvas.current_viewport
        print(vp)
        shader:set_uniform("window", Shader.uniform_value_float2(vp.w, vp.h))

        print(shadow_color)
        shader:set_uniform("color", Shader.uniform_value_color(shadow_color))
        shader:set_uniform("box", Shader.uniform_value_float4(rect.x, rect.y, rect.x+rect.w, rect.y+rect.h))
        shader:set_uniform("corner", Shader.uniform_value_float(radius))
        shader:set_uniform("sigma", Shader.uniform_value_float(1))

        local glid = get_buffer()
        gl.glBindBuffer(gl.GL_ARRAY_BUFFER, glid)
        local loc = 0 -- gl.glGetAttribLocation(shader.id, 'position')
        gl.glEnableVertexAttribArray(loc)
        gl.glVertexAttribPointer(loc, 2, gl.GL_FLOAT, gl.GL_FALSE, 0, 0)

        gl.glDrawArrays(gl.GL_TRIANGLE_STRIP, 0, 4)
        assert(gl.glGetError() == gl.GL_NO_ERROR)

        -- recover
        --canvas:rc().shader:bind_vertex_format(nil)
        --canvas:rc().shader:use()
        --canvas:reset_vbo()
    end, true)
end

return function(root)
    local rc = RenderContext(get_shadow_shader())
    local s = SetState("sigma", Shader.uniform_value_float(20))
    --local unit = TextureUnit(TextureCache.instance():get('sprite.png'))
    local unit = TextureUnit.default_unit()
    local offset = Point(10,10)
    local radius = 10
    local w = LuaWidget{
        do_draw = function(self, canvas)
            local bbox = Rect(self.content_bbox.x, self.content_bbox.y, self.content_bbox.w, self.content_bbox.h)
            canvas:add(draw_rounded_rect(bbox, radius, offset, Colorf.black))
            --bbox.w = bbox.w - 20
            --bbox.h = bbox.h - 20
            --canvas:begin_rc(rc)
            --canvas:add(BindTexture(unit.texture))
            --canvas:add(SetState("color", Shader.uniform_value_color(Colorf.black)))
            --canvas:add(SetState("box", Shader.uniform_value_float4(bbox.x + offset.x, bbox.y + offset.y, bbox.x + bbox.w + offset.x, bbox.y + bbox.h + offset.y)))
            --canvas:add(SetState("corner", Shader.uniform_value_float(radius + 10)))
            --local vp = canvas.current_viewport
            --canvas:add(SetState("window", Shader.uniform_value_float2(vp.w, vp.h)))
            --canvas:add(s)
            --canvas:add(Rectangle(Point(1,1), Matrix(), unit.uv_rect))

            --canvas:add(SetState("corner", Shader.uniform_value_float(radius)))
            --canvas:add(SetState("box", Shader.uniform_value_float4(bbox.x, bbox.y, bbox.x + bbox.w, bbox.y + bbox.h)))
            --canvas:add(SetState("sigma", Shader.uniform_value_float(0.25)))
            --canvas:add(Rectangle(Point(1,1), Matrix(), unit.uv_rect))
            --canvas:end_rc(rc)
        end,
    }
    --w.cache = true
    w.size = Point(200,200)
    root:add(w)

    --w.pos = Point(100,100)
    Clock.instance():schedule(function(dt)
        --w.pos = w.pos + Point(dt * 10, dt * 10)
    end)
end
