package main

import "core:fmt"
import "core:math"
import rl "vendor:raylib"
import "base:intrinsics"

WINDOW_W :: 1280
WINDOW_H :: 720

// Cámara simple en espacio Q32
CameraQ :: struct {
	pos:    Vec3Q,
	yaw:    Q32, // radianes aproximados en Q32
	pitch:  Q32,
}

main :: proc() {
	rl.InitWindow(WINDOW_W, WINDOW_H, "Prueba - SDF Volumétrico Q32.32 (Odin)")
	rl.SetTargetFPS(60)
	defer rl.CloseWindow()

	cam: CameraQ
	cam.pos = {q32_from_i64(0), q32_from_i64(8), q32_from_i64(20)}
	cam.yaw = 0
	cam.pitch = q32_from_f32(-0.3)

	fmt.println("=== Prueba SDF Q32.32 ===")
	fmt.println("Elementos cargados:", len(ELEMENTS))
	fmt.println("Materiales cargados:", len(MATERIALS))
	fmt.println("Controles: WASD mover, Espacio/Ctrl altura, rueda zoom, Esc salir")

	for !rl.WindowShouldClose() {
		dt := rl.GetFrameTime()

		// ---- Input ----
		speed := q32_from_f32(8.0 * dt)
		if rl.IsKeyDown(.LEFT_SHIFT) do speed = q32_mul(speed, q32_from_i64(3))

		forward := Vec3Q{
			q32_mul(q32_sin_approx(cam.yaw), q32_from_i64(-1)),
			0,
			q32_mul(q32_cos_approx(cam.yaw), q32_from_i64(-1)),
		}
		right := Vec3Q{
			q32_cos_approx(cam.yaw),
			0,
			q32_sin_approx(cam.yaw),
		}

		if rl.IsKeyDown(.W) || rl.IsKeyDown(.UP)    do cam.pos = v3q_add(cam.pos, v3q_scale(forward, speed))
		if rl.IsKeyDown(.S) || rl.IsKeyDown(.DOWN)  do cam.pos = v3q_sub(cam.pos, v3q_scale(forward, speed))
		if rl.IsKeyDown(.A) || rl.IsKeyDown(.LEFT)  do cam.pos = v3q_sub(cam.pos, v3q_scale(right, speed))
		if rl.IsKeyDown(.D) || rl.IsKeyDown(.RIGHT) do cam.pos = v3q_add(cam.pos, v3q_scale(right, speed))
		if rl.IsKeyDown(.SPACE) do cam.pos.y += speed
		if rl.IsKeyDown(.LEFT_CONTROL) || rl.IsKeyDown(.C) do cam.pos.y -= speed

		// Zoom con rueda (mueve hacia adelante/atrás)
		wheel := rl.GetMouseWheelMove()
		if wheel != 0 {
			cam.pos = v3q_add(cam.pos, v3q_scale(forward, q32_from_f32(wheel * 2.0)))
		}

		// Rotación con ratón (botón derecho)
		if rl.IsMouseButtonDown(.RIGHT) {
			delta := rl.GetMouseDelta()
			cam.yaw   -= q32_from_f32(delta.x * 0.005)
			cam.pitch -= q32_from_f32(delta.y * 0.005)
			cam.pitch  = q32_clamp(cam.pitch, q32_from_f32(-1.2), q32_from_f32(1.2))
		}

		// ---- Render ----
		rl.BeginDrawing()
		rl.ClearBackground({20, 25, 35, 255})

		render_raymarch(cam)

		// HUD
		rl.DrawText("SDF Volumetrico Q32.32 - Mapa RPG + Agua", 10, 10, 20, rl.RAYWHITE)
		rl.DrawText(fmt.ctprintf("Pos: %.1f  %.1f  %.1f", q32_to_f32(cam.pos.x), q32_to_f32(cam.pos.y), q32_to_f32(cam.pos.z)), 10, 40, 16, rl.LIGHTGRAY)
		rl.DrawText("WASD mover | RMB rotar | Rueda zoom | Espacio/Ctrl altura", 10, WINDOW_H - 30, 16, rl.GRAY)

		rl.EndDrawing()
	}
}

// Raymarching simple del SDF (la evaluación del SDF es 100% Q32.32)
render_raymarch :: proc(cam: CameraQ) {
	max_steps :: 64
	max_dist  := q32_from_i64(80)
	min_dist  := Q32(1 << 20) // ~0.0002

	for py in 0..<WINDOW_H {
		for px in 0..<WINDOW_W {
			// Coordenadas de pantalla normalizadas
			uv_x := (f32(px) / f32(WINDOW_W) * 2.0 - 1.0) * (f32(WINDOW_W) / f32(WINDOW_H))
			uv_y := (f32(py) / f32(WINDOW_H) * 2.0 - 1.0) * -1.0 // invertir Y

			// Dirección del rayo (aproximada)
			dir := Vec3Q{
				q32_from_f32(uv_x),
				q32_from_f32(uv_y + q32_to_f32(cam.pitch)),
				q32_from_i64(-1),
			}
			// Rotar por yaw de forma simple
			cy := q32_cos_approx(cam.yaw)
			sy := q32_sin_approx(cam.yaw)
			dir = {
				q32_mul(dir.x, cy) - q32_mul(dir.z, sy),
				dir.y,
				q32_mul(dir.x, sy) + q32_mul(dir.z, cy),
			}
			// Normalizar aproximadamente
			len := v3q_length(dir)
			if len > 0 {
				dir = v3q_scale(dir, q32_div(ONE, len))
			}

			// Raymarch
			t := Q32(0)
			hit := false
			var final_mat: Material_ID = .Air

			for step in 0..<max_steps {
				p := v3q_add(cam.pos, v3q_scale(dir, t))
				d, mat := world_sdf(p)

				if d < min_dist {
					hit = true
					final_mat = mat
					break
				}
				if t > max_dist do break
				t += d
			}

			col: rl.Color
			if hit {
				m := get_material(final_mat)
				// Sombreado simple por distancia
				shade := 1.0 - f32(t) / f32(max_dist)
				if shade < 0.2 do shade = 0.2
				col = {
					u8(f32(m.color_r) * shade),
					u8(f32(m.color_g) * shade),
					u8(f32(m.color_b) * shade),
					m.color_a,
				}
			} else {
				// Cielo
				col = {30, 40, 60, 255}
			}

			rl.DrawPixel(i32(px), i32(py), col)
		}
	}
}

// Cos aproximado (desplazamiento de sin)
q32_cos_approx :: proc(x: Q32) -> Q32 {
	PI_2 :: Q32(6746518852) // π/2 aproximado
	return q32_sin_approx(x + PI_2)
}
