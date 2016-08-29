local M = {}

local shader_header = [[
#ifdef GL_ES
precision highp float;
#endif

varying     vec2        varyTexCoord;
varying     vec4        varyColor;

uniform     sampler2D   texture0;
uniform     sampler2D   texture1;

]]

local shader_uniforms = [[
uniform vec2 resolution;
uniform float time;
uniform float size;
]]

local shader_footer_trivial = [[
void main (void){
     gl_FragColor = frag_color * texture2D(texture0, tex_coord0);
}
]]

local shader_footer_effect = [[
void main (void){
    vec4 normal_color = varyColor * texture2D(texture0, varyTexCoord);
    gl_FragColor = effect(normal_color, texture0, varyTexCoord,
                               gl_FragCoord.xy);
}
]]

local mask_fragment_shader = shader_header .. [[
    uniform vec4 o_color;

    void main()
    {
        vec4 colorT = texture2D(texture0, varyTexCoord);           
        vec4 r_color = colorT * varyColor + vec4(o_color.xyz / 255.0, o_color.a) * colorT.a;
        if(r_color.a < 0.01)
        {
            discard;
        }
        else
        gl_FragColor = clamp(r_color,0.0,1.0);
    }
]]


function effect_frag_shader(s)
    return shader_header .. shader_uniforms .. s .. shader_footer_effect
end

M.shaders = {}
do
    local vs, fs, uniforms = unpack(ShaderRegistry.instance().default_desc)
    M.shaders.mask = ShaderRegistry.instance():register_shader_desc{
        vs, mask_fragment_shader, uniforms
    }

    table.insert(uniforms, {'resolution', gl.GL_FLOAT_VEC2, 1, Shader.uniform_value_float2(0, 0)})
    table.insert(uniforms, {'time', gl.GL_FLOAT, 1, Shader.uniform_value_float(0)})
    table.insert(uniforms, {'size', gl.GL_FLOAT, 1, Shader.uniform_value_float(1)})
    M.shaders.monochrome = ShaderRegistry.instance():register_shader_desc{
        vs, effect_frag_shader[[
vec4 effect(vec4 color, sampler2D texture, vec2 tex_coords, vec2 coords)
{
    float mag = 1.0/3.0 * (color.x + color.y + color.z);
    return vec4(mag, mag, mag, color.w);
}
    ]], uniforms}
    M.shaders.invert = ShaderRegistry.instance():register_shader_desc{
        vs, effect_frag_shader[[
vec4 effect(vec4 color, sampler2D texture, vec2 tex_coords, vec2 coords)
{
    return vec4(1.0 - color.xyz, color.w);
}
    ]], uniforms}

    M.shaders.pixelate = ShaderRegistry.instance():register_shader_desc{
        vs, effect_frag_shader[[
vec4 effect(vec4 vcolor, sampler2D texture, vec2 texcoord, vec2 pixel_coords)
{
    vec2 pixelSize = 10.0 / resolution;
    vec2 xy = floor(texcoord/pixelSize)*pixelSize + pixelSize/2.0;
    return texture2D(texture, xy);
}
    ]], uniforms}
    M.shaders.scanlines = ShaderRegistry.instance():register_shader_desc{
        vs, effect_frag_shader[[
vec4 effect(vec4 color, sampler2D texture, vec2 tex_coords, vec2 coords)
{
    vec2 q = tex_coords * vec2(1, -1);
    vec2 uv = 0.5 + (q-0.5);//*(0.9);// + 0.1*sin(0.2*time));

    vec3 oricol = texture2D(texture,vec2(q.x,1.0-q.y)).xyz;
    vec3 col;

    col.r = texture2D(texture,vec2(uv.x+0.003,-uv.y)).x;
    col.g = texture2D(texture,vec2(uv.x+0.000,-uv.y)).y;
    col.b = texture2D(texture,vec2(uv.x-0.003,-uv.y)).z;

    col = clamp(col*0.5+0.5*col*col*1.2,0.0,1.0);

    //col *= 0.5 + 0.5*16.0*uv.x*uv.y*(1.0-uv.x)*(1.0-uv.y);

    col *= vec3(0.8,1.0,0.7);

    col *= 0.9+0.1*sin(10.0*time+uv.y*1000.0);

    col *= 0.97+0.03*sin(110.0*time);

    float comp = smoothstep( 0.2, 0.7, sin(time) );
    //col = mix( col, oricol, clamp(-2.0+2.0*q.x+3.0*comp,0.0,1.0) );

    return vec4(col, color.w);
}
]], uniforms}
    M.shaders.blur_h = ShaderRegistry.instance():register_shader_desc{
        vs, effect_frag_shader[[
vec4 effect(vec4 color, sampler2D texture, vec2 tex_coords, vec2 coords)
{
    float dt = (size / 4.0) * 1.0 / resolution.x;
    vec4 sum = vec4(0.0);
    sum += texture2D(texture, vec2(tex_coords.x - 4.0*dt, tex_coords.y))
                     * 0.05;
    sum += texture2D(texture, vec2(tex_coords.x - 3.0*dt, tex_coords.y))
                     * 0.09;
    sum += texture2D(texture, vec2(tex_coords.x - 2.0*dt, tex_coords.y))
                     * 0.12;
    sum += texture2D(texture, vec2(tex_coords.x - dt, tex_coords.y))
                     * 0.15;
    sum += texture2D(texture, vec2(tex_coords.x, tex_coords.y))
                     * 0.16;
    sum += texture2D(texture, vec2(tex_coords.x + dt, tex_coords.y))
                     * 0.15;
    sum += texture2D(texture, vec2(tex_coords.x + 2.0*dt, tex_coords.y))
                     * 0.12;
    sum += texture2D(texture, vec2(tex_coords.x + 3.0*dt, tex_coords.y))
                     * 0.09;
    sum += texture2D(texture, vec2(tex_coords.x + 4.0*dt, tex_coords.y))
                     * 0.05;
    return vec4(sum.xyz, color.w);
}
]], uniforms}
    M.shaders.blur_v = ShaderRegistry.instance():register_shader_desc{
        vs, effect_frag_shader[[
vec4 effect(vec4 color, sampler2D texture, vec2 tex_coords, vec2 coords)
{
    float dt = (size / 4.0)
                     * 1.0 / resolution.x;
    vec4 sum = vec4(0.0);
    sum += texture2D(texture, vec2(tex_coords.x, tex_coords.y - 4.0*dt))
                     * 0.05;
    sum += texture2D(texture, vec2(tex_coords.x, tex_coords.y - 3.0*dt))
                     * 0.09;
    sum += texture2D(texture, vec2(tex_coords.x, tex_coords.y - 2.0*dt))
                     * 0.12;
    sum += texture2D(texture, vec2(tex_coords.x, tex_coords.y - dt))
                     * 0.15;
    sum += texture2D(texture, vec2(tex_coords.x, tex_coords.y))
                     * 0.16;
    sum += texture2D(texture, vec2(tex_coords.x, tex_coords.y + dt))
                     * 0.15;
    sum += texture2D(texture, vec2(tex_coords.x, tex_coords.y + 2.0*dt))
                     * 0.12;
    sum += texture2D(texture, vec2(tex_coords.x, tex_coords.y + 3.0*dt))
                     * 0.09;
    sum += texture2D(texture, vec2(tex_coords.x, tex_coords.y + 4.0*dt))
                     * 0.05;
    return vec4(sum.xyz, color.w);
}
]], uniforms}
end

function M.set_blur_h(w, s)
    if s == 0 then
        w.shader = -1
    else
        w.shader = M.shaders.blur_h
        w:set_uniform('size', Shader.uniform_value_float(s))
        w:set_uniform('resolution', Shader.uniform_value_float2(w.width, w.height))
    end
end

return M
