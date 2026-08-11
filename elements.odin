package main

/*
Tabla de Elements (sistema elemental estilo RPG).
Cada elemento tiene un ID y propiedades básicas.
*/

Element_ID :: enum u8 {
	None = 0,
	Earth,
	Water,
	Air,
	Fire,
	Metal,
	Wood,
	Crystal,
	Void,
}

Element :: struct {
	id:          Element_ID,
	name:        string,
	density:     Q32,   // densidad relativa (Q32.32)
	hardness:    Q32,   // dureza (0..1 en Q32)
	flammable:   bool,
	conductive:  bool,
	color_r:     u8,
	color_g:     u8,
	color_b:     u8,
}

// Tabla estática de elementos
ELEMENTS := [Element_ID]Element{
	.None = {
		id = .None, name = "None",
		density = 0, hardness = 0,
		flammable = false, conductive = false,
		color_r = 0, color_g = 0, color_b = 0,
	},
	.Earth = {
		id = .Earth, name = "Earth",
		density = q32_from_i64(2), hardness = HALF,
		flammable = false, conductive = false,
		color_r = 120, color_g = 90, color_b = 50,
	},
	.Water = {
		id = .Water, name = "Water",
		density = ONE, hardness = 0,
		flammable = false, conductive = true,
		color_r = 40, color_g = 120, color_b = 220,
	},
	.Air = {
		id = .Air, name = "Air",
		density = Q32(1 << 24), hardness = 0, // muy ligero
		flammable = false, conductive = false,
		color_r = 200, color_g = 230, color_b = 255,
	},
	.Fire = {
		id = .Fire, name = "Fire",
		density = Q32(1 << 20), hardness = 0,
		flammable = true, conductive = false,
		color_r = 255, color_g = 100, color_b = 20,
	},
	.Metal = {
		id = .Metal, name = "Metal",
		density = q32_from_i64(7), hardness = q32_from_i64(1),
		flammable = false, conductive = true,
		color_r = 160, color_g = 160, color_b = 170,
	},
	.Wood = {
		id = .Wood, name = "Wood",
		density = q32_from_i64(1), hardness = QUARTER,
		flammable = true, conductive = false,
		color_r = 110, color_g = 70, color_b = 30,
	},
	.Crystal = {
		id = .Crystal, name = "Crystal",
		density = q32_from_i64(3), hardness = q32_from_i64(1),
		flammable = false, conductive = false,
		color_r = 180, color_g = 220, color_b = 255,
	},
	.Void = {
		id = .Void, name = "Void",
		density = 0, hardness = 0,
		flammable = false, conductive = false,
		color_r = 20, color_g = 0, color_b = 30,
	},
}

get_element :: proc(id: Element_ID) -> Element {
	return ELEMENTS[id]
}
