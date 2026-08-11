package main

/*
Primitivas SDF y operaciones CSG usando únicamente Q32.32 (i64).
Todas las distancias son signed distance en punto fijo.
*/

// Esfera centrada en el origen
sdf_sphere :: proc(p: Vec3Q, radius: Q32) -> Q32 {
	return v3q_length(p) - radius
}

// Caja centrada en el origen (half-extents)
sdf_box :: proc(p: Vec3Q, half: Vec3Q) -> Q32 {
	q := Vec3Q{
		q32_abs(p.x) - half.x,
		q32_abs(p.y) - half.y,
		q32_abs(p.z) - half.z,
	}
	// outside distance
	outside := v3q_length(Vec3Q{
		q32_max(q.x, 0),
		q32_max(q.y, 0),
		q32_max(q.z, 0),
	})
	// inside distance (negative)
	inside := q32_min(q32_max(q.x, q32_max(q.y, q.z)), 0)
	return outside + inside
}

// Plano horizontal (y = height). Normal hacia arriba.
sdf_plane_y :: proc(p: Vec3Q, height: Q32) -> Q32 {
	return p.y - height
}

// Unión (OR) — superficie más cercana
sdf_union :: proc(d1, d2: Q32) -> Q32 {
	return q32_min(d1, d2)
}

// Intersección (AND)
sdf_intersect :: proc(d1, d2: Q32) -> Q32 {
	return q32_max(d1, d2)
}

// Sustracción (d1 - d2)
sdf_subtract :: proc(d1, d2: Q32) -> Q32 {
	return q32_max(d1, -d2)
}

// Smooth union aproximada (k controla el suavizado)
sdf_smooth_union :: proc(d1, d2, k: Q32) -> Q32 {
	h := q32_clamp(HALF + q32_div(d2 - d1, q32_mul(k, q32_from_i64(2))), 0, ONE)
	return q32_mul(d1, ONE - h) + q32_mul(d2, h) - q32_mul(k, q32_mul(h, ONE - h))
}

// Desplazamiento de un punto
sdf_translate :: proc(p: Vec3Q, offset: Vec3Q) -> Vec3Q {
	return v3q_sub(p, offset)
}
