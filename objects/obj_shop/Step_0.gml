if (global.pause_menu_open) exit;
if (place_meeting(x, y, Player) && keyboard_check_pressed(ord("E"))) {
    // Example: Spend 10 coins to permanently increase starting armor
    if (global.total_coins >= 10) {
        global.total_coins -= 10;
        global.base_armor += 1;
        
        // Immediately apply the new armor to the player's current grid
        with (Player) {
            for (var _x = 0; _x < grid_width; _x++) {
                for (var _y = 0; _y < grid_height; _y++) {
                    hp_grid[_x][_y] = global.base_armor;
                }
            }
        }
    }
}
