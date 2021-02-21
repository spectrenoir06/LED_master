// #pragma language glsl3

uniform highp float iTime;
uniform vec3 iResolution;
//vec4 effect( vec4 color, Image tex, vec2 texture_coords, vec2 screen_coords)
//{
//	    return vec4(0,0,0,1);
//}


//void mainImage( out vec4 fragColor, in vec2 fragCoord )
vec4 effect( vec4 color, Image tex, vec2 texture_coords, vec2 screen_coords)
{
    // Normalized pixel coordinates (from 0 to 1)
    vec2 uv = texture_coords-vec2(0.5,0.0);//(screen_coords-iResolution.xy*.5/**sin(iTime*.5)*-.5+.5*/)/iResolution.y+.5;
	vec2 gv = vec2(uv.x * 5., -.25+uv.y * 5.);
    float rad = .25;
    float dist = length(gv)-rad;
    // Time varying pixel color
    vec3 col =atan(gv.x*uv.x*.5, gv.y) + .618 *cos(iTime+dist+vec3(0,2,4));

    // Output to screen
    return vec4(col,1.0);
}
