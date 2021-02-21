// #pragma language glsl3

uniform highp float iTime;
uniform highp float density;

highp vec3 hsb2rgb( in highp vec3 c ){
    highp vec3 rgb = clamp(abs(mod(c.x*6.0+vec3(0.0,4.0,2.0),
    6.0)-3.0)-1.0,
    0.0,
    1.0 );
    rgb = rgb*rgb*(3.0-2.0*rgb);
    return c.z * mix( vec3(1.0), rgb, c.y);
}

vec4 effect(vec4 color, Image tex, vec2 texture_coords, vec2 screen_coords)
{
    return vec4(hsb2rgb(vec3(texture_coords.x*density+iTime,1,1)), 1.0) * color;

}
