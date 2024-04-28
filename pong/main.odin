package pong

import "core:log"
import rl "vendor:raylib"

SCREEN_WIDTH :: 1280
SCREEN_HEIGHT :: 800

PADDLE_WIDTH :: 25
PADDLE_HEIGHT :: 120

// TODO: Move the ball around
// TODO: Check for a collision with edges
// TODO: Move the player's paddle
// TODO: Use AI to move the CPU paddle
// TODO: Check for paddle collisions
// TODO: Add scoring

main :: proc() {
	context.logger = log.create_console_logger()

	rl.InitWindow(SCREEN_WIDTH, SCREEN_HEIGHT, "pong")
	defer rl.CloseWindow()

	rl.SetTargetFPS(60)

	for !rl.WindowShouldClose() {
		rl.BeginDrawing()
		defer rl.EndDrawing()

		/* Draw a circle in the middle of the screen */
		rl.DrawCircle(SCREEN_WIDTH / 2, SCREEN_HEIGHT / 2, 20, rl.WHITE)

		/* Draw a paddle close to the left edge of the screen, centered vertically.
         * The reason why the y-coordinate is weird here is because the rectangle
         * is drawn from the top left. */
		rl.DrawRectangle(
			10,
			SCREEN_HEIGHT / 2 - PADDLE_HEIGHT / 2,
			PADDLE_WIDTH,
			PADDLE_HEIGHT,
			rl.WHITE,
		)

		/* Draw the paddle to the right edge of the screen. x-coord weird this time
         * due to the same reason as above. */
		rl.DrawRectangle(
			SCREEN_WIDTH - PADDLE_WIDTH - 10,
			SCREEN_HEIGHT / 2 - PADDLE_HEIGHT / 2,
			PADDLE_WIDTH,
			PADDLE_HEIGHT,
			rl.WHITE,
		)
	}
}
