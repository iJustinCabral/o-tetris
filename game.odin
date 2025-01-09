// Classic Tetris
package game

import    "core:fmt"
import    "core:math/rand"
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
TET_GREEN     :: rl.Color({0x76, 0xE6, 0x71, 0xFF})
PIECE_GREEN   :: rl.Color({0x45, 0x7A, 0x5F, 0xFF})

// Type and Variable Definitions
Vector2i     :: [2]int
game_over    := true
rows_cleared := 0
score        := 0
level        := 1
tick_timer   : f32 = TICK_RATE

Tetrimino :: struct {
    shape: [dynamic][dynamic]int,
    color: rl.Color,
    position: Vector2i,
    rotation: int,
}

// Define the shapes
o_tet := Tetrimino{
    shape = {
	{1, 1},
	{1, 1},
    },
    color = rl.YELLOW,
}

t_tet := Tetrimino{
    shape = {
	{1,1,1},
	{0,1,0},
	{0,0,0}
    },
    color = rl.PURPLE,
 }

i_tet := Tetrimino{
    shape = {
	{0,0,0,0},
	{0,0,0,0},
	{0,0,0,0},
	{1,1,1,1},
    },
    color = rl.SKYBLUE,
 }

l_tet := Tetrimino{
    shape = {
	{1,0,0},
	{1,0,0},
	{1,1,0},
    },
    color = rl.ORANGE,
}

j_tet := Tetrimino{
    shape = {
	{0,0,1},
	{0,0,1},
	{0,1,1},
    },
    color = rl.BLUE
}

s_tet := Tetrimino {
    shape = {
	{0,0,0},
	{0,1,1},
	{1,1,0},
    },
    color = rl.GREEN,
 }

z_tet := Tetrimino {
    shape = {
	{0,0,0},
	{1,1,0},
	{0,1,1},
    },
    color = rl.RED
}

tetriminos : []Tetrimino = {o_tet, t_tet, i_tet, l_tet, j_tet, s_tet, z_tet}
current_tet := rand.choice(tetriminos[:])

main :: proc() {
    rl.InitWindow(WINDOW_WIDTH, WINDOW_HEIGHT, "O-Tetris")
    defer rl.CloseWindow()
    defer free_all(context.temp_allocator)


    for !rl.WindowShouldClose() {

	// Input
	if rl.IsKeyPressed(.LEFT) {

	}
	if rl.IsKeyPressed(.RIGHT) {

	}
	if rl.IsKeyPressed(.UP) {

	}
	if rl.IsKeyPressed(.DOWN) {

	}
	if rl.IsKeyPressed(.SPACE) {

	}
	if rl.IsKeyPressed(.P) || rl.IsKeyPressed(.ESCAPE) {

	}

	// Updates
	if game_over && rl.IsKeyPressed(.ENTER) { reset_game() }
	else {
	   tick_timer -= rl.GetFrameTime() 
	}

	if tick_timer <= 0 {
	    // Gameplay logic goes here
	    tick_timer = TICK_RATE + tick_timer
	}


	// Render
	rl.BeginDrawing()
	defer rl.EndDrawing()

	rl.ClearBackground(rl.BLACK)
	draw_grid()
	draw_instructions()
	draw_stats()
	draw_tetrimino(i_tet)
    }

}

reset_game :: proc() {
    game_over = false
    score = 0
    level = 1
    rows_cleared = 0
}

next_level :: proc() {
    // TODO: Change the tick rate to make the drop rate faster for each level increase
}

draw_grid :: proc() {
    rl.DrawRectangle(WINDOW_WIDTH / 2 - CANVAS_WIDTH / 2, 0, CANVAS_WIDTH, CANVAS_HEIGHT, TET_GREEN )

    text := fmt.ctprint("Press Enter To Start")
    text_width := rl.MeasureText(text, 20)

    if game_over {
	rl.DrawText(text, WINDOW_WIDTH / 2 - text_width / 2, WINDOW_HEIGHT * .5, 20, PIECE_GREEN)
    }
}

draw_instructions :: proc() {
    rl.DrawText("    UP ARROW:  ROTATE", WINDOW_WIDTH * 0.75, 20, 20, TET_GREEN)
    rl.DrawText("DOWN ARROW:  SOFT DROP", WINDOW_WIDTH * 0.75, 40, 20, TET_GREEN)
    rl.DrawText("   SPACEBAR:  HARD DROP", WINDOW_WIDTH * 0.75, 60, 20, TET_GREEN)
    rl.DrawText("        ESC, P:  PAUSE", WINDOW_WIDTH * 0.75, 80, 20, TET_GREEN)

}

draw_stats :: proc() {

    // TODO: Make these work with formatted C Strings after
    rl.DrawText("ROWS HIT:                      0", 40, 20, 20, TET_GREEN)
    rl.DrawText("SCORE:                          0", 40, 40, 20, TET_GREEN)
    rl.DrawText("LEVEL:                           1", 40, 60, 20, TET_GREEN)
}

draw_tetrimino :: proc(tet: Tetrimino) {
    for row in 0..<len(tet.shape) {
	for col in 0..<len(tet.shape[row]) {
	    if tet.shape[row][col] == 1 {
		x := tet.position[0] + col * CELL_SIZE
		y := tet.position[1] + row * CELL_SIZE
		rl.DrawRectangle(i32(x), i32(y), CELL_SIZE, CELL_SIZE, tet.color)
	    }
	}
    }
}


draw_next_piece :: proc() {
    // TODO: Choose a random piece out of our array of tet_pieces to draw next
}

