// #pragma language glsl3

uniform highp float iTime;
uniform vec3 iResolution;
uniform Image fft;


vec4 effect( vec4 color, Image tex, vec2 texture_coords, vec2 screen_coords)
{
	vec2 uv = texture_coords;

	// the sound texture is 512x2
	int tx = int(uv.x*512.0);

	// first row is frequency data (48Khz/4 in 512 texels, meaning 23 Hz per texel)
	// float fft  = texelFetch( fft, ivec2(tx,0), 0 ).x;
	vec4 c = Texel(fft, vec2(uv.x, uv.y));
	return c;


	// convert frequency to colors
	// vec3 col = vec3( fft, 4.0*fft*(1.0-fft), 1.0-fft ) * fft;

	// output final color
	// return vec4(col,1.0);
}
