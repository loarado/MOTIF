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
                var _old_width = grid_width;
                var _old_height = grid_height;
                grid_width++;
                grid_height++;
                // Initialize only the added row and column; preserve existing health.
                for (var _x = 0; _x < grid_width; _x++) {
                    hp_grid[_x][_old_height] = 1;
                }
                for (var _y = 0; _y < grid_height; _y++) {
                    hp_grid[_old_width][_y] = 1;
                }
            }
        }
    }
    // Pause combat until the player attaches one new square to the attack shape.
    else if (upgrade_type == "attack_add") {
        with (Player) {
            attack_upgrade_active = true;
            attack_upgrade_dragging = false;
            attack_upgrade_has_target = false;
            global.combat_active = true;
        }
    }
    // Shorten both missed-attack and landed-attack cooldowns.
    else if (upgrade_type == "faster_attack") {
        with (Player) {
            attack_miss_cooldown = max(4, attack_miss_cooldown - 2);
            attack_hit_cooldown = max(60, attack_hit_cooldown - 15);
            attack_cooldown = max(0, attack_cooldown - 30);
        }
    }
    
    // Destroy ALL treasure pedestals in the room so the player can only pick ONE!
    with (obj_treasure) {
        instance_destroy();
    }
}
