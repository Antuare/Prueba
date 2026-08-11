package main

/*
Q32.32 Fixed-point arithmetic using i64.
32 bits integer part + 32 bits fractional part.
1.0 == 1 << 32
*/

Q32 :: distinct i64

ONE       :: Q32(1 << 32)
HALF      :: Q32(1 << 31)
QUARTER   :: Q32(1 << 30)
SCALE     :: 32

// Convert integer to Q32.32
q32_from_i64 :: proc(v: i64) -> Q32 {
	return Q32(v << SCALE)
}

// Convert Q32.32 to integer (truncate)
q32_to_i64 :: proc(v: Q32) -> i64 {
	return i64(v) >> SCALE
}

// Convert Q32.32 to f32 only for rendering (allowed at the boundary)
q32_to_f32 :: proc(v: Q32) -> f32 {
	return f32(v) / f32(ONE)
}

// Convert f32 to Q32.32 (only for input / camera)
q32_from_f32 :: proc(v: f32) -> Q32 {
	return Q32(v * f32(ONE))
}

// Basic arithmetic
q32_add :: proc(a, b: Q32) -> Q32 { return a + b }
q32_sub :: proc(a, b: Q32) -> Q32 { return a - b }

q32_mul :: proc(a, b: Q32) -> Q32 {
	// (a * b) >> 32  with intermediate i128 to avoid overflow
	return Q32((i128(a) * i128(b)) >> SCALE)
}

q32_div :: proc(a, b: Q32) -> Q32 {
	if b == 0 do return 0
	return Q32((i128(a) << SCALE) / i128(b))
}

q32_abs :: proc(v: Q32) -> Q32 {
	return v < 0 ? -v : v
}

q32_min :: proc(a, b: Q32) -> Q32 { return a < b ? a : b }
q32_max :: proc(a, b: Q32) -> Q32 { return a > b ? a : b }

q32_clamp :: proc(v, lo, hi: Q32) -> Q32 {
	return q32_min(q32_max(v, lo), hi)
}

// Integer square root of a Q32.32 value (returns Q32.32)
// Uses Newton-Raphson style iteration on the integer representation.
q32_sqrt :: proc(x: Q32) -> Q32 {
	if x <= 0 do return 0

	// Work with the raw i64 value (scaled)
	n := i64(x)
	// Initial guess: shift roughly by half the bits
	r := n
	if n > 1 {
		r = 1 << ((64 - intrinsics.count_leading_zeros(u64(n))) / 2)
	}

	// Newton iterations: r = (r + n/r) / 2
	for i in 0..<8 {
		if r == 0 do break
		r = (r + n / r) >> 1
	}
	return Q32(r)
}

// Squared length of a 3D vector in Q32.32 (result still Q32.32)
q32_length2 :: proc(x, y, z: Q32) -> Q32 {
	return q32_mul(x, x) + q32_mul(y, y) + q32_mul(z, z)
}

// Length (Euclidean) in Q32.32
q32_length :: proc(x, y, z: Q32) -> Q32 {
	return q32_sqrt(q32_length2(x, y, z))
}

// 3D vector type
Vec3Q :: struct {
	x, y, z: Q32,
}

v3q_add :: proc(a, b: Vec3Q) -> Vec3Q {
	return {a.x + b.x, a.y + b.y, a.z + b.z}
}

v3q_sub :: proc(a, b: Vec3Q) -> Vec3Q {
	return {a.x - b.x, a.y - b.y, a.z - b.z}
}

v3q_scale :: proc(v: Vec3Q, s: Q32) -> Vec3Q {
	return {q32_mul(v.x, s), q32_mul(v.y, s), q32_mul(v.z, s)}
}

v3q_length :: proc(v: Vec3Q) -> Q32 {
	return q32_length(v.x, v.y, v.z)
}

v3q_from_i64 :: proc(x, y, z: i64) -> Vec3Q {
	return {q32_from_i64(x), q32_from_i64(y), q32_from_i64(z)}
}
