#pragma language glsl3

uniform highp float iTime;
uniform highp float density;
uniform vec3 iResolution;

vec4 effect(vec4 color, Image tex, vec2 texture_coords, vec2 screen_coords)
{
	vec2 z = 1.15*(-iResolution.xy+2.0*screen_coords.xy)/iResolution.y;

	vec2 an = 0.51*cos( vec2(0.0,1.5708) + 0.1*iTime ) - 0.25*cos( vec2(0.0,1.5708) + 0.2*iTime );

	float f = 1e20;
	for( int i=0; i<128; i++ )
	{
		z = vec2( z.x*z.x-z.y*z.y, 2.0*z.x*z.y ) + an;
		f = min( f, dot(z,z) );
	}

	f = 1.0+log(f)/16.0;

	return vec4(1.0-f,1.0-f*f,1.0-f*f*f,1.0);
}
