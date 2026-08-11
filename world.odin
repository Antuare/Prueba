package main

/*
Mapa 3D estilo RPG generado con SDF implícito en Q32.32.
Incluye terreno, agua, colinas y una zona de cristal.
*/

// Altura base del agua
WATER_LEVEL :: q32_from_i64(0)

// Evaluación del mundo completo en un punto p (Q32.32)
// Devuelve la distancia signed y el material más cercano.
world_sdf :: proc(p: Vec3Q) -> (dist: Q32, mat: Material_ID) {
	// ---- Terreno base (plano + colinas suaves) ----
	// Colinas usando una suma de "ondas" enteras simples (sin floats)
	hill1 := q32_mul(q32_from_i64(3), q32_sin_approx(q32_mul(p.x, Q32(1 << 28))))
	hill2 := q32_mul(q32_from_i64(2), q32_sin_approx(q32_mul(p.z, Q32(1 << 27))))
	hill3 := q32_mul(ONE, q32_sin_approx(q32_mul(p.x + p.z, Q32(1 << 26))))

	terrain_height := q32_from_i64(-2) + hill1 + hill2 + hill3
	terrain_d := p.y - terrain_height

	// Material del terreno según altura
	terrain_mat: Material_ID = .Dirt
	if terrain_height > q32_from_i64(2) {
		terrain_mat = .Stone
	} else if terrain_height < q32_from_i64(-1) {
		terrain_mat = .Sand
	} else {
		terrain_mat = .Grass
	}

	// ---- Agua ----
	// Cuerpo de agua como un plano cortado por una caja grande
	water_plane := sdf_plane_y(p, WATER_LEVEL)
	water_box := sdf_box(sdf_translate(p, {0, q32_from_i64(-5), 0}), {q32_from_i64(40), q32_from_i64(5), q32_from_i64(40)})
	water_d := sdf_intersect(water_plane, water_box)

	// Si estamos debajo del terreno, el agua no cuenta
	if water_d < terrain_d {
		// Estamos en agua
		if p.y < q32_from_i64(-3) {
			return water_d, .Deep_Water
		}
		return water_d, .Water
	}

	// ---- Cristal flotante (ornamento RPG) ----
	crystal_pos := Vec3Q{q32_from_i64(8), q32_from_i64(4), q32_from_i64(-6)}
	crystal_d := sdf_sphere(sdf_translate(p, crystal_pos), q32_from_i64(2))

	// Unión del terreno con el cristal
	if crystal_d < terrain_d {
		return crystal_d, .Crystal
	}

	return terrain_d, terrain_mat
}

// Aproximación de seno usando polinomio de Taylor de bajo orden (solo enteros)
// Entrada y salida en Q32.32. Rango razonable ±π
q32_sin_approx :: proc(x: Q32) -> Q32 {
	// Normalizar aproximadamente a [-π, π] usando módulo grueso
	// π ≈ 3.14159 → Q32 ≈ 13493037705 (aprox 3.14159 * 2^32)
	PI :: Q32(13493037705)
	TWO_PI :: PI + PI

	// Reducir x módulo 2π de forma tosca
	x = x % TWO_PI
	if x > PI do x = x - TWO_PI
	if x < -PI do x = x + TWO_PI

	// Taylor: x - x³/6 + x⁵/120
	x2 := q32_mul(x, x)
	x3 := q32_mul(x2, x)
	x5 := q32_mul(x3, x2)

	term1 := x
	term2 := q32_div(x3, q32_from_i64(6))
	term3 := q32_div(x5, q32_from_i64(120))

	return term1 - term2 + term3
}
