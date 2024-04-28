package pong

import rl "vendor:raylib"

SCREEN_WIDTH :: 1280
SCREEN_HEIGHT :: 800

PADDLE_WIDTH :: 25
PADDLE_HEIGHT :: 120

DARK_GREEN :: rl.Color{38, 185, 154, 255}
GREEN :: rl.Color{20, 160, 133, 255}
MINT :: rl.Color{79, 239, 202, 255}

Scores :: struct {
	player: int,
	cpu:    int,
}

scores := Scores{}

Ball :: struct {
	x, y:             i32,
	speed_x, speed_y: i32,
	radius:           f32,
}

draw_ball :: proc(b: ^Ball) {
	rl.DrawCircle(b.x, b.y, b.radius, rl.YELLOW)
}

update_ball :: proc(b: ^Ball) {
	b.x += b.speed_x
	b.y += b.speed_y

	/* If the ball touches the edges of the screen, reverse the sign of its speed
     * to make it go the other way. */
	if b.y + i32(b.radius) >= SCREEN_HEIGHT || b.y - i32(b.radius) <= 0 {
		b.speed_y *= -1
	}

	if b.x + i32(b.radius) >= SCREEN_WIDTH {
		scores.cpu += 1
		reset_ball(b)
	}
	if b.x - i32(b.radius) <= 0 {
		scores.player += 1
		reset_ball(b)
	}
}

@(private = "file")
reset_ball :: proc(b: ^Ball) {
	b.x = SCREEN_WIDTH / 2
	b.y = SCREEN_HEIGHT / 2

	speed_choices := [2]i32{-1, 1}
	b.speed_x *= speed_choices[rl.GetRandomValue(0, 1)]
	b.speed_y *= speed_choices[rl.GetRandomValue(0, 1)]
}

Paddle :: struct {
	x, y:          i32,
	width, height: i32,

	/* Only one speed needed as paddle only moves on y-axis. */
	speed:         i32,
}

draw_paddle :: proc(p: ^Paddle) {
	rl.DrawRectangleRounded(
		rl.Rectangle{f32(p.x), f32(p.y), f32(p.width), f32(p.height)},
		0.8,
		0,
		rl.WHITE,
	)
}

update_paddle :: proc(p: ^Paddle) {
	kk :: rl.KeyboardKey

	if rl.IsKeyDown(kk.UP) || rl.IsKeyDown(kk.K) {
		p.y -= p.speed
	}

	if rl.IsKeyDown(kk.DOWN) || rl.IsKeyDown(kk.J) {
		p.y += p.speed
	}

	limit_movement(p)
}

CPUPaddle :: struct {
	using paddle: Paddle,
}

update_cpu :: proc(p: ^CPUPaddle, ball_y: i32) {
	if p.y + p.height / 2 > ball_y {
		p.y -= p.speed
	}

	if p.y + p.height / 2 <= ball_y {
		p.y += p.speed
	}

	limit_movement(p)
}

@(private = "file")
limit_movement :: proc(p: ^Paddle) {
	/* Prevent the paddle from going offscreen */
	if p.y <= 0 {
		p.y = 0
	}

	if p.y + p.height >= SCREEN_HEIGHT {
		p.y = SCREEN_HEIGHT - p.height
	}
}

draw :: proc {
	draw_ball,
	draw_paddle,
}

update :: proc {
	update_ball,
	update_paddle,
	update_cpu,
}

check_collision :: proc(p: ^Paddle, b: ^Ball) {
	if rl.CheckCollisionCircleRec(
		   rl.Vector2{f32(b.x), f32(b.y)},
		   b.radius,
		   rl.Rectangle{f32(p.x), f32(p.y), f32(p.width), f32(p.height)},
	   ) {
		b.speed_x *= -1
	}
}

main :: proc() {
	ball := Ball {
		x       = SCREEN_WIDTH / 2,
		y       = SCREEN_HEIGHT / 2,
		speed_x = 7,
		speed_y = 7,
		radius  = 20,
	}

	/* Player is on the right */
	player := Paddle {
		width  = PADDLE_WIDTH,
		height = PADDLE_HEIGHT,
		x      = SCREEN_WIDTH - PADDLE_WIDTH - 10,
		y      = SCREEN_HEIGHT / 2 - PADDLE_HEIGHT / 2,
		speed  = 6,
	}

	cpu := CPUPaddle {
		width  = PADDLE_WIDTH,
		height = PADDLE_HEIGHT,
		x      = 10,
		y      = SCREEN_HEIGHT / 2 - PADDLE_HEIGHT / 2,
		speed  = 6,
	}

	rl.InitWindow(SCREEN_WIDTH, SCREEN_HEIGHT, "pong")
	defer rl.CloseWindow()

	rl.SetTargetFPS(60)

	for !rl.WindowShouldClose() {
		rl.BeginDrawing()
		defer rl.EndDrawing()

		update(&ball)
		update(&player)
		update(&cpu, ball.y)

		check_collision(&player, &ball)
		check_collision(&cpu, &ball)

		rl.ClearBackground(DARK_GREEN)
		rl.DrawRectangle(SCREEN_WIDTH / 2, 0, SCREEN_WIDTH / 2, SCREEN_HEIGHT, GREEN)
		rl.DrawCircle(SCREEN_WIDTH / 2, SCREEN_HEIGHT / 2, 150, MINT)

		/* Draw a line to seperate two sides. */
		rl.DrawLine(SCREEN_WIDTH / 2, 0, SCREEN_WIDTH / 2, SCREEN_HEIGHT, rl.WHITE)

		draw(&ball)
		draw(&cpu)
		draw(&player)

		rl.DrawText(rl.TextFormat("%i", scores.cpu), SCREEN_WIDTH / 4 - 20, 20, 80, rl.WHITE)
		rl.DrawText(
			rl.TextFormat("%i", scores.player),
			3 * SCREEN_WIDTH / 4 - 20,
			20,
			80,
			rl.WHITE,
		)
	}
}
