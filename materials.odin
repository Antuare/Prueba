package main

/*
Materiales derivados de los Elements.
Cada material tiene un Element base + propiedades de rendering y física.
*/

Material_ID :: enum u8 {
	Air = 0,
	Dirt,
	Stone,
	Sand,
	Water,
	Deep_Water,
	Grass,
	Wood,
	Metal_Ore,
	Crystal,
	Lava,
	Ice,
}

Material :: struct {
	id:          Material_ID,
	name:        string,
	element:     Element_ID,
	density:     Q32,
	hardness:    Q32,
	roughness:   Q32,   // 0 = espejo, 1 = mate
	color_r:     u8,
	color_g:     u8,
	color_b:     u8,
	color_a:     u8,
	emissive:    bool,
}

MATERIALS := [Material_ID]Material{
	.Air = {
		id = .Air, name = "Air",
		element = .Air,
		density = Q32(1 << 24), hardness = 0, roughness = 0,
		color_r = 200, color_g = 230, color_b = 255, color_a = 0,
		emissive = false,
	},
	.Dirt = {
		id = .Dirt, name = "Dirt",
		element = .Earth,
		density = q32_from_i64(1), hardness = QUARTER, roughness = HALF + QUARTER,
		color_r = 110, color_g = 70, color_b = 40, color_a = 255,
		emissive = false,
	},
	.Stone = {
		id = .Stone, name = "Stone",
		element = .Earth,
		density = q32_from_i64(2), hardness = HALF + QUARTER, roughness = HALF,
		color_r = 130, color_g = 130, color_b = 140, color_a = 255,
		emissive = false,
	},
	.Sand = {
		id = .Sand, name = "Sand",
		element = .Earth,
		density = q32_from_i64(1), hardness = QUARTER, roughness = ONE - QUARTER,
		color_r = 210, color_g = 190, color_b = 130, color_a = 255,
		emissive = false,
	},
	.Water = {
		id = .Water, name = "Water",
		element = .Water,
		density = ONE, hardness = 0, roughness = 0,
		color_r = 30, color_g = 100, color_b = 200, color_a = 180,
		emissive = false,
	},
	.Deep_Water = {
		id = .Deep_Water, name = "Deep Water",
		element = .Water,
		density = ONE + HALF, hardness = 0, roughness = 0,
		color_r = 10, color_g = 40, color_b = 120, color_a = 220,
		emissive = false,
	},
	.Grass = {
		id = .Grass, name = "Grass",
		element = .Wood,
		density = HALF, hardness = Q32(1 << 28), roughness = ONE - QUARTER,
		color_r = 60, color_g = 140, color_b = 50, color_a = 255,
		emissive = false,
	},
	.Wood = {
		id = .Wood, name = "Wood",
		element = .Wood,
		density = q32_from_i64(1), hardness = QUARTER + Q32(1 << 28), roughness = HALF,
		color_r = 100, color_g = 60, color_b = 25, color_a = 255,
		emissive = false,
	},
	.Metal_Ore = {
		id = .Metal_Ore, name = "Metal Ore",
		element = .Metal,
		density = q32_from_i64(5), hardness = ONE - QUARTER, roughness = QUARTER,
		color_r = 140, color_g = 120, color_b = 90, color_a = 255,
		emissive = false,
	},
	.Crystal = {
		id = .Crystal, name = "Crystal",
		element = .Crystal,
		density = q32_from_i64(3), hardness = ONE, roughness = 0,
		color_r = 160, color_g = 210, color_b = 255, color_a = 200,
		emissive = true,
	},
	.Lava = {
		id = .Lava, name = "Lava",
		element = .Fire,
		density = q32_from_i64(2), hardness = 0, roughness = HALF,
		color_r = 255, color_g = 80, color_b = 10, color_a = 255,
		emissive = true,
	},
	.Ice = {
		id = .Ice, name = "Ice",
		element = .Water,
		density = ONE - QUARTER, hardness = HALF, roughness = QUARTER,
		color_r = 180, color_g = 220, color_b = 255, color_a = 200,
		emissive = false,
	},
}

get_material :: proc(id: Material_ID) -> Material {
	return MATERIALS[id]
}

// Devuelve el color del material como [4]u8
material_color :: proc(id: Material_ID) -> [4]u8 {
	m := MATERIALS[id]
	return {m.color_r, m.color_g, m.color_b, m.color_a}
}
