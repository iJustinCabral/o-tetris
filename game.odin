// Classic Tetris
package game

import    "core:fmt"
import rl "vendor:raylib"

// Constants
WINDOW_WIDTH  :: 640 * 2 
WINDOW_HEIGHT :: 480 * 2 
GRID_WIDTH    :: 10
GRID_HEIGHT   :: 20
CELL_SIZE     :: 48 
CANVAS_WIDTH  :: GRID_WIDTH * CELL_SIZE
CANVAS_HEIGHT :: GRID_HEIGHT * CELL_SIZE
CANVAS_SIZE   :: CANVAS_WIDTH * CANVAS_HEIGHT
TICK_RATE     :: 0.13

// Type and Variable Definitions
Vector2i      : [4]int

main :: proc() {
    rl.InitWindow(WINDOW_WIDTH, WINDOW_HEIGHT, "O-Tetris")
    defer rl.CloseWindow()
    defer free_all(context.temp_allocator)

    camera := rl.Camera2D { zoom = 1.0 }

    for !rl.WindowShouldClose() {

	// Input

	// Update

	// Render
	rl.BeginDrawing()
	defer rl.EndDrawing()

	rl.BeginMode2D(camera)
	defer rl.EndMode2D()


	rl.ClearBackground({0x56, 0x5C, 0x86, 0xFF})
	draw_grid()
	draw_next_piece_holder()
    }

}

draw_grid :: proc() {
    rl.DrawRectangle(100, 0, CANVAS_WIDTH, CANVAS_HEIGHT, rl.BLACK)
}

draw_next_piece_holder :: proc() {
    rl.DrawText("Next Piece:", CANVAS_WIDTH + 200, 20, 24, rl.WHITE)
    rl.DrawRectangle(CANVAS_WIDTH + 200, 56, CELL_SIZE * 3, CELL_SIZE * 3, rl.BLACK)
}

