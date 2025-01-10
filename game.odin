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
X_OFFSET      :: (WINDOW_WIDTH - CANVAS_WIDTH) / 2
TICK_RATE     :: 0.39
Y_OFFSET      :: (WINDOW_HEIGHT - CANVAS_HEIGHT) / 2
TET_GREEN     :: rl.Color({0x76, 0xE6, 0x71, 0xFF})
PIECE_GREEN   :: rl.Color({0x45, 0x7A, 0x5F, 0xFF})

// Type and Variable Definitions
Vector2i     :: [2]int
tick_timer   : f32 = TICK_RATE

GameMemory :: struct {
    current_tet: Tetrimino,
    next_tet: Tetrimino,
    grid: [20][10]Cell,
    game_over: bool,
    rows_cleared: int,
    score: int,
    level: int,
}

Tetrimino :: struct {
    shape: [][]int,
    color: rl.Color,
    position: Vector2i,
    rotation: int,
}

Cell :: struct {
    filled: bool,
    color: rl.Color,
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
	{1,1,1,1},
	{0,0,0,0},
	{0,0,0,0},
	{0,0,0,0},
    },
    color = rl.SKYBLUE,
 }

l_tet := Tetrimino{
    shape = {
	{0,1,0},
	{0,1,0},
	{0,1,1},
    },
    color = rl.ORANGE,
}

j_tet := Tetrimino{
    shape = {
	{0,1,0},
	{0,1,0},
	{1,1,0},
    },
    color = rl.BLUE
}

s_tet := Tetrimino {
    shape = {
	{0,1,1},
	{1,1,0},
	{0,0,0},
    },
    color = rl.GREEN,
 }

z_tet := Tetrimino {
    shape = {
	{1,1,0},
	{0,1,1},
	{0,0,0},
    },
    color = rl.RED
}

game_mem : GameMemory = {}  
tetriminos : [7]Tetrimino = {o_tet, t_tet, i_tet, l_tet, j_tet, s_tet, z_tet}

main :: proc() {
    rl.InitWindow(WINDOW_WIDTH, WINDOW_HEIGHT, "O-Tetris")
    defer rl.CloseWindow()
    defer free_all(context.temp_allocator)
    reset_game(&game_mem)

    for !rl.WindowShouldClose() {

	// Input
	if rl.IsKeyPressed(.LEFT)  && !game_mem.game_over {
	    game_mem.current_tet.position.x -= 1
	    if !can_place_tetrimino(&game_mem) { game_mem.current_tet.position.x += 1 } 
	}
	if rl.IsKeyPressed(.RIGHT)  && !game_mem.game_over {
	    game_mem.current_tet.position.x += 1
	    if !can_place_tetrimino(&game_mem) { game_mem.current_tet.position.x -= 1 }
	}
	if rl.IsKeyPressed(.UP) && !game_mem.game_over {
	   rotate_tetrimino(&game_mem) 
	}
	if rl.IsKeyPressed(.DOWN) && !game_mem.game_over {
	    game_mem.current_tet.position.y += 1
	    if !can_place_tetrimino(&game_mem) { game_mem.current_tet.position.y -= 1}
	}
	if rl.IsKeyPressed(.SPACE) && !game_mem.game_over {
	   hard_slam(&game_mem)	
	}

	// Updates
	if game_mem.game_over && rl.IsKeyPressed(.ENTER) { 
	    reset_game(&game_mem)
	    game_mem.game_over = false
	}
	else {
	   tick_timer -= rl.GetFrameTime() 
	}

	if tick_timer <= 0 && !game_mem.game_over {
	    // Gameplay logic goes here
	    game_mem.current_tet.position.y += 1
	    if !can_place_tetrimino(&game_mem) {
		game_mem.current_tet.position.y -= 1 // undo
		place_tetrimino(&game_mem)
	    }


	    tick_timer = TICK_RATE + tick_timer
	}


	// Render
	rl.BeginDrawing()
	defer rl.EndDrawing()

	rl.ClearBackground(rl.BLACK)
	draw_grid(&game_mem)
	draw_instructions()
	draw_stats()
	draw_next_piece(&game_mem)
    }

}

reset_game :: proc(mem: ^GameMemory) {
    mem.game_over = true
    mem.level = 1
    mem.score = 0
    mem.current_tet = rand.choice(tetriminos[:])
    mem.next_tet = rand.choice(tetriminos[:])
    mem.rows_cleared = 0
    mem.grid = [20][10]Cell{}

    mem.current_tet.position.x = (GRID_WIDTH - len(mem.current_tet.shape[0])) / 2; // Center horizontally
    mem.current_tet.position.y = 0; // Start at the top

}


rotate_shape :: proc(shape: [][]int) -> [][]int {
    rows := len(shape);
    cols := len(shape[0]);

    // Create a new slice to hold the rotated shape
    result := make([][]int, cols); // New shape will have transposed dimensions
    for i in 0..<cols {
        result[i] = make([]int, rows); // Each row in the result is sized to 'rows'
    }

    // Perform the rotation (90 degrees clockwise)
    for row in 0..<rows {
        for col in 0..<cols {
            result[col][rows - row - 1] = shape[row][col];
        }
    }

    return result;
}

rotate_tetrimino :: proc(mem: ^GameMemory) {
    old_shape := mem.current_tet.shape; // Save the current shape
    mem.current_tet.shape = rotate_shape(mem.current_tet.shape);

    // Check if the rotated shape can be placed
    if !can_place_tetrimino(mem) {
        mem.current_tet.shape = old_shape; // Revert if rotation is invalid
    }
}


find_lowest_position :: proc(mem: ^GameMemory) -> int {
    original_y := mem.current_tet.position[1]; // Save the original y position
    for true {
        mem.current_tet.position[1] += 1; // Try moving down

        if !can_place_tetrimino(mem) {
            mem.current_tet.position[1] -= 1; // Revert the last move
            break;
        }
    }
    return mem.current_tet.position[1];
}

hard_slam :: proc(mem: ^GameMemory) {
    find_lowest_position(mem); // Move the Tetrimino to the lowest valid position
    place_tetrimino(mem);      // Lock the Tetrimino into the grid and handle row clearing
}

is_row_full :: proc(grid: [20][10]Cell, row: int) -> bool {
    for col in 0..<GRID_WIDTH {
        if !grid[row][col].filled {
            return false;
        }
    }
    return true;
}



clear_rows :: proc(mem: ^GameMemory) -> int {
    cleared := 0;

    for row := GRID_HEIGHT - 1; row >= 0; row -= 1 { // Start from the last row and move upward
        if is_row_full(mem.grid, row) {
            cleared += 1;

            // Shift rows above down
            for r := row; r > 0; r -= 1 {
                mem.grid[r] = mem.grid[r - 1];
            }

            // Clear the topmost row
            mem.grid[0] = [GRID_WIDTH]Cell{}; // Reset the top row to empty
        }
    }

    return cleared;
}


can_place_tetrimino :: proc(mem: ^GameMemory) -> bool {
    for row in 0..<len(mem.current_tet.shape) {
        for col in 0..<len(mem.current_tet.shape[row]) {
            if mem.current_tet.shape[row][col] == 1 {
                grid_x := mem.current_tet.position[0] + col;
                grid_y := mem.current_tet.position[1] + row;

                // Check boundaries
                if grid_x < 0 || grid_x >= GRID_WIDTH || grid_y >= GRID_HEIGHT {
                    return false;
                }

                // Check collision with existing grid
		cell := mem.grid[grid_y][grid_x]
                if grid_y >= 0 && cell.filled == true {
                    return false;
                }
            }
        }
    }
    return true;
}


place_tetrimino :: proc(mem: ^GameMemory) {
    for row in 0..<len(mem.current_tet.shape) {
        for col in 0..<len(mem.current_tet.shape[row]) {
            if mem.current_tet.shape[row][col] == 1 {
                grid_x := mem.current_tet.position[0] + col;
                grid_y := mem.current_tet.position[1] + row;

                mem.grid[grid_y][grid_x] = Cell {
		    filled = true,
		    color = mem.current_tet.color,
		} // Lock into grid
            }
        }
    }

    // Check for completed rows and clear them
    cleared := clear_rows(mem)
    mem.rows_cleared += cleared;
    mem.score += 100 * mem.rows_cleared
    next_level(mem)

    // Spawn new Tetrimino
    mem.current_tet = mem.next_tet;
    mem.current_tet.position.x = (GRID_WIDTH - len(mem.current_tet.shape[0])) / 2; // Center horizontally
    mem.current_tet.position.y = 0; // Start at the top
    mem.next_tet = rand.choice(tetriminos[:]);

    // Check if the new Tetrimino can be placed
    if !can_place_tetrimino(mem) {
        mem.game_over = true;
    }
}

next_level :: proc(mem: ^GameMemory) {
    mem.level =(mem.rows_cleared / 10) + 1

}


draw_grid :: proc(mem: ^GameMemory) {
    // Draw the game canvas
    rl.DrawRectangle(WINDOW_WIDTH / 2 - CANVAS_WIDTH / 2, 0, CANVAS_WIDTH, CANVAS_HEIGHT, TET_GREEN);

    // Draw the grid cells
    for row in 0..<GRID_HEIGHT {
        for col in 0..<GRID_WIDTH {
            cell := mem.grid[row][col];
            x := X_OFFSET + col * CELL_SIZE;
            y := Y_OFFSET + row * CELL_SIZE;

            if !cell.filled {
                // Draw tiny rectangle for empty cells
                rect_size := CELL_SIZE / 8;
                rect_x := x + (CELL_SIZE - rect_size) / 2;
                rect_y := y + (CELL_SIZE - rect_size) / 2;
                rl.DrawRectangle(i32(rect_x), i32(rect_y), i32(rect_size), i32(rect_size), PIECE_GREEN);
            } else {
                // Draw filled cell with its color
                rl.DrawRectangle(i32(x), i32(y), CELL_SIZE, CELL_SIZE, cell.color);
            }
        }
    }

    // Draw the current Tetrimino only if the game has started
    if !mem.game_over {
        for row in 0..<len(mem.current_tet.shape) {
            for col in 0..<len(mem.current_tet.shape[row]) {
                if mem.current_tet.shape[row][col] == 1 {
                    x := X_OFFSET + (mem.current_tet.position.x + col) * CELL_SIZE;
                    y := Y_OFFSET + (mem.current_tet.position.y + row) * CELL_SIZE;
                    rl.DrawRectangle(i32(x), i32(y), CELL_SIZE, CELL_SIZE, mem.current_tet.color);
                }
            }
        }
    }

    // Draw the "Press Enter to Start" text when the game is over
    if mem.game_over {
        text := fmt.ctprint("Press Enter To Start");
        text_width := rl.MeasureText(text, 20);
        rl.DrawText(text, WINDOW_WIDTH / 2 - text_width / 2, WINDOW_HEIGHT * .5, 20, PIECE_GREEN);
    }
}


draw_instructions :: proc() {
    rl.DrawText("    UP ARROW:  ROTATE", WINDOW_WIDTH * 0.75, 20, 20, TET_GREEN)
    rl.DrawText("DOWN ARROW:  SOFT DROP", WINDOW_WIDTH * 0.75, 40, 20, TET_GREEN)
    rl.DrawText("   SPACEBAR:  HARD DROP", WINDOW_WIDTH * 0.75, 60, 20, TET_GREEN)
    rl.DrawText("        ESC :  QUIT", WINDOW_WIDTH * 0.75, 80, 20, TET_GREEN)

}

draw_stats :: proc() {

    // TODO: Make these work with formatted C Strings after
    score_text := fmt.ctprintf("SCORE:                           %d", game_mem.score)
    cleared_text := fmt.ctprintf("ROWS HIT:                      %d", game_mem.rows_cleared)

    rl.DrawText(cleared_text, 40, 20, 20, TET_GREEN)
    rl.DrawText(score_text, 40, 40, 20, TET_GREEN)
    rl.DrawText("LEVEL:                           1", 40, 60, 20, TET_GREEN)
}

draw_tetrimino :: proc(tet: Tetrimino) {
    for row in 0..<len(tet.shape) {
	for col in 0..<len(tet.shape[row]) {
	    if tet.shape[row][col] == 1 {
		x := tet.position.x + col * CELL_SIZE
		y := tet.position.y + row * CELL_SIZE
		rl.DrawRectangle(i32(x), i32(y), CELL_SIZE, CELL_SIZE, tet.color)
	    }
	}
    }
}

draw_next_piece :: proc(mem: ^GameMemory) {

    if !game_mem.game_over {
	for row in 0..<len(mem.next_tet.shape) {
		for col in 0..<len(mem.next_tet.shape[row]) {
		    if mem.next_tet.shape[row][col] == 1 {
			x := WINDOW_WIDTH * 0.1 + col * CELL_SIZE
			y := WINDOW_HEIGHT * 0.5 + row * CELL_SIZE
			rl.DrawRectangle(i32(x), i32(y), CELL_SIZE, CELL_SIZE, mem.next_tet.color)
		    }
		}
	    }
    }
}

