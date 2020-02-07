uniform float iTime;
uniform vec3 iResolution;
uniform float density;


#define FALLING_SPEED  0.25
#define STRIPES_FACTOR 1.0

vec3 hsb2rgb( in vec3 c ){
    vec3 rgb = clamp(abs(mod(c.x*6.0+vec3(0.0,4.0,2.0),
    6.0)-3.0)-1.0,
    0.0,
    1.0 );
    rgb = rgb*rgb*(3.0-2.0*rgb);
    return c.z * mix( vec3(1.0), rgb, c.y);
}


//main
vec4 effect( vec4 color, Image tex, vec2 texture_coords, vec2 screen_coords)
{
    //normalize pixel coordinates
    vec2 uv = screen_coords / iResolution.xy;
    //pixellize uv
    vec2 clamped_uv = (floor(screen_coords / density) * density) / iResolution.xy;
    //get pseudo-random value for stripe height
    float value = fract(sin(clamped_uv.x) * 43758.5453123);
    //create stripes
    vec3 col = vec3(1.0 - mod(uv.y * 0.5 - (iTime * (FALLING_SPEED + value / 5.0)) + value, 0.5));
    //add color
    col *= hsb2rgb(vec3(iTime/4.0-uv.y/4.0/8.0,1,1));
    return vec4(col,1.0) * color;
}
