if (place_meeting(x, y, Player)) {
    
    // Option 1: Add +1 Armor Layer to all healthy cells (and heal broken ones)
    if (upgrade_type == "armor") {
        with (Player) {
            for (var _x = 0; _x < grid_width; _x++) {
                for (var _y = 0; _y < grid_height; _y++) {
                    if (hp_grid[_x][_y] <= 0) hp_grid[_x][_y] = 1; // Heal broken cell
                    else if (hp_grid[_x][_y] < 3) hp_grid[_x][_y] += 1; // Add armor (cap at 3)
                }
            }
        }
    }
    // Option 2: Expand Player Health Grid Size (+1 Row & Column, up to 5x5)
    else if (upgrade_type == "expand_grid") {
        with (Player) {
            if (grid_width < 5) {
                grid_width++;
                grid_height++;
            }
            // Fill new expanded grid directly on the Player
            for (var _x = 0; _x < grid_width; _x++) {
                for (var _y = 0; _y < grid_height; _y++) {
                    hp_grid[_x][_y] = 1; 
                }
            }
        }
    }
    // Option 3: Upgrade Attack Pattern to a 3-Block L-Shape
    else if (upgrade_type == "attack_L") {
        Player.my_attack_pattern = [[0, 0], [1, 0], [0, 1]];
    }
    // Option 4: Upgrade Attack Pattern to a 5-Block Cross
    else if (upgrade_type == "attack_cross") {
        Player.my_attack_pattern = [[0, 0], [1, 0], [-1, 0], [0, 1], [0, -1]];
    }
    
    // Destroy ALL treasure pedestals in the room so the player can only pick ONE!
    with (obj_treasure) {
        instance_destroy();
    }
}