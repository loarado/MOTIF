// 4x4 core plus two health tiles on each cardinal side (a 6x6 circle-like grid).
enemy_grid_width = 6;
enemy_grid_height = 6;
cell_size = 32;
enemy_hp_grid = ds_grid_create(enemy_grid_width, enemy_grid_height);
ds_grid_clear(enemy_hp_grid, 0);
for (var _x = 1; _x <= 4; _x++) {
    for (var _y = 1; _y <= 4; _y++) {
        ds_grid_set(enemy_hp_grid, _x, _y, 1);
    }
}
ds_grid_set(enemy_hp_grid, 2, 0, 1);
ds_grid_set(enemy_hp_grid, 3, 0, 1);
ds_grid_set(enemy_hp_grid, 2, 5, 1);
ds_grid_set(enemy_hp_grid, 3, 5, 1);
ds_grid_set(enemy_hp_grid, 0, 2, 1);
ds_grid_set(enemy_hp_grid, 0, 3, 1);
ds_grid_set(enemy_hp_grid, 5, 2, 1);
ds_grid_set(enemy_hp_grid, 5, 3, 1);

image_blend = c_fuchsia;
movement_mode = "orbit";
anchor_x = x;
anchor_y = y;
move_angle = 0;
move_radius = 80;
orbit_speed = 1.4;
phase_timer = irandom_range(180, 240);
move_speed = 2;
target_x = x;
target_y = y;

// The circle fires two rotating fans of projectiles and deals a five-cell diamond.
shoot_timer = 35;
spiral_angle = 0;
attack_shape = [[1, 0], [0, 1], [1, 1], [2, 1], [1, 2]];
