uniform highp float density;
uniform highp float iTime;
uniform vec3 iResolution;

vec3 hsb2rgb( in vec3 c ){
    vec3 rgb = clamp(abs(mod(c.x*6.0+vec3(0.0,4.0,2.0),
    6.0)-3.0)-1.0,
    0.0,
    1.0 );
    rgb = rgb*rgb*(3.0-2.0*rgb);
    return c.z * mix( vec3(1.0), rgb, c.y);
}

vec4 effect(vec4 color, Image tex, vec2 texture_coords, vec2 screen_coords)
{
    highp float PI = 3.1415926;
    vec2 st = texture_coords;

    vec2 toCenter = vec2(0.5)-st;
    highp float radius = length(toCenter)*2.0;
    highp float angle = iTime*2.0 + radius*density;
    vec3 c = vec3((angle/(2.0*PI)),1.0,1.0);

    return vec4(hsb2rgb(c), 1.0) * color;

}
