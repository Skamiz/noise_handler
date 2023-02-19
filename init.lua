noise_handler = {}

-- These guards are here because 'minetest.get_perlin' isn't aviable at startup,
-- which is when the noise object is registered
-- and 'PerlinNoise()' doesn't take into acount the map seed
local function get_2d(noise, pos)
    if not noise.noise_obj then
        noise.noise_obj = minetest.get_perlin(noise.params)
    end
    -- switched around z and y as this is the usual use case
    return noise.noise_obj:get_2d({x = pos.x, y = pos.z, z = 0})
end

local function get_3d(noise, pos)
    if not noise.noise_obj then
        noise.noise_obj = minetest.get_perlin(noise.params)
    end
    return noise.noise_obj:get_3d(pos)
end

local function get_2d_map_flat(noise, minp)
    if not noise.noise_map_obj then
        noise.noise_map_obj = minetest.get_perlin_map(noise.params, noise.chunk_size)
    end
    -- switched around z and y as this is the usual use case
    noise.noise_map_obj:get_2d_map_flat({x = minp.x, y = minp.z, z = 0}, noise.buffer_2d)
    return noise.buffer_2d
end

local function get_3d_map_flat(noise, minp)
    if not noise.noise_map_obj then
        noise.noise_map_obj = minetest.get_perlin_map(noise.params, noise.chunk_size)
    end
    noise.noise_map_obj:get_3d_map_flat(minp, noise.buffer_3d)
    return noise.buffer_3d
end


-- Returns a noise object which combines the capacity of those returned by
-- 'minetest.get_perlin' and 'minetest.get_perlin_map'
-- and automaticaly maintains buffer tables for better performance.

local blocks_per_chunk = tonumber(minetest.settings:get("chunksize")) or 5
local side_lenght = blocks_per_chunk * 16

function noise_handler.get_noise_object(params, chunk_size)
	local amplitude = 0
	for i = 1, params.octaves do
		amplitude = amplitude + math.pow(params.persist, i - 1)
	end
	amplitude = amplitude * params.scale

	local min = amplitude + params.offset
	local max = amplitude + params.offset


    local noise_object = {
        params = params,
        chunk_size = chunk_size or {x = side_lenght, y = side_lenght, z = side_lenght},
        buffer_2d = {},
        buffer_3d = {},
        get_2d = get_2d,
        get_3d = get_3d,
        get_2d_map_flat = get_2d_map_flat,
        get_3d_map_flat = get_3d_map_flat,
		min = min,
		max = max,
    }

    return noise_object
end
