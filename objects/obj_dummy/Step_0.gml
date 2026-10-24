// Ensure the grid exists
if (!variable_instance_exists(id, "enemy_hp_grid") || is_array(enemy_hp_grid)) {
    enemy_grid_width = 3;
    enemy_grid_height = 3;
    cell_size = 32;
    enemy_hp_grid = ds_grid_create(enemy_grid_width, enemy_grid_height);
    ds_grid_clear(enemy_hp_grid, 1);
}

// Die when health is depleted, but instantly respawn for more practice
if (ds_grid_get_max(enemy_hp_grid, 0, 0, enemy_grid_width - 1, enemy_grid_height - 1) <= 0) {
    if (instance_exists(Player)) {
        global.combat_active = false;
        Player.is_dragging = false;
        global.target_enemy = noone;
    }
    ds_grid_destroy(enemy_hp_grid);
    instance_create_layer(x, y, layer, obj_dummy); // Instantly respawn
    instance_destroy();
}