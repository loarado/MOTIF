// Safety check: if enemy_hp_grid wasn't initialized yet, create it now
if (!variable_instance_exists(id, "enemy_hp_grid") || is_array(enemy_hp_grid)) {
    enemy_grid_width = 3;
    enemy_grid_height = 3;
    cell_size = 32;
    enemy_hp_grid = ds_grid_create(enemy_grid_width, enemy_grid_height);
    ds_grid_clear(enemy_hp_grid, 1);
}

// Check if the highest value in the enemy grid is 0 or less (all blocks destroyed)
if (ds_grid_get_max(enemy_hp_grid, 0, 0, enemy_grid_width - 1, enemy_grid_height - 1) <= 0) {
    if (instance_exists(Player)) {
        global.combat_active = false;
        Player.is_dragging = false;
        global.target_enemy = noone;
    }
    ds_grid_destroy(enemy_hp_grid);
    instance_destroy();
    exit;
}

// Safety check: if enemy_hp_grid wasn't initialized yet, create it now
if (!variable_instance_exists(id, "enemy_hp_grid") || is_array(enemy_hp_grid)) {
    enemy_grid_width = 3;
    enemy_grid_height = 3;
    cell_size = 32;
    enemy_hp_grid = ds_grid_create(enemy_grid_width, enemy_grid_height);
    ds_grid_clear(enemy_hp_grid, 1);
}

// Check if the enemy is defeated
if (!ds_grid_value_exists(enemy_hp_grid, 0, 0, enemy_grid_width - 1, enemy_grid_height - 1, 1)) {
    if (instance_exists(Player)) {
        global.combat_active = false;
        Player.is_dragging = false;
        global.target_enemy = noone;
    }
    ds_grid_destroy(enemy_hp_grid);
    instance_destroy();
    exit;
}

// Real-Time Dodge Phase: Patterned Movement & Shooting
if (!global.combat_active) {
    // 1. Move in a smooth circle around the starting position
    move_angle = (move_angle + orbit_speed) mod 360;
    x = anchor_x + lengthdir_x(move_radius, move_angle);
    y = anchor_y + lengthdir_y(move_radius, move_angle);
    
    // 2. Shoot a 4-way rotating spiral pattern
    shoot_timer--;
    if (shoot_timer <= 0) {
        shoot_timer = 65; // Frames between shots
        
        for (var i = 0; i < 4; i++) {
            var _proj = instance_create_layer(x, y, layer, obj_projectile);
            _proj.move_dir = spiral_angle + (i * 90);
            _proj.move_spd = 3;
            _proj.damage_shape = attack_shape;
        }
        spiral_angle = (spiral_angle + 20) mod 360; // Rotate next volley
    }
}