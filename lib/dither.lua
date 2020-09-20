local function getPixelRgb(src, x, y)
	local r,g,b,a = src:getPixel(x, y)
	return r*255, g*255, b*255, 255
end

local function setPixelRgb(src, x, y, r, g, b)
	src:setPixel(x, y, r/255, g/255, b/255)
end

local function fs_dither_4c(x, maxval, r1, g1, b1, a1, r0, g0, b0, a0)
	return
		math.min(r0 + bit.rshift(x * r1, 4), maxval),
		math.min(g0 + bit.rshift(x * g1, 4), maxval),
		math.min(b0 + bit.rshift(x * b1, 4), maxval),
		255
end

function dither_fs(src, rbits, gbits, bbits, abits)
	local w,h = src:getDimensions()
	local maxbits = 8
	local maxval  = 0xff
	local rmask = 2^(maxbits-rbits)-1
	local gmask = 2^(maxbits-gbits)-1
	local bmask = 2^(maxbits-bbits)-1
	for y = 0, h-1 do
		for x = 0, w-1 do
			local r0, g0, b0 = getPixelRgb(src, x, y)
			local r1 = bit.band(r0, rmask)
			local g1 = bit.band(g0, gmask)
			local b1 = bit.band(b0, bmask)
			setPixelRgb(src, x, y,
				bit.band(r0, maxval-rmask),
				bit.band(g0, maxval-gmask),
				bit.band(b0, maxval-bmask))
			if x < w-1 then
				setPixelRgb(src, x+1, y, fs_dither_4c(7, maxval, r1, g1, b1, a1,  getPixelRgb(src,x+1, y)))
			end
			if y < h-1 and x > 0 then
				setPixelRgb(src, x-1, y+1, fs_dither_4c(3, maxval, r1, g1, b1, a1,  getPixelRgb(src,x-1, y+1)))
			end
			if y < h-1 then
				setPixelRgb(src, x, y+1, fs_dither_4c(5, maxval, r1, g1, b1, a1,  getPixelRgb(src,x, y+1)))
			end
			if y < h-1 and x < w-1 then
				setPixelRgb(src, x+1, y+1, fs_dither_4c(1, maxval, r1, g1, b1, a1,  getPixelRgb(src,x+1, y+1)))
			end
		end
	end
end


--ordered dithering

local tmap = {} --threshold maps from wikipedia

tmap[2] = {[0] =
	{[0] = 1, 3},
	{[0] = 4, 2}}

tmap[3] = {[0] =
	{[0] = 3, 7, 4},
	{[0] = 6, 1, 9},
	{[0] = 2, 8, 5}}

tmap[4] = {[0] =
	{[0] =  1,  9,  3, 11},
	{[0] = 13,  5, 15,  7},
	{[0] =  4, 12,  2, 10},
	{[0] = 16,  8, 14, 6}}

tmap[8] = {[0] =
	{[0] =  1, 49, 13, 61,  4, 52, 16, 64},
	{[0] = 33, 17, 45, 29, 36, 20, 48, 32},
	{[0] =  9, 57,  5, 53, 12, 60,  8, 56},
	{[0] = 41, 25, 37, 21, 44, 28, 40, 24},
	{[0] =  3, 51, 15, 63,  2, 50, 14, 62},
	{[0] = 35, 19, 47, 31, 34, 18, 46, 30},
	{[0] = 11, 59,  7, 55, 10, 58,  6, 54},
	{[0] = 43, 27, 39, 23, 42, 26, 38, 22}}

--NOTE: actual clipping of the low bits is not done here, it will be done
--naturally when converting the bitmap to lower bpc.
local ordered_dither = {}

ordered_dither[4] = function(t, maxval, r, g, b, a)
	return
		math.min(r + t, maxval),
		math.min(g + t, maxval),
		math.min(b + t, maxval),
		math.min(a + t, maxval)
end

ordered_dither[2] = function(t, maxval, g, a)
	return
		math.min(g + t, maxval),
		math.min(a + t, maxval)
end

function dither_ordered(src, mapsize)
	-- local colortype = bitmap.colortype(src)
	local w,h = src:getDimensions()
	local maxval = 0xff
	local kernel = ordered_dither[4]
	-- local getpixel, setpixel = bitmap.pixel_interface(src)
	local tmap = assert(tmap[mapsize], 'invalid map size')
	for y = 0, h-1 do
		local tmap = tmap[bit.band(y, mapsize-1)]
		for x = 0, w-1 do
			local t = tmap[bit.band(x, mapsize-1)]
			local r,g,b,a = getPixelRgb(src, x, y)
			local ra, ga, ba, aa = kernel(t, maxval, r, g, b, a)
			-- print(r, g, b, ra, ga, ba)
			setPixelRgb(src, x, y, ra/2, ga, ba, aa)
		end
	end
end
