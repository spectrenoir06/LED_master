uniform float iTime;
uniform vec3 iResolution;


#define FALLING_SPEED  0.25
#define STRIPES_FACTOR 1.0

//get sphere
float sphere(vec2 coord, vec2 pos, float r) {
    vec2 d = pos - coord;
    return smoothstep(60.0, 0.0, dot(d, d) - r * r);
}

//main
vec4 effect( vec4 color, Image tex, vec2 texture_coords, vec2 screen_coords)
{
    //normalize pixel coordinates
    vec2 uv = screen_coords / iResolution.xy;
    //pixellize uv
    vec2 clamped_uv = ((screen_coords / STRIPES_FACTOR) * STRIPES_FACTOR) / iResolution.xy;
    //get pseudo-random value for stripe height
    float value = fract(sin(clamped_uv.x) * 43758.5453123);
    //create stripes
    vec3 col = vec3(1.0 - mod(uv.y * 0.5 + (iTime * (FALLING_SPEED + value / 5.0)) + value, 0.5));
    //add color
    col *= clamp(cos(iTime * 2.0 + uv.xyx + vec3(0, 2, 4)), 0.0, 1.0);
    //add glowing ends
    // col += vec3(
    //     sphere(screen_coords, vec2(clamped_uv.x, (1.0 - 2.0 * mod((iTime * (FALLING_SPEED + value / 5.0)) + value, 0.5))) * iResolution.xy, 0.9)
    // ) / 2.0;
    //add screen fade
    // col *= vec3(exp(-pow(abs(uv.y - 0.5), 6.0) / pow(2.0 * 0.05, 2.0)));
    // Output to screen
    return vec4(col,1.0);
}
