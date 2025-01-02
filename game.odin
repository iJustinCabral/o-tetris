// Classic Tetris
package game

import    "core:fmt"
import rl "vendor:raylib"

// Constants
WINDOW_WIDTH  :: 640 * 2
WINDOW_HEIGHT :: 480 * 2
GRID_WIDTH    :: 10
GRID_HEIGHT   :: 20
CELL_SIZE     :: 12
CANVAS_WIDTH  :: GRID_WIDTH * CELL_SIZE
CANVAS_HEIGHT :: GRID_HEIGHT * CELL_SIZE
CANVAS_SIZE   :: CANVAS_WIDTH * CANVAS_HEIGHT
TICK_RATE     :: 0.13
MAX_SIZE      :: GRID_WIDTH * GRID_HEIGHT

main :: proc() {
    rl.InitWindow(WINDOW_WIDTH, WINDOW_HEIGHT, "O-Tetris")
    defer rl.CloseWindow()

    for !rl.WindowShouldClose() {
	defer free_all(context.temp_allocator)

	// Input

	// Update

	// Render
	rl.BeginDrawing()
	defer rl.EndDrawing()

	rl.ClearBackground({0x56, 0x5C, 0x86, 0xFF})
    }

}

